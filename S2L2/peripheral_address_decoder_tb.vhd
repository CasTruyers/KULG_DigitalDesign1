----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: peripheral_address_decoder_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Test the peripheral_address_decoder module.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use IEEE.NUMERIC_STD.ALL;

library STD;
use STD.TEXTIO.ALL;

entity peripheral_address_decoder_tb is
end peripheral_address_decoder_tb;

architecture Behavioral of peripheral_address_decoder_tb is
    
    -- constants
    constant clk_period : time := 10 ns;
    -- MAG DIT, HOE GENERIC GEBRUIKEN?
    constant C_BASE_ADDR_TB : std_logic_vector(7 downto 0) := x"F0"; 
    constant C_PERI_ADDR_WIDTH_TB : natural := 4;

    
    -- system clock (not needed because DUT is a combinatorial circuit, but timing can be derived from it)
    signal clk : std_logic := '0';
    
    -- inputs
    signal addr_TB : std_logic_vector(C_BASE_ADDR_TB'range) := (others => '0'); -- Nog generic maken
    signal write_en_TB : std_logic := '0';
    signal read_en_TB : std_logic := '0';
    
    -- outputs
    signal addr_peri_TB : std_logic_vector(C_PERI_ADDR_WIDTH_TB - 1 downto 0) := (others => '0');  -- Nog generic maken
    signal read_en_peri_TB : std_logic := '0';
    signal write_en_peri_TB : std_logic :='0';
    
    -- procedure is basically a function that doesn't return anything
    procedure sim_message(msg : string) is 
        variable s : line;
    begin
        write (s, msg);
        writeline (output, s);
    end procedure;
    
    -- convert number (0 to 15) to hex string representation
    function int_to_hex(num: natural) return string is
        variable lut : string(1 to 16) := "0123456789ABCDEF";
    begin
        if num > 15 then
            return "";
        else
            return string'("" & lut(num+1));
        end if;
    end function;
    
    -- convert std_logic_vector to hex string representation
    -- TODO: write function that converts a std_logic_vector to hex string representation
    --       this wil also be a recursive function
    function to_hstring(slv: std_logic_vector) return string is
        variable res: string(1 to slv'length / 4);
        variable temp: std_logic_vector(3 downto 0);
    begin
        for i in 0 to res'length - 1 loop
            temp := slv(slv'high - i*4 downto slv'high - i*4 - 3);
            case temp is
                when "0000" => res(i+1) := '0';
                when "0001" => res(i+1) := '1';
                when "0010" => res(i+1) := '2';
                when "0011" => res(i+1) := '3';
                when "0100" => res(i+1) := '4';
                when "0101" => res(i+1) := '5';
                when "0110" => res(i+1) := '6';
                when "0111" => res(i+1) := '7';
                when "1000" => res(i+1) := '8';
                when "1001" => res(i+1) := '9';
                when "1010" => res(i+1) := 'A';
                when "1011" => res(i+1) := 'B';
                when "1100" => res(i+1) := 'C';
                when "1101" => res(i+1) := 'D';
                when "1110" => res(i+1) := 'E';
                when "1111" => res(i+1) := 'F';
                when others => res(i+1) := 'X';
            end case;
        end loop;
        return res;
    end function;
    
    -- convert std_logic_vector to binary string representation
    function to_bin_string(vector : std_logic_vector) return string is
    begin
        if vector(vector'high) = '0' then
            if vector'length = 1 then
                return "0";
            else
                return string'("0" & to_bin_string(vector(vector'high-1 downto 0)) ); -- recursive
            end if;
        else
            if vector'length = 1 then
                return "1";
            else
                return string'("1" & to_bin_string(vector(vector'high-1 downto 0)) ); -- recursive
            end if;
        end if;
    end function;
    
    -- component that will be tested
    component peripheral_address_decoder is
        generic(
                  C_BASE_ADDR : std_logic_vector := x"F0"; 
            C_PERI_ADDR_WIDTH : natural := 1
        );
        port(
                     addr : in  std_logic_vector(C_BASE_ADDR'range);
                  read_en : in  std_logic;
                 write_en : in  std_logic;
                addr_peri : out std_logic_vector(C_PERI_ADDR_WIDTH-1 downto 0);
             read_en_peri : out std_logic;
            write_en_peri : out std_logic
        );
    end component;

    --debug information
    type debug_t is (resetting, invalid_addr, peripheral_test, ended);
    signal debug : debug_t;
    
begin

    -- DUT
    -- TODO: instantiate DUT
peri_addr_decode_TB: peripheral_address_decoder
        generic map(
                  C_BASE_ADDR => C_BASE_ADDR_TB, -- HIERVAN NIET ZEKER
            C_PERI_ADDR_WIDTH => C_PERI_ADDR_WIDTH_TB
        )
        port map(
                     addr => addr_TB,
                  read_en => read_en_TB,
                 write_en => write_en_TB,
                addr_peri => addr_peri_TB,
             read_en_peri => read_en_peri_TB,
            write_en_peri => write_en_peri_TB
        );

    CLK_PROC: process
    begin
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
    end process CLK_PROC;

    STIM_PROC: process

    begin
        debug <= resetting;
        wait for clk_period;
        
	-- TODO: write stim process
        
        addr_TB <= x"F0";
        write_en_tb <= '0';
        wait for 50ns;
        write_en_tb <= '1';
        wait for 50ns;
        addr_TB <= x"F1";
        write_en_tb <= '0';
        wait for 50ns;
        write_en_tb <= '1';
        wait for 50ns;
        addr_TB <= x"F2";
        write_en_tb <= '0';
        wait for 50ns;
        write_en_tb <= '1';
        wait for 50ns;
        addr_TB <= x"F3";
        write_en_tb <= '0';
        wait for 50ns;
        write_en_tb <= '1';
        wait for 50ns;

        
        -- end simulation
        debug <= ended;
        assert false -- will always execute
                report "SIMULATION ENDED"
                severity NOTE;
        
        wait;
            
    end process STIM_PROC;
    
    
end Behavioral;

