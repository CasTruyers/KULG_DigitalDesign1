----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/14/2025 03:45:37 PM
-- Design Name: 
-- Module Name: singlePulse - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- This vhdl module is made generic

entity singlePulse is
    generic(
        N_PORTS : natural := 1
        );
    port(
            CLK : in std_logic;
            btns_in : in std_logic_vector(N_PORTS-1 downto 0); -- Buttons input vector based on N_PORTS
            results_out : out std_logic_vector(N_PORTS-1 downto 0) -- Pulse output
    );
end singlePulse;

architecture Behavioral of singlePulse is

-- For generating a pulse we need one simple D-FLIPFLOP, we need N_PORT's vector signal to pass to the flipflop
signal flipflops : std_logic_vector(N_PORTS-1 downto 0) := (others=>'0');

begin

-- We create the flip-flop by describing a process that stores the button state on each clock cycle
FF1: process(CLK)
begin
    if rising_edge(CLK) then
        flipflops <= btns_in;  -- Store current button states
    end if;
end process;

-- Generate a single pulse when the button transitions from 0 to 1
-- btns_in is the current button state, flipflops holds the previous state
-- If the button was 0 before and is 1 now, we detect a rising edge
results_out <= btns_in and not(flipflops); (*@\textcolor{G}{-- Detect button press}@*)

end Behavioral;

