library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_graphics is
	port (
		clk          : in  std_logic;
		bird_height       : in  std_logic_vector(7 downto 0);
		adress_vga        : out std_logic_vector(16 downto 0);
		data_vga          : out std_logic_vector(2 downto 0);
		write_VGA         : out std_logic;
		status_sync_write : in  std_logic
	);
end entity;

architecture behavoiour of game_graphics is
	signal counter_x : unsigned(8 downto 0) := (others => '0');
	signal counter_y : unsigned(7 downto 0)  := (others => '0');
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if status_sync_write = '1' then
				write_VGA <= '1'; -- Enable write_VGA (WE on ram)
				
				-- Always keep the write address updated with current position.
				-- Memory adressing is 17 bits, the first 9 represents x-position and the
				-- following 8 the horisontal position.
				adress_vga <= std_logic_vector(counter_x) & std_logic_vector(counter_y);
				
				if (std_logic_vector(240 - counter_y) = bird_height) then
					data_vga <= "111";
				else
					data_vga <= "000";
				end if;
				
				-- Counter incrementation, x-first then y
				-- restart on x:320 y:240 (post-incremented!)
				if (counter_x < 320) then
					counter_x <= counter_x + 1;
					counter_y <= counter_y;
				elsif (counter_x = 320 and counter_y < 240) then
					counter_x <= (others => '0');
					counter_y <= counter_y + 1;						
				else
					counter_x <= (others => '0');
					counter_y <= (others => '0');
				end if;
			else
				-- Don't write when status_sync_write = 0
				write_VGA <= '0';
			end if;
		end if;
	end process;
end;