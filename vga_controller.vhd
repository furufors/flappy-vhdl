-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2015 nov 8
-- Design Name: vhdl_uppgift_9
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
-- Implements a basic VGA-controller for 640x480 px output with
--  - Timing, PLL-clock and synchronisation
--  - Dual port ram memory with peripheral access

-- Driver for the VGA-communication
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_controller is
	port(
		reset_n, CLOCK_50, clk_pll : in std_logic;
		VGA_HS, VGA_VS, VGA_CLK : out std_logic;
		VGA_BLANK_N, VGA_SYNC_N : buffer std_logic;
		VGA_B, VGA_G, VGA_R : out std_logic_vector(7 downto 0);
		VGA_ADDRESS_r : out std_logic_vector(16 downto 0);
		VGA_DATA_r : in std_logic_vector(2 downto 0);
		allow_write : out std_logic
	);
end vga_controller;

architecture vga_controller_rtl of vga_controller is
	type position_type is
	record
		h : unsigned(9 downto 0);
		v : unsigned(9 downto 0);
	end record;
	
	signal counter_int : position_type := (H => (others =>'0'), V => (others =>'0'));
	signal clk_25mhz : std_logic := '0';
	
	constant color_upper_limit_const : integer := 200; -- Color ~1/3 of the screen
	constant counter_h_upper_const : integer := 799; -- Upper counter bound
	constant counter_v_upper_const : integer := 524; -- Upper counter bound
	constant v_sync_inc_const : integer := 706; -- Increment v when h is at (value + 1)
	constant h_sync_low_const : integer := 660; -- Start of pulse
	constant h_sync_high_const : integer := 755; -- End of pulse
	constant v_sync_const : integer := 494; -- Pulse for 1 period
	constant display_upper_h_limit_const : integer := 639; -- 0-639 = 640 columns
	constant display_upper_v_limit_const : integer := 479; -- 0-479 = 480 rows
	
begin
	
	allow_write <= not VGA_BLANK_N or not VGA_SYNC_N;
	
	vga_CLK <= clk_pll;
	VGA_ADDRESS_r <= std_logic_vector(counter_int.h(9 downto 1))
		& std_logic_vector(counter_int.v(8 downto 1));
	
	
	process_counters : process (clk_pll, reset_n)
	-- Increment and keep counters for horisonal and vertical position within bounds
	begin
		if rising_edge(clk_pll) then
			if reset_n = '0' then
				-- Asynchronous reset
				counter_int.H <= (others => '0');
				counter_int.V <= (others => '0');
			else 
				-- Increment counters and keep within bounds
				if counter_int.h = counter_h_upper_const then
					counter_int.h <= (others => '0');
				else
					counter_int.h <= counter_int.h + 1;
				end if;
				
				-- Increment at v_sync_inc_const
				if (counter_int.v = counter_v_upper_const 
					and counter_int.h = v_sync_inc_const) then
					counter_int.v <= (others => '0');
				elsif counter_int.h = v_sync_inc_const then
					counter_int.v <= counter_int.v + 1;
				end if;
			end if;
		end if;
	end process process_counters;
		
	process_sync_screen : process(counter_int)
	-- Signals to implement the synchronisation of the VGA-controller
	begin
		-- Horizontal synchronisation
		if (counter_int.h >= h_sync_low_const
			and counter_int.h <= h_sync_high_const) then
			VGA_HS <= '0';
		else 
			VGA_HS <= '1';
		end if;
		
		-- Vertical synchronisation
		if (counter_int.v = v_sync_const) then
			VGA_VS <= '0';
		else 
			VGA_VS <= '1';
		end if;
		
		-- Blanking when counters are outside the display area
		if (counter_int.h > display_upper_h_limit_const) then
			VGA_BLANK_N <= '0';
		else
			VGA_BLANK_N <= '1';
		end if;
		
		-- Blanking when vertical counter outside the upper limit 
		if (COUNTER_int.V > display_upper_v_limit_const) then
			VGA_SYNC_N <= '0';
		else
			VGA_SYNC_N <= '1';
		end if;
	end process process_sync_screen;

	process_screen_colors : process (clk_pll)
	-- Draws a horisontal segment with a color corresponding to the pressed buttons
	-- Example: Pressing key 0 and 1 would yield a yellow colored segment
	begin
		if rising_edge(clk_pll) then
			if reset_n = '0' then
				-- black screen on reset
				VGA_R <= (others => '0');
				VGA_G <= (others => '0');
				VGA_B <= (others => '0');
			else
				-- Update output from VGA-memory
				case VGA_DATA_r is
				when "100" =>
					-- Background: Medium turqouise
					VGA_R <= "01001000"; -- 72
					VGA_G <= "11010001"; -- 209
					VGA_B <= "11001100"; -- 204
				when "010" =>
					-- Pipes: Forest green
					VGA_R <= "00100010"; -- 34
					VGA_G <= "10001011"; -- 139
					VGA_B <= "00100010"; -- 34
				when "001" =>
					-- Bird: #ffd500
					VGA_R <= "11111111"; -- 255
					VGA_G <= "11010101"; -- 213
					VGA_B <= "00000000"; -- 0
				when others =>
					VGA_R <= (others => VGA_DATA_r(2));
					VGA_G <= (others => VGA_DATA_r(1));
					VGA_B <= (others => VGA_DATA_r(0));
				end case;
			end if;
		end if;
	end process process_screen_colors;
end vga_controller_rtl;