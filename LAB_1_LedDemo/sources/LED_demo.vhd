----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
----------------------------------------------------------------------
entity LED_demo is
    Port ( 
    -- DATA : in INTEGER;
    -- CLK : in STD_LOGIC;                        -- 0 1
    -- DATA_OUT : in BIT_VECTOR(31 DOWNTO 0);
    
    SW : in STD_LOGIC_VECTOR (3 downto 0);
    BTN : in STD_LOGIC_VECTOR (3 downto 0);
    LED : out STD_LOGIC_VECTOR (7 downto 0)
    );
end LED_demo;
----------------------------------------------------------------------
architecture Behavioral of LED_demo is

begin
    -- LED(0) <= BTN(0);
    -- LED(1) <= NOT BTN(1);
    
    -- LED(2) <= '0';
    
    -- LED(3) <= '1';

    -- LED(7 DOWNTO 4) <= "1100";
    

    LED <= "11111111" when (BTN = "0110" and SW = "0110")
           else "00000000";
end Behavioral;
----------------------------------------------------------------------