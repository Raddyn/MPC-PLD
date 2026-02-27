----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/27/2026 09:36:28 AM
-- Design Name: 
-- Module Name: simple_adder_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simple_adder_tb is
--  Port ( );
end simple_adder_tb;

architecture Behavioral of simple_adder_tb is

component simple_adder
    Port (
        A : in STD_LOGIC_VECTOR (3 downto 0);
        B : in STD_LOGIC_VECTOR (3 downto 0);
        Y : out STD_LOGIC_VECTOR (3 downto 0);
        C : out STD_LOGIC;
        Z : out STD_LOGIC
    );
end component simple_adder;

       signal a_sig : STD_LOGIC_VECTOR (3 downto 0);
       signal b_sig : STD_LOGIC_VECTOR (3 downto 0);
       signal y_sig : STD_LOGIC_VECTOR (3 downto 0);
       signal c_sig : STD_LOGIC;
       signal z_sig : STD_LOGIC;
       signal y_ref : STD_LOGIC_VECTOR (3 downto 0);
begin

    simple_adder_i : simple_adder
    Port Map(
        A => a_sig,
        B => b_sig,
        Y => y_sig,
        C => c_sig,
        Z => z_sig
    );

------------------------------------------------------------------------------------------
--stimulus generator
PROCESS
BEGIN
    a_sig <= "0000";
    b_sig <= X"0";
    WAIT FOR 1 ns;
    --b_sig <= std_logic_vector(TO_UNSIGNED(1,b_sig'length));
    --b_sig <= std_logic_vector(TO_UNSIGNED(1,b_sig'length));
    
    -- a_sig <= X"2";
    -- b_sig <= X"4";
    -- WAIT FOR 10 ns;
    
    -- a_sig <= X"1";
    -- b_sig <= X"7";
    -- WAIT FOR 10 ns;
    
    -- a_sig <= X"8";
    -- b_sig <= X"4";
    -- WAIT FOR 10 ns;
    
    for i in 0 to 15 loop
        a_sig <= std_logic_vector(to_unsigned(i,4));
        for j in 0 to 15 loop
            b_sig <= std_logic_vector(to_unsigned(j,4));
            wait for 1 ns;
        end loop;
    end loop;
    

    
    REPORT "Simulation finished!" SEVERITY FAILURE;
    WAIT;
END PROCESS;
-- Output checker
process
    VARIABLE  cnt_err : INTEGER := 0;

    BEGIN
        WAIT ON a_sig,b_sig;
        WAIT FOR 1 ns;    
        y_ref <= STD_LOGIC_VECTOR(UNSIGNED(a_sig) + UNSIGNED(b_sig));
        
    --  ASSERT y_sig = y_ref REPORT "Error in addition!" SEVERITY ERROR;
    
        IF NOT (y_sig = y_ref) THEN
            cnt_err := cnt_err + 1;
        report "Error! Expected: " 
        & integer'image(to_integer(unsigned(y_ref))) 
        & " Got: " 
        & integer'image(to_integer(unsigned(y_sig))) 
        & "(inputs A = " 
        & integer'image(to_integer(unsigned(a_sig)))  
        & ",B = " 
        & integer'image(to_integer(unsigned(b_sig)))
        & " Count: " & integer'image(cnt_err) severity error;
        END IF;    
END PROCESS;

end Behavioral;

        
