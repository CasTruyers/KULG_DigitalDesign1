library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity auto_repeat is
  generic (
    C_F_CLK   : natural := 100000000; -- system clock frequency
    T_LONG    : natural := 2000,      -- long press duration in ms (2 seconds)
    T_REPEAT  : natural := 100        -- repeat interval in ms (100ms)
  );
  port (
    clk   : in std_logic;
    btn   : in std_logic;  -- button input signal
    pulse : out std_logic  -- output pulses
  );
end auto_repeat;

architecture Behavioral of auto_repeat is
  -- Calculating clock pulses for correc timing
  constant C_T_LONG   : integer := (C_F_CLK / 1000) * T_LONG;
  constant C_T_REPEAT : integer := (C_F_CLK / 1000) * T_REPEAT;
  
  signal hold_counter   : integer := 0;
  signal repeat_counter : integer := 0;
  signal auto_active    : std_logic := '0';
begin

  process(clk)
  begin
    if rising_edge(clk) then
-- Counting how long the button is being pressed
      if btn = '1' then
        if hold_counter < C_T_LONG then
          hold_counter <= hold_counter + 1; -- Increasing the counter
          pulse <= '0'; -- Not pressed long enough yet so pulse = 0
        else -- When pressed it long enough (2000ms or C_T_LONG cycles)
          auto_active <= '1';
          -- Generating pulse at 200 ms interval
          if repeat_counter < C_T_REPEAT then
            pulse <= '1';
            repeat_counter <= 0;
          else
            pulse <= '0';
            repeat_counter <= repeat_counter + 1;
          end if;
        end if;
      else
        -- Reset counters when button is released
        hold_counter   <= 0;
        repeat_counter <= 0;
        auto_active    <= '0';
        pulse          <= '0';
      end if;
    end if;
  end process;

end Behavioral;