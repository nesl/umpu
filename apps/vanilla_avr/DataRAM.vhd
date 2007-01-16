--************************************************************************************************
-- Data RAM(behavioural) for AVR microcontroller (for simulation)
-- Version 0.1
-- Designed by Ruslan Lepetenok 
-- Modified 02.11.2002
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use WORK.AVRuCPackage.all;

entity DataRAM is generic(RAMSize :     positive := 4096);
                  port(
                    cp2           : in  std_logic;
                    address       : in  std_logic_vector (15 downto 0);
                    ramwe         : in  std_logic;
                    din           : in  std_logic_vector (7 downto 0);
                    dout          : out std_logic_vector (7 downto 0)
                    );
end DataRAM;

architecture Beh of DataRAM is

component RAM
  port (
    address : in std_logic_vector(15 downto 0);
    clock : in std_logic;
    dataIn : in std_logic_vector(7 downto 0);
    dataOut : out std_logic_vector(7 downto 0);
    wrEn : in std_logic
    );
end component;

begin

  RAM_Block : RAM
    port map(
      address => address,
      clock => cp2,
      dataIn => din,
      dataOut => dout,
      wrEn => ramwe
      );
  
end Beh;
