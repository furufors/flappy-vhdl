library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package bird_pkg is
	
	type bird is
	record
		pos_x : unsigned(8 downto 0);
		pos_y : unsigned(7 downto 0);
	end record;

	function check_pixel(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic_vector;
	
	function update_bird(b : bird; h : std_logic_vector(7 downto 0)) return bird;
	
	function within_bird(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0)
	) return std_logic;
	
	function check_hit(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic;
end;

package body bird_pkg is 	
	function check_pixel(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic_vector is
	begin
		if (within_bird(b,x,y) = '1') then
			return "001"; -- Bird color
		else
			return col;
		end if;
	end;
	
	function check_hit(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0);
		col : std_logic_vector(2 downto 0)
	) return std_logic is
	begin
		if (within_bird(b,x,y) = '1' and col = "010") then
			return '1';
		else
			return '0';
		end if;
	end;
	
	function update_bird(b : bird; h : std_logic_vector(7 downto 0)) return bird is
		variable temp : bird;
	begin
		temp.pos_x := b.pos_x;
		if (unsigned(h) > b.pos_y and
			 b.pos_y < to_unsigned(220,8)
			) then
			temp.pos_y := b.pos_y + 1; -- down
		elsif (b.pos_y > to_unsigned(20,8)
			) then
			temp.pos_y := b.pos_y - 1; -- up
		end if;
		return temp;
	end;
	
	function within_bird(
		b : bird;
		x : unsigned(8 downto 0);
		y : unsigned(7 downto 0)
	) return std_logic is
	begin
		if (
			(
				y = b.pos_y or
				y = b.pos_y + 1 or
				y = b.pos_y - 1
			) and (
				x = b.pos_x or
				x = b.pos_x + 1 or
				x = b.pos_x - 1
			)
		) then
		-- Insanely redundant...
			return '1';
		else
			return '0';
		end if;
	end;
	
end package body;