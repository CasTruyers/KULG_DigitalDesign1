--  ____  ____      _    __  __  ____ ___
-- |  _ \|  _ \    / \  |  \/  |/ ___/ _ \
-- | | | | |_) |  / _ \ | |\/| | |  | | | |
-- | |_| |  _ <  / ___ \| |  | | |__| |_| |
-- |____/|_| \_\/_/   \_\_|  |_|\____\___/
--                           research group
--                             dramco.be/
--
--  KU Leuven - Technology Campus Gent,
--  Gebroeders De Smetstraat 1,
--  B-9000 Gent, Belgium
--
--         File: ROM.vhd

--      Created: 15:01:31 28-10-2024

--       Author: firstname lastname and other guy/girl/...
--
--  Description: LDD Processor Program ROM



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ROM is
    generic( -- do not change these values
        C_ADDR_WIDTH : natural := 7;
        C_DATA_WIDTH : natural := 8
    );
    port(
                 clk : in  std_logic;
             read_en : in  std_logic;
         address_bus : in  std_logic_vector((C_ADDR_WIDTH -1) downto 0);
        data_bus_out : out std_logic_vector((C_DATA_WIDTH -1) downto 0)
    );
end entity;

architecture LDOI of ROM is

	-- Build a 2-D array type for the ROM
	subtype word_t is std_logic_vector((C_DATA_WIDTH-1) downto 0);
	type memory_t is array(2**C_ADDR_WIDTH-1 downto 0) of word_t;

	-- Initialize all memory locations with the desired data
	signal rom : memory_t := (
		-- program start (do not alter!)
		  0 => "00100000", -- jump setup
		  1 => "00001100",
		  2 => "01010000", -- ldr	r0, irqf
		  3 => "11000001",
		  4 => "10100000", -- andl	r0, 04
		  5 => "00000100",
		  6 => "00101000", -- jz	no_timer_irq
		  7 => "00001010",
		  8 => "00011000", -- call	inc_counter
		  9 => "00100000",
		 10 => "00001000", -- reti
		 11 => "00000000",
		 12 => "01000000", -- movl	r0, 04
		 13 => "00000100",
		 14 => "01011000", -- str	irqe, r0
		 15 => "11000000",
		 16 => "01000000", -- movl	r0, t1s_on
		 17 => "00000001",
		 18 => "01011000", -- str	tmr1s, r0
		 19 => "11011000",
		 20 => "00100000", -- jmp	loop
		 21 => "00010110",
		 22 => "01011110", -- str	bcd3, d3
		 23 => "11111011",
		 24 => "01011101", -- str	bcd2, d2
		 25 => "11111010",
		 26 => "01011100", -- str	bcd1, d1
		 27 => "11111001",
		 28 => "01011011", -- str	bcd0, d0
		 29 => "11111000",
		 30 => "00100000", -- jmp	loop
		 31 => "00010110",
		 32 => "11010011", -- inc	d0
		 33 => "00000001",
		 34 => "11110011", -- cmpl	d0, 0a
		 35 => "00001010",
		 36 => "00101010", -- je	inc_d1
		 37 => "00101000",
		 38 => "00010000", -- retc
		 39 => "00000000",
		 40 => "01000011", -- movl	d0, 00
		 41 => "00000000",
		 42 => "11010100", -- inc	d1
		 43 => "00000001",
		 44 => "11110100", -- cmpl	d1, 0a
		 45 => "00001010",
		 46 => "00101010", -- je	inc_d2
		 47 => "00110010",
		 48 => "00010000", -- retc
		 49 => "00000000",
		 50 => "01000100", -- movl	d1, 00
		 51 => "00000000",
		 52 => "11010101", -- inc	d2
		 53 => "00000001",
		 54 => "11110101", -- cmpl	d2, 0a
		 55 => "00001010",
		 56 => "00101010", -- je	inc_d3
		 57 => "00111100",
		 58 => "00010000", -- retc
		 59 => "00000000",
		 60 => "01000101", -- movl	d2, 00
		 61 => "00000000",
		 62 => "11010110", -- inc	d3
		 63 => "00000001",
		 64 => "11110110", -- cmpl	d3, 0a
		 65 => "00001010",
		 66 => "00101010", -- je	reset_d3
		 67 => "01000110",
		 68 => "00010000", -- retc
		 69 => "00000000",
		 70 => "01000110", -- movl	d3, 00
		 71 => "00000000",
		 72 => "00010000", -- retc
		 73 => "00000000",
		 74 => "00000000",
		 75 => "00000000",
		 76 => "00000000",
		 77 => "00000000",
		 78 => "00000000",
		 79 => "00000000",
		 80 => "00000000",
		 81 => "00000000",
		 82 => "00000000",
		 83 => "00000000",
		 84 => "00000000",
		 85 => "00000000",
		 86 => "00000000",
		 87 => "00000000",
		 88 => "00000000",
		 89 => "00000000",
		 90 => "00000000",
		 91 => "00000000",
		 92 => "00000000",
		 93 => "00000000",
		 94 => "00000000",
		 95 => "00000000",
		 96 => "00000000",
		 97 => "00000000",
		 98 => "00000000",
		 99 => "00000000",
		100 => "00000000",
		101 => "00000000",
		102 => "00000000",
		103 => "00000000",
		104 => "00000000",
		105 => "00000000",
		106 => "00000000",
		107 => "00000000",
		108 => "00000000",
		109 => "00000000",
		110 => "00000000",
		111 => "00000000",
		112 => "00000000",
		113 => "00000000",
		114 => "00000000",
		115 => "00000000",
		116 => "00000000",
		117 => "00000000",
		118 => "00000000",
		119 => "00000000",
		120 => "00000000",
		121 => "00000000",
		122 => "00000000",
		123 => "00000000",
		124 => "00000000",
		125 => "00000000",
		126 => "00000000",
		127 => "00000000"
		-- program end (do not alter!)
	);

	signal rdata : std_logic_vector((C_DATA_WIDTH-1) downto 0);
begin
	-- the one and only process: output the data stored at the address (addr)
	rdata <= rom(conv_integer(address_bus));
	
	DO_REG_PROC : process(clk)
	   variable do_reg : std_logic_vector((C_DATA_WIDTH-1) downto 0) := (others=>'0');
	begin
        if(rising_edge(clk)) then
            if read_en = '1' then
                do_reg := rdata;
            end if;
        end if;
        data_bus_out <= do_reg;
	end process DO_REG_PROC;

end LDOI;
