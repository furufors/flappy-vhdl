library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_graphics is
	port (
		clk               : in  std_logic;
		height            : in  std_logic_vector( 7 downto 0);
		random				: in  std_logic_vector( 2 downto 0);
		adress_vga        : out std_logic_vector(16 downto 0);
		data_vga          : out std_logic_vector( 2 downto 0);
		write_VGA         : out std_logic;
		status_sync_write : in  std_logic
	);
end entity;

architecture behavoiour of game_graphics is

	type game_state is (
		init_game_state,
		wait_state,
		draw_state,
		update_obstacle_state
	);
	type bird is
	record
		pos_x : unsigned(8 downto 0);
		pos_y : unsigned(7 downto 0);
	end record;
	
	type obstacle is
	record
		left_x         : unsigned(8 downto 0);
		right_x        : unsigned(8 downto 0);
		upper_bottom_y : unsigned(7 downto 0);
		lower_top_y 	: unsigned(7 downto 0);
	end record;
	
	signal counter_x : unsigned(8 downto 0) := (others => '0');
	signal counter_y : unsigned(7 downto 0) := (others => '0');
	
	type obstacle_list is array (0 to 3) of obstacle;
	signal flappy : bird := (pos_x => to_unsigned(0,9), pos_y => to_unsigned(120,8));
	
	constant empty_obstacle : obstacle := (
		left_x => to_unsigned(0,9),
		right_x => to_unsigned(0,9),
		upper_bottom_y => to_unsigned(0,8),
		lower_top_y => to_unsigned(240,8)
	);
	signal obstacles : obstacle_list := (others => empty_obstacle);
begin
	process(clk)
		variable current_state : game_state := init_game_state;
		variable game_sync_timer : unsigned(31 downto 0) := (others => '0');
		variable frame_counter : unsigned(31 downto 0) := (others => '0');
		variable pixel_color : std_logic_vector(2 downto 0);
	begin
		if rising_edge(clk) then
			game_sync_timer := game_sync_timer + 1;
			
			case current_state is
			when init_game_state =>
				obstacles(0) <= (
					left_x => to_unsigned(120,9),
					right_x => to_unsigned(140,9),
					upper_bottom_y => to_unsigned(100,8),
					lower_top_y => to_unsigned(180,8)
				);
				current_state := wait_state;
				
			when wait_state =>
				-- Synchronizes the frame rate
				write_VGA <= '0';
				if (game_sync_timer < 833333) then
					-- Draw a new frame 60 times per seconds.
					current_state := wait_state;
				else
					game_sync_timer := (others => '0');
					current_state := draw_state;
				end if;
		
			when draw_state =>
				if status_sync_write = '1' then
					write_VGA <= '1'; -- Enable write_VGA (WE on ram)
					
					-- Always keep the write address updated with current position.
					-- Memory adressing is 17 bits, the first 9 represents x-position and the
					-- following 8 the horisontal position.
					adress_vga <= std_logic_vector(counter_x) & std_logic_vector(counter_y);
					
					-- Assume background
					pixel_color := "100";
					
					-- Set to obstacle
					if (
						counter_x > obstacles(0).left_x and
						counter_x < obstacles(0).right_x and
						(
							counter_y < obstacles(0).upper_bottom_y or
							counter_y > obstacles(0).lower_top_y
						)
					) then
						pixel_color := "010";
					end if;
				
					-- Set to bird
					if (counter_y = flappy.pos_y) then
						pixel_color := "111";
					end if;
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
						current_state := update_obstacle_state;
						counter_x <= (others => '0');
						counter_y <= (others => '0');
					end if;
				else
					-- Don't write when status_sync_write = 0
					write_VGA <= '0';
				end if;
				
			when update_obstacle_state =>
				frame_counter := frame_counter + 1;
				write_VGA <= '0';
				current_state := wait_state;
				
				if (frame_counter(1) = '0') then
					-- Every other frame, update position and bounds check
					if (height > std_logic_vector(to_unsigned(120,8)) and
						 flappy.pos_y > to_unsigned(20,8)
						) then
						flappy.pos_y <= flappy.pos_y - 1; -- up
					elsif (height < std_logic_vector(to_unsigned(120,8)) and
						    flappy.pos_y < to_unsigned(220,8)
						) then
						flappy.pos_y <= flappy.pos_y + 1; -- down
					end if;
				end if;
				
			end case;
		end if;
	end process;
end;