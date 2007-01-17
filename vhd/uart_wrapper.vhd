library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

use WORK.AVRuCPackage.all;

entity uart_wrapper is port (
  reset : in  std_logic;
  clock : in  std_logic;
  rxd   : in  std_logic;
  txd   : out std_logic;

  tx_data : in std_logic_vector(7 downto 0);

  rx_data_req   : in  std_logic;
  rx_data_ready : out std_logic;
  rx_data       : out std_logic_vector(7 downto 0)
  );
end uart_wrapper;

architecture Beh of uart_wrapper is

  component uart is port(
    -- AVR Control
    ireset   : in  std_logic;
    cp2      : in  std_logic;
    adr      : in  std_logic_vector(5 downto 0);
    dbus_in  : in  std_logic_vector(7 downto 0);
    dbus_out : out std_logic_vector(7 downto 0);
    iore     : in  std_logic;
    iowe     : in  std_logic;
    out_en   : out std_logic;

    --UART
    rxd   : in  std_logic;
    rx_en : out std_logic;
    txd   : out std_logic;
    tx_en : out std_logic;

    --IRQ
    txcirq     : out std_logic;
    txc_irqack : in  std_logic;
    udreirq    : out std_logic;
    rxcirq     : out std_logic
    );
  end component;

  signal reg_adr   : std_logic_vector(5 downto 0);
  signal reg_data  : std_logic_vector(7 downto 0);
  signal reg_wr_en : std_logic;

  signal data       : std_logic_vector(7 downto 0);
  signal data_rd_en : std_logic;

  signal rxd_irq : std_logic;

  signal state         : std_logic_vector(1 downto 0);
  signal state_counter : std_logic_vector(1 downto 0);
  signal change_state  : std_logic;

begin  -- Beh

  STATE_TRANS : process(reset, clock)
  begin
    if (reset = '0') then
      state <= (others => '0');
    elsif (change_state = '1' and state /= "11") then
      state <= state + 1;
    elsif (change_state = '1' and state = "11") then
      state <= "10";
    end if;
  end process;

  STATE_COUNT : process(reset, clock)
  begin
    if (reset = '0') then
      state_counter <= (others => '0');
    elsif (clock = '1' and clock'event) then
      state_counter <= state_counter + 1;
    end if;
  end process;

  change_state <= '1' when state_counter = "11"
                       else '0';

  WRITE_REGS : process(reset, clock)
  begin
    if (clock = '1' and clock'event) then
      if (state = "00") then
        reg_adr <= UBRR_Address;
        reg_data <= x"33";
        reg_wr_en <= '1';
      elsif state = "01" then
        reg_adr <= UCR_Address;
        reg_data <= x"D8";
        reg_wr_en <= '1';
      else
        reg_adr <= (others  => '0');
        reg_data <= (others => '0');
        reg_wr_en <= '0';
      end if;
    end if;
  end process;

  RXD_IRQ_HANDLER : process(reset,rxd_irq)
  begin
    if (reset = '0') then
      data_rd_en <= '0';
    elsif (rxd_irq = '1' and rxd_irq'event) then
      data_rd_en <= '1';
    else
      data_rd_en <= '0';
    end if;
  end process;
  rx_data <= data;
  
  UART_MODULE : component uart port map(
    ireset   => reset,
    cp2      => clock,
    adr      => reg_adr,
    dbus_in  => reg_data,
    dbus_out => data,
    iore     => data_rd_en,
    iowe     => reg_wr_en,
    out_en   =>,                        -- Indicates when sending data

    rxd   => rxd,
    rx_en =>,                           -- Not needed
    txd   => txd,                       -- Not needed
    tx_en =>,                           -- Not needed

    txcirq     =>,                      -- Not needed
    txc_irqack => '0',                  -- Not needed
    udreirq    =>,                      -- Not needed
    rxcirq     => rxd_irq               -- Indicates when data ready
    );

end Beh;
