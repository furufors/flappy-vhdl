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
	component hcsr04 is
		port (
			Clk        : in  std_logic;
			Echo       : in  std_logic;
			Trig       : out std_logic;
			Done       : out std_logic;
			PulseWidth : out std_logic_vector(17 downto 0)
		);
	end component;
	
	component filter is
		port (
			Step   : in  std_logic;
			Input  : in  std_logic_vector(17 downto 0);
			Output : out std_logic_vector(17 downto 0)
		);
	end component;
	
	component sensor_to_height is
	port (
		sensor  : in  std_logic_vector(17 downto 0);
		height : out std_logic_vector(7 downto 0)
	);
	end component;
	
	component sensor_to_prng is
	port (
		sensor  : in  std_logic_vector(17 downto 0);
		random  : out std_logic_vector(2 downto 0)
	);
	end component;
	
	component vga_component is
		port(
			reset_n, clock_50 : IN std_logic; -- reset_n
			-- till VGA enheten
			VGA_HS, VGA_VS, VGA_CLK : OUT std_logic;
			VGA_BLANK_N, VGA_SYNC_N : OUT std_logic;
			VGA_B, VGA_G, VGA_R : OUT std_logic_vector(7 downto 0);
			-- Minnes interfacet
			adress_vga_w : IN std_logic_vector(16 downto 0);
			data_vga_w : IN std_logic_vector(2 downto 0);
			write_vga : IN std_logic;
			status_sync_write : OUT std_logic
		);	
	end component vga_component;
	
	component bird_writer is
	port (
		clk               : in  std_logic;
		bird_height       : in  std_logic_vector(7 downto 0);
		adress_vga        : out std_logic_vector(16 downto 0);
		data_vga          : out std_logic_vector(2 downto 0);
		write_VGA         : out std_logic;
		status_sync_write : in  std_logic
	);
	end component;
	
--	component bird_inertia is
--	port (
--		height          : in  std_logic_vector(7 downto 0);
--		step            : in  std_logic;
--		inertial_height : out std_logic_vector(7 downto 0)
--	);
--	end component;
	
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
sensor : hcsr04 port map (
				 Clk        => CLOCK_50,
				 Echo       => GPIO_TX_P0,
				 Trig       => GPIO_TX_P1,
				 Done       => Done,
				 PulseWidth => PulseWidth
	  );

average : filter port map (
				 Step   => Done,
				 Input  => PulseWidth,
				 Output => FilteredSensor
	  ); 

height : sensor_to_height port map (
			sensor => FilteredSensor,
			height => bird_height
);

random : sensor_to_prng port map (
			sensor => FilteredSensor,
			random => LEDG
	);
	
-- Routing of signals to the vga-component
-- Memory signals come from the case-FSM.
controller : vga_component
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
bird_writer_inst : bird_writer
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