-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Top level routing of the game. Connects the filtered sensor and
--   VGA-controller to the game logic.
library ieee;

use ieee.std_logic_1164.all;

entity vhdl_ingenjors is
  port (
    CLOCK_50   : in std_logic;
    GPIO_TX_P0 : in std_logic;
    GPIO_TX_P1 : out std_logic;
    LEDR       : out std_logic_vector(17 downto 0);
    LEDG       : out std_logic_vector(2 downto 0);
    SW      : in std_logic_vector(17 downto 0);
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
  signal sensor_height : std_logic_vector(7 downto 0);
  signal random_signal : std_logic_vector(2 downto 0);
  signal score_signal : std_logic_vector(31 downto 0);
begin

-- The mapping of the HC-SR04 to hardware, attached to GPIO and +5V and GND
sensor : entity work.hcsr04
  port map (
    clk        => CLOCK_50,
    echo       => GPIO_TX_P0,
    trig       => GPIO_TX_P1,
    done       => done,
    pulse_width => pulse_width
  );

-- Perform the average filtering on the sensor signal
average : entity work.filter
  port map (
    step   => done,
    input  => pulse_width,
    output => filtered_sensor
  );

-- Convert the sensor value to a useable format
height : entity work.sensor_to_height
  port map (
    sensor => filtered_sensor,
    height => sensor_height
  );

-- Extract some randomness from the sensor
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
    -- VGA
    VGA_HS,
    VGA_VS,
    VGA_clk,
    VGA_BLANK_N,
    VGA_SYNC_N,
    VGA_B,
    VGA_G,
    VGA_R,
    -- Memory interface
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
    sensor_height,
    random_signal,
    adress_vga_signal,
    data_vga_signal,
    write_vga_signal,
    status_sync_write_signal,
    score_signal
  );

  -- The game score in seconds is displayed on the leds, binary...
  LEDR <= score_signal(17 downto 0);

end architecture;