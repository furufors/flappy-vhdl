library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sensor_to_height is
	port (
		sensor  : in  std_logic_vector(17 downto 0);
		height : out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of sensor_to_height is
	signal inv_height : std_logic_vector(7 downto 0);
begin
	-- Coerce the sensor value to 20-220
	-- this represents the y_value of the bird
	process(sensor)
	begin
		-- Bits 11 throuh 4 are used, higher values get set to 255
		if unsigned(sensor(17 downto 4)) > 255 then -- 255 << 4
			inv_height <= std_logic_vector(to_unsigned(255,8));
		else
			inv_height <= sensor(11 downto 4);
		end if;
	end process;
	
	-- Invert the inverse signal to correspond to pixels on the screen
	height <= std_logic_vector(255 - unsigned(inv_height));
end;