library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
--use std.textio.all;

entity data_col is
  generic (
    NEVENTS  :    integer := 100;
    FILENAME :    string  := "log_file"
    );
  port (
    reset    : in std_logic;
    clock    : in std_logic;
    monitor  : in std_logic;
    stop     : in std_logic;
    value    : in std_logic_vector(7 downto 0)
    );

end data_col;

architecture beh of data_col is

  type time_stamp_type is array (0 to NEVENTS) of std_logic_vector(31 downto 0);
  type data_type is array (0 to NEVENTS) of std_logic_vector(7 downto 0);

  type integer_file is file of integer;
  file write_file : integer_file open write_mode is FILENAME;
  --file log : text open write_mode is "log_file";

  signal time_stamp : time_stamp_type;
  signal data       : data_type;

  signal counter       : std_logic_vector(31 downto 0);
  signal point_counter : integer;

begin

  INCREMENT_COUNTER : process(reset, stop, clock)
  begin
    if (reset = '0') then
      counter <= (others => '0');
    elsif (stop = '0' and clock = '1' and clock'event) then
      counter <= counter + 1;
    end if;
  end process;

  POINTER_INC : process(reset, stop, monitor)
  begin

    if (reset = '0') then
      point_counter            <= 0;
      time_stamp(0 to NEVENTS) <= (others => (others => '0'));
      data(0 to NEVENTS)       <= (others => value);

    elsif (stop = '0' and reset = '1' and monitor'event) then
      time_stamp(point_counter) <= counter;
      data(point_counter)       <= value;
      point_counter             <= point_counter + 1;
    end if;
  end process;

  FILE_OUT : process(stop)
-- variable trace_line : line;
  begin
    if (stop = '1' and stop'event) then
      --for index in 0 to (10) loop
      for index in 0 to (conv_integer(point_counter) - 2) loop
-- write(trace_line, time_stamp(index));
-- write(trace_line, string'(" "));
-- write(trace_line, data(index));
-- writeline(log, trace_line);
        write(write_file, conv_integer(time_stamp(index)));
        write(write_file, conv_integer(data(index)));
      end loop;  -- index
    end if;
  end process;

end beh;
