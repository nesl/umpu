library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shifter is
  port (
    shift_input  : in  std_logic_vector(15 downto 0);
    shift_amount : in  std_logic_vector(3 downto 0);
    shift_output : out std_logic_vector(15 downto 0)
    );
end shifter;

architecture archi of shifter is
begin

  shift_output(15 downto 13) <= "000";

  process(shift_input,shift_amount)
  begin
    if (shift_amount = "0011") then
      shift_output(12 downto 0) <= shift_input(15 downto 3);
    elsif (shift_amount = "0100") then
      shift_output(11 downto 0) <= shift_input(15 downto 4);
      shift_output(12) <= '0';
    elsif shift_amount = "0101" then
      shift_output(10 downto 0) <= shift_input(15 downto 5);
      shift_output(12 downto 11) <= "00";
    elsif shift_amount = "0110" then
      shift_output(9 downto 0) <= shift_input(15 downto 6);
      shift_output(12 downto 10) <= "000";
    elsif shift_amount = "0111" then
      shift_output(8 downto 0) <= shift_input(15 downto 7);
      shift_output(12 downto 9) <= "0000";
    elsif shift_amount = "1000" then
      shift_output(7 downto 0) <= shift_input(15 downto 8);
      shift_output(12 downto 8) <= "00000";
    elsif shift_amount = "1001" then
      shift_output(6 downto 0) <= shift_input(15 downto 9);
      shift_output(12 downto 7) <= "000000";
    elsif shift_amount = "1010" then
      shift_output(5 downto 0) <= shift_input(15 downto 10);
      shift_output(12 downto 6) <= "0000000";
    else
      shift_output(12 downto 0) <= (others => '0');
    end if;
  end process;

end archi;
