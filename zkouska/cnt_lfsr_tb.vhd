library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cnt_lfsr is
end tb_cnt_lfsr;

architecture Behavioral of tb_cnt_lfsr is

    component cnt_lfsr
        Port ( CLK : in STD_LOGIC;
               EN : in STD_LOGIC;
               RST : in STD_LOGIC;
               DOUT : out STD_LOGIC_VECTOR (7 downto 0);
               STATUS : out STD_LOGIC_VECTOR (17 downto 0));
    end component;

    signal CLK : STD_LOGIC := '0';
    signal EN : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';

    signal DOUT : STD_LOGIC_VECTOR (7 downto 0);
    signal STATUS : STD_LOGIC_VECTOR (17 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    uut: cnt_lfsr PORT MAP (
          CLK => CLK,
          EN => EN,
          RST => RST,
          DOUT => DOUT,
          STATUS => STATUS
        );

    clk_process :process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;

    stim_proc: process
        variable v_start_state : STD_LOGIC_VECTOR(17 downto 0);
        variable v_period_count : integer := 0;
    begin
        RST <= '1';
        EN <= '0';
        wait for CLK_PERIOD * 2;
        
        RST <= '0';
        wait for CLK_PERIOD;        
        v_start_state := STATUS;

        EN <= '1';
        
        wait until rising_edge(CLK);
        v_period_count := v_period_count + 1;



       wait for 1 ns;
        while STATUS /= v_start_state loop
            wait until rising_edge(CLK);
            
            wait for 1 ns;
            v_period_count := v_period_count + 1;
        end loop;
        
        --ukazka resetu na konci simulace
        
        wait for CLK_PERIOD * 2;
        EN <= '0';
        wait for CLK_PERIOD * 2;
        RST <= '1';
        wait for CLK_PERIOD * 2;
        report "=======================================================" severity note;
        report "SIMULACE USPESNE DOKONCENA" severity note;
        report "Pocet pracovnich stavu citace (perioda) je: " & integer'image(v_period_count) severity note;
        report "=======================================================" severity note;

        assert false report "Konec simulace" severity failure;
        
        wait;
    end process;

end Behavioral;