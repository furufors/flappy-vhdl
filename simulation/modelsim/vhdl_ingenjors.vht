-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus II License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "01/23/2016 22:51:15"
                                                            
-- Vhdl Test Bench template for design  :  vhdl_ingenjors
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY vhdl_ingenjors_vhd_tst IS
END vhdl_ingenjors_vhd_tst;
ARCHITECTURE vhdl_ingenjors_arch OF vhdl_ingenjors_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL CLOCK_50 : STD_LOGIC;
SIGNAL GPIO_TX_P0 : STD_LOGIC;
SIGNAL GPIO_TX_P1 : STD_LOGIC;
SIGNAL LEDR : STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL SW : STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL VGA_B : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_BLANK_N : STD_LOGIC;
SIGNAL VGA_clk : STD_LOGIC;
SIGNAL VGA_G : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_HS : STD_LOGIC;
SIGNAL VGA_R : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VGA_SYNC_N : STD_LOGIC;
SIGNAL VGA_VS : STD_LOGIC;
COMPONENT vhdl_ingenjors
	PORT (
	CLOCK_50 : IN STD_LOGIC;
	GPIO_TX_P0 : IN STD_LOGIC;
	GPIO_TX_P1 : OUT STD_LOGIC;
	LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
	SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
	VGA_B : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_BLANK_N : OUT STD_LOGIC;
	VGA_clk : OUT STD_LOGIC;
	VGA_G : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_HS : OUT STD_LOGIC;
	VGA_R : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	VGA_SYNC_N : OUT STD_LOGIC;
	VGA_VS : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : vhdl_ingenjors
	PORT MAP (
-- list connections between master ports and signals
	CLOCK_50 => CLOCK_50,
	GPIO_TX_P0 => GPIO_TX_P0,
	GPIO_TX_P1 => GPIO_TX_P1,
	LEDR => LEDR,
	SW => SW,
	VGA_B => VGA_B,
	VGA_BLANK_N => VGA_BLANK_N,
	VGA_clk => VGA_clk,
	VGA_G => VGA_G,
	VGA_HS => VGA_HS,
	VGA_R => VGA_R,
	VGA_SYNC_N => VGA_SYNC_N,
	VGA_VS => VGA_VS
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
                                   
BEGIN                                                         

WAIT;                                                        
END PROCESS always;                                          
END vhdl_ingenjors_arch;
