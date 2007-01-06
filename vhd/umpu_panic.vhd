library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity umpu_panic is
  port(
    -- Debug signals
    dbg_umpu_panic : out std_logic;       -- panic signal

    -- General signals
    clock  : in std_logic;
    ireset : in std_logic;

    -- MMC status register
    mmc_status_reg : in std_logic_vector(7 downto 0);

    -- Errors detected by mmc, ssp, dt
    mmc_error          : in std_logic;
    ssp_stack_overflow : in std_logic;
    dt_error           : in std_logic;

    -- Interrupt port
    umpu_irq    : out std_logic;
    umpu_irqack : in  std_logic
    );
end umpu_panic;

architecture Beh of umpu_panic is

  -- the protection enable bit in mmc_status_reg
  signal umpu_en  : std_logic;
  -- The two stages of panic, 2 is set combinationally and 1 is set due to the
  -- clock'event
  signal panic_stage1 : std_logic;
  signal panic_stage2 : std_logic;
  -- The actual panic signal for umpu
  signal umpu_panic : std_logic;

  -- Internal signal for umpu_irq
  signal sg_umpu_irq : std_logic;

  -- Local register used by the software to clear the panic
  signal umpu_panic_reg : std_logic_vector(7 downto 0);

begin

  dbg_umpu_panic <= umpu_panic;
  
  -- Extracting the protection bit from mmc_status_reg
  umpu_en <= mmc_status_reg(0);

  -- Two stages of receiving panic
  -- In the first stage, the panic is set on a clock'event
  PANIC_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      panic_stage1 <= '0';
    elsif (clock = '1' and clock'event) then
      panic_stage1 <= (mmc_error or ssp_stack_overflow or dt_error) and umpu_en;
    end if;
  end process;
  -- In the second stage, the panic is set when the panic from first stage is set
  SG_PANIC_LATCH_LATCH : process(ireset, panic_stage1)
  begin
    if ireset = '0' then
      panic_stage2 <= '0';
    elsif (panic_stage1 = '1' and panic_stage1'event) then
      panic_stage2 <= '1';
    end if;
  end process;
  -- The actual panic signal is ored between the latched panic signal and the errors
  umpu_panic <= ((mmc_error or ssp_stack_overflow or dt_error) and umpu_en) or panic_stage2;

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

end Beh;
