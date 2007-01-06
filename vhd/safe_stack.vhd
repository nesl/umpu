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
    fet_dec_ssp_retL_wr       : in  std_logic;
    fet_dec_ssp_retH_wr       : in  std_logic;
    fet_dec_ssp_retL_rd       : in  std_logic;
    fet_dec_ssp_retH_rd       : in  std_logic;
    fet_dec_call_dom_change   : in  std_logic_vector(4 downto 0);
    fet_dec_ret_dom_change    : in  std_logic_vector(4 downto 0);
    fet_dec_write_ram_data    : in  std_logic_vector(7 downto 0);
    fet_dec_ssp_ret_dom_start : out std_logic;

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

  -- internal signals
  signal sg_ssp_incremented : std_logic_vector(15 downto 0);
  signal sg_ssp_decremented : std_logic_vector(15 downto 0);
  signal sg_ssp             : std_logic_vector(15 downto 0);

  signal stack_bound        : std_logic_vector(15 downto 0);
  signal cross_dom_ret_addr : std_logic_vector(15 downto 0);

  -- signals in the status register from mmc
  signal in_trusted_domain : std_logic;
  signal dom_id            : std_logic_vector(2 downto 0);
  signal umpu_en : std_logic;

  signal sg_fet_dec_ssp_ret_wr : std_logic;
  signal sg_fet_dec_ssp_ret_rd : std_logic;

  signal call_dom_change : std_logic;
  signal ret_dom_change  : std_logic;

  signal ret_cmpH       : std_logic_vector(7 downto 0);
  signal ret_cmpL       : std_logic_vector(7 downto 0);
  signal ret_cmp        : std_logic_vector(15 downto 0);
  signal ret_cmp_result : std_logic;

  signal sg_call_addr : std_logic_vector(15 downto 0);

  signal cross_dom_call_in_progress : std_logic;

  signal stack_overflow : std_logic;

begin

  CROSS_DOMAIN_CALL_PROGRESS_LATCH : process(clock, ireset)
  begin
    if (ireset = '0') then
      cross_dom_call_in_progress   <= '0';
    elsif (clock'event and clock = '1') then
      if (dt_update_dom_id = '1') then
        cross_dom_call_in_progress <= '1';
      elsif (fet_dec_ssp_retH_wr = '1') then
        cross_dom_call_in_progress <= '0';
      end if;
    end if;
  end process;

  -- send the stack_bound to mmc
  ssp_stack_bound <= stack_bound;

  -- receive the stack pointer from io_adr_dec
  stack_pointer(15 downto 8) <= stack_pointer_high;
  stack_pointer(7 downto 0)  <= stack_pointer_low;

  -- Detecting the stack overflow error
  -- Error occurs when the stack pointer is equal to or less than the
  -- safe stack pointer
  stack_overflow <= '1' when stack_pointer <= ssp else '0';
  -- Only checking for overflow if the protection bit is set
  ssp_stack_overflow <= stack_overflow and umpu_en;

  -- Call domain change - Writing cross domain stuff to safe stack
  call_dom_change <= fet_dec_call_dom_change(0) or fet_dec_call_dom_change(1) or fet_dec_call_dom_change(2) or fet_dec_call_dom_change(3) or fet_dec_call_dom_change(4);
  -- Ret domain change - Writing cross domain stuff to safe stack
  ret_dom_change  <= fet_dec_ret_dom_change(0) or fet_dec_ret_dom_change(1) or fet_dec_ret_dom_change(2) or fet_dec_ret_dom_change(3) or fet_dec_ret_dom_change(4);

  -- Writing return address to safe stack
  sg_fet_dec_ssp_ret_wr <= fet_dec_ssp_retL_wr or fet_dec_ssp_retH_wr;
  sg_fet_dec_ssp_ret_rd <= fet_dec_ssp_retL_rd or fet_dec_ssp_retH_rd;

  -- safe stack controls addr bus on read and write
  ss_addr_sel <= (sg_fet_dec_ssp_ret_rd or sg_fet_dec_ssp_ret_wr or call_dom_change or ret_dom_change) and not in_trusted_domain;

  -- Mux for ss_addr
  ss_addr <= sg_ssp_decremented when sg_fet_dec_ssp_ret_rd = '1' or ret_dom_change = '1'
             else ssp;

  -----------------------------------------------------------------------------
  -- CURRENT DOMAIN ID
  -----------------------------------------------------------------------------
  -- get the dom id from status reg of mmc
  dom_id            <= mmc_status_reg(4 downto 2);
  -- get the protection bit from the mmc_status_reg
  umpu_en <= mmc_status_reg(0);
  -- will be '1' only when dom_id = "111" i.e. trusted domain
  in_trusted_domain <= dom_id(0) and dom_id(1) and dom_id(2);

  -----------------------------------------------------------------------------
  -- SAFE STACK POINTER
  -----------------------------------------------------------------------------
  -- mux for incrementing or writing to the ssp
  sg_ssp_incremented  <= ssp + 1;
  sg_ssp_decremented  <= ssp - 1;
  sg_ssp(15 downto 8) <= reg_bus                              when (adr = SSP_HIGH_Address and iowe = '1' and in_trusted_domain = '1')
                         else sg_ssp_incremented(15 downto 8) when (sg_fet_dec_ssp_ret_wr = '1' or call_dom_change = '1')
                         else sg_ssp_decremented(15 downto 8) when sg_fet_dec_ssp_ret_rd = '1'
                         else ssp(15 downto 8);
  sg_ssp(7 downto 0)  <= reg_bus                              when (adr = SSP_LOW_Address and iowe = '1' and in_trusted_domain = '1')
                         else sg_ssp_incremented(7 downto 0)  when (sg_fet_dec_ssp_ret_wr = '1' or call_dom_change = '1')
                         else sg_ssp_decremented(7 downto 0)  when sg_fet_dec_ssp_ret_rd = '1'
                         else ssp(7 downto 0);

  -- Latch for ssp
  SSP_HIGH_DFF : process(clock, ireset)
  begin
    if (ireset = '0') then
      ssp <= (others => '0');
    elsif (clock = '1' and clock'event) then
      ssp <= sg_ssp;
    end if;
  end process;

  ssph_out <= ssp(15 downto 8);
  sspl_out <= ssp(7 downto 0);

  -----------------------------------------------------------------------------
  -- Latching the call addr for the call instrs
  -----------------------------------------------------------------------------
  LATCH_CALL_ADDR : process(ireset, clock)
  begin
    if ireset = '0' then
      sg_call_addr   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (dt_update_dom_id = '1') then
        sg_call_addr <= fet_dec_pc;
      end if;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- CROSS DOMAIN CHANGE PUSH
  -----------------------------------------------------------------------------
  ss_dbusout_sel <= dt_update_dom_id or fet_dec_call_dom_change(0) or fet_dec_call_dom_change(1) or fet_dec_call_dom_change(2) or fet_dec_call_dom_change(3)
                    or fet_dec_call_dom_change(4) or (fet_dec_ssp_retL_wr and cross_dom_call_in_progress);
  ss_dbusout     <= "00000"&dom_id                  when (dt_update_dom_id = '1')                                         else
                    stack_bound(7 downto 0)         when (fet_dec_call_dom_change(0) = '1')                               else
                    stack_bound(15 downto 8)        when (fet_dec_call_dom_change(1) = '1')                               else
                    cross_dom_ret_addr(7 downto 0)  when (fet_dec_call_dom_change(2) = '1')                               else
                    cross_dom_ret_addr(15 downto 8) when (fet_dec_call_dom_change(3) = '1')                               else
                    sg_call_addr(7 downto 0)        when fet_dec_call_dom_change(4) = '1'                                 else
                    sg_call_addr(15 downto 8)       when (fet_dec_ssp_retL_wr = '1' and cross_dom_call_in_progress = '1') else
                    "00000000";
  -------------------------------------------------------------------------------
  -- CROSS DOMAIN CHANGE POP 
  -------------------------------------------------------------------------------

  COMPARE_LATCH : process(ireset, clock)
  begin
    if ireset = '0' then
      ret_cmpH   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (fet_dec_ssp_retH_rd = '1') then
        ret_cmpH <= ram_bus;
      end if;
    end if;
  end process;

  ret_cmpL <= ram_bus when (fet_dec_ssp_retL_rd = '1') else
              (others => '0');

  ret_cmp(15 downto 8) <= ret_cmpH;
  ret_cmp(7 downto 0)  <= ret_cmpL;

  ret_cmp_result            <= '1' when (ret_cmp = cross_dom_ret_addr) else
                    '0';
  -- Signal is high on return match => Goes high only for one clock cycle
  fet_dec_ssp_ret_dom_start <= ret_cmp_result and fet_dec_ssp_retL_rd;

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
        cross_dom_ret_addr(7 downto 0)  <= sg_call_addr(7 downto 0);
      elsif (fet_dec_ret_dom_change(1) = '1') then
        cross_dom_ret_addr(7 downto 0)  <= ram_bus;
      end if;
      -- Input signal corresponds to retL even though we are reading in retH
      -- This is because data on RamDataBus is put one clock cycle before write
      if (fet_dec_call_dom_change(3) = '1') then
        cross_dom_ret_addr(15 downto 8) <= sg_call_addr(15 downto 8);
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

      if ((fet_dec_ssp_retH_wr = '1') and (cross_dom_call_in_progress = '1')) then
        stack_bound(15 downto 8) <= stack_pointer(15 downto 8);
      elsif (fet_dec_ret_dom_change(2) = '1') then
        stack_bound(15 downto 8) <= ram_bus;
      end if;

      if ((fet_dec_ssp_retH_wr = '1') and (cross_dom_call_in_progress = '1')) then
        stack_bound(7 downto 0) <= stack_pointer(7 downto 0);
      elsif (fet_dec_ret_dom_change(3) = '1') then
        stack_bound(7 downto 0) <= ram_bus;
      end if;

-- stack_bound(15 downto 8) <= stack_pointer(15 downto 8) when fet_dec_ssp_retH_wr = '1'
-- else ram_bus when fet_dec_ret_dom_change(2) = '1'
-- else stack_bound(15 downto 8);
-- stack_bound(7 downto 0) <= stack_pointer(7 downto 0) when fet_dec_ssp_retH_wr = '1'
-- else ram_bus when fet_dec_ret_dom_change(3) = '1'
-- else stack_bound(7 downto 0);

    end if;
  end process;

  ssp_new_dom_id    <= ram_bus(2 downto 0);
  ssp_update_dom_id <= fet_dec_ret_dom_change(4);

--  -- Latch for prev domain ID
--   PREV_DOMID_LATCH : process(ireset, dt_update_dom_id)
--   begin
--     if (ireset = '0') then
--       prev_dom_id   <= "111"
--     elsif (dt_update_dom_id = '1' and dt_update_dom_id'event) then
--         prev_dom_id <= dom_id;
--       end if;
-- end process;

end Beh;
