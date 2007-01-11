--************************************************************************************************
-- This is the safe stack module. This implements all the functionality for the
-- safe stack. It stores and retrives appropriate information on cross domain
-- call and returns. It identifies when a particular return is a cross domain
-- return. It also checks for stack overflow
--************************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity safe_stack is

  port (
    -- General signals
    ireset : in std_logic;
    clock  : in std_logic;

    -- ssp-umpu_panic interface
    ssp_stack_overflow : out std_logic;

    -- Bus signals
    adr     : in std_logic_vector(5 downto 0);
    reg_bus : in std_logic_vector(7 downto 0);
    ram_bus : in std_logic_vector(7 downto 0);
    iowe    : in std_logic;

    -- Output the safe stack pointer out to io_adr_dec so it is visible to the
    -- software
    ssph_out : out std_logic_vector(7 downto 0);
    sspl_out : out std_logic_vector(7 downto 0);

    -- Status register from the MMC
    mmc_status_reg : in std_logic_vector(7 downto 0);

    -- signals for the ram_busArbiter
    ss_addr        : out std_logic_vector(15 downto 0);
    ss_addr_sel    : out std_logic;
    ss_dbusout     : out std_logic_vector(7 downto 0);
    ss_dbusout_sel : out std_logic;

    -- Signals from pm_fetch_decoder
    fet_dec_pc                : in  std_logic_vector(15 downto 0);
    fet_dec_retL_wr       : in  std_logic;
    fet_dec_retH_wr       : in  std_logic;
    fet_dec_retL_rd       : in  std_logic;
    fet_dec_retH_rd       : in  std_logic;
    fet_dec_call_dom_change   : in  std_logic_vector(4 downto 0);
    fet_dec_ret_dom_change    : in  std_logic_vector(4 downto 0);
    fet_dec_write_ram_data    : in  std_logic_vector(7 downto 0);
    fet_dec_ret_dom_start : out std_logic;

    -- Signals from Domain Tracker
    dt_update_dom_id : in std_logic;

    -- ssp-MMC to update the dom id and send present stack_bound
    ssp_new_dom_id    : out std_logic_vector(2 downto 0);
    ssp_update_dom_id : out std_logic;
    ssp_stack_bound   : out std_logic_vector(15 downto 0);

    -- Signal from io_reg_file
    stack_pointer_low  : in std_logic_vector(7 downto 0);
    stack_pointer_high : in std_logic_vector(7 downto 0)
    );

end safe_stack;

architecture Beh of safe_stack is

  -- safe stack pointer register
  signal ssp : std_logic_vector(15 downto 0);

  -- stack pointer from io_adr_dec
  signal stack_pointer : std_logic_vector(15 downto 0);

  -- signals used to update ssp
  signal ssp_incremented : std_logic_vector(15 downto 0);
  signal ssp_decremented : std_logic_vector(15 downto 0);
  signal ssp_int         : std_logic_vector(15 downto 0);

  -- These signals are saved from the last cross domain call
  signal stack_bound        : std_logic_vector(15 downto 0);
  signal cross_dom_ret_addr : std_logic_vector(15 downto 0);

  -- signals in the status register from mmc
  signal in_trusted_domain : std_logic;
  signal dom_id            : std_logic_vector(2 downto 0);
  signal umpu_en           : std_logic;

  -- These signals are high when return addr is been written or been read
  signal ret_addr_wr : std_logic;
  signal ret_addr_rd : std_logic;

  signal call_dom_change : std_logic;
  signal ret_dom_change  : std_logic;

  signal ret_cmp        : std_logic_vector(15 downto 0);
  signal ret_cmp_result : std_logic;

  signal call_addr : std_logic_vector(15 downto 0);

  signal cross_dom_call_in_progress : std_logic;

  signal stack_overflow : std_logic;

begin

  -- send the stack_bound to mmc
  ssp_stack_bound <= stack_bound;

  -----------------------------------------------------------------------------
  -- RETRIVE THE DIFFERENT REGIONS OF THE mmc_status_reg
  -----------------------------------------------------------------------------
  -- get the dom id from status reg of mmc
  dom_id            <= mmc_status_reg(4 downto 2);
  -- get the protection bit from the mmc_status_reg
  umpu_en           <= mmc_status_reg(0);
  -- will be '1' only when dom_id = "111" i.e. trusted domain
  in_trusted_domain <= dom_id(0) and dom_id(1) and dom_id(2);

  -- receive the stack pointer from io_adr_dec
  stack_pointer(15 downto 8) <= stack_pointer_high;
  stack_pointer(7 downto 0)  <= stack_pointer_low;

  -- Detecting the stack overflow error
  -- Error occurs when the stack pointer is equal to or less than the
  -- safe stack pointer
  stack_overflow     <= '1' when stack_pointer <= ssp else '0';
  -- Only checking for overflow if the protection bit is set
  ssp_stack_overflow <= stack_overflow and umpu_en;

  -- This latches the cross_dom_call_in_progress signal.
  -- The signal goes high when domain_tracker reports that this is a cross
  -- domain call and then goes low at the end of writing the two bytes of
  -- return address to the safe stack
  CROSS_DOMAIN_CALL_PROGRESS_LATCH : process(clock, ireset)
  begin
    if (ireset = '0') then
      cross_dom_call_in_progress   <= '0';
    elsif (clock'event and clock = '1') then
      if (dt_update_dom_id = '1') then
        cross_dom_call_in_progress <= '1';
      elsif (ret_addr_wr = '1') then
        cross_dom_call_in_progress <= '0';
      end if;
    end if;
  end process;

  -- Call domain change - Writing cross domain stuff to safe stack
  -- The things written to the safe stack consist of the dom_id, stack_bound
  -- and ssp. Therefore, five clock cycles are needed
  call_dom_change <= fet_dec_call_dom_change(0) or fet_dec_call_dom_change(1) or fet_dec_call_dom_change(2) or fet_dec_call_dom_change(3) or fet_dec_call_dom_change(4);
  -- Ret domain change - Writing cross domain stuff to safe stack
  -- Similar to above, the five bytes of information is read from the safe stack
  ret_dom_change  <= fet_dec_ret_dom_change(0) or fet_dec_ret_dom_change(1) or fet_dec_ret_dom_change(2) or fet_dec_ret_dom_change(3) or fet_dec_ret_dom_change(4);

  -- These signals denote when the return address is written to and read from
  -- the safe stack
  ret_addr_wr <= fet_dec_retL_wr or fet_dec_retH_wr;
  ret_addr_rd <= fet_dec_retL_rd or fet_dec_retH_rd;

  -- If any of the above signals are set, that means that the safe stack is
  -- going to either read or write to the RAM. So the select line is set.
  -- When in the trusted domain, the safe stack is not used so at that point
  -- this signal is not set.
  ss_addr_sel <= (ret_addr_rd or ret_addr_wr or call_dom_change or ret_dom_change) and not in_trusted_domain;

  -- The address to read from in the ram is based on if the action is read or
  -- write. For read, the ssp_decremented is used, for write, the ssp is used 
  ss_addr <= ssp_decremented when ret_addr_rd = '1' or ret_dom_change = '1'
             else ssp;

  -----------------------------------------------------------------------------
  -- SAFE STACK POINTER
  -----------------------------------------------------------------------------
  -- This is the mux for updating the ssp
  ssp_incremented      <= ssp + 1;
  ssp_decremented      <= ssp - 1;
  -- ssp can be written to by the software
  ssp_int(15 downto 8) <= reg_bus                           when (adr = SSP_HIGH_Address and iowe = '1' and in_trusted_domain = '1')
                          -- ssp is incremented when things are written to the
                          -- ssp, either the return addr or the different items
                          -- from a cross domain call
                          else ssp_incremented(15 downto 8) when (ret_addr_wr = '1' or call_dom_change = '1')
                          -- ssp is decremented when the return addr is read
                          -- from it. WHY IS NOT DECREMENTED WHEN THE CROSS_DOMAIN_
                          -- RETURN STUFF IS READ FROM IT??????????????????????
                          else ssp_decremented(15 downto 8) when ret_addr_rd = '1'
                          else ssp(15 downto 8);
  -- The lower ssp set in the similar way as above
  ssp_int(7 downto 0)  <= reg_bus                           when (adr = SSP_LOW_Address and iowe = '1' and in_trusted_domain = '1')
                          else ssp_incremented(7 downto 0)  when (ret_addr_wr = '1' or call_dom_change = '1')
                          else ssp_decremented(7 downto 0)  when ret_addr_rd = '1'
                          else ssp(7 downto 0);

  -- Latch for ssp
  SSP_HIGH_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      ssp  <= (others => '0');
    elsif (clock = '1' and clock'event) then
      ssp  <= ssp_int;
    end if;
  end process;
  ssph_out <= ssp(15 downto 8);
  sspl_out <= ssp(7 downto 0);

  -----------------------------------------------------------------------------
  -- Latching the call addr for the cross domain call instrs. No need to latch
  -- it on a regular call intsr as there is no delay in using it.
  -----------------------------------------------------------------------------
  LATCH_CALL_ADDR : process(ireset, clock)
  begin
    if ireset = '0' then
      call_addr   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (dt_update_dom_id = '1') then
        call_addr <= fet_dec_pc;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- CROSS DOMAIN CHANGE PUSH
  -----------------------------------------------------------------------------
  ss_dbusout_sel <= dt_update_dom_id or fet_dec_call_dom_change(0) or fet_dec_call_dom_change(1) or fet_dec_call_dom_change(2) or fet_dec_call_dom_change(3)
                    or fet_dec_call_dom_change(4) or (fet_dec_retL_wr and cross_dom_call_in_progress);
  ss_dbusout     <= "00000"&dom_id                  when (dt_update_dom_id = '1')                                         else
                    stack_bound(7 downto 0)         when (fet_dec_call_dom_change(0) = '1')                               else
                    stack_bound(15 downto 8)        when (fet_dec_call_dom_change(1) = '1')                               else
                    cross_dom_ret_addr(7 downto 0)  when (fet_dec_call_dom_change(2) = '1')                               else
                    cross_dom_ret_addr(15 downto 8) when (fet_dec_call_dom_change(3) = '1')                               else
                    call_addr(7 downto 0)           when fet_dec_call_dom_change(4) = '1'                                 else
                    call_addr(15 downto 8)          when (fet_dec_retL_wr = '1' and cross_dom_call_in_progress = '1') else
                  "00000000";

  -------------------------------------------------------------------------------
  -- CROSS DOMAIN CHANGE POP 
  -------------------------------------------------------------------------------
  COMPARE_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      ret_cmp(15 downto 8)   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (fet_dec_retH_rd = '1') then
        ret_cmp(15 downto 8) <= ram_bus;
      end if;
    end if;
  end process;

  ret_cmp(7 downto 0) <= ram_bus when (fet_dec_retL_rd = '1') else
                         (others => '0');

  ret_cmp_result            <= '1' when (ret_cmp = cross_dom_ret_addr) else
                               '0';
  -- Signal is high on return match => Goes high only for one clock cycle
  fet_dec_ret_dom_start <= ret_cmp_result and fet_dec_retL_rd;

  -----------------------------------------------------------------------------
  -- LATCHES FOR CURRENT RETURN ADDRESS AND STACK BOUND
  -----------------------------------------------------------------------------
  -- Register for cross domain return address
  CROSS_DOM_RET_ADDR_REG : process(ireset, clock)
  begin  -- process
    if (ireset = '0') then
      cross_dom_ret_addr <= (others => '0');
    elsif (clock'event and clock = '1') then
      if (fet_dec_call_dom_change(3) = '1') then
        cross_dom_ret_addr(7 downto 0)  <= call_addr(7 downto 0);
      elsif (fet_dec_ret_dom_change(1) = '1') then
        cross_dom_ret_addr(7 downto 0)  <= ram_bus;
      end if;
      -- Input signal corresponds to retL even though we are reading in retH
      -- This is because data on RamDataBus is put one clock cycle before write
      if (fet_dec_call_dom_change(3) = '1') then
        cross_dom_ret_addr(15 downto 8) <= call_addr(15 downto 8);
      elsif (fet_dec_ret_dom_change(0) = '1') then
        cross_dom_ret_addr(7 downto 0)  <= ram_bus;
      end if;
    end if;
  end process;

  -- Register for stack bound
  STACK_BOUND_REGISTER : process(ireset, clock)
  begin
    if (ireset = '0') then
      stack_bound <= (others => '0');
    elsif (clock'event and clock = '1') then

      if ((fet_dec_retH_wr = '1') and (cross_dom_call_in_progress = '1')) then
        stack_bound(15 downto 8) <= stack_pointer(15 downto 8);
      elsif (fet_dec_ret_dom_change(2) = '1') then
        stack_bound(15 downto 8) <= ram_bus;
      end if;

      if ((fet_dec_retH_wr = '1') and (cross_dom_call_in_progress = '1')) then
        stack_bound(7 downto 0) <= stack_pointer(7 downto 0);
      elsif (fet_dec_ret_dom_change(3) = '1') then
        stack_bound(7 downto 0) <= ram_bus;
      end if;
    end if;
  end process;

  ssp_new_dom_id    <= ram_bus(2 downto 0);
  ssp_update_dom_id <= fet_dec_ret_dom_change(4);

end Beh;
