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

-- Standard template Dual port, dual clock RAM.
library ieee;
use ieee.std_logic_1164.all;

entity vga_dual_port_ram is
  generic(
    DATA_WIDTH : natural := 3;
    ADDR_WIDTH : natural := 17
  );

  port(
    rclk  : in std_logic;
    wclk  : in std_logic;
    raddr : in natural range 0 to 2**ADDR_WIDTH - 1;
    waddr : in natural range 0 to 2**ADDR_WIDTH - 1;
    data  : in std_logic_vector((DATA_WIDTH-1) downto 0);
    we    : in std_logic := '1';
    q   : out std_logic_vector((DATA_WIDTH -1) downto 0)
  );
end vga_dual_port_ram;

architecture rtl of vga_dual_port_ram is

  -- Build a 2-D array type for the RAM
  subtype word_t is std_logic_vector((DATA_WIDTH-1) downto 0);
  type memory_t is array(2**ADDR_WIDTH-1 downto 0) of word_t;

  -- Declare the RAM signal.
  signal ram : memory_t;

begin
  process(wclk)
  begin
  if(rising_edge(wclk)) then
    if(we = '1') then
      ram(waddr) <= data;
    end if;
  end if;
  end process;

  process(rclk)
  begin
  if(rising_edge(rclk)) then
    q <= ram(raddr);
  end if;
  end process;
end rtl;