-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Converts a sensor reading to a distance from the sensor in the range
--   0 - 255 which roughly represents 0-80 cm.
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_to_height is
  port (
    sensor  : in  std_logic_vector(22 downto 0);
    height : out std_logic_vector(7 downto 0)
  );
end;

architecture rtl of sensor_to_height is
begin
  -- Distance from sensor 0-255
  -- Effective range around 0-80 cm, above 80 cm => 255
  process(sensor)
  begin
    -- Bits 17 throuh 9 are used, higher values get set to 255
    if unsigned(sensor(22 downto 10)) > 255 then
      height <= std_logic_vector(to_unsigned(255,8));
    else
      height <= sensor(17 downto 10);
    end if;
  end process;
end;