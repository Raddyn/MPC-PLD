library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cnt_lfsr is
    Port ( CLK : in STD_LOGIC;
           EN : in STD_LOGIC;
           RST : in STD_LOGIC;
           DOUT : out STD_LOGIC_VECTOR (7 downto 0);
           STATUS : out STD_LOGIC_VECTOR (17 downto 0));
end cnt_lfsr;

architecture Behavioral of cnt_lfsr is

    signal lfsr_reg : STD_LOGIC_VECTOR (17 downto 0) := "000000000011111111";

begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                lfsr_reg <= "000000000011111111";
            elsif EN = '1' then
                lfsr_reg <= lfsr_reg(16 downto 0) & (lfsr_reg(17) XOR lfsr_reg(9));
            end if;
        end if;
    end process;
            
    STATUS <= lfsr_reg;

    DOUT(7) <= lfsr_reg(5);
    DOUT(6) <= lfsr_reg(12);
    DOUT(5) <= lfsr_reg(10);
    DOUT(4) <= lfsr_reg(11);
    DOUT(3) <= lfsr_reg(4);
    DOUT(2) <= lfsr_reg(6);
    DOUT(1) <= lfsr_reg(8);
    DOUT(0) <= lfsr_reg(7);


end Behavioral;
