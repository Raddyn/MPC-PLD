----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
----------------------------------------------------------------------------------
ENTITY sync_reg IS
  PORT(
    CLK                 : IN    STD_LOGIC;
    SIG_IN              : IN    STD_LOGIC;
    SIG_OUT             : OUT   STD_LOGIC
  );
  END ENTITY sync_reg;
  ----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF sync_reg IS
  ----------------------------------------------------------------------------------
    signal sig_reg        : std_logic;
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of sig_reg : signal is "TRUE";
    attribute SHREG_EXTRACT : string;
    attribute SHREG_EXTRACT of sig_reg : signal is "NO";
    attribute SHREG_EXTRACT of sig_out : signal is "NO";
----------------------------------------------------------------------------------
    COMPONENT d_flipflop
    PORT(
      CLK : IN STD_LOGIC;
      D : IN STD_LOGIC;
      Q : OUT STD_LOGIC
      );
    END COMPONENT d_flipflop;
BEGIN
----------------------------------------------------------------------------------
  reg_1: d_flipflop
  PORT MAP(
    CLK => CLK,
    D => SIG_IN,
    Q => sig_reg
  );
  reg_2: d_flipflop
  PORT MAP(
    CLK => CLK,
    D => sig_reg,
    Q => SIG_OUT
  );
----------------------------------------------------------------------------------
END ARCHITECTURE Behavioral;
----------------------------------------------------------------------------------
