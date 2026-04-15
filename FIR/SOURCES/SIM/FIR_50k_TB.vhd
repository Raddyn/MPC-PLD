----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE std.textio.ALL;
----------------------------------------------------------------------------------
entity FIR_50k_TB is
end FIR_50k_TB;
----------------------------------------------------------------------------------
architecture tb of FIR_50k_TB is
----------------------------------------------------------------------------------
  COMPONENT FIR_50k_wrapper IS
  GENERIC (
    SIM_MODEL                           : BOOLEAN := TRUE
  );
  PORT (
    aclk                                : IN  STD_LOGIC;
    s_axis_data_tvalid                  : IN  STD_LOGIC;
    s_axis_data_tready                  : OUT STD_LOGIC;
    s_axis_data_tdata                   : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
    m_axis_data_tvalid                  : OUT STD_LOGIC;
    m_axis_data_tdata                   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
  END COMPONENT FIR_50k_wrapper;
  -----------------------------------------------------------------------
  SIGNAL sig_SIM_finished               : BOOLEAN := FALSE;
  CONSTANT C_aclk_period                : time := 20 ns;
  SIGNAL aclk                           : STD_LOGIC := '0';
  SIGNAL s_axis_data_tvalid             : STD_LOGIC := '0';
  SIGNAL s_axis_data_tready             : STD_LOGIC;
  SIGNAL s_axis_data_tdata              : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
  SIGNAL m_axis_data_tvalid             : STD_LOGIC;
  SIGNAL m_axis_data_tdata              : STD_LOGIC_VECTOR(15 DOWNTO 0);
----------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  -- Clock process
  --------------------------------------------------------------------------------
  P_aclk: PROCESS
  BEGIN
    aclk <= '0'; WAIT FOR C_aclk_period/2;
    aclk <= '1'; WAIT FOR C_aclk_period/2;
    IF sig_SIM_finished THEN WAIT; END IF;
  END PROCESS P_aclk;

  -----------------------------------------------------------------------
  -- Instantiate the DUT
  -----------------------------------------------------------------------
  FIR_50k_wrapper_i : FIR_50k_wrapper
  GENERIC MAP(
    SIM_MODEL           => TRUE
  )
  PORT MAP(
    aclk                => aclk,
    s_axis_data_tvalid  => s_axis_data_tvalid,
    s_axis_data_tready  => s_axis_data_tready,
    s_axis_data_tdata   => s_axis_data_tdata,
    m_axis_data_tvalid  => m_axis_data_tvalid,
    m_axis_data_tdata   => m_axis_data_tdata
  );

  -----------------------------------------------------------------------
  -- FIR input
  --    read FIR_data_in.txt
  --    feed the FIR filter with the data from file
  -----------------------------------------------------------------------
  P_input: PROCESS
    FILE     file_in  : TEXT;
    VARIABLE line_in  : LINE;
    VARIABLE v_number : INTEGER;
  BEGIN
    FILE_OPEN(file_in, "..\..\..\..\SOURCES\FIR_data\FIR_data_in.txt", READ_MODE);

    WAIT UNTIL falling_edge(aclk);

    WHILE NOT ENDFILE(file_in) LOOP
      READLINE(file_in, line_in);
      READ(line_in, v_number);

      s_axis_data_tdata  <= STD_LOGIC_VECTOR(RESIZE(TO_SIGNED(v_number, 9), 16));
      s_axis_data_tvalid <= '1';

      WAIT UNTIL rising_edge(aclk) AND s_axis_data_tready = '1';

      s_axis_data_tvalid <= '0';

      WAIT FOR C_aclk_period * 7;

    END LOOP;

    FILE_CLOSE(file_in);

    WAIT FOR C_aclk_period * 500;

    sig_SIM_finished <= TRUE;
    WAIT;
  END PROCESS P_input;

  -----------------------------------------------------------------------
  -- FIR output data check
  --    read reference data from FIR_data_out.txt
  --    compare the reference and actual data
  --    report any discrepancy (both a text LOG file and simulator console)
  --    report overall test result
  -----------------------------------------------------------------------
  P_output: PROCESS
    FILE     file_out : TEXT;
    FILE     file_log : TEXT;
    VARIABLE line_out  : LINE;
    VARIABLE line_log  : LINE;
    VARIABLE v_expected : INTEGER;
    VARIABLE v_actual   : INTEGER;
    VARIABLE err_count  : INTEGER := 0;
  BEGIN
    FILE_OPEN(file_out, "..\..\..\..\SOURCES\FIR_data\FIR_data_out.txt", READ_MODE);
    FILE_OPEN(file_log, "FIR_sim_LOG.txt", WRITE_MODE);

    WRITE(line_log, STRING'("FIR Filter Simulation LOG"));
    WRITELINE(file_log, line_log);
    WRITE(line_log, STRING'("=========================="));
    WRITELINE(file_log, line_log);

    WAIT UNTIL falling_edge(aclk);

    WHILE NOT ENDFILE(file_out) LOOP

      WAIT UNTIL rising_edge(aclk) AND m_axis_data_tvalid = '1';

      READLINE(file_out, line_out);
      READ(line_out, v_expected);

      v_actual := TO_INTEGER(SIGNED(m_axis_data_tdata(8 DOWNTO 0)));

      IF v_expected /= v_actual THEN
        err_count := err_count + 1;

        WRITE(line_log, STRING'("ERROR at ") & TIME'image(NOW));
        WRITE(line_log, STRING'(" | Expected: "));
        WRITE(line_log, v_expected);
        WRITE(line_log, STRING'(" | Actual: "));
        WRITE(line_log, v_actual);

        -- (WRITELINE clears line_log!)
        REPORT line_log.ALL SEVERITY NOTE;
        WRITELINE(file_log, line_log);

      END IF;

    END LOOP;

    WAIT UNTIL sig_SIM_finished;
    WRITE(line_log, STRING'("=========================="));
    WRITELINE(file_log, line_log);
    WRITE(line_log, STRING'("Total errors: "));
    WRITE(line_log, err_count);
    WRITELINE(file_log, line_log);

    IF err_count = 0 THEN
      WRITE(line_log, STRING'("RESULT: PASS"));
      WRITELINE(file_log, line_log);
      REPORT "SIMULATION PASSED" SEVERITY NOTE;
    ELSE
      WRITE(line_log, STRING'("RESULT: FAIL"));
      WRITELINE(file_log, line_log);
      REPORT "SIMULATION FAILED - Total errors: " & 
             INTEGER'image(err_count) SEVERITY ERROR;
    END IF;

    FILE_CLOSE(file_out);
    FILE_CLOSE(file_log);
    WAIT;
  END PROCESS P_output;

----------------------------------------------------------------------------------
end tb;
----------------------------------------------------------------------------------