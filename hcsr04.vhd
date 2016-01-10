library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hcsr04 is
	port (
		Clk        : in  std_logic;
		Echo       : in  std_logic;
		Trig       : out std_logic;
		Done       : out std_logic;
		PulseWidth : out std_logic_vector(17 downto 0)
	);
end;

architecture rtl of hcsr04 is
	constant MaxPeriod  : unsigned(22 downto 0) := "01001100010010110100000"; -- 50 ms
	constant NoObstacle : unsigned(22 downto 0) := "00111001111110111100000"; -- 38 ms
begin
	process(Clk)
		variable PeriodCounter : unsigned(22 downto 0) := (others => '0');
		variable WidthCounter  : unsigned(22 downto 0) := (others => '0');
	begin
		if rising_edge(Clk) and Clk = '1' then
			-- Increment counter
			PeriodCounter := PeriodCounter + 1;

			-- Pulse the trigger for 24 µs
			if PeriodCounter < 120 then
				Trig <= '1';
			else
				Trig <= '0';
			end if;

			if Echo = '1' and PeriodCounter < NoObstacle then
				-- Count within interval
				WidthCounter := WidthCounter + 1;
			end if;

			if PeriodCounter = (MaxPeriod - 1) then -- 50 ms
				-- Set output based on pulse width
				PulseWidth <= std_logic_vector(WidthCounter(22 downto 5));
				-- Signal that a measurement is completed
				Done <= '1';
			elsif PeriodCounter = MaxPeriod then
				-- Reset counters
				PeriodCounter := (others => '0');
				WidthCounter  := (others => '0');
				Done <= '0';
			else
				Done <= '0';
			end if;
		end if;
	end process;
end;