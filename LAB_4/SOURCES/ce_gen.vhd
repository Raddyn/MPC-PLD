----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
ENTITY ce_gen IS
  GENERIC (
    G_DIV_FACT          : POSITIVE := 2
  );
  PORT (
    CLK                 : IN  STD_LOGIC;
    SRST                : IN  STD_LOGIC;
    CE                  : IN  STD_LOGIC;
    CE_O                : OUT STD_LOGIC 
  );
END ENTITY ce_gen;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF ce_gen IS
----------------------------------------------------------------------------------
SIGNAL cnt_div : INTEGER RANGE 0 TO G_DIV_FACT := 0;
----------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------
  clk_en_gen: PROCESS (CLK) BEGIN
    IF rising_edge(CLK) THEN
      if cnt_div = G_DIV_FACT-1 then
        cnt_div <= 0;
        CE_O <= '1';
      else
        cnt_div <= cnt_div + 1;
        CE_O <= '0';
      end if;
    end if;
  END PROCESS clk_en_gen;
----------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;
----------------------------------------------------------------------------------
