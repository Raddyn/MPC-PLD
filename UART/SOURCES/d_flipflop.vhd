library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity d_flipflop is
    Port ( CLK : in STD_LOGIC;
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end d_flipflop;

architecture Behavioral of d_flipflop is

begin

    process(clk)
    begin
        if rising_edge(clk) then
            Q <= D;
        end if;
    end process;
end Behavioral;
