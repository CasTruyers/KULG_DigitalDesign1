----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: firstname lastname and other guy/girl/...
-- 
-- Module Name: data_path - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  A preliminary Data Path for the processor.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library work;
use work.processor_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_path is
    generic(
        C_DATA_WIDTH : natural := 8;
          C_NR_FLAGS : natural := 5
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
         -- ALU-related control inputs 
              alu_op : in  std_logic_vector(3 downto 0);
                y_le : in  std_logic;
                z_le : in  std_logic;
            flags_le : in  std_logic;
         -- Regsiter File control inputs
         reg_file_le : in  std_logic;
             Rsource : in  std_logic_vector(2 downto 0);
        Rdestination : in  std_logic_vector(2 downto 0);
         -- CPU bus control and inputs
         cpu_bus_sel : in  std_logic_vector(3 downto 0);
                dibr : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                  pc : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                  sp : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                ir_l : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
         -- Data path outputs
             cpu_bus : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
               flags : out std_logic_vector(C_NR_FLAGS-1 downto 0)
          
    );
end data_path;

architecture Behavioral of data_path is
    -- Constants
    constant C_NR_REGS : natural := 8;
    constant C_ZF : natural := 4;
    constant C_CF : natural := 3;
    constant C_EF : natural := 2;
    constant C_GF : natural := 1;
    constant C_SF : natural := 0;
    constant IV : std_logic_vector(C_DATA_WIDTH-1 downto 0) := std_logic_vector( RESIZE(to_unsigned(2,3), C_DATA_WIDTH));

    -- Signals ------------------------------------------------------------------------------------------------------
    -- Data lines
    signal cpu_bus_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal y_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal z_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal alu_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal alu_flags_i : std_logic_vector(C_NR_FLAGS-1 downto 0) := (others=>'0');
    signal flags_i : std_logic_vector(C_NR_FLAGS-1 downto 0) := (others=>'0');
    signal reg_file_out_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal reg_file_in_sel_i : std_logic_vector(C_NR_REGS-1 downto 0) := (others=>'0');
    signal reg_file_out_sel_i : std_logic_vector(C_NR_REGS-1 downto 0) := (others=>'0');
    -- Control lines
    signal y_le_i : std_logic := '0';
    signal z_le_i : std_logic := '0';
    signal reg_file_le_i : std_logic := '0';
    signal flags_le_i : std_logic := '0';
    signal alu_op_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal Rs_i : std_logic_vector(2 downto 0) := (others=>'0');
    signal Rd_i : std_logic_vector(2 downto 0) := (others=>'0');

    -- Components ---------------------------------------------------------------------------------------------------
    -- Register file
    component register_file is
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
    end component;

    -- Basic 8-bit register
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
    
    -- Arithmetic and Logic Unit
    component ALU8bit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
         X : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Y : in std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Z : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
        -- operation select
        op : in std_logic_vector(3 downto 0);
        -- flags
        zf : out std_logic;
        cf : out std_logic;
        ef : out std_logic;
        gf : out std_logic;
        sf : out std_logic
    );
    end component;

begin
    -- TODO: complete description
    -- Outputs (map to internal signals)
    cpu_bus <= cpu_bus_i;
    flags <= flags_i;
    -- Inputs (map to internal signals <optional>)
    reg_file_le_i <= reg_file_le;
    Rd_i <= Rdestination;
    Rs_i <= Rsource;
    alu_op_i <= alu_op;
    y_le_i <= y_le;
    z_le_i <= z_le;
    flags_le_i <= flags_le;
    
    -- CPU bus control
    with cpu_bus_sel select
        cpu_bus_i <= dibr when SFR_DBR,
                     z_i when SFR_Z,
                     pc when SFR_PC,
                     IV when SFR_IV,
                     reg_file_out_i when GP_REG ,
                     sp when SFR_SP,
                     ir_l when SFR_IR_L,
                     (others => '0') when others;
    
    -- ALU secondary input (Y register)
    ALU_Y_REG : basic_register
        generic map(
            C_DATA_WIDTH => C_DATA_WIDTH
        )
        port map(
            data_in => cpu_bus_i,
            le => y_le_i,
            clk => clk,
            reset => reset,
            data_out => y_i 
        );
    
    -- ALU output (Z register)
    ALU_Z_REG : basic_register
        generic map(
            C_DATA_WIDTH => C_DATA_WIDTH
        )
            port map(
                data_in=>alu_out_i,
                le=>z_le_i,
                clk=>clk,
                reset=>reset,
                data_out =>z_i 
            );
    
    -- ALU flags register
    ALU_Flag_REG : basic_register
        generic map(
            C_DATA_WIDTH => C_NR_FLAGS
        )
        port map(
            data_in=> alu_flags_i,
            le=>flags_le_i,
            clk=>clk,
            reset=>reset,
            data_out=> flags_i
        );
    
    -- ALU
    ALU_INST : ALU8bit
        generic map(
            C_DATA_WIDTH => C_DATA_WIDTH
        )
        port map(
            X=>cpu_bus_i,
            Y=> y_i,
            Z=> alu_out_i,
            op=>alu_op_i,
            zf=> alu_flags_i(C_ZF),
            cf=> alu_flags_i(C_CF),
            ef=> alu_flags_i(C_EF),
            gf=> alu_flags_i(C_GF),
            sf=> alu_flags_i(C_SF)
        );
    
    -- register file register selection decoding
    with Rd_i select 
    reg_file_in_sel_i<= "00000001" when "000", 
                        "00000010" when "001", 
                        "00000100" when "010", 
                        "00001000" when "011", 
                        "00010000" when "100", 
                        "00100000" when "101", 
                        "01000000" when "110", 
                        "10000000" when "111",
                        (others => '0') when others;
                        
    with Rs_i select 
    reg_file_out_sel_i<= "00000001" when "000", 
                        "00000010" when "001", 
                        "00000100" when "010", 
                        "00001000" when "011", 
                        "00010000" when "100", 
                        "00100000" when "101", 
                        "01000000" when "110", 
                        "10000000" when "111",
                        (others => '0') when others;
    
    -- register file
    Reg_File_Inst : register_file
        generic map(
            C_DATA_WIDTH => C_DATA_WIDTH,
            C_NR_REGS => C_NR_REGS
        )
        port map(
            data_in => cpu_bus_i,
            le => reg_file_le_i,
            in_sel => reg_file_in_sel_i,
            out_sel => reg_file_out_sel_i,
            clk=>clk,
            reset=>reset,
            data_out => reg_file_out_i
        );
    
end Behavioral;
