library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use WORK.AVRuCPackage.all;

entity umpu
is port (

  -- temp signals begin
  loadingData    : out std_logic_vector(15 downto 0);
  loadingAddress : out std_logic_vector(15 downto 0);
  procData       : out std_logic_vector(15 downto 0);
  procAddress    : out std_logic_vector(15 downto 0);
  loadingWrEn    : out std_logic;

  RamAddress : out std_logic_vector(15 downto 0);
  RamDataIn  : out std_logic_vector(7 downto 0);
  RamDataOut : out std_logic_vector(7 downto 0);
  RamWrEn    : out std_logic;
  -- temp signals end

  -- Real time clock for timer counter
  rt_Clock : in std_logic;

  -- Panic signal from mmc
  panic : out std_logic;

  -- General Ports
  clock : in std_logic;
  reset : in std_logic;

  -- avr specific ports
  porta : inout std_logic_vector(7 downto 0);
  portb : inout std_logic_vector(7 downto 0);
  -- uart
  rxd   : in    std_logic;
  txd   : out   std_logic;
  -- External interrupt inputs
  nINT0 : in    std_logic;
  nINT1 : in    std_logic;
  nINT2 : in    std_logic;
  nINT3 : in    std_logic;
  INT4  : in    std_logic;
  INT5  : in    std_logic;
  INT6  : in    std_logic;
  INT7  : in    std_logic
  );

end umpu;

architecture beh of umpu is

  signal eightMhzClock : std_logic_vector(1 downto 0);

  component top_avr_core_sim
    is port (

      -- Temp signals
      tempPromAddress : out std_logic_vector(15 downto 0);
      tempPromData    : out std_logic_vector(15 downto 0);
      tempRamAddress  : out std_logic_vector(15 downto 0);
      tempRamDataIn   : out std_logic_vector(7 downto 0);
      tempRamDataOut  : out std_logic_vector(7 downto 0);
      tempRamWrEn     : out std_logic;

      -- Real time clock for timer counter
      rt_Clock : in std_logic;

      -- Panic signal from mmc
      panic : out std_logic;

      -- avr_core
      cp2           : in    std_logic;
      ireset        : in    std_logic;
      porta         : inout std_logic_vector(7 downto 0);
      portb         : inout std_logic_vector(7 downto 0);
      -- UART 
      rxd           : in    std_logic;
      txd           : out   std_logic;
      -- External interrupt inputs
      nINT0         : in    std_logic;
      nINT1         : in    std_logic;
      nINT2         : in    std_logic;
      nINT3         : in    std_logic;
      INT4          : in    std_logic;
      INT5          : in    std_logic;
      INT6          : in    std_logic;
      INT7          : in    std_logic;
      -- Loader specific ports
      promAddressIn : in    std_logic_vector( 15 downto 0);
      promDataIn    : in    std_logic_vector(15 downto 0);
      promWrEn      : in    std_logic
      );
  end component;

  component programToLoad
    is port (
      address_in : in  std_logic_vector (15 downto 0);
      data_out   : out std_logic_vector (15 downto 0)
      );
  end component;

  component uart_wrapper
    is port (
      reset : in  std_logic;
      clock : in  std_logic;
      load_rxd   : in  std_logic;
      load_txd   : out std_logic;

      tx_data : in std_logic_vector(7 downto 0);

      rx_data_req   : in  std_logic;
      rx_data_ready : out std_logic;
      rx_data       : out std_logic_vector(7 downto 0)
      );
  end component;

  component program_loader
    is port (
      reset : in std_logic;
      clock : in std_logic;

      data_in   : in  std_logic_vector(7 downto 0);
      data_req  : out std_logic;
      data_recd : in  std_logic;

      avr_reset : out std_logic;

      prom_wr_en   : out std_logic;
      prom_address : out std_logic_vector(15 downto 0);
      prom_data    : out std_logic_vector(15 downto 0)
      );
  end component;

  signal sgData     : std_logic_vector(15 downto 0);
  signal sgAddress  : std_logic_vector(15 downto 0);
  signal sgWrEn     : std_logic;
  signal sgAvrReset : std_logic;
  signal sgPanic    : std_logic;

  signal avr_txd : std_logic;

begin  -- beh

  loadingAddress <= sgAddress;
  loadingData    <= sgData;
  loadingWrEn    <= sgWrEn;

  -- map the panic signal so it can be observed
  panic <= sgPanic;

  UART_LOADER : component uart_wrapper port map (
    reset => reset,
    clock => eightMhzClock(1),
    load_rxd => avr_txd,
--     load_txd => ,
     tx_data => (others => '0'),
     rx_data_req => '0'
--     rx_data_ready => ,
--     rx_data => 
    );

  TOP_AVR : component top_avr_core_sim port map (
    -- temp signals begin
    tempPromData    => procData,
    tempPromAddress => procAddress,
    tempRamAddress  => RamAddress,
    tempRamDataOut  => RamDataOut,
    tempRamDataIn   => RamDataIn,
    tempRamWrEn     => RamWrEn,
    -- temp signals end

    -- real time clock for timer counter
    rt_Clock      => rt_Clock,
    -- Panic signal from mmc
    panic         => sgPanic,
    -- avr_core
    cp2           => eightMhzClock(1),
    ireset        => sgAvrReset,
    porta         => porta,
    portb         => portb,
    -- UART 
    rxd           => rxd,
    txd           => avr_txd,
    -- External interrupt inputs
    nINT0         => nINT0,
    nINT1         => nINT1,
    nINT2         => nINT2,
    nINT3         => nINT3,
    INT4          => INT4,
    INT5          => INT5,
    INT6          => INT6,
    INT7          => INT7,
    -- Loader specific ports
    promAddressIn => sgAddress,
    promDataIn    => sgData,
    promWrEn      => sgWrEn
    );
  txd <= avr_txd;

  loader : component programToLoad port map (
    address_in => sgAddress,
    data_out   => sgData
    );

  scalingClock : process(reset, clock)
  begin
    if (reset = '0') then
      eightMhzClock <= "00";

    elsif (clock = '1' and clock'event) then
      eightMhzClock <= eightMhzClock + 1;
    end if;
  end process scalingClock;

  resetProcess : process (eightMhzClock(1), reset)
  begin  -- process on clock or reset
    -- if initial reset, reset the entire system
    if (reset = '0') then
      sgAddress      <= "0000000000000000";
      sgWrEn         <= '1';
      sgAvrReset     <= '0';
    else
      if (eightMhzClock(1) = '1' and eightMhzClock(1)'event) then
        -- if we are done loading the PROM
        if (sgAddress = X"4000") then
          -- Stop writing and reset the avr_core
          sgWrEn     <= '0';
          sgAvrReset <= '1';
        else
          -- Else keep writing and incrementing the PROM address
          sgWrEn     <= '1';
          sgAvrReset <= '0';
          sgAddress  <= sgAddress + 1;
        end if;
      end if;
    end if;
  end process resetProcess;

end beh;
