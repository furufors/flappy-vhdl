library ieee;

use ieee.std_logic_1164.all;

entity vhdl_ingenjors is
	port (
		CLOCK_50   : in std_logic;
		GPIO_TX_P0 : in std_logic;
		GPIO_TX_P1 : out std_logic;
		LEDR       : out std_logic_vector(17 downto 0);
		LEDG       : out std_logic_vector(2 downto 0);
		SW			: in std_logic_vector(17 downto 0);
		-- till VGA enheten
		VGA_HS, VGA_VS, VGA_clk : OUT std_logic;
		VGA_BLANK_N, VGA_SYNC_N : OUT std_logic;
		VGA_B, VGA_G, VGA_R : OUT std_logic_vector(7 downto 0)
	);
end entity;

architecture behavoiour of vhdl_ingenjors is	
	signal done : std_logic;
	signal pulse_width : std_logic_vector(22 downto 0);
	signal filtered_sensor : std_logic_vector(22 downto 0);
	signal adress_vga_signal : std_logic_vector(16 downto 0);
	signal data_vga_signal : std_logic_vector(2 downto 0);
	signal write_vga_signal : std_logic;
	signal status_sync_write_signal : std_logic;
	signal bird_height : std_logic_vector(7 downto 0);
	signal random_signal : std_logic_vector(2 downto 0);
	signal score_signal : std_logic_vector(31 downto 0);
begin
sensor : entity work.hcsr04
	port map (
		clk        => CLOCK_50,
		echo       => GPIO_TX_P0,
		trig       => GPIO_TX_P1,
		done       => done,
		pulse_width => pulse_width
	);

average : entity work.filter
	port map (
		step   => done,
		input  => pulse_width,
		output => filtered_sensor
	); 

height : entity work.sensor_to_height
	port map (
		sensor => filtered_sensor,
		height => bird_height
	);

random : entity work.sensor_to_prng
	port map (
		sensor => filtered_sensor,
		random => random_signal
	);
	
-- Routing of signals to the vga-component
-- Memory signals come from the case-FSM.
controller : entity work.vga_component
	port map (
		SW(17),
		CLOCK_50,
		-- till VGA enheten
		VGA_HS,
		VGA_VS,
		VGA_clk,
		VGA_BLANK_N,
		VGA_SYNC_N,
		VGA_B,
		VGA_G,
		VGA_R,
		-- Minnes interfacet
		adress_vga_signal,
		data_vga_signal,
		write_vga_signal,
		status_sync_write_signal
	);

-- Routing of input to the state machine
-- key inputs are negated: active low -> boolean state (pressed=true)
graphics_inst : entity work.game_graphics
	port map (
		CLOCK_50,
		SW(17),
		bird_height,
		random_signal,
		adress_vga_signal,
		data_vga_signal,
		write_vga_signal,
		status_sync_write_signal,
		score_signal
	);

	LEDR <= score_signal(17 downto 0);
	
end architecture;