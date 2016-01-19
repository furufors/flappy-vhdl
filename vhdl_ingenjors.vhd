library ieee;

use ieee.std_logic_1164.all;

entity vhdl_ingenjors is
	  port (
				 CLOCK_50   : in std_logic;
				 GPIO_TX_P0 : in std_logic;
				 GPIO_TX_P1 : out std_logic;
				 LEDR       : out std_logic_vector(7 downto 0);
				 LEDG       : out std_logic_vector(2 downto 0)
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
	
--	component vga_controller is
--	port(
--		reset_n, CLOCK_50, clk_pll : in std_logic;
--		VGA_HS, VGA_VS, VGA_CLK : out std_logic;
--		VGA_BLANK_N, VGA_SYNC_N : buffer std_logic;
--		VGA_B, VGA_G, VGA_R : out std_logic_vector(7 downto 0);
--		VGA_ADDRESS_r : out std_logic_vector(16 downto 0);
--		VGA_DATA_r : in std_logic_vector(2 downto 0);
--		allow_write : out std_logic
--	);
--	end component;
	  signal Done : std_logic;
	  signal PulseWidth : std_logic_vector(17 downto 0);
	  signal FilteredSensor : std_logic_vector(17 downto 0);
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
			height => LEDR
);

random : sensor_to_prng port map (
			sensor => FilteredSensor,
			random => LEDG
	);

end architecture;