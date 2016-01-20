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
		if unsigned(sensor(11 downto 4)) > 220 then
			inv_height <= std_logic_vector(to_unsigned(220,8));
		elsif unsigned(sensor(11 downto 4)) < 20 then
			inv_height <= std_logic_vector(to_unsigned(20,8));
		else
			inv_height <= sensor(11 downto 4);
		end if;
--		case to_unsigned(sensor(17 downto 10), 8) is
--			when to_unsigned(220,8) to to_unsigned(255,8) =>
--				height <= std_logic_vector(220);
--			when to_unsigned(0,8) to to_unsigned(20,8) =>
--				height <= std_logic_vector(20);
--			when others =>
--				height <= sensor(17 downto 10);
--		end case;
	end process;
	
	-- Invert the inverse signal to correspond to pixels on the screen
	height <= std_logic_vector(240 - unsigned(inv_height));
end;