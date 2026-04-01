library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.pkg_constants.ALL; 

entity PWM_driver is
    Port ( 
        clk     : in  STD_LOGIC;
        -- Port sized dynamically based on the package constants
        PWM_ref : in  STD_LOGIC_VECTOR ((G_NCH * G_RES)-1 downto 0);
        PWM_OUT : out STD_LOGIC_VECTOR (G_NCH-1 downto 0);
        CNT_OUT : out STD_LOGIC_VECTOR (G_RES-1 downto 0)
    );
end PWM_driver;

architecture Behavioral of PWM_driver is
    signal Counter : unsigned(G_RES-1 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            
            -- 100% duty cycle fix: count 0 to 254
            if Counter = (2**G_RES) - 2 then
                Counter <= (others => '0');
            else
                Counter <= Counter + 1;
            end if;

            -- Evaluate all channels based on G_NCH from the package
            for i in 0 to G_NCH-1 loop
                if Counter < unsigned(PWM_ref((i+1)*G_RES-1 downto i*G_RES)) then
                    PWM_OUT(i) <= '1';
                else
                    PWM_OUT(i) <= '0';
                end if;
            end loop;
            
        end if;
    end process;
    
    CNT_OUT <= std_logic_vector(Counter);

end Behavioral;