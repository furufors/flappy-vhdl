-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Game logic, most functionality has been abstracted to the packages:
--     - obstacke_pkg
--     - bird_pkg
--   This is done with the intention of keeping the game logic a bit more
--   high-level and managable.
--
--   State machine that executes at 60 frames per second. Init states resets
--   the game variables. Wait state synchronizes the frames. Draw state draws
--   the visual representation of the game by polling all objects. Update
--   state updates obstacles and bird with a step. End state provides a white
---  infinite background until an reset occurs.
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.obstacle_pkg.all;
use work.bird_pkg.all;

entity game_graphics is
  port (
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    height            : in  std_logic_vector( 7 downto 0);
    random            : in  std_logic_vector( 2 downto 0);
    adress_vga        : out std_logic_vector(16 downto 0);
    data_vga          : out std_logic_vector( 2 downto 0);
    write_vga         : out std_logic;
    status_sync_write : in  std_logic;
    score_out         : out std_logic_vector(31 downto 0)
  );
end entity;

architecture behavoiour of game_graphics is

  type game_state is (
    init_game_state,
    wait_state,
    draw_state,
    update_objects_state,
    end_game_state
  );

  -- Counters for adressing the VGA memory
  signal counter_x : unsigned(8 downto 0) := (others => '0');
  signal counter_y : unsigned(7 downto 0) := (others => '0');

  type obstacle_list is array (0 to 3) of obstacle;
  signal flappy : bird := bird_init;
  signal obstacles : obstacle_list := (others => empty_obstacle);
begin

  process(clk)
    variable current_state : game_state := init_game_state;
    variable game_sync_timer : unsigned(31 downto 0) := (others => '0');
    variable frame_counter : unsigned(31 downto 0) := (others => '0');
    variable pixel_color : std_logic_vector(2 downto 0);
  begin
    -- Score in seconds, 60 Hz
    score_out <= std_logic_vector(frame_counter / 60);

    if rising_edge(clk) then
      if (reset_n = '0') then
        -- Reset game to initial state
        current_state := init_game_state;
      else
        -- Increment the game timer
        game_sync_timer := game_sync_timer + 1;

        -- Finite state machine to handle program flow
        case current_state is
        when init_game_state =>
          flappy <= bird_init;
          -- Initiate infinite thin obstacles
          -- will be given correct width at first update
          obstacles(0) <= obstacle_init_0;
          obstacles(1) <= obstacle_init_1;
          obstacles(2) <= obstacle_init_2;
          obstacles(3) <= obstacle_init_3;
          frame_counter := (others => '0');
          game_sync_timer := (others => '0');
          counter_x <= (others => '0');
          counter_y <= (others => '0');
          current_state := wait_state;

        when wait_state =>
          -- Synchronizes the frame rate
          write_vga <= '0';
          if (game_sync_timer < 833333) then
            -- Draw a new frame 60 times per seconds.
            current_state := wait_state;
          else
            game_sync_timer := (others => '0');
            current_state := draw_state;
          end if;

        when draw_state =>
          if status_sync_write = '1' then
            write_vga <= '1'; -- Enable write_vga (WE on ram)

            -- Always keep the write address updated with current position.
            -- Memory adressing is 17 bits, the first 9 represents x-position
            -- and the following 8 the horisontal position.
            adress_vga <= std_logic_vector(counter_x) & std_logic_vector(counter_y);

            -- Assume background
            pixel_color := "100"; -- Background color

            -- Check if given pixel is within an obstacle
            pixel_color := check_pixel(obstacles(0), counter_x, counter_y, pixel_color);
            pixel_color := check_pixel(obstacles(1), counter_x, counter_y, pixel_color);
            pixel_color := check_pixel(obstacles(2), counter_x, counter_y, pixel_color);
            pixel_color := check_pixel(obstacles(3), counter_x, counter_y, pixel_color);

            -- Check if bird crashes into object using the color
            if (check_hit(flappy, counter_x, counter_y, pixel_color) = '1') then
              current_state := end_game_state;
            end if;
            -- Update color if within bird
            pixel_color := check_pixel(flappy, counter_x, counter_y, pixel_color);
            data_vga <= pixel_color;

            -- Counter incrementation, x-first then y
            -- restart on x:320 y:240 (post-incremented!)
            if (counter_x < 320) then
              counter_x <= counter_x + 1;
              counter_y <= counter_y;
            elsif (counter_x = 320 and counter_y < 240) then
              counter_x <= (others => '0');
              counter_y <= counter_y + 1;
            else
              current_state := update_objects_state;
              counter_x <= (others => '0');
              counter_y <= (others => '0');
            end if;
          else
            -- Don't write when status_sync_write = 0
            write_vga <= '0';
          end if;

        when update_objects_state =>
          frame_counter := frame_counter + 1;
          write_vga <= '0';
          current_state := wait_state;

          -- Update the birds position
          ---- Every other frame, update position and bounds check
          flappy <= update_bird(flappy, height);

          -- Update the obstacles
          if (frame_counter(1) = '0') then
            obstacles(0) <= update_obstacle(obstacles(0), random);
            obstacles(1) <= update_obstacle(obstacles(1), random);
            obstacles(2) <= update_obstacle(obstacles(2), random);
            obstacles(3) <= update_obstacle(obstacles(3), random);
          end if;

        when end_game_state =>
          if status_sync_write = '1' then
            write_vga <= '1'; -- Enable write_vga (WE on ram)

            -- Always keep the write address updated with current position.
            -- Memory adressing is 17 bits, the first 9 represents x-position and the
            -- following 8 the horisontal position.
            adress_vga <= std_logic_vector(counter_x) & std_logic_vector(counter_y);
            data_vga <= "111";

            -- Counter incrementation, x-first then y
            -- restart on x:320 y:240 (post-incremented!)
            if (counter_x < 320) then
              counter_x <= counter_x + 1;
              counter_y <= counter_y;
            elsif (counter_x = 320 and counter_y < 240) then
              counter_x <= (others => '0');
              counter_y <= counter_y + 1;
            else
              current_state := end_game_state;
              counter_x <= (others => '0');
              counter_y <= (others => '0');
            end if;
          end if;
        end case;
      end if;
    end if;
  end process;
end;