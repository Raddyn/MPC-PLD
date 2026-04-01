library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pkg_constants.ALL; 

entity pwm_driver_tb is
end pwm_driver_tb;

architecture Behavioral of pwm_driver_tb is
    component PWM_driver
        Port (
            clk     : in  STD_LOGIC;
            PWM_ref : in  STD_LOGIC_VECTOR ((G_NCH * G_RES)-1 downto 0);
            PWM_OUT : out STD_LOGIC_VECTOR (G_NCH-1 downto 0);
            CNT_OUT : out STD_LOGIC_VECTOR (G_RES-1 downto 0)
        );
    end component;

    constant C_CLK_PERIOD : TIME := 20 ns; 

    signal clk     : STD_LOGIC := '0';
    signal pwm_ref : STD_LOGIC_VECTOR ((G_NCH * G_RES)-1 downto 0) := (others => '0');
    signal pwm_out : STD_LOGIC_VECTOR (G_NCH-1 downto 0);
    signal cnt_out : STD_LOGIC_VECTOR (G_RES-1 downto 0);
    
    signal F_sim_finished : BOOLEAN := FALSE;

begin

    uut : PWM_driver
    port map (
        clk     => clk,
        PWM_ref => pwm_ref,
        PWM_OUT => pwm_out,
        CNT_OUT => cnt_out
    );

    -- Clock Generation
    clk_process : process
    begin
        while not F_sim_finished loop
            clk <= '0';
            wait for C_CLK_PERIOD/2;
            clk <= '1';
            wait for C_CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        wait for 1 ns; 
        --iterate through all channels with incrementing duty cycle
        for i in 0 to G_NCH-1 loop
            pwm_ref((i+1)*G_RES-1 downto i*G_RES) <= std_logic_vector(to_unsigned(i * (2**G_RES) / G_NCH, G_RES));
        end loop;

        wait for C_CLK_PERIOD * 1000; 

        F_sim_finished <= TRUE;
        
        report LF &
               "================================================================" & LF &
               "Simulation finished! Check the waveform window!" & LF &
               "================================================================" & LF
               severity note;
               
        wait;
    end process;

end Behavioral;