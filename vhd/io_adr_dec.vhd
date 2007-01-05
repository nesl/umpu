--************************************************************************************************
-- Internal I/O registers decoder/multiplexer for the AVR core
-- Version 1.1
-- Designed by Ruslan Lepetenok
-- Modified 02.11.2002
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

use WORK.AVRuCPackage.all;

entity io_adr_dec is port (
  adr        : in  std_logic_vector(5 downto 0);
  iore       : in  std_logic;
  dbusin_int : out std_logic_vector(7 downto 0);
  dbusin_ext : in  std_logic_vector(7 downto 0);

  -- Registers from mmc.vhd
  mem_map_pointer_low_out  : in std_logic_vector(7 downto 0);
  mem_map_pointer_high_out : in std_logic_vector(7 downto 0);
  mem_prot_bottom_low_out  : in std_logic_vector(7 downto 0);
  mem_prot_bottom_high_out : in std_logic_vector(7 downto 0);
  mem_prot_top_low_out     : in std_logic_vector(7 downto 0);
  mem_prot_top_high_out    : in std_logic_vector(7 downto 0);
  mmc_status_reg_out       : in std_logic_vector(7 downto 0);
  ssph_out                 : in std_logic_vector(7 downto 0);
  sspl_out                 : in std_logic_vector(7 downto 0);

  -- registers from the domain tracker
  jmp_table_low_out  : in std_logic_vector(7 downto 0);
  jmp_table_high_out : in std_logic_vector(7 downto 0);
  dom_bnd_ctl_out    : in std_logic_vector(7 downto 0);
  dom_bnd_data_out   : in std_logic_vector(7 downto 0);

  spl_out   : in std_logic_vector(7 downto 0);
  sph_out   : in std_logic_vector(7 downto 0);
  sreg_out  : in std_logic_vector(7 downto 0);
  rampz_out : in std_logic_vector(7 downto 0));
end io_adr_dec;

architecture rtl of io_adr_dec is


begin

  dbusin_int <= spl_out                  when (adr = SPL_Address and iore = '1')                  else
                sph_out                  when (adr = SPH_Address and iore = '1')                  else
                sreg_out                 when (adr = SREG_Address and iore = '1')                 else
                rampz_out                when (adr = RAMPZ_Address and iore = '1')                else
                mem_map_pointer_low_out  when (adr = MEM_MAP_POINTER_LOW_Address and iore = '1')  else
                mem_map_pointer_high_out when (adr = MEM_MAP_POINTER_HIGH_Address and iore = '1') else
                mem_prot_bottom_low_out  when (adr = MEM_PROT_BOTTOM_LOW_Address and iore = '1')  else
                mem_prot_bottom_high_out when (adr = MEM_PROT_BOTTOM_HIGH_Address and iore = '1') else
                mem_prot_top_low_out     when (adr = MEM_PROT_TOP_LOW_Address and iore = '1')     else
                mem_prot_top_high_out    when (adr = MEM_PROT_TOP_HIGH_Address and iore = '1')    else
                mmc_status_reg_out       when (adr = MMC_STATUS_REG_Address and iore = '1')       else
                jmp_table_low_out        when (adr = DT_JUMP_TABLE_LOW_Address and iore = '1')    else
                jmp_table_high_out       when (adr = DT_JUMP_TABLE_HIGH_Address and iore = '1')   else
                dom_bnd_ctl_out          when (adr = DOM_BND_CTL_Address and iore = '1')          else
                dom_bnd_data_out         when (adr = DOM_BND_DATA_Address and iore = '1')         else
                sspl_out                 when (adr = SSP_LOW_Address and iore = '1')              else
                ssph_out                 when (adr = SSP_HIGH_Address and iore = '1')             else
                dbusin_ext;

end rtl;
