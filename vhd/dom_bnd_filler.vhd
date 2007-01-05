library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use ieee.numeric_std.all;

use WORK.AVRuCPackage.all;

entity dom_bnd_filler is

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

end dom_bnd_filler;

architecture Beh of dom_bnd_filler is
  -- Giant array to maintain the bounds for all the domains
  -- There are seven untrusted domains, and each domain has an upper and lower
  -- bound. The size of each bound is two bytes so 16 * 2 * 7 bits are required
  signal bounds : std_logic_vector(223 downto 0);

begin

  -- Process to receive the domain bounds on a write to the control register
  process(clock, ireset)
  begin
    if (ireset = '0') then
      bounds                  <= (others => '0');
      updated_domain_bounds   <= '0';
    elsif (clock = '1' and clock'event) then
      if (dom_bnd_ctl(0) = '1') then
        -- Signal that the domain bound is accepted successfully
        updated_domain_bounds <= '1';
        -- Based on the dom_id, H/L Byte and U/L Bound write to the correct
        -- location in the bounds array
        case dom_bnd_ctl(5 downto 1) is

          when "00000" => bounds(7 downto 0)     <= dom_bnd_data;
          when "00001" => bounds(15 downto 8)    <= dom_bnd_data;
          when "00010" => bounds(23 downto 16)   <= dom_bnd_data;
          when "00011" => bounds(31 downto 24)   <= dom_bnd_data;
          when "00100" => bounds(39 downto 32)   <= dom_bnd_data;
          when "00101" => bounds(47 downto 40)   <= dom_bnd_data;
          when "00110" => bounds(55 downto 48)   <= dom_bnd_data;
          when "00111" => bounds(63 downto 56)   <= dom_bnd_data;
          when "01000" => bounds(71 downto 64)   <= dom_bnd_data;
          when "01001" => bounds(79 downto 72)   <= dom_bnd_data;
          when "01010" => bounds(87 downto 80)   <= dom_bnd_data;
          when "01011" => bounds(95 downto 88)   <= dom_bnd_data;
          when "01100" => bounds(103 downto 96)  <= dom_bnd_data;
          when "01101" => bounds(111 downto 104) <= dom_bnd_data;
          when "01110" => bounds(119 downto 112) <= dom_bnd_data;
          when "01111" => bounds(127 downto 120) <= dom_bnd_data;
          when "10000" => bounds(135 downto 128) <= dom_bnd_data;
          when "10001" => bounds(143 downto 136) <= dom_bnd_data;
          when "10010" => bounds(151 downto 144) <= dom_bnd_data;
          when "10011" => bounds(159 downto 152) <= dom_bnd_data;
          when "10100" => bounds(167 downto 160) <= dom_bnd_data;
          when "10101" => bounds(175 downto 168) <= dom_bnd_data;
          when "10110" => bounds(183 downto 176) <= dom_bnd_data;
          when "10111" => bounds(191 downto 184) <= dom_bnd_data;
          when "11000" => bounds(199 downto 192) <= dom_bnd_data;
          when "11001" => bounds(207 downto 200) <= dom_bnd_data;
          when "11010" => bounds(215 downto 208) <= dom_bnd_data;
          when "11011" => bounds(223 downto 216) <= dom_bnd_data;
          when others  => null;
        end case;
      else
        -- Lower the accepted successfully signal on the next clock cycle
        updated_domain_bounds                    <= '0';
      end if;
    end if;
  end process;

  -- Process to change the lower_bound and upper_bound on a change to cur_dom_id
  process(ireset, cur_dom_id)
  begin
    if ireset = '0' then
      lower_bound     <= (others => '0');
      upper_bound     <= (others => '0');
    else
      case cur_dom_id is
        when "000"               =>
          lower_bound <= bounds(15 downto 0);
          upper_bound <= bounds(31 downto 16);
        when "001"               =>
          lower_bound <= bounds(47 downto 32);
          upper_bound <= bounds(63 downto 48);
        when "010"               =>
          lower_bound <= bounds(79 downto 64);
          upper_bound <= bounds(95 downto 80);
        when "011"               =>
          lower_bound <= bounds(111 downto 96);
          upper_bound <= bounds(127 downto 112);
        when "100"               =>
          lower_bound <= bounds(143 downto 128);
          upper_bound <= bounds(159 downto 144);
        when "101"               =>
          lower_bound <= bounds(175 downto 160);
          upper_bound <= bounds(191 downto 176);
        when "110"               =>
          lower_bound <= bounds(207 downto 192);
          upper_bound <= bounds(223 downto 208);
        when others              => null;
      end case;
    end if;
  end process;

end Beh;
