library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity uart_tx is
    Port ( CLK_EN : in STD_LOGIC;
           TX_START : in STD_LOGIC;
           DATA_IN : in STD_LOGIC_VECTOR (7 downto 0);
           UART_TXD : out STD_LOGIC;
           TX_BUSY : out STD_LOGIC;
           CLK : in STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is

        TYPE t_st_uart IS (st_idle, st_start_b,
            st_bit_0, st_bit_1, st_bit_2, st_bit_3,
            st_bit_4, st_bit_5, st_bit_6, st_bit_7, st_stop_b);
            
        
        SIGNAL pres_st : t_st_uart := st_idle;
        SIGNAL next_st : t_st_uart;
        
        
        SIGNAL sig_data_register : std_logic_vector(7 DOWNTO 0);
        SIGNAL sig_data_tx : std_logic;


        SIGNAL sig_tx_busy : std_logic := '0';
begin

    process (CLK) BEGIN
        IF rising_edge(CLK) THEN
            if  pres_st = st_idle AND TX_START = '1' and sig_tx_busy = '0' then
                sig_data_register <= DATA_IN;
                sig_tx_busy <= '1';
            end if;
            if CLK_EN = '1' AND sig_tx_busy = '1' then
                pres_st <= next_st;
                if next_st = st_idle then
                    sig_tx_busy <= '0';
                end if;
            end if;

        END IF;
    
    END PROCESS;


    PROCESS (pres_st) BEGIN
    
        CASE  pres_st IS 
            when st_idle    => next_st <= st_start_b;
            WHEN st_start_b => next_st <= st_bit_0;
            WHEN st_bit_0 => next_st <= st_bit_1;
            WHEN st_bit_1 => next_st <= st_bit_2;
            WHEN st_bit_2 => next_st <= st_bit_3;
            WHEN st_bit_3 => next_st <= st_bit_4;
            WHEN st_bit_4 => next_st <= st_bit_5;
            WHEN st_bit_5 => next_st <= st_bit_6;
            WHEN st_bit_6 => next_st <= st_bit_7;
            WHEN st_bit_7 => next_st <= st_stop_b;
            WHEN st_stop_b => next_st <= st_idle;
        END CASE;
    END PROCESS;
    
    output_logic: process (pres_st, sig_data_register) 
    begin
        case pres_st is
            when st_idle    => sig_data_tx <= '1';
            when st_start_b => sig_data_tx <= '0';
            when st_bit_0   => sig_data_tx <= sig_data_register(0);
            when st_bit_1   => sig_data_tx <= sig_data_register(1);
            when st_bit_2   => sig_data_tx <= sig_data_register(2);
            when st_bit_3   => sig_data_tx <= sig_data_register(3);
            when st_bit_4   => sig_data_tx <= sig_data_register(4);
            when st_bit_5   => sig_data_tx <= sig_data_register(5);
            when st_bit_6   => sig_data_tx <= sig_data_register(6);
            when st_bit_7   => sig_data_tx <= sig_data_register(7);
            when st_stop_b  => sig_data_tx <= '1';
            when others     => sig_data_tx <= '1';
        end case;
    end process;


    process (CLK) begin
        if rising_edge(CLK) then
            UART_TXD <= sig_data_tx;
        end if;
    end process;
    
    TX_BUSY <= sig_tx_busy;
end Behavioral;
