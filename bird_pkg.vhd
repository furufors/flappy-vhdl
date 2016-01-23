-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Provides the data type bird and functions for manipulating instances in
--   the context of the game.
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

  -- A bird type in the starting position:
  constant bird_init : bird := (
    pos_x => to_unsigned(10,9),
    pos_y => to_unsigned(120,8)
  );

  -- The upper border of the game:
  constant upper_limit : unsigned(7 downto 0) := to_unsigned( 20,8);
  -- The lower border of the game:
  constant lower_limit : unsigned(7 downto 0) := to_unsigned(220,8);
  -- The sensor distance to determine bird direction:
  constant threshold_height : unsigned(7 downto 0) := to_unsigned(100,8);
end;

package body bird_pkg is

  -- Determine if the given pixel is within the bird, if so update the color
  -- with the bird color
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

  -- Determine if the bird has hit an pixel with the obstacle color,
  -- the value 1 signals a hit
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

  -- Updates a bird with a new vertical position depending on the sensor height
  function update_bird(
    b : bird;
    h : std_logic_vector(7 downto 0)
  ) return bird is
    variable temp : bird;
  begin
    temp.pos_x := b.pos_x;
    -- If the hand distance (h) is within threshold of the sensor move up, else
    -- move down. Respects borders.
    if (unsigned(h) < threshold_height and b.pos_y > upper_limit) then
      temp.pos_y := b.pos_y - 1; -- up
    elsif (b.pos_y < lower_limit) then
      temp.pos_y := b.pos_y + 1; -- down
	 else
		temp.pos_y := b.pos_y;
    end if;
    return temp;
  end;

  -- Helper function to determine if a pixel is within the bird
  function within_bird(
    b : bird;
    x : unsigned(8 downto 0);
    y : unsigned(7 downto 0)
  ) return std_logic is
  begin
    -- The bird has the shape of
    --  xxx
    -- xxxxx
    -- xxxxx
    -- xxxxx
    --  xxx
    if (
        ((y >= b.pos_y - 2 and y <= b.pos_y + 2) and
        (x >= b.pos_x - 1 and x <= b.pos_x + 1))
        or
        ((y >= b.pos_y - 1 and y <= b.pos_y + 1) and
        (x >= b.pos_x - 2 and x <= b.pos_x + 2))
       ) then
    -- This feels redundant...
      return '1';
    else
      return '0';
    end if;
  end;

end package body;