--************************************************************************************************
-- This is the bus arbiter for the RAM between pm_fetch_module and mmc
--************************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

use WORK.AVRuCPackage.all;

entity ram_busArbiter is

  port (
    -- Output to the ram
    ram_wr_en       : out std_logic;
    ram_rd_en       : out std_logic;
    ram_addr        : out std_logic_vector(15 downto 0);
    ram_dbusout     : out std_logic_vector(7 downto 0);
    -- Input from the pm_fetch_module for ram
    fet_dec_rd_en   : in  std_logic;
    fet_dec_wr_en   : in  std_logic;
    fet_dec_addr    : in  std_logic_vector(15 downto 0);
    fet_dec_dbusout : in  std_logic_vector(7 downto 0);
    -- Input from the mmc for ram
    mmc_rd_en       : in  std_logic;
    mmc_wr_en       : in  std_logic;
    mmc_addr        : in  std_logic_vector(15 downto 0);
    mmc_dbusout     : in  std_logic_vector(7 downto 0);
    -- Input from mmc for read and write cycles
    mmc_read_cycle  : in  std_logic;
    mmc_write_cycle : in  std_logic;
    -- Input from safe stack
    ss_addr         : in  std_logic_vector(15 downto 0);
    ss_addr_sel     : in  std_logic;
    ss_dbusout      : in  std_logic_vector(7 downto 0);
    ss_dbusout_sel  : in  std_logic
    );
end ram_busArbiter;

architecture Beh of ram_busArbiter is

  signal ram_addr_sel    : std_logic_vector(1 downto 0);
  signal ram_dbusout_sel : std_logic_vector(1 downto 0);

  signal ram_wr_en_sel : std_logic_vector(1 downto 0);
  signal ram_rd_en_sel : std_logic_vector(1 downto 0);

begin
  -- RAM Address Select Logic
  ram_addr_sel(1) <= ss_addr_sel;
  ram_addr_sel(0) <= mmc_read_cycle or mmc_write_cycle;
  ram_addr        <= mmc_addr     when ram_addr_sel = "01"
                     else ss_addr when ram_addr_sel = "10"
                     else fet_dec_addr;

  -- RAM DataBus Out Logic
  ram_dbusout_sel(1) <= ss_dbusout_sel;
  ram_dbusout_sel(0) <= mmc_write_cycle;
  ram_dbusout        <= mmc_dbusout     when ram_dbusout_sel = "01"
                        else ss_dbusout when ram_dbusout_sel = "10"
                        else fet_dec_dbusout;

  -- RAM Write Enable Select Logic
  ram_wr_en_sel(1) <= ss_dbusout_sel;
  ram_wr_en_sel(0) <= mmc_write_cycle or mmc_read_cycle;
  ram_wr_en        <= mmc_wr_en when ram_wr_en_sel = "01"
               else '1'         when ram_wr_en_sel = "10"
               else fet_dec_wr_en;

  -- RAM Read Enable Select Logic
  ram_rd_en_sel(1) <= ss_addr_sel and (not ss_dbusout_sel);
  ram_rd_en_sel(0) <= mmc_read_cycle;
  ram_rd_en        <= mmc_rd_en when ram_rd_en_sel = "01"
               else '1'         when ram_rd_en_sel = "10"
               else fet_dec_rd_en;
end Beh;
