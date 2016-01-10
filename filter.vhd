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
	signal i0 : unsigned(19 downto 0) := (others => '0');
	signal i1 : unsigned(19 downto 0) := (others => '0');
	signal i2 : unsigned(19 downto 0) := (others => '0');
	signal i3 : unsigned(19 downto 0) := (others => '0');
	signal iA : unsigned(19 downto 0) := (others => '0');
begin
	iA <= i0 + i1 + i2 + i3;
	-- Output sum of last 4 values / 4
	Output <= std_logic_vector(iA(19 downto 2));
	
	process (step)
	begin
		if rising_edge(step) and step = '1' then
			-- Extend input to 19 bits for 2x carry
			i0 <= unsigned('0' & '0' & Input); 
			i1 <= i0;
			i2 <= i1;
			i3 <= i2;
		end if;
	end process;
end;