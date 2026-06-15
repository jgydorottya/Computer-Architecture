-- Description: 4-digit 7-segment display
 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ssd is
    port(
        CLK:    in std_logic;
        RST:    in std_logic;
        DIGITS: in std_logic_vector(15 downto 0);
        
        CAT:    out std_logic_vector(6 downto 0);  -- active LOW
        AN:     out std_logic_vector(3 downto 0)   -- active LOW
    );
end ssd;

architecture Behavioral of ssd is

    signal COUNTER_OUT  : unsigned(15 downto 0)         := (others => '0');
    signal MUX1_OUT     : std_logic_vector(3 downto 0)  := (others => '0');
    
begin

    Counter: process(CLK, RST)
    begin
        if RST = '1' then
            COUNTER_OUT <= x"0000";
        elsif rising_edge(CLK) then
            COUNTER_OUT <= COUNTER_OUT + 1;
        end if;
    end process;
    
    MUX1: process(DIGITS, COUNTER_OUT(15 downto 14))
    begin
        case COUNTER_OUT(15 downto 14) is
            when "00"   => MUX1_OUT <= DIGITS(3 downto 0);
            when "01"   => MUX1_OUT <= DIGITS(7 downto 4);
            when "10"   => MUX1_OUT <= DIGITS(11 downto 8);
            when others => MUX1_OUT <= DIGITS(15 downto 12);
        end case;
    end process;

--      0
--     ---
--  5 |   | 1
--     ---   <- 6
--  4 |   | 2
--     ---
--      3
    with MUX1_OUT select
        CAT <= "1111001" when "0001",   --1
               "0100100" when "0010",   --2
               "0110000" when "0011",   --3
               "0011001" when "0100",   --4
               "0010010" when "0101",   --5
               "0000010" when "0110",   --6
               "1111000" when "0111",   --7
               "0000000" when "1000",   --8
               "0010000" when "1001",   --9
               "0001000" when "1010",   --A
               "0000011" when "1011",   --b
               "1000110" when "1100",   --C
               "0100001" when "1101",   --d
               "0000110" when "1110",   --E
               "0001110" when "1111",   --F
               "1000000" when others;   --0
    
    MUX2: process(COUNTER_OUT(15 downto 14))
    begin
        case COUNTER_OUT(15 downto 14) is
            when "00"   => AN <= "1110";
            when "01"   => AN <= "1101";
            when "10"   => AN <= "1011";
            when others => AN <= "0111";
        end case;
    end process;
       
end Behavioral;
