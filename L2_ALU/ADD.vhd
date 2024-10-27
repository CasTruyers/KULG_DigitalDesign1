----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: Cas Truyers, Xander Rasschaet
-- 
-- Module Name: ADD - Structural
-- Course Name: Lab Digital Design
--
-- Description:
--  n-bit ripple carry adder
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity ADD is
	generic(
       C_DATA_WIDTH : natural := 4
	);
	port(
                a : in  std_logic_vector((C_DATA_WIDTH-1) downto 0); -- input var 1
                b : in  std_logic_vector((C_DATA_WIDTH-1) downto 0); -- input var 2
         carry_in : in  std_logic;                                   -- input carry
           result : out std_logic_vector((C_DATA_WIDTH-1) downto 0); -- alu operation result
        carry_out : out std_logic                                    -- carry
	);
end entity;

architecture LDD1 of ADD is
	-- list of signals and components

	-- signals
	signal carry : std_logic_vector(C_DATA_WIDTH downto 0); -- Carry signal for connecting the carry signals between FA1B, note that we have an extra bit for the carry_out of the last adder.

	
	-- components: Declaration of FA1B component for later initialization in architecture, same syntax as entity with entity -> component
	component  FA1B IS
	PORT(
		A : in std_logic;
		B : in std_logic;
		C_in : in std_logic;
		S : out std_logic;
		C_out : out std_logic);
    END component;


begin
    carry(0) <= carry_in; -- External carry_in gets put on first bit of carry signal
    -- Initializes (C_DATA_WIDTH - 1) times the FA1B component to create n-bit full adder
    FA_array: For i in C_DATA_WIDTH-1 downto 0 generate
        Inst_FullAdder: FA1B  PORT MAP(
            A => A(i), -- FA1B input A bit gets linked to the i-th bit from vector input A of n-bit full adder 
            B => B(i), -- FA1B input B bit gets linked to the i-th bit from the vector input B of n-bit full adder
            C_in => carry(i), -- Carry in (C_in) from FA1B bit gets linked to i-th bit of carry signal vector
            S => Result(i), -- Result (S) from FA1B gets linked to the i-th bit of result vector of n-bit adder
            C_out => carry(i+1) -- link the output carry to the input carry of the next FA
        );
    end generate FA_array;
	
	carry_out <= carry(C_DATA_WIDTH); -- Carry out of n-bit adder components gets linked to the last (MSB) of carry signal.

end LDD1;
