library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_programLoader is

end tb_programLoader;

architecture test_bench of tb_programLoader is

  -- General Ports
  signal tbClock : std_logic;
  signal tbReset : std_logic;

  -- real time clock for timer counter
  signal tb_rt_Clock : std_logic;
  -- avr specific ports
  signal tbPorta     : std_logic_vector(7 downto 0);
  signal tbPortb     : std_logic_vector(7 downto 0);
  -- uart
  signal tbRxd       : std_logic;
  signal tbTxd       : std_logic;
  -- External interrupt inputs
  signal tb_nINT0    : std_logic;
  signal tb_nINT1    : std_logic;
  signal tb_nINT2    : std_logic;
  signal tb_nINT3    : std_logic;
  signal tb_INT4     : std_logic;
  signal tb_INT5     : std_logic;
  signal tb_INT6     : std_logic;
  signal tb_INT7     : std_logic;

  -- Temp signals begin
  signal tbProcData       : std_logic_vector(15 downto 0);
  signal tbProcAddress    : std_logic_vector(15 downto 0);
  signal tbLoadingData    : std_logic_vector(15 downto 0);
  signal tbLoadingAddress : std_logic_vector(15 downto 0);
  signal tbLoadingWrEn    : std_logic;

  signal tbRamAdress  : std_logic_vector(15 downto 0);
  signal tbRamDataOut : std_logic_vector(7 downto 0);
  signal tbRamDataIn  : std_logic_vector(7 downto 0);
  signal tbRamWrEn    : std_logic;
  -- temp signals end

  component programLoader
    port (
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

  end component;

begin  -- test_bench

  programLoader1 : programLoader
    port map (

      -- temp signals begin
      loadingData    => tbLoadingData,
      loadingAddress => tbLoadingAddress,
      procData       => tbProcData,
      procAddress    => tbProcAddress,
      LoadingWrEn    => tbLoadingWrEn,

      RamAddress => tbRamAdress,
      RamDataOut => tbRamDataOut,
      RamDataIn  => tbRamDataIn,
      RamWrEn    => tbRamWrEn,
      -- temp signals end

      -- real time clock for timer counter
      rt_Clock => tb_rt_Clock,

      clock => tbClock,
      reset => tbReset,
      porta => tbPorta,
      portb => tbPortb,
      rxd   => tbRxd,
      txd   => tbTxd,
      nINT0 => tb_nINT0,
      nINT1 => tb_nINT1,
      nINT2 => tb_nINT2,
      nINT3 => tb_nINT3,
      INT4  => tb_INT4,
      INT5  => tb_INT5,
      INT6  => tb_INT6,
      INT7  => tb_INT7
      );

--   rt_clock_process : process
--     begin
--       -- rt clock period of 30518 ns or 32,768 Hz
--       tb_rt_Clock <= '1', '0' after 15259 ns;
--       wait for 30518 ns;
--     end process rt_clock_process;
  
  rt_clock_process : process
    begin
      -- rt clock period of 30518 ns or 32,768 Hz
      tb_rt_Clock <= '1', '0' after 150 ns;
      wait for 300 ns;
    end process rt_clock_process;
  
  clock_process : process
  begin
    -- clock period of 100 ns
    tbClock <= '1', '0' after 50 ns;
    wait for 100 ns;
  end process clock_process;

  test_stimuli : process
  begin
    -- reset for two clock cycles and then start the system
    tbReset <= '0', '1' after 400 ns;

    wait;

  end process test_stimuli;

end test_bench;

configuration cfg_tb_programLoader of tb_programLoader is

  for test_bench
    for programLoader1 : programLoader
      use entity work.programLoader(Behavioral);
    end for;
  end for;

end cfg_tb_programLoader;
