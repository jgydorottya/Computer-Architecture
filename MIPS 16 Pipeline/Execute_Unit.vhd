-- Description: Instruction-Execute-Unit = ALU + ALU-control + Adder 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Execute_Unit is
    port(
        -- inputs
        PC_PLUS_ONE : in std_logic_vector(15 downto 0);
        RD1         : in std_logic_vector(15 downto 0);
        RD2         : in std_logic_vector(15 downto 0);
        EXT_IMM     : in std_logic_vector(15 downto 0);
        FUNC        : in std_logic_vector(2 downto 0);
        SA          : in std_logic;
        -- control signals
        ALU_SRC     : in std_logic;
        ALU_OP      : in std_logic_vector(2 downto 0);
        -- outputs
        BRANCH_ADDR : out std_logic_vector(15 downto 0);
        ALU_RES     : out std_logic_vector(15 downto 0);
        ZERO        : out std_logic
    );
end Execute_Unit;

architecture Behavioral of Execute_Unit is

    signal ALU_IN2  : std_logic_vector(15 downto 0);
    signal ALU_CTRL : std_logic_vector(2 downto 0);
    signal ALU_OUT  : std_logic_vector(15 downto 0);
    
begin
    
    -- select 2nd ALU operand
    ALU_IN2 <= RD2 when ALU_SRC = '0' else EXT_IMM;
    
    -- ALU control:
    -- ALU_OP = 111 means R-type -> use FUNC
    -- otherwise ALU_OP already is final ALU command
    ALU_CTRL <= FUNC when ALU_OP = "111" else ALU_OP;
    
    -- ALU
    ALU: process(RD1, RD2, ALU_IN2, ALU_CTRL, SA)
    begin
        case ALU_CTRL is
            when "000" =>       -- ADD
                ALU_OUT <= std_logic_vector(signed(RD1) + signed(ALU_IN2));
            when "001" =>       -- SUB
                ALU_OUT <= std_logic_vector(signed(RD1) - signed(ALU_IN2));
            when "010" =>       -- SLL
                if SA = '1' then
                    ALU_OUT <= RD2(14 downto 0) & '0';
                else
                    ALU_OUT <= RD2;
                end if;
            when "011" =>       -- SRL
                if SA = '1' then
                    ALU_OUT <= '0' & RD2(15 downto 1);
                else
                    ALU_OUT <= RD2;
                end if; 
            when "100" =>       -- AND
                ALU_OUT <= RD1 and ALU_IN2;
            when "101" =>       -- OR
                ALU_OUT <= RD1 or ALU_IN2;
            when "110" =>       -- XOR
                ALU_OUT <= RD1 xor ALU_IN2;
            when "111" =>       -- SLT
                if signed(RD1) < signed(ALU_IN2) then
                    ALU_OUT <= x"0001";
                else
                    ALU_OUT <= x"0000";
                end if;
            when others => ALU_OUT <= x"0000";
        end case;
    end process;
    
    ALU_RES <= ALU_OUT;
    
    -- branch target address
    BRANCH_ADDR <= std_logic_vector(signed(PC_PLUS_ONE) + signed(EXT_IMM));
    
    -- zero flag
    ZERO <= '1' when ALU_OUT = x"0000" else '0';
    
end Behavioral;
