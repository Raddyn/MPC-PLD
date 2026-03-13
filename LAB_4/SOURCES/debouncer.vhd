----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
ENTITY debouncer IS
  GENERIC(
    G_DEB_PERIOD        : POSITIVE := 3
  );    
  PORT( 
    CLK                 : IN    STD_LOGIC;
    CE                  : IN    STD_LOGIC;
    BTN_IN              : IN    STD_LOGIC;
    BTN_OUT             : OUT   STD_LOGIC
  );
END ENTITY debouncer;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF debouncer IS
----------------------------------------------------------------------------------
  SIGNAL shift_reg      : STD_LOGIC_VECTOR(G_DEB_PERIOD-1 DOWNTO 0);
  -- IDK PROC ALE BEZ PREDDEFINOVANEHO JEDNICKOVE VEKTORU NEECHTEL DELAT PODMINKU WHEN SKRZE OTHRES
  SIGNAl ones_vector     : STD_LOGIC_VECTOR(G_DEB_PERIOD-1 DOWNTO 0) := (OTHERS => '1');
----------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------
debounce_proc: PROCESS(CLK) BEGIN
  IF rising_edge(CLK) THEN
    if CE = '1' then
      shift_reg <= shift_reg(G_DEB_PERIOD-2 DOWNTO 0) & BTN_IN;
    end if;
  END IF;
END PROCESS debounce_proc;

BTN_OUT <= '1' WHEN shift_reg = ones_vector ELSE '0';
----------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;
----------------------------------------------------------------------------------
