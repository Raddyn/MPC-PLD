----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
ENTITY edge_detector IS
  PORT(
    CLK                 : IN    STD_LOGIC;
    SIG_IN              : IN    STD_LOGIC;
    EDGE_POS            : OUT   STD_LOGIC;
    EDGE_NEG            : OUT   STD_LOGIC;
    EDGE_ANY            : OUT   STD_LOGIC
  );
END ENTITY edge_detector;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF edge_detector IS
----------------------------------------------------------------------------------
signal sig_in_delayed : std_logic;
----------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------
delay_process: PROCESS(CLK) BEGIN
  IF rising_edge(CLK) THEN
    sig_in_delayed <= SIG_IN;
  END IF;
END PROCESS delay_process;

edge_proc: PROCESS(CLK) BEGIN
  IF rising_edge(CLK) THEN
    if (SIG_IN = '1' and sig_in_delayed = '0') then
      EDGE_POS <= '1';
    else
      EDGE_POS <= '0';
    end if;

    if (SIG_IN = '0' and sig_in_delayed = '1') then
      EDGE_NEG <= '1';
    else
      EDGE_NEG <= '0';
    end if;

    if (SIG_IN /= sig_in_delayed) then
      EDGE_ANY <= '1';
    else
      EDGE_ANY <= '0';
    end if;
  END IF;
END PROCESS edge_proc;

----------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;
----------------------------------------------------------------------------------
