library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx_tb is
-- Testbench nemá žádné vstupní ani výstupní porty
end uart_tx_tb;

architecture Behavioral of uart_tx_tb is

    -- 1. Deklarace komponenty generátoru CLK_EN (podle vašeho kódu)
    component ce_gen is
        Generic (
            G_DIV_FACT : POSITIVE := 2
        );
        Port (
            CLK  : in  STD_LOGIC;
            SRST : in  STD_LOGIC;
            CE   : in  STD_LOGIC;
            CE_O : out STD_LOGIC 
        );
    end component;

    -- 2. Deklarace komponenty testovaného UART vysílače
    component uart_tx is
        Port ( 
            CLK_EN   : in STD_LOGIC;
            TX_START : in STD_LOGIC;
            DATA_IN  : in STD_LOGIC_VECTOR (7 downto 0);
            UART_TXD : out STD_LOGIC;
            TX_BUSY  : out STD_LOGIC;
            CLK      : in STD_LOGIC
        );
    end component;

    -- Konstanty pro časování
    constant C_CLK_PERIOD : time := 20 ns; -- 50 MHz hodiny
    constant C_DIV_FACT   : integer := 10; -- Zrychleno pro simulaci (dle slajdu 38)

    -- Interní signály testbenche pro propojení komponent
    signal sig_clk      : std_logic := '0';
    signal sig_srst     : std_logic := '0'; -- Nepoužívá se uvnitř ce_gen, ale zapojíme ho
    signal sig_ce       : std_logic := '1'; -- Nepoužívá se uvnitř ce_gen, zapojíme na log. 1
    signal sig_clk_en   : std_logic;
    
    signal sig_tx_start : std_logic := '0';
    signal sig_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal sig_uart_txd : std_logic;
    signal sig_tx_busy  : std_logic;

begin


    uut_ce_gen: ce_gen
        generic map (
            G_DIV_FACT => C_DIV_FACT
        )
        port map (
            CLK  => sig_clk,
            SRST => sig_srst,
            CE   => sig_ce,
            CE_O => sig_clk_en
        );


    uut_uart_tx: uart_tx
        port map (
            CLK_EN   => sig_clk_en,
            TX_START => sig_tx_start,
            DATA_IN  => sig_data_in,
            UART_TXD => sig_uart_txd,
            TX_BUSY  => sig_tx_busy,
            CLK      => sig_clk
        );

    clk_process: process
    begin
        sig_clk <= '0';
        wait for C_CLK_PERIOD / 2;
        sig_clk <= '1';
        wait for C_CLK_PERIOD / 2;
    end process;


    stim_process: process
    begin
        wait for 100 ns;
        
        sig_data_in <= x"41"; 
        wait for C_CLK_PERIOD;
        

        sig_tx_start <= '1';
        wait for C_CLK_PERIOD;
        sig_tx_start <= '0';

        wait until falling_edge(sig_tx_busy);
        

        wait for 500 ns; 

        sig_data_in <= x"55";
        wait for C_CLK_PERIOD;
        

        sig_tx_start <= '1';
        wait for 15 * C_CLK_PERIOD;
        sig_tx_start <= '0';
        
        wait until falling_edge(sig_tx_busy);

        wait;
    end process;

end Behavioral;