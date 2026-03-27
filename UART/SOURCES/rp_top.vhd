----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
----------------------------------------------------------------------------------
ENTITY rp_top IS
  PORT(
    CLK             : IN  STD_LOGIC;
    BTN             : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    SW              : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    LED             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    DISP_SEG        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    DISP_DIG        : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
    UART_TXD        : OUT STD_LOGIC
  );
END ENTITY rp_top;
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF rp_top IS
----------------------------------------------------------------------------------

  COMPONENT seg_disp_driver
  PORT(
    CLK             : IN  STD_LOGIC;
    DIG_1           : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    DIG_2           : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    DIG_3           : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    DIG_4           : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
    DP              : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);        -- [DP4 DP3 DP2 DP1]
    DOTS            : IN  STD_LOGIC_VECTOR (2 DOWNTO 0);        -- [L3 L2 L1]
    DISP_SEG        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
    DISP_DIG        : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
  );
  END COMPONENT seg_disp_driver;

  COMPONENT ce_gen
    GENERIC (
      G_DIV_FACT          : POSITIVE := 2
    );
  PORT(
    CLK             : IN  STD_LOGIC;
    SRST            : IN  STD_LOGIC;
    CE              : IN  STD_LOGIC;
    CE_O            : OUT STD_LOGIC 
  );
  END COMPONENT ce_gen;

  COMPONENT btn_in
  GENERIC(
    G_DEB_PERIOD        : POSITIVE := 3
  );
  PORT(
    CLK                 : IN    STD_LOGIC;
    CE                  : IN    STD_LOGIC;
    BTN                 : IN    STD_LOGIC;
    BTN_DEBOUNCED       : OUT   STD_LOGIC;
    BTN_EDGE_POS        : OUT   STD_LOGIC;
    BTN_EDGE_NEG        : OUT   STD_LOGIC;
    BTN_EDGE_ANY        : OUT   STD_LOGIC
  );
  END COMPONENT btn_in;

  COMPONENT bcd_counter
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
  END COMPONENT bcd_counter;


  COMPONENT stopwatch_fsm
  PORT(
    CLK             : IN    STD_LOGIC;
    BTN_S_S         : IN    STD_LOGIC;
    BTN_L_C         : IN    STD_LOGIC;
    CNT_RESET       : OUT   STD_LOGIC;
    CNT_ENABLE      : OUT   STD_LOGIC;
    DISP_ENABLE     : OUT   STD_LOGIC
  );
  END COMPONENT stopwatch_fsm;


  COMPONENT uart_tx
    PORT(
      CLK_EN   : in  STD_LOGIC;
      TX_START : in  STD_LOGIC;
      DATA_IN  : in  STD_LOGIC_VECTOR (7 downto 0);
      UART_TXD : out STD_LOGIC;
      TX_BUSY  : out STD_LOGIC;
      CLK      : in  STD_LOGIC
    );
    END COMPONENT uart_tx;


  ------------------------------------------------------------------------------

  SIGNAL cnt_0              : STD_LOGIC_VECTOR( 3 DOWNTO 0);
  SIGNAL cnt_1              : STD_LOGIC_VECTOR( 3 DOWNTO 0);
  SIGNAL cnt_2              : STD_LOGIC_VECTOR( 3 DOWNTO 0);
  SIGNAL cnt_3              : STD_LOGIC_VECTOR( 3 DOWNTO 0);
  SIGNAL ce_100hz           : STD_LOGIC;
  SIGNAL BTN_S_S             : STD_LOGIC;
  SIGNAL BTN_L_C             : STD_LOGIC;
  SIGNAL CNT_RESET_SIG           : STD_LOGIC;
  SIGNAL CNT_ENABLE_SIG          : STD_LOGIC;
  SIGNAL DISP_ENABLE_SIG         : STD_LOGIC;
  

  --uart
  SIGNAL sig_uart_ce        : STD_LOGIC;
  SIGNAL sig_btn_uart_start : STD_LOGIC;
  SIGNAL sig_uart_data      : STD_LOGIC_VECTOR(7 DOWNTO 0);
  
  SIGNAL msg_counter         : INTEGER := 0;
  type t_msg_array is array (0 to 13) of std_logic_vector(7 downto 0);
  constant C_HELLO_MSG : t_msg_array := (
      x"48", x"65", x"6C", x"6C", x"6F", x"20", -- "Hello "
      x"57", x"6F", x"72", x"6C", x"64", x"21", -- "World!"
      x"0D", x"0A"                              -- CR, LF
  );
----------------------------------------------------------------------------------
BEGIN
----------------------------------------------------------------------------------
  -- sen ascii data sequence to uart_tx  
  process(clk) begin
    if rising_edge(clk) then
        if sig_btn_uart_start = '1' then
            sig_uart_data <= C_HELLO_MSG(msg_counter);
            msg_counter <= msg_counter + 1;
        end if;
    end if;
  end process;
  --------------------------------------------------------------------------------
  -- display driver
  --
  --       DIG 1       DIG 2       DIG 3       DIG 4
  --                                       L3
  --       -----       -----       -----   o   -----
  --      |     |     |     |  L1 |     |     |     |
  --      |     |     |     |  o  |     |     |     |
  --       -----       -----       -----       -----
  --      |     |     |     |  o  |     |     |     |
  --      |     |     |     |  L2 |     |     |     |
  --       -----  o    -----  o    -----  o    -----  o
  --             DP1         DP2         DP3         DP4
  --
  --------------------------------------------------------------------------------

  seg_disp_driver_i : seg_disp_driver
  PORT MAP(
    CLK                 => CLK,
    DIG_1               => cnt_3,
    DIG_2               => cnt_2,
    DIG_3               => cnt_1,
    DIG_4               => cnt_0,
    DP                  => "0000",
    DOTS                => "011",
    DISP_SEG            => DISP_SEG,
    DISP_DIG            => DISP_DIG
  );

  --------------------------------------------------------------------------------
  -- clock enable generator
  ce_gen_i : ce_gen
  GENERIC MAP(
    G_DIV_FACT          => 500000
  )
  PORT MAP(
    CLK                 => CLK,
    SRST                => '0',
    CE                  => '1',
    CE_O                => ce_100hz
  );


  --------------------------------------------------------------------------------
  -- button input module
  btn_in_s_s : btn_in
  GENERIC MAP(
    G_DEB_PERIOD        => 3
  )
  PORT MAP(
    CLK                 => CLK,
    CE                  => ce_100hz,
    BTN                 => BTN(0),
    BTN_DEBOUNCED       => open,
    BTN_EDGE_POS        => BTN_S_S,
    BTN_EDGE_NEG        => open,
    BTN_EDGE_ANY        => open
  );

  btn_in_l_c : btn_in
  GENERIC MAP(
    G_DEB_PERIOD        => 3
  )
  PORT MAP(
    CLK                 => CLK,
    CE                  => ce_100hz,
    BTN                 => BTN(3),
    BTN_DEBOUNCED       => open,
    BTN_EDGE_POS        => BTN_L_C,
    BTN_EDGE_NEG        => open,
    BTN_EDGE_ANY        => open
  );


  --------------------------------------------------------------------------------
  -- stopwatch module (4-decade BCD counter)

  bcd_counter_i : bcd_counter
  PORT MAP(
    CLK                 => CLK,
    CE_100HZ            => ce_100hz,
    CNT_RESET           => CNT_RESET_SIG,
    CNT_ENABLE          => CNT_ENABLE_SIG,
    DISP_ENABLE         => DISP_ENABLE_SIG,
    CNT_0               => cnt_0,
    CNT_1               => cnt_1,
    CNT_2               => cnt_2,
    CNT_3               => cnt_3
  );

  --------------------------------------------------------------------------------
  -- stopwatch control FSM
  stopwatch_fsm_i : stopwatch_fsm
  PORT MAP(
    CLK                 => CLK,
    BTN_S_S             => BTN_S_S,
    BTN_L_C             => BTN_L_C,
    CNT_RESET           => CNT_RESET_SIG,
    CNT_ENABLE          => CNT_ENABLE_SIG,
    DISP_ENABLE         => DISP_ENABLE_SIG
  );
  

  ce_gen_uart : ce_gen
  GENERIC MAP(
    G_DIV_FACT          => 434
  )
  PORT MAP(
    CLK                 => CLK,
    SRST                => '0',
    CE                  => '1',
    CE_O                => sig_uart_ce
  );


  btn_in_uart_start : btn_in
  GENERIC MAP( G_DEB_PERIOD => 3 )
  PORT MAP(
    CLK           => CLK,
    CE            => ce_100hz,  
    BTN           => BTN(1),
    BTN_EDGE_POS  => sig_btn_uart_start, 
    BTN_DEBOUNCED => open, BTN_EDGE_NEG => open, BTN_EDGE_ANY => open
  );

  uart_tx_i : uart_tx
  PORT MAP(
    CLK      => CLK,
    CLK_EN   => sig_uart_ce,        
    TX_START => sig_btn_uart_start, 
    DATA_IN  => sig_uart_data,      
    UART_TXD => UART_TXD,
    TX_BUSY  => LED(7)
  );


  --------------------------------------------------------------------------------
  -- LED connection

  LED(6 downto 4) <= cnt_3(2 downto 0); 
  LED(3 downto 0) <= cnt_2;

----------------------------------------------------------------------------------
END ARCHITECTURE Structural;
----------------------------------------------------------------------------------
