-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: test_filter
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Tests that 0-signals don't affect the output
--   Expected result should be 25,50,75,100,100...
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_filter_2 is
end test_filter_2;
architecture rtl of test_filter_2 is
  signal step   : in  std_logic;
  signal input  : in  std_logic_vector(22 downto 0);
  signal output : out std_logic_vector(22 downto 0);
  constant step_pulse : time := 20 ns;
begin
  i1 : entity work.filter
 port map (
    step;
    input;
    output
  );
init : process
begin
  input <= to_unsigned(100,23);
  step <= '0';
  wait for step_pulse;
  step <= '1';
  wait for step_pulse;
  step <= '0';
  input <= to_unsigned(0,23);
  step <= '0';
  wait for step_pulse;
  step <= '1';
  wait for step_pulse;
  step <= '0';
end process init;
end rtl;
