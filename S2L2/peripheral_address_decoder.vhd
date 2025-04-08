----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: peripheral_address_decoder - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  The peripheral address decoder will detect if an address is in its assigned
--  range (or not). It will pass (or block) the general read_en and write_en
--  signals accordingly.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


    
entity peripheral_address_decoder is
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
end peripheral_address_decoder;



architecture Behavioral of peripheral_address_decoder is
    
    -- generate a bit mask to isolate the base address from the peripheral address
    function mask(peripheral_range_len : natural; addr_len : natural) return std_logic_vector is
        variable m : std_logic_vector(addr_len-1 downto 0);
    begin
 	-- TODO: complete function to generate address mask
 	    for i in addr_len-1 downto 0 loop
 	        if i < peripheral_range_len then
 	            m(addr_len-1 - i) := '0';
 	        else  
 	            m(addr_len-1 - i) := '1';
 	        end if;
 	    end loop;  
        return m;
    end function;
    
    --mask isolating the peripheral base address from the input address
    constant C_ADDR_MASK : std_logic_vector(addr'range) := mask(C_PERI_ADDR_WIDTH, addr'length); 
    
    constant zeros : std_logic_vector(C_PERI_ADDR_WIDTH-1 downto 0) := (others => '0');

    
    --1 if address inputed is the address space of the peripheral, 0 otherwise
    signal in_address_range_i :std_logic;
    
    -- internal counterpart of addr input
    signal addr_i : std_logic_vector(addr'length-1 downto 0) := (others=>'0');

begin
	-- some design checks
	-- make sure mask and address have the same length
	assert C_ADDR_MASK'length = addr'length
		report "C_ADDR_MASK and addr need to have the same length."
		severity ERROR;
	-- make sure the C_PERI_ADDR_WIDTH lowest bits of C_BASE_ADDR are 0
	-- TODO: add test using assert statement
    assert (to_integer(unsigned(C_BASE_ADDR) mod 2**C_PERI_ADDR_WIDTH) = 0)
		report "C_BASE_ADDR must have its least significant C_PERI_ADDR_WIDTH bits set to 0."
		severity FAILURE;
    -- this avoids compiler errors about indexing
    addr_i <= addr;
    
    -- TODO: check if the address is in the specified range
    in_address_range_i <= '1' when (addr_i and C_ADDR_MASK) = C_BASE_ADDR else '0';
    
    -- TODO: generate the outputs
    read_en_peri <= read_en when in_address_range_i = '1' else '0';
    write_en_peri <= write_en when in_address_range_i = '1' else '0';
    addr_peri <= addr_i(C_PERI_ADDR_WIDTH - 1 downto 0);

end Behavioral;
