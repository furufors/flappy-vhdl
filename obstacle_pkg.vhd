-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Provides the data type obstacle and functions for manipulating instances
--   in the context of the game.
--
--   The obstacles live in a translated coordinate system 40 pixels to the
--   right of the display system. This is to allow obstacles to gracefully
--   'exit stage left' without the need for signed values.
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package obstacle_pkg is

  type obstacle is
  record
    left_x         : unsigned(8 downto 0);
    right_x        : unsigned(8 downto 0);
    upper_bottom_y : unsigned(7 downto 0);
    lower_top_y   : unsigned(7 downto 0);
  end record;

  function to_obstacle_x(x : unsigned(8 downto 0)) return unsigned;

  function update_obstacle(o : obstacle; random : std_logic_vector(2 downto 0)) return obstacle;

  function check_pixel(
    o : obstacle;
    x : unsigned(8 downto 0);
    y : unsigned(7 downto 0);
    col : std_logic_vector(2 downto 0)
  ) return std_logic_vector;

  constant empty_obstacle : obstacle := (
    left_x => to_unsigned(0,9),
    right_x => to_unsigned(0,9),
    upper_bottom_y => to_unsigned(0,8),
    lower_top_y => to_unsigned(240,8)
  );
  constant obstacle_init_0 : obstacle := (
    left_x => to_unsigned(40,9),
    right_x => to_unsigned(40,9),
    upper_bottom_y => to_unsigned(0,8),
    lower_top_y => to_unsigned(240,8)
  );
  constant obstacle_init_1 : obstacle := (
    left_x => to_unsigned(120,9),
    right_x => to_unsigned(120,9),
    upper_bottom_y => to_unsigned(0,8),
    lower_top_y => to_unsigned(240,8)
  );
  constant obstacle_init_2 : obstacle := (
    left_x => to_unsigned(200,9),
    right_x => to_unsigned(200,9),
    upper_bottom_y => to_unsigned(0,8),
    lower_top_y => to_unsigned(240,8)
  );
  constant obstacle_init_3 : obstacle := (
    left_x => to_unsigned(280,9),
    right_x => to_unsigned(280,9),
    upper_bottom_y => to_unsigned(0,8),
    lower_top_y => to_unsigned(240,8)
  );
end;

package body obstacle_pkg is
  -- Function to convert from screen coordinates to obstacles internal
  -- representation
  function to_obstacle_x(x : unsigned(8 downto 0)) return unsigned is
  begin
    return x + to_unsigned(40,9);
  end;

  -- Checks if a pixel is within the given obstacle
  function check_pixel(
    o : obstacle;
    x : unsigned(8 downto 0);
    y : unsigned(7 downto 0);
    col : std_logic_vector(2 downto 0)
  ) return std_logic_vector is
  begin
    if ( -- Within bounds
      to_obstacle_x(x) > o.left_x and
      to_obstacle_x(x) < o.right_x and
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

  -- Updates obstacles and replaces obstacles that has left the left border
  -- with a new to the right of the screen.
  function update_obstacle(o : obstacle; random : std_logic_vector(2 downto 0)) return obstacle is
    variable temp : obstacle; -- The updated obstacle
  begin
    if (o.right_x > to_obstacle_x(to_unsigned(0,9))) then
      -- Normal step
      temp.left_x := o.left_x - 1;
      temp.right_x := o.right_x - 1;
      temp.upper_bottom_y := o.upper_bottom_y;
      temp.lower_top_y := o.lower_top_y;
    else
      -- Regenerate object at the right side of screen
      temp.left_x  := to_unsigned(360,9);
      temp.right_x := to_unsigned(380,9);

      -- Assign height depending on random
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
		when others =>
		  temp.upper_bottom_y := to_unsigned(80, 8);
        temp.lower_top_y    := to_unsigned(160,8);
      end case;
    end if;
    return temp;
  end update_obstacle;
end package body;