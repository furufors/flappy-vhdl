library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_to_prng is
	port (
		sensor  : in  std_logic_vector(17 downto 0);
		random  : out std_logic_vector(2 downto 0)
	);
end;

architecture rtl of sensor_to_prng is
begin
	-- LSB:s will be noise, it can be used for generation of
	-- non-deterministic pseudo random numbers.
	random <= sensor(6 downto 4);
end;