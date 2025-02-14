----------------------------------------------------------------------------------
-- Institution: KU Leuven
-- Students: Xander Rasschaert and Cas Truyers
-- 
-- Module Name: ALU8bit - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  8-bit ALU that supports several logic and arithmetic operations
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- TODO: use processor_pkg from the work library
use work.processor_pkg.all;

entity ALU8bit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
         X : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
         Y : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
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
end ALU8bit;

architecture Behavioral of ALU8bit is
    -- operations defined in processor_pkg
    -- ALU_OP_NOT  
    -- ALU_OP_AND  
    -- ALU_OP_OR   
    -- ALU_OP_XOR  
    -- ALU_OP_ADD  
    -- ALU_OP_CMP  
    -- ALU_OP_RR   
    -- ALU_OP_RL   
    -- ALU_OP_SWAP 

    signal carry_r : std_logic;
    -- operation results
    signal result_i      : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal not_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal and_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal or_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal xor_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal rr_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal rl_result_i   : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_result_i  : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal swap_result_i : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    -- help signals
    signal add_secondary_input_i     : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal add_carry_in_i: std_logic := '0';
    signal add_carry_i   : std_logic := '0';

    
    -- we use a separate module for the addition/subtraction
    component ADD is
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
    end component;
begin
    
    -- TODO: complete the following lines to perform logical operations
    -- implementation of some operations

    -- We describe the logic for the basic gate operations simply with the operator of that gate used on input x and y
    -- and
    and_result_i <= x and y ;
    -- or
    or_result_i <= x or y ;
    -- xor
    xor_result_i <= x xor y ;
    -- not
    not_result_i <= not x ;


    -- rr      
    rr_result_i <= '0' & X(C_DATA_WIDTH-1 downto 1);        --shift to the right
    -- rl
    rl_result_i <= X(C_DATA_WIDTH-2 downto 0) & '0';        --shift to the left

    -- swap
    swap_result_i <= X((C_DATA_WIDTH/2)-1 downto 0) & X(C_DATA_WIDTH-1 downto C_DATA_WIDTH/2);  -- swap first half MSB's with second half LSB's, for n-bit ALU (only even n-number)
    
    -- Extra carry signal defined for the rotate operations (we chose to make extra carry signal for our readability and understanding)
    carry_r <= X(0) when (op = ALU_OP_RR) else              
               X(C_DATA_WIDTH -1) when (op = ALU_OP_RL) else
               '0';
    
    -- TODO: have a look at how this module is instantiated
    -- Ripple carry adder instantiation
    ADDER : ADD
    generic map(
        C_DATA_WIDTH => C_DATA_WIDTH -- this will change the default width of the adder to the width specified here
    )
    port map(
                a => X,
                b => add_secondary_input_i,
         carry_in => add_carry_in_i,
           result => add_result_i,
        carry_out => add_carry_i
    );

    -- TODO: change the adder's secondary input and carry in, based on the operation (addition/subtraction)
    -- addition and subtraction

    -- Describing MUX logic at inputs Y and carry_in of n-bit adder as described by diagram in assignment
    add_secondary_input_i <= NOT Y when (op = ALU_OP_SUB) else
                             Y when (op = ALU_OP_ADD);
    add_carry_in_i <= '1' when (op = ALU_OP_SUB) else
                      '0' when (op = ALU_OP_ADD);
    
    -- TODO: set 'result_i' to a specific operation result based on the selected operation 'op'
    -- result mux determines which internal signal gets linked to the output, determined by the "op" input vector of the ALU
    with op select
        result_i <= not_result_i when ALU_OP_NOT,
                    and_result_i when ALU_OP_AND,
                    or_result_i when ALU_OP_OR,
                    xor_result_i when ALU_OP_XOR,
                    add_result_i when ALU_OP_ADD,
                    add_result_i when ALU_OP_SUB,
                    rr_result_i when ALU_OP_RR,
                    rl_result_i when ALU_OP_RL,
                    swap_result_i when ALU_OP_SWAP,
                    (others => '0') when others;
    
    Z <= result_i;
    
    -- TODO: control the flags
    -- carry flag: 1 carry flag for SUB, ADD, RR and RL (based on op)
    --   don't forget that rotate left/right can also produce a carry
    --   you might need some extra signals
    cf <= add_carry_i  when  op = ALU_OP_ADD else   -- Carry for ADD or SUB (based on adder carry out)
          not add_carry_i when op = ALU_OP_SUB else
          carry_r when (op = ALU_OP_RR) else                            -- Carry for Rotate Right (RR) from original LSB (see carry_r signal linking above)
          carry_r when (op = ALU_OP_RL) else                            -- Carry for Rotate Left (RL) from original MSB (see carry_r signal linking above)
          '0';                                                          -- Default case

    -- zero flag
    zf <= '1' when result_i = (result_i'range => '0') else '0' ; -- Assign zero-flag with '1' when all bits of the signal vector result_i are '0', else assing '0'. result_i'range returns the range of result_i
    
    -- equal, smaller, greater flag -> using the "when ... else" syntax to simply assign '1' when the condition is true and '0' when false
    ef <= '1' when X = Y else '0' ;
    gf <= '1' when X > Y else '0' ;
    sf <= '1' when X < Y else '0' ;

end Behavioral;
