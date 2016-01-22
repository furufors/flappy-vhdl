library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package obstacle_pkg is
	
	type obstacle is
	record
		left_x         : unsigned(8 downto 0);
		right_x        : unsigned(8 downto 0);
		upper_bottom_y : unsigned(7 downto 0);
		lower_top_y 	: unsigned(7 downto 0);
	end record;
	
	function to_disp_x(x : unsigned(8 downto 0)) return unsigned;
	function update_obstacle(o : obstacle; random : std_logic_vector(2 downto 0)) return obstacle;
	function check_pixel(
		o : obstacle;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic_vector;
end;

package body obstacle_pkg is 
	-- Function to convert from obstacles internal representation to screen coordinate
	function to_disp_x(x : unsigned(8 downto 0)) return unsigned is
	begin
		return x - to_unsigned(40,9);
	end to_disp_x;
	
	function check_pixel(
		o : obstacle;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic_vector is
	begin
		if (
			x > to_disp_x(o.left_x) and
			x < to_disp_x(o.right_x) and
			(
				y < o.upper_bottom_y or
				y > o.lower_top_y
			)
		) then
			return "010"; -- Obstacle color
		else
			return col; -- no color change
		end if;
	end;
	
	function update_obstacle(o : obstacle; random : std_logic_vector(2 downto 0)) return obstacle is
		variable temp : obstacle; -- The updated obstacle
	begin
		if (o.right_x > 40) then
			-- Normal step
			temp.left_x := o.left_x - 1;
			temp.right_x := o.right_x - 1;
			temp.upper_bottom_y := o.upper_bottom_y;
			temp.lower_top_y := o.lower_top_y;
		else
			-- Regenerate object at the right side of screen
			temp.left_x  := to_unsigned(360,9);
			temp.right_x := to_unsigned(380,9);
			-- Random height
			case random is
			when "000" =>
				temp.upper_bottom_y := to_unsigned(20, 8);
				temp.lower_top_y    := to_unsigned(100,8);
			when "001" =>
				temp.upper_bottom_y := to_unsigned(40, 8);
				temp.lower_top_y    := to_unsigned(120,8);
			when "010" =>
				temp.upper_bottom_y := to_unsigned(60, 8);
				temp.lower_top_y    := to_unsigned(140,8);
			when "011" =>
				temp.upper_bottom_y := to_unsigned(80, 8);
				temp.lower_top_y    := to_unsigned(160,8);
			when "100" =>
				temp.upper_bottom_y := to_unsigned(80, 8);
				temp.lower_top_y    := to_unsigned(160,8);
			when "101" =>
				temp.upper_bottom_y := to_unsigned(100,8);
				temp.lower_top_y    := to_unsigned(180,8);
			when "110" =>
				temp.upper_bottom_y := to_unsigned(120,8);
				temp.lower_top_y    := to_unsigned(200,8);
			when "111" =>
				temp.upper_bottom_y := to_unsigned(140,8);
				temp.lower_top_y    := to_unsigned(220,8);
			end case;
		end if;
		return temp;
	end update_obstacle;
end package body;