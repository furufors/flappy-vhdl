library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_to_height is
	port (
		sensor  : in  std_logic_vector(17 downto 0);
		height : out std_logic_vector(8 downto 0)
	);
end;

architecture rtl of sensor_to_height is
begin
	-- Coerce the sensor value to 20-220
	-- this represents the y_value of the bird
	case unsigned(sensor(17 downto 10)) is
		when 220 to 255 =>
			height <= std_logic_vector(220);
		when 0 to 20 =>
			height <= std_logic_vector(20);
		when others =>
			height <= sensor(17 downto 10);
	end case;
end;