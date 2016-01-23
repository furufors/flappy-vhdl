-- Company: TEIS AB
-- Engineer: Fredrik Furufors
--
-- Create Date: 2016 jan 22
-- Design Name: vhdl_ingenjors
-- Target Devices: ALTERA Cyclone IV EP4CE115F29C7
-- Description:
--   Filters an input vector by averaging the last four samples as well as
--   replacing any zero-vectors by the previous sample.
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter is
  port (
    step   : in  std_logic;
    input  : in  std_logic_vector(22 downto 0);
    output : out std_logic_vector(22 downto 0)
  );
end;

architecture rtl of filter is
  signal i0 : std_logic_vector(24 downto 0) := (others => '0');
  signal i1 : std_logic_vector(24 downto 0) := (others => '0');
  signal i2 : std_logic_vector(24 downto 0) := (others => '0');
  signal i3 : std_logic_vector(24 downto 0) := (others => '0');
  signal ia : std_logic_vector(24 downto 0) := (others => '0');
begin
  ia <= std_logic_vector(
      unsigned(i0) +
      unsigned(i1) +
      unsigned(i2) +
      unsigned(i3)
    );
  -- Output sum of last 4 values / 4
  output <= ia(24 downto 2);

  process (step)
  begin
    if rising_edge(step) and step = '1' then
      -- Extend input to 19 bits for 2x carry
      if (input /= std_logic_vector(to_unsigned(0,23))) then
        i0 <= '0' & '0' & input;
      else
        i0 <= i1;
      end if;
      i1 <= i0;
      i2 <= i1;
      i3 <= i2;
    end if;
  end process;
end;