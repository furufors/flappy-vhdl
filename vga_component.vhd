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

-- Provides internal routing in the VGA-component
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_component is
	port(
		reset_n, clock_50 : IN std_logic; -- reset_n
		-- till VGA enheten
		VGA_HS, VGA_VS, VGA_CLK : OUT std_logic;
		VGA_BLANK_N, VGA_SYNC_N : OUT std_logic;
		VGA_B, VGA_G, VGA_R : OUT std_logic_vector(7	downto 0);
		-- Minnes interfacet
		adress_vga_w : IN	std_logic_vector(16 downto 0);
		data_vga_w : IN std_logic_vector(2 downto 0);
		write_VGA : IN std_logic;
		status_sync_write : OUT std_logic
	);
end vga_component;

architecture rtl of vga_component is
	component vga_controller is
		port(
			reset_n, CLOCK_50, clk_pll : in std_logic;
			VGA_HS, VGA_VS, VGA_CLK : out std_logic;
			VGA_BLANK_N, VGA_SYNC_N : out std_logic;
			VGA_B, VGA_G, VGA_R : out std_logic_vector(7 downto 0);
			VGA_ADDRESS_r : out std_logic_vector(16 downto 0);
			VGA_DATA_r : in std_logic_vector(2 downto 0);
			allow_write : out std_LOGIC
		);
	end component vga_controller;
	
	component vga_dual_port_ram is
		generic(
			DATA_WIDTH : natural := 3;
			ADDR_WIDTH : natural := 17
		);

		port(
			rclk	: in std_logic;
			wclk	: in std_logic;
			raddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
			waddr	: in natural range 0 to 2**ADDR_WIDTH - 1;
			data	: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we		: in std_logic := '1';
			q		: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
	end component vga_dual_port_ram;
	
	component vga_pll is
		PORT(
			inclk0		: IN STD_LOGIC  := '0';
			c0		: OUT STD_LOGIC ;
			locked		: OUT STD_LOGIC 
		);
	end component vga_pll;
	
	signal clk_pll_signal : std_logic;
	signal vga_address_signal : std_logic_vector(16 downto 0);
	signal vga_data_signal : std_logic_vector(2 downto 0);
	signal int_vga_address_signal : integer := 0;
	signal int_adress_vga_w : integer := 0;
begin
	
	-- Connects input and memory to the vga-controller
	controller : vga_controller
		port map (
			reset_n,
			clock_50,
			clk_pll_signal,
			vga_hs,
			vga_vs,
			vga_clk,
			vga_blank_n,
			vga_sync_n,
			vga_b,
			vga_g,
			vga_r,
			vga_address_signal,
			vga_data_signal,
			status_sync_write
		);
	
	int_vga_address_signal <= to_integer(unsigned(vga_address_signal));
	int_adress_vga_w <= to_integer(unsigned(adress_vga_w));
	
	-- Routes input and memory to the VGA-controller
	memory : vga_dual_port_ram
		generic map (3, 17)
		port map (
			clk_pll_signal,
			clock_50,
			int_vga_address_signal,
			int_adress_vga_w,
			data_vga_w,
			write_VGA,
			vga_data_signal
		);
	
	-- Turns 50Hz inclock to a 25 MHz clock (clk_pll_signal)
	pll : vga_pll
		port map (clock_50, clk_pll_signal, open);
end;