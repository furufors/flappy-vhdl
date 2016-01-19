library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bird_inertia is
	port (
		height          : in  std_logic_vector(7 downto 0);
		step            : in  std_logic;
		inertial_height : out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of bird_inertia is
begin
	process (step)
		variable position : unsigned(7 downto 0) := (others => '0');
	begin
		if rising_edge(step) and step = '1' then
		
			-- Change position depending on height signal
			if (unsigned(height) > position) then
				position := position + 1;
			elsif (unsigned(height) < position) then
				position := position - 1;
			end if;
			
			-- Change another step if the difference is bigger than 20 px
			if (unsigned(height) > position + 20) then
				position := position + 1;
			elsif (unsigned(height) < position - 20) then
				position := position - 1;
			end if;
			
			-- Change another step if the difference is bigger than 40 px
			if (unsigned(height) > position + 40) then
				position := position + 2;
			elsif (unsigned(height) < position - 40) then
				position := position - 2;
			end if;

			-- Coerce position
			if unsigned(position) > 220 then
				position := to_unsigned(220,8);
			elsif unsigned(position) < 20 then
				position := to_unsigned(20,8);
			end if;
			inertial_height <= std_logic_vector(position);
		end if;
	end process;
end;