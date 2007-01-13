library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity umpu_panic is
  port(
    -- Debug signals
    dbg_umpu_panic : out std_logic;     -- panic signal

    -- General signals
    clock  : in std_logic;
    ireset : in std_logic;

    -- MMC status register
    mmc_status_reg : in std_logic_vector(7 downto 0);

    -- Errors detected by mmc, ssp, dt
    mmc_error          : in std_logic;
    ssp_stack_overflow : in std_logic;
    dt_error           : in std_logic;

    -- signals to update the domain id at the mmc module when a panic occurs
    up_update_dom_id : out std_logic;
    up_new_dom_id    : out std_logic_vector(2 downto 0);

    -- Interrupt port
    umpu_irq    : out std_logic;
    umpu_irqack : in  std_logic;

    -- output the local registers
    umpu_panic_reg_out : out std_logic_vector(7 downto 0);

    -- umpu_panic-avr_core interface to allow local registers to be written in SW
    adr     : in std_logic_vector(5 downto 0);
    reg_bus : in std_logic_vector(7 downto 0);
    iowe    : in std_logic
    );
end umpu_panic;

architecture Beh of umpu_panic is

  -- different regions of the mmc_status_reg
  signal umpu_en           : std_logic;
  signal dom_id            : std_logic_vector(2 downto 0);
  signal in_trusted_domain : std_logic;

  -- The two stages of panic, 2 is set combinationally and 1 is set due to the
  -- clock'event
  signal panic_stage1 : std_logic;
  signal panic_stage2 : std_logic;
  -- The actual panic signal for umpu
  signal umpu_panic   : std_logic;

  -- Internal signal for umpu_irq
  signal sg_umpu_irq : std_logic;

  -- Local register used by the software to clear the panic
  signal umpu_panic_reg : std_logic_vector(7 downto 0);

begin
  -- Setting the dbg panic signal to be observable at the top most entity
  dbg_umpu_panic <= umpu_panic;

  -- Extracting the protection bit from mmc_status_reg
  umpu_en           <= mmc_status_reg(0);
  -- Extracting the domain id from the mmc_status_reg
  dom_id            <= mmc_status_reg(4 downto 2);
  -- Checking when in trusted domain
  in_trusted_domain <= dom_id(2) and dom_id(1) and dom_id(0);

  -- Two stages of receiving panic
  -- In the first stage, the panic is set on a clock'event
  PANIC_LATCH          : process(ireset, clock)
  begin
    if ireset = '0' then
      panic_stage1 <= '0';
    elsif (clock = '1' and clock'event) then
      panic_stage1 <= (mmc_error or ssp_stack_overflow or dt_error) and umpu_en;
    end if;
  end process;

  panic_stage2 <= umpu_panic_reg(0);
  
  -- The actual panic signal is ored between the latched panic signal and the errors
  umpu_panic       <= ((mmc_error or ssp_stack_overflow or dt_error) and umpu_en) or panic_stage2;

  -- Setting the signals for updating the dom_id on a panic
  -- Need to update whenever a panic occurs
  up_update_dom_id <= umpu_panic;
  -- Always setting the dom_id to '111' on a panic
  up_new_dom_id    <= "111";

  -- Process to set the interrupt and then receive the ack from the interrupt
  -- We are using the interrupt for the ADC to send the interrupt to the processor
  irq_out : process(clock, ireset)
  begin
    if ireset = '0' then
      sg_umpu_irq <= '0';
    elsif clock = '1' and clock'event then
      sg_umpu_irq <= (not sg_umpu_irq and umpu_panic) or(sg_umpu_irq and not umpu_irqack);
    end if;
  end process;
  umpu_irq        <= sg_umpu_irq;

  -- umpu_panic_reg
  -- This register only contains valid information when a panic happens.
  -- Reading from it when there is no panic will give outdated or wrong information
  -- |UNUSED|DOM_ID(2:0)|PANIC_CODE (2:0)|CLEAR_PANIC BIT|
  -- DOM_ID => dom_id of the domain that triggered the panic
  -- PANIC_CODE = 111 => No error code 
  -- PANIC_CODE = 001 => Panic from mmc
  -- PANIC_CODE = 010 => Panic from DT 
  -- PANIC_CODE = 011 => Panic from safe_stack
  -- CLEAR_PANIC => Written to in software. Clears the panic to let execution
  -- continue after a panic. 
  -- The only bit that can be written to by software is the CLEAR_PANIC bit.
  -- The other regions can only be read
  --
  -- The panic from mmc is generated if the store instruction is trying to
  -- write to a bad area of the memory, The panic from DT is generated if the
  -- call intruction is trying to jump to a bad address in the memory. The
  -- panic in safe_stack is generated if the normal stack overflows. This can
  -- occur in the trusted domain and in the untrusted domains. The other errors
  -- can only occur in the untrusted domains. Return will never generate an
  -- error. A bad return will always succeed causing the current function to
  -- return early 

  -- This process sets the panic code based on the kind of error causing the panic
  SET_PANIC_CODE : process(ireset,mmc_error,ssp_stack_overflow,dt_error)
  begin
    if (ireset = '0') then 
      umpu_panic_reg(3 downto 1) <= (others => '1');
    elsif (mmc_error = '1') then
      umpu_panic_reg(3 downto 1) <= "001";
    elsif (dt_error = '1') then
      umpu_panic_reg(3 downto 1) <= "010";
    elsif (ssp_stack_overflow = '1') then
      umpu_panic_reg(3 downto 1) <= "011";
    end if;
  end process;

  -- This process sets the dom_id of the domain that caused the panic
  SET_PANIC_DOM_ID : process(ireset, panic_stage2)
  begin
    if (ireset = '0') then
      umpu_panic_reg(6 downto 4) <= (others => '1');
    elsif (panic_stage2 = '1') then
      umpu_panic_reg(6 downto 4) <= dom_id;
    end if;
  end process;

  SET_PANIC_BIT : process(ireset, clock)
  begin
    if (ireset = '0') then
      umpu_panic_reg(0)   <= '0';
    elsif (clock = '1' and clock'event) then
      if (adr = UMPU_PANIC_REG_Address and iowe = '1' and in_trusted_domain = '1' and reg_bus(0) = '0') then
        umpu_panic_reg(0) <= '0';
      elsif (umpu_panic = '1') then
        umpu_panic_reg(0) <= '1';
      end if;
    end if;
  end process;

  UMPU_PANIC_REG_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      umpu_panic_reg(7)   <= '0';
    elsif (clock = '1' and clock'event) then
      if (adr = UMPU_PANIC_REG_Address and iowe = '1' and in_trusted_domain = '1') then
        umpu_panic_reg(7) <= reg_bus(7);
      end if;
    end if;
  end process;
  umpu_panic_reg_out      <= umpu_panic_reg;

end Beh;
