entity vhdl_ingenjors is
	port();
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
	
	component vga_controller is
	port(
		reset_n, CLOCK_50, clk_pll : in std_logic;
		VGA_HS, VGA_VS, VGA_CLK : out std_logic;
		VGA_BLANK_N, VGA_SYNC_N : buffer std_logic;
		VGA_B, VGA_G, VGA_R : out std_logic_vector(7 downto 0);
		VGA_ADDRESS_r : out std_logic_vector(16 downto 0);
		VGA_DATA_r : in std_logic_vector(2 downto 0);
		allow_write : out std_logic
	);
	end component;
begin

end architecture;