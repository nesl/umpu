--************************************************************************************************
-- External multeplexer for AVR core
-- Version 2.1
-- Designed by Ruslan Lepetenok 05.11.2001
-- Modified 02.11.2002
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

	entity external_mux is port (
		  ramre              : in  std_logic;
		  dbus_out           : out std_logic_vector (7 downto 0);
		  ram_data_out       : in  std_logic_vector (7 downto 0);
		  io_port_bus0       : in  std_logic_vector (7 downto 0);
		  io_port_bus1       : in  std_logic_vector (7 downto 0);
		  io_port_bus2       : in  std_logic_vector (7 downto 0);
		  io_port_bus3       : in  std_logic_vector (7 downto 0);
		  io_port_bus4       : in  std_logic_vector (7 downto 0);
		  io_port_en_bus     : in  ext_mux_en_type;
          irqack             : in  std_logic;
          irqackad           : in  std_logic_vector(4 downto 0);		  
		  ind_irq_ack        : out std_logic_vector(22 downto 0)		  
		                            );
	end external_mux;

architecture rtl of external_mux is
signal   ext_mux_out      : ext_mux_din_type;

begin

ext_mux_out(0) <= io_port_bus0 when io_port_en_bus(0)='1' else (others => '0');
ext_mux_out(1) <= io_port_bus1 when io_port_en_bus(1)='1' else ext_mux_out(1-1);
ext_mux_out(2) <= io_port_bus2 when io_port_en_bus(2)='1' else ext_mux_out(2-1);
ext_mux_out(3) <= io_port_bus3 when io_port_en_bus(3)='1' else ext_mux_out(3-1);
ext_mux_out(4) <= io_port_bus4 when io_port_en_bus(4)='1' else ext_mux_out(4-1);

dbus_out <= ram_data_out when ramre='1' else ext_mux_out(ext_mux_in_num);
	
interrupt_ack:for i in ind_irq_ack'range generate
ind_irq_ack(i) <= '1' when (irqackad=i+1 and irqack='1') else '0';
end generate;	

end rtl;
