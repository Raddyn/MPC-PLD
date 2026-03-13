----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
ENTITY bcd_counter IS
  PORT(
    CLK                 : IN    STD_LOGIC;      -- clock signal
    CE_100HZ            : IN    STD_LOGIC;      -- 100 Hz clock enable
    CNT_RESET           : IN    STD_LOGIC;      -- counter reset
    CNT_ENABLE          : IN    STD_LOGIC;      -- counter enable
    DISP_ENABLE         : IN    STD_LOGIC;      -- enable display update
    CNT_0               : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    CNT_1               : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    CNT_2               : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
    CNT_3               : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0)
  );
END ENTITY bcd_counter;
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF bcd_counter IS
----------------------------------------------------------------------------------
signal ss_mm_0 : std_logic_vector(3 downto 0) := (others => '0');
signal ss_mm_1 : std_logic_vector(3 downto 0) := (others => '0');
signal ss_mm_2 : std_logic_vector(3 downto 0) := (others => '0');
signal ss_mm_3 : std_logic_vector(3 downto 0) := (others => '0');

----------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------
  -- BCD counter
process(CLK) BEGIN
  IF rising_edge(CLK) THEN
    IF CNT_RESET = '1' THEN
    ss_mm_0 <= (others => '0');
    ss_mm_1 <= (others => '0');
    ss_mm_2 <= (others => '0');
    ss_mm_3 <= (others => '0');
    ELSIF CNT_ENABLE = '1' THEN
      IF CE_100HZ = '1' THEN
        if ss_mm_0 = "1001" then
          ss_mm_0 <= (others => '0');
          if ss_mm_1 = "1001" then
            ss_mm_1 <= (others => '0');
            if ss_mm_2 = "1001" then
              ss_mm_2 <= (others => '0');
              if ss_mm_3 = "0101" then
                ss_mm_3 <= (others => '0');
              else
                ss_mm_3 <= std_logic_vector(unsigned(ss_mm_3) + 1);
              end if;
            else
              ss_mm_2 <= std_logic_vector(unsigned(ss_mm_2) + 1);
            end if;
          else
            ss_mm_1 <= std_logic_vector(unsigned(ss_mm_1) + 1);
          end if;
        else
          ss_mm_0 <= std_logic_vector(unsigned(ss_mm_0) + 1);
        end if;
      END IF;
    END IF;
  END IF;
END PROCESS;
  --------------------------------------------------------------------------------
  -- Output (display) register
process(CLK) BEGIN
  IF rising_edge(CLK) THEN
    if DISP_ENABLE = '1' then
      CNT_0 <= ss_mm_0;
      CNT_1 <= ss_mm_1;
      CNT_2 <= ss_mm_2;
      CNT_3 <= ss_mm_3;
    END IF;
  END IF;
END PROCESS;

----------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;
----------------------------------------------------------------------------------
