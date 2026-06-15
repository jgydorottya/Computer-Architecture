-- Description: Mono-Pulse-Generator

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mpg is
  port(
        CLK     : in std_logic;
        BTN     : in std_logic;
        RST     : in std_logic;
        
        ENABLE  : out std_logic
  );
end mpg;

architecture Behavioral of mpg is

   signal COUNT     : unsigned(15 downto 0);
   signal REG_EN    : std_logic;
   signal REGS_OUT  : std_logic_vector(0 to 2);
   
begin

    REG_EN <= '1' when COUNT = x"FFFF" else '0';
    
    Counter: process(CLK, RST)
    begin
        if RST = '1' then
            COUNT <= x"0000";
        elsif rising_edge(CLK) then
            COUNT <= COUNT + 1;
        end if; 
    end process;
    
    Registers: process(CLK, RST)
    begin
        if RST = '1' then
            REGS_OUT <= "000";
        elsif rising_edge(CLK) then
            if REG_EN = '1' then
                REGS_OUT(0) <= BTN;
            end if;
            REGS_OUT(1) <= REGS_OUT(0);
            REGS_OUT(2) <= REGS_OUT(1);
        end if;
    end process;
    
    ENABLE <= REGS_OUT(1) and (not REGS_OUT(2)); 
    
end Behavioral;
