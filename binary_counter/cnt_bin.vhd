library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cnt_bin is
    Port ( CNT : out STD_LOGIC_VECTOR (31 downto 0);
           CLK : in STD_LOGIC;
           SRST : in STD_LOGIC;
           CE : in STD_LOGIC;
           CNT_LOAD : in STD_LOGIC;
           CNT_UP : in STD_LOGIC);
end cnt_bin;

architecture Behavioral of cnt_bin is
    SIGNAL cnt_sig  : std_logic_vector (31 downto 0) := (others => '0');
begin

    PROCESS (CLK) BEGIN
        IF rising_edge(CLK) THEN
            IF SRST = '1' THEN
                cnt_sig <= (others => '0');
            
            ELSIF CE = '1' THEN
                IF CNT_LOAD = '1' THEN
                cnt_sig <= x"55555555";
                ELSIF CNT_UP = '1' THEN
                    cnt_sig <= std_logic_vector( UNSIGNED(cnt_sig ) + 1);
                ELSE
                    cnt_sig <= std_logic_vector( UNSIGNED(cnt_sig ) - 1);          
                END IF;
            END IF;
        END IF;
    END PROCESS;
    CNT <= cnt_sig;
end Behavioral;
