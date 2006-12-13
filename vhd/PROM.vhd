-------------------------------------------------------------------------------
-- Data port A is used for data out
-- Data port B is used for data in
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity PROM is
  port (
    addressDO : in  std_logic_vector (15 downto 0);  --address for data out
    addressDI : in  std_logic_vector (15 downto 0);  --address for data in
    clock     : in  std_logic;                       --clock signal
    dataIn    : in  std_logic_vector (15 downto 0);  --port for data in
    wrEn      : in  std_logic;                       --port for write enable
    dataOut   : out std_logic_vector (15 downto 0)   --port for data out
    );
end PROM;

architecture Beh of PROM is

  signal sgDataOut : std_logic_vector(255 downto 0);
  signal sgWrEn    : std_logic_vector(15 downto 0);
  signal ssr       : std_logic;
  signal sgClockA : std_logic;

begin  -- Beh

  sgClockA <= not clock ;

  --Logic to configure the individual write enables for the different RAM blocks

  sgWrEn(0)  <= not addressDI(15) and not addressDI(14) and not addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(1)  <= not addressDI(15) and not addressDI(14) and not addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(2)  <= not addressDI(15) and not addressDI(14) and addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(3)  <= not addressDI(15) and not addressDI(14) and addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(4)  <= not addressDI(15) and addressDI(14) and not addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(5)  <= not addressDI(15) and addressDI(14) and not addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(6)  <= not addressDI(15) and addressDI(14) and addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(7)  <= not addressDI(15) and addressDI(14) and addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(8)  <= addressDI(15) and not addressDI(14) and not addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(9)  <= addressDI(15) and not addressDI(14) and not addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(10) <= addressDI(15) and not addressDI(14) and addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(11) <= addressDI(15) and not addressDI(14) and addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(12) <= addressDI(15) and addressDI(14) and not addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(13) <= addressDI(15) and addressDI(14) and not addressDI(13) and addressDI(12) and wrEn;
  sgWrEn(14) <= addressDI(15) and addressDI(14) and addressDI(13) and not addressDI(12) and wrEn;
  sgWrEn(15) <= addressDI(15) and addressDI(14) and addressDI(13) and addressDI(12) and wrEn;

  process (sgDataOut, addressDO)
  begin  -- Process begins on change in address out port or data out signal
--Logic to configure which data out signal gets maped to the to the actaul data
--out
    if (addressDO(15 downto 12) = "0000") then
      dataOut <= sgDataOut(15 downto 0);
    elsif (addressDO(15 downto 12) = "0001") then
      dataOut <= sgDataOut(31 downto 16);
    elsif (addressDO(15 downto 12) = "0010") then
      dataOut <= sgDataOut(47 downto 32);
    elsif (addressDO(15 downto 12) = "0011") then
      dataOut <= sgDataOut(63 downto 48);
    elsif (addressDO(15 downto 12) = "0100") then
      dataOut <= sgDataOut(79 downto 64);
    elsif (addressDO(15 downto 12) = "0101") then
      dataOut <= sgDataOut(95 downto 80);
    elsif (addressDO(15 downto 12) = "0110") then
      dataOut <= sgDataOut(111 downto 96);
    elsif (addressDO(15 downto 12) = "0111") then
      dataOut <= sgDataOut(127 downto 112);
    elsif (addressDO(15 downto 12) = "1000") then
      dataOut <= sgDataOut(143 downto 128);
    elsif (addressDO(15 downto 12) = "1001") then
      dataOut <= sgDataOut(159 downto 144);
    elsif (addressDO(15 downto 12) = "1010") then
      dataOut <= sgDataOut(175 downto 160);
    elsif (addressDO(15 downto 12) = "1011") then
      dataOut <= sgDataOut(191 downto 176);
    elsif (addressDO(15 downto 12) = "1100") then
      dataOut <= sgDataOut(207 downto 192);
    elsif (addressDO(15 downto 12) = "1101") then
      dataOut <= sgDataOut(223 downto 208);
    elsif (addressDO(15 downto 12) = "1110") then
      dataOut <= sgDataOut(239 downto 224);
    elsif (addressDO(15 downto 12) = "1111") then
      dataOut <= sgDataOut(255 downto 240);
    end if;
  end process;

  --Generate 64 blocks of memory
  generateMemory : for index in 0 to 63 generate
  begin

    -- RAMB16_S4_S4: Virtex-II/II-Pro, Spartan-3/3E 4k x 4 Dual-Port RAM
    -- Xilinx  HDL Language Template version 8.1i

    RAMB16_S4_S4_inst : RAMB16_S4_S4
      generic map (
        INIT_A              => X"0",    --  Value of output RAM registers on Port A at startup
        INIT_B              => X"0",    --  Value of output RAM registers on Port B at startup
        SRVAL_A             => X"0",    --  Port A ouput value upon SSR assertion
        SRVAL_B             => X"0",    --  Port B ouput value upon SSR assertion
        WRITE_MODE_A        => "WRITE_FIRST",  --  WRITE_FIRST, READ_FIRST or NO_CHANGE
        WRITE_MODE_B        => "WRITE_FIRST",  --  WRITE_FIRST, READ_FIRST or NO_CHANGE
        SIM_COLLISION_CHECK => "NONE",  -- "NONE", "WARNING", "GENERATE_X_ONLY", "ALL
        -- The following INIT_xx declarations specify the initial contents of the RAM
        -- Address 0 to 1023
        INIT_00             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_01             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_02             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_03             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_04             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_05             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_06             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_07             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_08             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_09             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0A             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0B             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0C             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0D             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0E             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_0F             => X"0000000000000000000000000000000000000000000000000000000000000000",
        -- Address 1024 to 2047
        INIT_10             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_11             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_12             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_13             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_14             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_15             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_16             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_17             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_18             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_19             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1A             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1B             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1C             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1D             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1E             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_1F             => X"0000000000000000000000000000000000000000000000000000000000000000",
        -- Address 2048 to 3071
        INIT_20             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_21             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_22             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_23             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_24             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_25             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_26             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_27             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_28             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_29             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2A             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2B             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2C             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2D             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2E             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_2F             => X"0000000000000000000000000000000000000000000000000000000000000000",
        -- Address 3072 to 4095
        INIT_30             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_31             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_32             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_33             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_34             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_35             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_36             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_37             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_38             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_39             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3A             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3B             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3C             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3D             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3E             => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_3F             => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map (
        DOA                 => sgDataOut((index * 4 + 3) downto (index * 4)),  -- 4-bit Data Output
        DOB                 => open,    -- Data out of port B is not used
        ADDRA               => addressDO(11 downto 0),  -- Port A 12-bit Address Input
        ADDRB               => addressDI(11 downto 0),  -- Port B 12-bit Address Input
        CLKA                => sgClockA,   -- Port A Clock
        CLKB                => clock,   -- Port B Clock
        DIA                 => "0000",  -- Port A is not used for writing
        DIB                 => dataIn( (((index mod 4) * 4) + 3) downto ((index mod 4) * 4) ),  -- 4-bit Data Input
        ENA                 => '1',     -- Port A RAM Enable Input
        ENB                 => '1',     -- Port B RAM Enable Input
        SSRA                => SSR,     -- Port A Synchronous Set/Reset Input
        SSRB                => SSR,     -- Port B Synchronous Set/Reset Input
        WEA                 => '0',     -- Port A is not used for Writing
        WEB                 => sgWrEn(index / 4)  -- Port B Write Enable Input
        );

    -- End of RAMB16_S4_S4_inst instantiation

  end generate generateMemory;

end Beh;
