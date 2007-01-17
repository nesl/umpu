library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use WORK.AVRuCPackage.all;

entity program_loader is port (
  reset : in std_logic;
  clock  : in std_logic;

  data_in : in std_logic_vector(7 downto 0);
  data_req : out std_logic;
  data_recd : in std_logic;

  avr_reset : out std_logic;

  prom_wr_en   : out std_logic;
  prom_address : out std_logic_vector(15 downto 0);
  prom_data    : out std_logic_vector(15 downto 0)
  );
end program_loader;

architecture Beh of program_loader is

  signal prom_address_int : std_logic_vector(15 downto 0);

  signal data_ready : std_logic;
  signal counter : std_logic;

begin

  GET_DATA : process(reset,data_recd)
  begin
    if (reset = '0' or data_recd = '1' or prom_address_int >= x"2000") then
      data_req <= '0';
    else
      data_req <= '1';
      counter <= not counter;
    end if;
  end process;

  prom_data(15 downto 8) <= data_in when counter = '0';
  prom_data(7 downto 0) <= data_in when counter = '0';
  data_ready <= '1' when counter = '1'
                else '0';
  
  WRITE_PROM:process(reset,clock)
  begin
    if (reset = '0') then
      prom_address <= (others => '0');
      prom_wr_en <= '1';
      avr_reset <= '0';
    elsif (clock = '1' and clock'event) then
      if (prom_address_int = X"2000") then
        prom_wr_en <= '0';
        avr_reset <= '1';
      elsif (data_ready = '1') then
        prom_wr_en <= '1';
        prom_address_int <= prom_address_int + 1;
      end if;
    end if;
  end process;
  prom_address <= prom_address_int;

end Beh;
