library ieee;

use ieee.std_logic_1164.all;

entity vhdl_ingenjors is
	port (
		CLOCK_50   : in std_logic;
		GPIO_TX_P0 : in std_logic;
		GPIO_TX_P1 : out std_logic;
		LEDR       : out std_logic_vector(7 downto 0);
		LEDG       : out std_logic_vector(2 downto 0);
		SW			: in std_logic_vector(17 downto 0);
		-- till VGA enheten
		VGA_HS, VGA_VS, VGA_CLK : OUT std_logic;
		VGA_BLANK_N, VGA_SYNC_N : OUT std_logic;
		VGA_B, VGA_G, VGA_R : OUT std_logic_vector(7 downto 0)
	);
end entity;

architecture behavoiour of vhdl_ingenjors is	
	signal Done : std_logic;
	signal PulseWidth : std_logic_vector(17 downto 0);
	signal FilteredSensor : std_logic_vector(17 downto 0);
	signal adress_vga_signal : std_logic_vector(16 downto 0);
	signal data_vga_signal : std_logic_vector(2 downto 0);
	signal write_vga_signal : std_logic;
	signal status_sync_write_signal : std_logic;
	signal bird_height : std_logic_vector(7 downto 0);
	signal bird_inerial_height : std_logic_vector(7 downto 0);
begin
sensor : entity work.hcsr04
	port map (
		Clk        => CLOCK_50,
		Echo       => GPIO_TX_P0,
		Trig       => GPIO_TX_P1,
		Done       => Done,
		PulseWidth => PulseWidth
	);

average : entity work.filter
	port map (
		Step   => Done,
		Input  => PulseWidth,
		Output => FilteredSensor
	); 

height : entity work.sensor_to_height
	port map (
		sensor => FilteredSensor,
		height => bird_height
	);

random : entity work.sensor_to_prng
	port map (
		sensor => FilteredSensor,
		random => LEDG
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
		VGA_CLK,
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
		bird_inerial_height,
		adress_vga_signal,
		data_vga_signal,
		write_vga_signal,
		status_sync_write_signal
	);

	LEDR <= bird_height;
	
physics : entity work.bird_inertia
	port map (
		bird_height,
		done,
		bird_inerial_height
	);
end architecture;