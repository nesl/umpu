--************************************************************************************************
-- This is the domain tracker. This calculates the new domain from a
-- call instruction, and signals the mmc when this new domain is a valid update.
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity domain_tracker is
port (
  -- General signals
  ireset : in std_logic;
  clock : in std_logic;

  -- Bus signals
  adr : in std_logic_vector(5 downto 0);
  reg_bus : in std_logic_vector(7 downto 0);
  iowe : in std_logic;

  -- pc from pm_fetch_decoder
  fet_dec_pc : in std_logic_vector(15 downto 0);
  -- indication of call insrt from pm_fetch_decoder
  fet_dec_call_instr : in std_logic;

  -- send the local registers to io_adr_dec so SW can read
  jmp_table_high_out : out std_logic_vector(7 downto 0);
  jmp_table_low_out : out std_logic_vector(7 downto 0);

  -- calculated domain id to mmc
  mmc_new_dom_id : out std_logic_vector(2 downto 0);
  -- signal to update domain id to mmc
  mmc_update_dom_id : out std_logic;
  --Trusted domain signal from MMC
  mmc_trusted_domain : in std_logic

 );
  
end domain_tracker;

architecture Beh of domain_tracker is

  -- Local register maintaining the jump table
  signal dt_jmp_table : std_logic_vector(15 downto 0);

  -- to calculate new domain id
  signal difference : std_logic_vector(15 downto 0);
  signal is_positive : std_logic;
  signal not_bit_ten : std_logic;

begin
  -- Subtract jump table from pc
  difference <= fet_dec_pc - dt_jmp_table;
  -- is the result positive
  is_positive <= '1' when dt_jmp_table <= fet_dec_pc
                 else '0';
  -- is bit ten positive
  not_bit_ten <= not difference(10);

  -- Decide if we have a new domain id
  mmc_new_dom_id <= difference(9 downto 7);
  mmc_update_dom_id <= is_positive and fet_dec_call_instr and not_bit_ten;

  --Register high byte update process
  DT_JUMP_TABLE_HIGH_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dt_jmp_table(15 downto 8) <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = DT_JUMP_TABLE_HIGH_Address and iowe = '1' and mmc_trusted_domain = '1') then
         dt_jmp_table(15 downto 8) <= reg_bus;
      end if;
    end if;
  end process;

  --Register low byte update process
  DT_JUMP_TABLE_LOW_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dt_jmp_table(7 downto 0) <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = DT_JUMP_TABLE_LOW_Address and iowe = '1' and mmc_trusted_domain = '1') then
         dt_jmp_table(7 downto 0) <= reg_bus;
      end if;
    end if;
  end process;

  -- expose the internal registers to io_adr_dec
  jmp_table_low_out <= dt_jmp_table(7 downto 0);
  jmp_table_high_out <= dt_jmp_table(15 downto 8);
end Beh;
