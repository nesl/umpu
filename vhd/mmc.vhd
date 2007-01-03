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

entity mmc is

  port (
    -- General Signals
    ireset : in std_logic;
    clock  : in std_logic;

    -- MMC-Bus arbiter interface
    mmc_addr        : out std_logic_vector(15 downto 0);  -- R/W addr
    mmc_wr_en       : out std_logic;                      -- Write enable
    mmc_rd_en       : out std_logic;                      -- Read enable
    mmc_dbusout     : out std_logic_vector(7 downto 0);
    mmc_read_cycle  : out std_logic;
    mmc_write_cycle : out std_logic;

    -- MMC-pm_fetch_decoder interface
    fet_dec_pc_stop    : out std_logic;  -- Stop increment of pc
    fet_dec_nop_insert : out std_logic;  -- Insert nop in the processor
    fet_dec_str_addr   : in  std_logic_vector(15 downto 0);  -- str addr
    fet_dec_run_mmc    : in  std_logic;
    fet_dec_data       : in  std_logic_vector(7 downto 0);

    -- MMC-io_adr_dec interface to allow local registers to be read in SW
    mem_map_pointer_low_out  : out std_logic_vector(7 downto 0);
    mem_map_pointer_high_out : out std_logic_vector(7 downto 0);
    mem_prot_bottom_low_out  : out std_logic_vector(7 downto 0);
    mem_prot_bottom_high_out : out std_logic_vector(7 downto 0);
    mem_prot_top_low_out     : out std_logic_vector(7 downto 0);
    mem_prot_top_high_out    : out std_logic_vector(7 downto 0);
    mmc_status_reg_out       : out std_logic_vector(7 downto 0);

    -- MMC-io_reg_file interface to get the stack pointer
    stack_pointer_low  : in std_logic_vector(7 downto 0);
    stack_pointer_high : in std_logic_vector(7 downto 0);

    -- MMC-domain_tracker interface to update the domain id
    dt_new_dom_id     : in  std_logic_vector(2 downto 0);
    dt_update_dom_id  : in  std_logic;
    dt_trusted_domain : out std_logic;

    -- MMC-avr_core interface to allow local registers to be written in SW and
    -- receive the data when performing a ram read
    adr     : in std_logic_vector(5 downto 0);
    reg_bus : in std_logic_vector(7 downto 0);
    ram_bus : in std_logic_vector(7 downto 0);
    iowe    : in std_logic;

    -- MMC-ssp interface to update the dom id on a ret and receive the stack bound
    ssp_new_dom_id    : in std_logic_vector(2 downto 0);
    ssp_update_dom_id : in std_logic;
    ssp_stack_bound   : in std_logic_vector(15 downto 0);

    -- Debug signals
    dbg_mmc_panic : out std_logic       -- panic signal

    );

end mmc;

architecture Beh of mmc is

  component mem_map_addr_calc
    is port (
      -- pointer, prot addrs and status registers
      mem_map_pointer  : in  std_logic_vector(15 downto 0);
      mem_prot_bottom  : in  std_logic_vector(15 downto 0);
      mem_prot_top     : in  std_logic_vector(15 downto 0);
      mmc_status_reg   : in  std_logic_vector(7 downto 0);
      -- store addr from fet_dec and mmc
      fet_dec_str_addr : in  std_logic_vector(15 downto 0);
      mmc_rd_addr      : out std_logic_vector(15 downto 0)
      );
  end component;

  component mem_map_error_calc
    is port(
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
  end component;

  -- Local software registers maintained by this module
  signal mem_map_pointer : std_logic_vector(15 downto 0);
  signal mem_prot_bottom : std_logic_vector(15 downto 0);
  signal mem_prot_top    : std_logic_vector(15 downto 0);
  signal mmc_status_reg  : std_logic_vector(7 downto 0);

  -- panic signal
  signal mmc_panic         : std_logic;
  -- mem_map_error signal
  signal mem_map_error     : std_logic;
  -- check_cycle signal
  signal check_cycle       : std_logic;
  -- Domain id
  signal dom_id            : std_logic_vector(2 downto 0);
  -- Indicates if processor is executing in trusted domain
  signal in_trusted_domain : std_logic;

  -- mmc read cycle
  signal sg_mmc_read_cycle : std_logic;
  -- mmc read address
  signal mmc_rd_addr       : std_logic_vector(15 downto 0);
  -- mmc ram data
  signal mmc_ram_data      : std_logic_vector(7 downto 0);

  -- stack pointer from io_reg_file
  signal stack_pointer : std_logic_vector(15 downto 0);

  -- internal signals to identify panic
  signal sg_panic_int   : std_logic;
  signal sg_panic_latch : std_logic;

begin
  -- the debug panic signal is exposed to the uppermost entity
  dbg_mmc_panic <= mmc_panic;

  -- setting the output registers, these registers are sent to io_adr_dec so
  -- that they can be read out in software
  mem_map_pointer_low_out  <= mem_map_pointer(7 downto 0);
  mem_map_pointer_high_out <= mem_map_pointer(15 downto 8);
  mem_prot_bottom_low_out  <= mem_prot_bottom(7 downto 0);
  mem_prot_bottom_high_out <= mem_prot_bottom(15 downto 8);
  mem_prot_top_low_out     <= mem_prot_top(7 downto 0);
  mem_prot_top_high_out    <= mem_prot_top(15 downto 8);
  mmc_status_reg_out       <= mmc_status_reg;

  -- receive the stack pointer from io_reg_file
  -- The stack pointer is used to check when a store instruction is occuring on
  -- the stack and if it is, no mmc check is required on it, the only check
  -- that needs to be performed is if the store in inside the stack bound
  stack_pointer(15 downto 8) <= stack_pointer_high;
  stack_pointer(7 downto 0)  <= stack_pointer_low;

  -- send the in_trusted_domain signal to domain_tracker
  dt_trusted_domain <= in_trusted_domain;

  -- calculate mmc read addr
  MMC_ADDR_CALC : component mem_map_addr_calc port map(
    mem_map_pointer  => mem_map_pointer,
    mem_prot_bottom  => mem_prot_bottom,
    mem_prot_top     => mem_prot_top,
    mmc_status_reg   => mmc_status_reg,
    fet_dec_str_addr => fet_dec_str_addr,
    mmc_rd_addr      => mmc_rd_addr
    );


  -- mmc read cycle latch
  -- This latch is set whenever the processor is starting to execute a store
  -- instruction and the mmc is enabled, i.e. we are not operating in the
  -- trusted domain
  MMC_READ_CYCLE_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      sg_mmc_read_cycle <= '0';
    elsif (clock = '1' and clock'event) then
      sg_mmc_read_cycle <= fet_dec_run_mmc and not in_trusted_domain;
    end if;
  end process;
  -- setting the output of the internal signal
  mmc_read_cycle        <= sg_mmc_read_cycle;

  -- check cycle latch
  -- check cycle comes after read cycle, here the check is performed to ensure
  -- that the specific store address can be written to and if so, the write is
  -- performed.
  -- The latch is set in the clock cycle after read cycle is set and if the mmc
  -- is enabled i.e. we are not operating in the trusted domain
  CHECK_CYCLE_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      check_cycle <= '0';
    elsif (clock = '1' and clock'event) then
      check_cycle <= sg_mmc_read_cycle;
    end if;
  end process;
  -- setting the output to the internal signal
  -- The check cycle is also the cycle in which write is performed
  mmc_write_cycle <= check_cycle;

  -- Latch the data for str instr from pm_fetch_decoder
  -- This is the data that the processor wanted to write to the store address.
  -- Presently we have not figured out how to make the processor retain this
  -- data so we are latching the data for it. This can be a source of optimization
  MMC_DBUSOUT_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      mmc_dbusout   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if fet_dec_run_mmc = '1' then
        mmc_dbusout <= fet_dec_data;
      end if;
    end if;
  end process;

  -- setting mmc write enable
  -- Sending the signal to the bus arbiter to perform the write. This signal is
  -- set during the check cycle only if there was no error in verifying that
  -- the current domain can write to the store address
  mmc_wr_en <= check_cycle and not mem_map_error;

  -- setting the mmc read enable
  -- During the read cycle, the mmc will read the ownership information for the
  -- store address pertaining to the current domain
  mmc_rd_en <= sg_mmc_read_cycle;

  -- mux to set the mmc_addr on check_cycle
  -- This mux selects the correct address to be sent to the bus arbiter.
  -- If this is the read cycle, then the address is set to the calculated read
  -- address, else it is set to the store address from the processor
  mmc_addr <= mmc_rd_addr when sg_mmc_read_cycle = '1'
              else fet_dec_str_addr;


  -- Calculates any errors based on domain ids and the addr of str instr
  MMC_ERROR_CALC : component mem_map_error_calc port map(
    mmc_ram_data     => mmc_ram_data,
    dom_id           => dom_id,
    mmc_status_reg   => mmc_status_reg,
    mem_prot_bottom  => mem_prot_bottom,
    mem_prot_top     => mem_prot_top,
    fet_dec_str_addr => fet_dec_str_addr,
    stack_pointer    => stack_pointer,
    ssp_stack_bound  => ssp_stack_bound,
    mem_map_error    => mem_map_error
    );


  -- sg_panic_int latch
  SG_PANIC_INT_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      sg_panic_int <= '0';
    elsif (clock = '1' and clock'event) then
      sg_panic_int <= mem_map_error and check_cycle;
    end if;
  end process;

  SG_PANIC_LATCH_LATCH : process(ireset, sg_panic_int)
  begin
    if ireset = '0' then
      sg_panic_latch <= '0';
    elsif (sg_panic_int = '1' and sg_panic_int'event) then
      sg_panic_latch <= '1';
    end if;
  end process;

  mmc_panic <= (mem_map_error and check_cycle) or sg_panic_latch;

  fet_dec_pc_stop <= sg_mmc_read_cycle;

  -- fet_dec_nop_insert latch
  -- This signal generates a nop in the processor.
  -- The signal is generated during the read cycle of the mmc and during the
  -- panic period of mmc only if the mmc is enabled, i.e. we are not operating
  -- in the trusted domain
  FET_DEC_NOP_INSERT_DFF : process(ireset, clock)
  begin
    if ireset = '0' then
      fet_dec_nop_insert <= '0';
    elsif (clock = '1' and clock'event) then
      fet_dec_nop_insert <= sg_mmc_read_cycle or mmc_panic;
    end if;
  end process;

  -- mmc_ram_data latch
  -- This latches the data read from the ram during the read cycle
  GET_RAM_DATA : process(ireset, clock)
  begin
    if ireset = '0' then
      mmc_ram_data   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if sg_mmc_read_cycle = '1' then
        mmc_ram_data <= ram_bus;
      end if;
    end if;
  end process;

  -- update the dom_id when set by the domain_tracker or the ssp module
  -- This will update the domain id of the currently running domain if the
  -- domain id or the ssp module indicate that a cross domain call or return
  -- respectively has taken place
  UPDATE_DOM_ID : process(ireset, clock)
  begin
    if (ireset = '0') then
      dom_id   <= "111";
    elsif (clock'event and clock = '1') then
      if (dt_update_dom_id = '1') then
        dom_id <= dt_new_dom_id;
      elsif (ssp_update_dom_id = '1') then
        dom_id <= ssp_new_dom_id;
      end if;
    end if;
  end process;

  -- will be '1' only when dom_id = "111" i.e. trusted domain
  in_trusted_domain <= dom_id(0) and dom_id(1) and dom_id(2);

  -- mmc_status_reg
  -- |LOG_BLK_SIZE(2:0)|DOMAIN_ID(2:0)|REC_SIZE|UNUSED|
  -- REC_SIZE = 1 => 4 records per byte
  -- REC_SIZE = 0 => 2 records per byte
  -- The Domain_Id cannot be written to and can only read
  -- Writing to the unused bit will have no effect and can be used for expansion
  STATUS_REG_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      -- Special init value to set dom id to 111 on processor startup
      mmc_status_reg(7 downto 5)   <= "000";
      mmc_status_reg(1 downto 0)   <= "00";
    elsif (clock = '1' and clock'event) then
      if (adr = MMC_STATUS_REG_Address and iowe = '1' and in_trusted_domain = '1') then
        mmc_status_reg(7 downto 5) <= reg_bus(7 downto 5);
        mmc_status_reg(1 downto 0) <= reg_bus(1 downto 0);
      end if;
    end if;
  end process;

  -- Expose the current domain id to the software through the mmc status register
  mmc_status_reg(4 downto 2) <= dom_id;

  -- THE FOLLOWING ARE SIMPLE WRITES TO THE REGISTERS MAINTAINED BY THIS MODULE

  -- mem_map_pointer register
  MM_POINTER_HIGH_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_map_pointer(15 downto 8)   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_MAP_POINTER_HIGH_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_map_pointer(15 downto 8) <= reg_bus;
      end if;
    end if;
  end process;
  MM_POINTER_LOW_DFF  : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_map_pointer(7 downto 0)    <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_MAP_POINTER_LOW_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_map_pointer(7 downto 0)  <= reg_bus;
      end if;
    end if;
  end process;

  -- mem_prot_bottom register
  MM_BOTTOM_HIGH_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_prot_bottom(15 downto 8)   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_PROT_BOTTOM_HIGH_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_prot_bottom(15 downto 8) <= reg_bus;
      end if;
    end if;
  end process;
  MM_BOTTOM_LOW_DFF  : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_prot_bottom(7 downto 0)    <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_PROT_BOTTOM_LOW_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_prot_bottom(7 downto 0)  <= reg_bus;
      end if;
    end if;
  end process;

  -- mem_prot_top register
  MM_TOP_HIGH_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_prot_top(15 downto 8)   <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_PROT_TOP_HIGH_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_prot_top(15 downto 8) <= reg_bus;
      end if;
    end if;
  end process;
  MM_TOP_LOW_DFF  : process(clock, ireset)
  begin
    if (ireset = '0') then
      mem_prot_top(7 downto 0)    <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = MEM_PROT_TOP_LOW_Address and iowe = '1' and in_trusted_domain = '1') then
        mem_prot_top(7 downto 0)  <= reg_bus;
      end if;
    end if;
  end process;

end Beh;

