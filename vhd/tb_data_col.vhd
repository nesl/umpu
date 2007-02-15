library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity tb_data_col is

end tb_data_col;

architecture test_bench of tb_data_col is

  signal clock : std_logic;
  signal reset : std_logic;
  signal monitor : std_logic;
  signal stop : std_logic;
  signal value : std_logic_vector(7 downto 0);

  component data_col
    generic (
      NEVENTS :    integer;
      filename : string
      );
    port (
      reset   : in std_logic;
      clock   : in std_logic;
      monitor : in std_logic;
      stop    : in std_logic;
      value   : in std_logic_vector(7 downto 0)
      );

  end component;

begin
  
  data_col1 : data_col
    generic map (
      NEVENTS => 30,
      filename => "test1"
      )
    port map (
      reset => reset,
      clock => clock,
      monitor => monitor,
      stop => stop,
      value => value
      );

  monitor_process : process
  begin
    monitor <= '1', '0' after 20 ns;
    wait for 40 ns;
  end process;

  value_process : process
  begin
    value <= x"01";
    wait for 10 ns;
    value <= x"02";
    wait for 10 ns;
    value <= x"03";
    wait for 10 ns;
  end process;

  stop_process : process
  begin
    stop <= '0', '1' after 500 ns;
    wait;
  end process;
  
  clock_process : process
  begin
    -- clock period of 100 ns
    clock <= '1', '0' after 15.625 ns;
    wait for 31.25 ns;
  end process clock_process;

  test_stimuli : process
  begin
    -- reset for two clock cycles and then start the system
    reset <= '0', '1' after 200 ns;
    wait;
  end process test_stimuli;
end test_bench;

configuration cfg_tb_data_col of tb_data_col is

  for test_bench
    for data_col1 : data_col
      use entity work.data_col(Behavioral);
    end for;
  end for;

end cfg_tb_data_col;
