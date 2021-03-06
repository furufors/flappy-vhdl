-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: test_filter
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Tests that the filter changes value when step is applied.
--   Expected output is 0, 25, 50, 75, 100, 100 ...
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_filter is
end test_filter;
architecture rtl of test_filter is
  signal step   : std_logic;
  signal input  : std_logic_vector(22 downto 0);
  signal output : std_logic_vector(22 downto 0);
  constant step_pulse : time := 20 ns;
begin
  i1 : entity work.filter
 port map (
    step,
    input,
    output
  );
init : process
begin
  input <= std_logic_vector(to_unsigned(100,23));
  step <= '0';
  wait for step_pulse;
  step <= '1';
  wait for step_pulse;
  step <= '0';
end process init;
end rtl;
