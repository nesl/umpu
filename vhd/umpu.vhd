library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

use WORK.AVRuCPackage.all;

entity umpu
is port (
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

  component top_avr_core_sim
    is port (
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

  component sos_packet
    is port(
      reset    : in  std_logic;
      clock    : in  std_logic;
      load_rxd : in  std_logic;
      load_txd : out std_logic
      );
  end component;

  component data_col
    generic (
      NEVENTS  :    integer;
      filename :    string
      );
    port (
      reset    : in std_logic;
      clock    : in std_logic;
      monitor  : in std_logic;
      stop     : in std_logic;
      value    : in std_logic_vector(7 downto 0)
      );
  end component;

  signal sgAddress : std_logic_vector(15 downto 0);
  signal sgData : std_logic_vector(15 downto 0);
  signal sgWrEn : std_logic;
  
  signal eightMhzClock : std_logic_vector(1 downto 0);
  signal sgAvrReset : std_logic;
  signal sgPanic    : std_logic;
  signal avr_txd : std_logic;
  signal stop : std_logic;

begin  -- beh

  panic <= sgPanic;

  SOS_PACKET_MODULE : component sos_packet port map (
    reset    => reset,
    clock    => eightMhzClock(1),
    load_rxd => avr_txd
    );

  TOP_AVR : component top_avr_core_sim port map (
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

  data_col0 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb0"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(0),
      stop => stop,
      value => portb
      );

  data_col1 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb1"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(1),
      stop => stop,
      value => portb
      );

  data_col2 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb2"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(2),
      stop => stop,
      value => portb
      );

  data_col3 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb3"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(3),
      stop => stop,
      value => portb
      );

  data_col4 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb4"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(4),
      stop => stop,
      value => portb
      );

  data_col5 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb5"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(5),
      stop => stop,
      value => portb
      );

  data_col6 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb6"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(6),
      stop => stop,
      value => portb
      );

  data_col7 : data_col
    generic map (
      NEVENTS => 100,
      FILENAME => "portb7"
      )
    port map (
      reset => reset,
      clock => eightMhzClock(1),
      monitor => portb(7),
      stop => stop,
      value => portb
      );

  COUNTING_STOP : process(reset, clock)
  begin
    if (reset = '0') then
      stop <= '0';
    elsif (clock = '1' and clock'event) then
      if (portb = x"5A") then
        stop <= '1';
      end if;
    end if;
  end process;
 
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
