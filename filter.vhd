library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
	port (
		Step   : in  std_logic;
		Input  : in  std_logic_vector(17 downto 0);
		Output : out std_logic_vector(17 downto 0)
	);
end;

architecture rtl of filter is
	signal i0 : std_logic_vector(19 downto 0) := (others => '0');
	signal i1 : std_logic_vector(19 downto 0) := (others => '0');
	signal i2 : std_logic_vector(19 downto 0) := (others => '0');
	signal i3 : std_logic_vector(19 downto 0) := (others => '0');
	signal iA : std_logic_vector(19 downto 0) := (others => '0');
begin
	iA <= std_logic_vector(
			unsigned(i0) + 
			unsigned(i1) + 
			unsigned(i2) + 
			unsigned(i3)
		);
	-- Output sum of last 4 values / 4
	Output <= iA(19 downto 2);
	
	process (step)
	begin
		if rising_edge(step) and step = '1' then
			-- Extend input to 19 bits for 2x carry
			i0 <= '0' & '0' & Input; 
			i1 <= i0;
			i2 <= i1;
			i3 <= i2;
		end if;
	end process;
end;