library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

entity sos_packet is port (
  reset    : in  std_logic;
  clock    : in  std_logic;
  load_rxd : in  std_logic;
  load_txd : out std_logic
  );
end sos_packet;

architecture Beh of sos_packet is

  component uart_wrapper is port(
    reset    : in  std_logic;
    clock    : in  std_logic;
    load_rxd : in  std_logic;
    load_txd : out std_logic;

    tx_data : in std_logic_vector(7 downto 0);

    rx_data_req   : in  std_logic;
    rx_data_ready : out std_logic;
    rx_data       : out std_logic_vector(7 downto 0)
    );
  end component;

  signal data_ready : std_logic;
  signal rx_data : std_logic_vector(7 downto 0);
  signal rx_data_latched : std_logic_vector(7 downto 0);
  signal data_req : std_logic;
  
begin  -- Beh

  process(clock)
  begin
    if (clock = '1' and clock'event) then
      if (data_ready = '1') then
        data_req <= '1';
      else
        data_req <= '0';
      end if;
    end if;
  end process;

  process(reset,clock)
  begin
    if (reset = '0') then
      rx_data_latched <= (others => '0');
    elsif (clock = '0' and clock'event) then
      if (data_req = '1') then
        rx_data_latched <= rx_data;
      end if;
    end if;
  end process;
  
  
  UART_WRAPPER_MODULE : component uart_wrapper port map(
    reset => reset,
    clock => clock,
    load_rxd => load_rxd,
    load_txd => load_txd,

    tx_data => (others => '0'),

    rx_data_req => data_req,
    rx_data_ready => data_ready,
    rx_data => rx_data
    );

  
end Beh;
