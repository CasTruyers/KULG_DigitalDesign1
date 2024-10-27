----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: register_file - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Generic register file description. The number of registers and the data width
--  can be set with C_NR_REGS and C_DATA_WIDTH respectively.
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

entity register_file is
    generic(
        C_DATA_WIDTH : natural := 8;
           C_NR_REGS : natural := 8
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
                  le : in  std_logic;
              in_sel : in  std_logic_vector(C_NR_REGS-1 downto 0);
             out_sel : in  std_logic_vector(C_NR_REGS-1 downto 0);
             data_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    -- TODO: declare what will be used
    -- signal types
    type data_reg_out is array (0 to C_NR_REGS-1) of std_logic_vector (C_DATA_WIDTH-1 downto 0);

    -- signals
    signal data_out_s : data_reg_out; 
    --signal data_out_s2 : data_reg_out; 

    -- components
    component basic_register is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
                  le : in  std_logic;
             data_in : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(C_DATA_WIDTH-1 downto 0)
    );
    end component;
begin

    -- TODO: describe how it's all connected and how it basic_register
    REG_FILE: for i in C_NR_REGS-1 downto 0 generate
        basic_reg: basic_register
        generic map(C_DATA_WIDTH => C_DATA_WIDTH)
        port map(
            clk => clk,
            reset => reset,
            le => (le and in_sel(i)),
            data_in => data_in,
            data_out => data_out_s(i)
        );
    end generate REG_FILE;
    
    
    process (out_sel, data_out_s)
    begin
        data_out <= (others => '0');
        for i in 0 to C_NR_REGS-1 loop
            if out_sel(i) = '1' then
                data_out <= data_out_s(i);
            end if;
        end loop;
    end process;

end Behavioral;
