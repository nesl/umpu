--************************************************************************************************
-- This is the memory map checker module. This checks the mem map to ensure
-- that the address been written is under the ownership of the current application.
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity mem_map_addr_calc
is port (
  -- pointer, prot addrs, status registers
  mem_map_pointer : in  std_logic_vector(15 downto 0);
  mem_prot_bottom : in  std_logic_vector(15 downto 0);
  mem_prot_top    : in  std_logic_vector(15 downto 0);
  mmc_status_reg  : in  std_logic_vector(7 downto 0);
  -- addr from fet_dec and mmc
  fet_dec_str_addr    : in  std_logic_vector(15 downto 0);
  mmc_rd_addr     : out std_logic_vector(15 downto 0)
  );

end mem_map_addr_calc;

architecture Beh of mem_map_addr_calc is

  component shifter
    is port (
      shift_input  : in  std_logic_vector(15 downto 0);
      shift_amount : in  std_logic_vector(3 downto 0);
      shift_output : out std_logic_vector(15 downto 0)
      );
  end component;

  -- shift amount based on log of block size and record size
  signal shift_amount     : std_logic_vector(3 downto 0);
  -- offset from the beginning of the prot
  signal mem_prot_offset  : std_logic_vector(15 downto 0);
  -- offset from the mem map
  signal mem_map_offset   : std_logic_vector(15 downto 0);

  -- log of block size obtained from the status reg
  signal log_block_size   : std_logic_vector(3 downto 0);
  -- record size obtained from the status reg
  signal record_size    : std_logic;

  -- shift amount due to the record size
  signal rec_shift_amount : std_logic_vector(3 downto 0);

  
begin

  -- receive record_size and log_block_size
  record_size                <= mmc_status_reg(1);
  log_block_size(3)          <= '0';
  log_block_size(2 downto 0) <= mmc_status_reg(7 downto 5);

  -- Calculate the total shift amount
  shift_amount     <= log_block_size + rec_shift_amount;
  -- Shift amount due to record size
  rec_shift_amount <= "0010" when record_size = '1'
                      else "0001";

  -- calculate the offset from the mem prot
  mem_prot_offset <= fet_dec_str_addr - mem_prot_bottom;
  -- calculate the mmc read addr based on the pointer and offset from mem map
  mmc_rd_addr <= mem_map_pointer + mem_map_offset;

  -- shift offset from the prot by the amount based on log of block size and
  -- record size to obtain the offset from the mem map
  SHIFT_MEM_ADDR : component shifter port map(
    shift_input  => mem_prot_offset,
    shift_amount => shift_amount,
    shift_output => mem_map_offset
    );

end Beh;
