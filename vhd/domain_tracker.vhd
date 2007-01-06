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
    clock  : in std_logic;

    -- dt-umpu_panic interface
    dt_error            : out std_logic;

    -- Bus signals
    adr     : in std_logic_vector(5 downto 0);
    reg_bus : in std_logic_vector(7 downto 0);
    iowe    : in std_logic;

    -- pc from pm_fetch_decoder
    fet_dec_pc         : in std_logic_vector(15 downto 0);
    -- indication of call insrt from pm_fetch_decoder
    fet_dec_call_instr : in std_logic;

    -- send the local registers to io_adr_dec so SW can read
    jmp_table_high_out : out std_logic_vector(7 downto 0);
    jmp_table_low_out  : out std_logic_vector(7 downto 0);
    dom_bnd_ctl_out    : out std_logic_vector(7 downto 0);
    dom_bnd_data_out   : out std_logic_vector(7 downto 0);

    -- status register from mmc
    dt_mmc_status_reg : in  std_logic_vector(7 downto 0);
    -- calculated domain id to mmc
    dt_new_dom_id     : out std_logic_vector(2 downto 0);
    -- signal to update domain id to mmc
    dt_update_dom_id  : out std_logic
    );

end domain_tracker;

architecture Beh of domain_tracker is

  component dom_bnd_filler
    port (
      -- General signals
      clock        : in std_logic;
      ireset       : in std_logic;
      -- Domain_bounds_control register
      -- |UNUSED|DOMAIN ID (2:0)|UPPER OR LOWER BOUND|HIGH OR LOW BYTE BIT|UPDATE BIT|
      dom_bnd_ctl  : in std_logic_vector(7 downto 0);
      -- Data on the bound of the domain 
      dom_bnd_data : in std_logic_vector(7 downto 0);

      -- Current Domain ID
      cur_dom_id            : in  std_logic_vector(2 downto 0);
      -- Lower and Upper bound of the current domain
      lower_bound           : out std_logic_vector(15 downto 0);
      upper_bound           : out std_logic_vector(15 downto 0);
      -- Signal to inform domain_tracker module that the bound was successfully updated
      updated_domain_bounds : out std_logic
      );
  end component;

  -- Local register maintaining the jump table
  signal dt_jmp_table : std_logic_vector(15 downto 0);
  -- Local registers to maintain the dom_bnd_data and ctl
  signal dom_bnd_ctl  : std_logic_vector(7 downto 0);
  signal dom_bnd_data : std_logic_vector(7 downto 0);

  -- to calculate new domain id
  signal difference  : std_logic_vector(15 downto 0);
  signal is_positive : std_logic;
  signal not_bit_ten : std_logic;

  -- Different regions in the mmc_status_reg
  -- Protection bit
  signal umpu_en    : std_logic;
  -- Current domain Id
  signal cur_dom_id : std_logic_vector(2 downto 0);

  -- signal to denote when in trusted domain
  signal in_trusted_domain : std_logic;

  -- Lower and Upper bound of the current domain
  signal lower_bound           : std_logic_vector(15 downto 0);
  signal upper_bound           : std_logic_vector(15 downto 0);
  signal updated_domain_bounds : std_logic;

  signal lb_err : std_logic;
  signal ub_err : std_logic;
begin

  -- Extract different regions from the mmc_status_reg
  umpu_en    <= dt_mmc_status_reg(0);           -- Protection bit
  cur_dom_id <= dt_mmc_status_reg(4 downto 2);  -- Current Domain ID

  -- In trusted domain when the current domain ID is '111'
  in_trusted_domain <= cur_dom_id(2) and cur_dom_id(1) and cur_dom_id(0);

  -- Subtract jump table from pc
  -- This is used to figure out the offset from the beginning of the jump table
  difference  <= fet_dec_pc - dt_jmp_table;
  -- is the result positive
  -- If the result is not positive, then the call address is below the jump table
  is_positive <= '1' when dt_jmp_table <= fet_dec_pc
                 else '0';

  -- Each domain in the jump table has one flash page amount of space so it
  -- has 256 bytes of space. There are eight possible domains so the size of
  -- the jump table is 8 * 256 bytes. Therefore if the tenth bit of the
  -- difference is positive, then the call address is outside the jump table
  not_bit_ten <= not difference(10);

  -- Decide if we have a new domain id
  dt_new_dom_id    <= difference(9 downto 7);
  -- A cross domain call is only permitted if protection is enabled
  dt_update_dom_id <= is_positive and fet_dec_call_instr and not_bit_ten and umpu_en;

  -- There is an error in cross domain call if
  -- We are not in the trusted domain
  -- This is a call instruction and
  -- The jump address is outside the bounds and
  -- The jump address is outside the jump table
  lb_err <= '1' when fet_dec_pc < lower_bound
            else '0';
  ub_err <= '1' when fet_dec_pc > upper_bound
            else '0';
  dt_error <= '1' when
            (not in_trusted_domain and
             fet_dec_call_instr and
             (lb_err or ub_err)
             and (not is_positive or not not_bit_ten)) = '1'
            else '0';

  -- This component will update the bound information whenever the dom_bnd_ctl
  -- register is written to. This component also makes available the lower and
  -- upper bound of the current domain for checking
  DOM_BND_FIL : component dom_bnd_filler port map(
    clock                 => clock,
    ireset                => ireset,
    dom_bnd_ctl           => dom_bnd_ctl,
    dom_bnd_data          => dom_bnd_data,
    cur_dom_id            => cur_dom_id,
    lower_bound           => lower_bound,
    upper_bound           => upper_bound,
    updated_domain_bounds => updated_domain_bounds
    );

--  -- When the dom_bnd_filler successfully accepts the new bound, the update bit
--   -- in the dom_bnd_ctl is set back to '0'
--   SET_UPDATE_BIT : process(clock, ireset)
--   begin
--     if ireset /= '0' then
--       if (clock = '1' and clock'event) then
--         if updated_domain_bounds = '1' then
--           dom_bnd_ctl(0) <= '0';
--         end if;
--       end if;
--     end if;
--   end process;

  -- Register for DOM_BND_CTL
  -- |UNUSED|DOMAIN ID (2:0)|UPPER OR LOWER BOUND|HIGH OR LOW BYTE BIT|UPDATE BIT|
  --
  -- UPPER OR LOWER BOUND: indicates which bound of the domain the data is for
  -- HIGH OR LOW BYTE: indicates which byte of the address is sent in the data register
  -- DOMAIN ID: indicates for which domain the bound is been sent
  -- UPDATE BIT: When this bit is set to 1, the hardware copies the data from
  -- the data register and sets this bit to 0.
  DOM_BND_CTL_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dom_bnd_ctl               <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = DOM_BND_CTL_Address and iowe = '1' and in_trusted_domain = '1') then
        dom_bnd_ctl(7 downto 1) <= reg_bus(7 downto 1);
      end if;
      if (adr = DOM_BND_CTL_Address and iowe = '1' and in_trusted_domain = '1' and reg_bus(0) = '1') then
        dom_bnd_ctl(0)          <= '1';
      else
      --elsif updated_domain_bounds = '1' then
        dom_bnd_ctl(0)          <= '0';
      end if;
    end if;
  end process;

  -- Register for DOM_BND_DATA
  -- This will contain one byte of the address of the bound of the domain
  DOM_BND_DATA_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dom_bnd_data   <= (others => '0');
    elsif (clock = '1' and clock'event) then
      if (adr = DOM_BND_DATA_Address and iowe = '1' and in_trusted_domain = '1') then
        dom_bnd_data <= reg_bus;
      end if;
    end if;
  end process;

  --Register for high byte of jump table
  DT_JUMP_TABLE_HIGH_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dt_jmp_table(15 downto 8)   <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = DT_JUMP_TABLE_HIGH_Address and iowe = '1' and in_trusted_domain = '1') then
        dt_jmp_table(15 downto 8) <= reg_bus;
      end if;
    end if;
  end process;

  --Register for low byte of jump table
  DT_JUMP_TABLE_LOW_DFF : process(clock, ireset)
  begin
    if ireset = '0' then
      dt_jmp_table(7 downto 0)   <= (others => '1');
    elsif (clock = '1' and clock'event) then
      if (adr = DT_JUMP_TABLE_LOW_Address and iowe = '1' and in_trusted_domain = '1') then
        dt_jmp_table(7 downto 0) <= reg_bus;
      end if;
    end if;
  end process;

  -- expose the internal registers to io_adr_dec
  jmp_table_low_out  <= dt_jmp_table(7 downto 0);
  jmp_table_high_out <= dt_jmp_table(15 downto 8);
  dom_bnd_data_out   <= dom_bnd_data;
  dom_bnd_ctl_out    <= dom_bnd_ctl;
end Beh;
