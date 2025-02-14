----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: Cas Truyers, Xander Rasschaert
-- 
-- Module Name: FA1B - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Full adder (1-bit)
--
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Entity lists inputs/outputs of FA1B component

ENTITY FA1B IS 
	PORT(
		-- TODO: complete entity declaration
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
END entity;

-- Architecture describes behaviour of FA1B
-- Implementing the logic gates diagram using xor/and/or gates

ARCHITECTURE LDD1 OF FA1B IS
BEGIN
	S <= (A xor B) xor C_in ; -- resulting output of adder
	C_out <= (A and B) or ((A xor B) and C_in); -- Carry out bit from add operation
END LDD1;

