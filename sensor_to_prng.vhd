-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Uses the LSB of the sensor reading which is a good source of noise for
--   the random number.
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_to_prng is
  port (
    sensor  : in  std_logic_vector(22 downto 0);
    random  : out std_logic_vector(2 downto 0)
  );
end;

architecture rtl of sensor_to_prng is
begin
  -- LSB:s will be noise, it can be used for generation of
  -- non-deterministic pseudo random numbers.
  random <= sensor(2 downto 0);
end;