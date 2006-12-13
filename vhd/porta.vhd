--**********************************************************************************************
--  Parallel Port Peripheral for the AVR Core
--  Version 0.4 02.01.2003
--  Designed by Ruslan Lepetenok
--**********************************************************************************************
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

use WORK.AVRuCPackage.all;

entity pporta is
  -- generic(
  --    PORTX_Adr : std_logic_vector(IOAdrWidth-1 downto 0);
  --    DDRX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0);
  --    PINX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0)
  -- );
  port(
    -- AVR Control
    ireset   : in  std_logic;
    cp2      : in  std_logic;
    adr      : in  std_logic_vector(5 downto 0);
    dbus_in  : in  std_logic_vector(7 downto 0);
    dbus_out : out std_logic_vector(7 downto 0);
    iore     : in  std_logic;
    iowe     : in  std_logic;
    out_en   : out std_logic;
    -- External connection
    portx    : out std_logic_vector(7 downto 0);
    ddrx     : out std_logic_vector(7 downto 0);
    pinx     : in  std_logic_vector(7 downto 0));
end pporta;

architecture rtl of pporta is
  signal PORTX_Int   : std_logic_vector(portx'range) := (others => '0');
  signal DDRX_Int    : std_logic_vector(ddrx'range)  := (others => '0');
  signal PINX_Resinc : std_logic_vector(pinx'range)  := (others => '0');

  signal PORTX_Sel : std_logic := '0';
  signal DDRX_Sel  : std_logic := '0';
  signal PINX_Sel  : std_logic := '0';

  constant PORTX_Adr : std_logic_vector(IOAdrWidth-1 downto 0) := CONV_STD_LOGIC_VECTOR(16#1B#, IOAdrWidth);
  constant DDRX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0) := CONV_STD_LOGIC_VECTOR(16#1A#, IOAdrWidth);
  constant PINX_Adr  : std_logic_vector(IOAdrWidth-1 downto 0) := CONV_STD_LOGIC_VECTOR(16#19#, IOAdrWidth);

begin

  PORTX_Sel <= '1' when adr = PORTX_Adr else '0';
  DDRX_Sel  <= '1' when adr = DDRX_Adr  else '0';
  PINX_Sel  <= '1' when adr = PINX_Adr  else '0';

  out_en <= (PORTX_Sel or DDRX_Sel or PINX_Sel) and iore;

  PORTX_DFF : process(cp2, ireset)
  begin
    if (ireset = '0') then                      -- Reset
      PORTX_Int   <= (others => '0');
    elsif (cp2 = '1' and cp2'event) then        -- Clock
      if (adr = PORTX_Adr and iowe = '1') then  -- Clock enable
        PORTX_Int <= dbus_in;
      end if;
    end if;
  end process;

  DDRX_DFF : process(cp2, ireset)
  begin
    if (ireset = '0') then                     -- Reset
      DDRX_Int   <= (others => '0');
    elsif (cp2 = '1' and cp2'event) then       -- Clock
      if (adr = DDRX_Adr and iowe = '1') then  -- Clock enable
        DDRX_Int <= dbus_in;
      end if;
    end if;
  end process;

  PINX_DFF : process(cp2, ireset)
  begin
    if (ireset = '0') then                -- Reset
      PINX_Resinc <= (others => '0');
    elsif (cp2 = '1' and cp2'event) then  -- Clock
      PINX_Resinc <= pinx;
    end if;
  end process;

  DBusOutMux : for i in pinx'range generate
    dbus_out(i) <= (PORTX_Int(i) and PORTX_Sel)or(DDRX_Int(i) and DDRX_Sel)or(PINX_Resinc(i) and PINX_Sel);
  end generate;

-- Outputs
  portx <= PORTX_Int;
  ddrx  <= DDRX_Int;   

end rtl;
