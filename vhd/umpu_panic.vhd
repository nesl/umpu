library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity umpu_panic is
  port(
    -- General signals
    clock  : in std_logic;
    ireset : in std_logic;

    mmc_status_reg : in std_logic_vector(7 downto 0);

    mmc_error          : in std_logic;
    ssp_stack_overflow : in std_logic;
    dt_error           : in std_logic;

    -- Interrupt port
    umpu_irq    : out std_logic;
    umpu_irqack : in  std_logic
    );
end umpu_panic;

architecture Beh of umpu_panic is

  signal umpu_en  : std_logic;
  signal panic_stage1 : std_logic;
  signal panic_stage2 : std_logic;
  signal umpu_panic : std_logic;
  
  signal sg_umpu_irq : std_logic;

begin

  umpu_en <= mmc_status_reg(0);

  PANIC_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      panic_stage1 <= '0';
    elsif (clock = '1' and clock'event) then
      panic_stage1 <= (mmc_error or ssp_stack_overflow or dt_error) and umpu_en;
    end if;
  end process;

  SG_PANIC_LATCH_LATCH : process(ireset, panic_stage1)
  begin
    if ireset = '0' then
      panic_stage2 <= '0';
    elsif (panic_stage1 = '1' and panic_stage1'event) then
      panic_stage2 <= '1';
    end if;
  end process;

  umpu_panic <= (mmc_error or ssp_stack_overflow or dt_error) or panic_stage2;

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
