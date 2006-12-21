--************************************************************************************************
-- This is the memory map error calculator module. This checks the mem map to ensure
-- that the address been written is under the ownership of the current application.
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity mem_map_error_calc is

  port (
    -- status and prot addrs registers
    mmc_status_reg   : in  std_logic_vector(7 downto 0);
    mem_prot_bottom  : in  std_logic_vector(15 downto 0);
    mem_prot_top     : in  std_logic_vector(15 downto 0);
    -- data from ram after performing the mmc read
    mmc_ram_data     : in  std_logic_vector(7 downto 0);
    -- dom id of the currently executing domain
    dom_id           : in  std_logic_vector(2 downto 0);
    -- str addr from fetch decoder
    fet_dec_str_addr : in  std_logic_vector(15 downto 0);
    -- stack pointer from io_reg_file
    stack_pointer    : in  std_logic_vector(15 downto 0);
    -- stack bound from the ssp module
    ssp_stack_bound  : in  std_logic_vector(15 downto 0);
    -- error signal based on calculations
    mem_map_error    : out std_logic
    );

end mem_map_error_calc;

architecture Beh of mem_map_error_calc is

  component shifter
    port (
      shift_input  : in  std_logic_vector(15 downto 0);
      shift_amount : in  std_logic_vector(3 downto 0);
      shift_output : out std_logic_vector(15 downto 0)
      );
  end component;

  -- record size and log of block size from status reg
  signal record_size    : std_logic;
  signal log_block_size : std_logic_vector(3 downto 0);

  -- dom id when there are 4 or 2 records
  signal recs_4_dom_id   : std_logic_vector(2 downto 0);
  signal recs_2_dom_id   : std_logic_vector(2 downto 0);
  -- dom id after picking from above two based on record size
  signal ram_data_dom_id : std_logic_vector(2 downto 0);

  -- byte offset in the block number when there are 4 or 2 records
  signal recs_4_byte_offset : std_logic_vector(1 downto 0);
  signal recs_2_byte_offset : std_logic;

  -- errors on different things
  signal err_mem_prot_bottom : std_logic;
  signal err_mem_prot_top    : std_logic;
  signal err_dom_id          : std_logic;
  signal err_stack_bound     : std_logic;

  -- checking for writes on stack
  signal stack_write : std_logic;

  -- the offset from mem_prot
  signal mem_prot_offset : std_logic_vector(15 downto 0);
  -- the block number calculated from offset of mem_prot
  signal block_number    : std_logic_vector(15 downto 0);

  -- mismatch bits for checking the dom id
  signal bit_0_mismatch : std_logic;
  signal bit_1_mismatch : std_logic;
  signal bit_2_mismatch : std_logic;

begin
  -- mem_map_error occurs
  -- if the write is to stack and outside the stack bound
  -- or outside the protected memory
  -- or there is a error in ownership information
  mem_map_error <= (stack_write and err_stack_bound) and
                   (err_mem_prot_top or err_mem_prot_bottom or err_dom_id);

  -- Check for stack write
  stack_write <= '1' when fet_dec_str_addr > stack_pointer
                 else '0';
  -- Check for stack writes outside the stack bound
  err_stack_bound <= '1' when fet_dec_str_addr > ssp_stack_bound
                     else '0';

  -- prot bottom and top errors
  err_mem_prot_bottom <= '1' when fet_dec_str_addr < mem_prot_bottom else '0';
  err_mem_prot_top    <= '1' when fet_dec_str_addr >= mem_prot_top   else '0';

  -- receive the record size and log of block size
  record_size                <= mmc_status_reg(1);
  log_block_size(3)          <= '0';    -- need to keep four bits for the shifter
  log_block_size(2 downto 0) <= mmc_status_reg(7 downto 5);

  -- offset is just the str addr minus the bottom
  mem_prot_offset <= fet_dec_str_addr - mem_prot_bottom;

  -- shifting the offset to calculate the block number
  SHIFT_ADDR : component shifter port map(
    shift_input  => mem_prot_offset,
    shift_amount => log_block_size,
    shift_output => block_number
    );

  -- receiving the byte offset in the block number
  recs_4_byte_offset <= block_number(1 downto 0);
  recs_2_byte_offset <= block_number(0);

  -- mux for the dom id if we have 4 records
  recs_4_dom_id(0)          <= mmc_ram_data(0) when recs_4_byte_offset = "00" else
                      mmc_ram_data(2)          when recs_4_byte_offset = "01" else
                      mmc_ram_data(4)          when recs_4_byte_offset = "10" else
                      mmc_ram_data(6)          when recs_4_byte_offset = "11";
  -- the other bits are just zeros
  recs_4_dom_id(2 downto 1) <= "00";

  -- mux for dom id if we have 2 records
  recs_2_dom_id <= mmc_ram_data(2 downto 0) when recs_2_byte_offset = '0' else
                   mmc_ram_data(6 downto 4) when recs_2_byte_offset = '1';

  -- mux between the two dom ids based on record size
  ram_data_dom_id <= recs_2_dom_id when record_size = '0' else
                     recs_4_dom_id when record_size = '1';

  -- calculate if we have an error based on mismatch and record size
  err_dom_id <= bit_0_mismatch                                       when record_size = '1' else
                (bit_0_mismatch or bit_1_mismatch or bit_2_mismatch) when record_size = '0';

  -- calculating the mismatch of the bits from the ram_data_dom_id
  bit_0_mismatch <= '0' when (ram_data_dom_id(0) = dom_id(0)) else '1';
  bit_1_mismatch <= '0' when (ram_data_dom_id(1) = dom_id(1)) else '1';
  bit_2_mismatch <= '0' when (ram_data_dom_id(2) = dom_id(2)) else '1';


end Beh;
