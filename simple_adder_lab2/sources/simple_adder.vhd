library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

------------------------------------------------------------------------------------------
entity simple_adder is
    Port ( A : in STD_LOGIC_VECTOR (3 downto 0);
    B : in STD_LOGIC_VECTOR (3 downto 0);
    Y : out STD_LOGIC_VECTOR (3 downto 0);
    C : out STD_LOGIC;
    Z : out STD_LOGIC
    );
end simple_adder;
------------------------------------------------------------------------------------------
architecture Behavioral of simple_adder is
------------------------------------------------------------------------------------------
    signal A_UNS: unsigned(A'high downto A'low); --ekvivalentni s normalnim zapisem
    signal B_UNS: unsigned(3 downto 0);
    signal Y_UNS: unsigned(4 downto 0);
------------------------------------------------------------------------------------------
begin
------------------------------------------------------------------------------------------
A_UNS <= unsigned(A);
B_UNS <= unsigned(B);

Y_UNS <= "00000" + A_UNS + B_UNS;

Z <= '1' when (Y_UNS(3 downto 0)) = "0000" else '0';

C <= std_logic(Y_UNS(4));
Y <= std_logic_vector(Y_UNS(3 downto 0));
------------------------------------------------------------------------------------------
end Behavioral;
------------------------------------------------------------------------------------------
