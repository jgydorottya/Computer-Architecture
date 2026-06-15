-- Description: Instruction-Fetch-Unit = Program-Counter + ROM + Adder

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instr_Fetch is
    port(
        -- inputs
        CLK         : in std_logic;
        PC_EN       : in std_logic;
        PC_RST      : in std_logic;
        BRANCH_ADDR : in std_logic_vector(15 downto 0);
        JUMP_ADDR   : in std_logic_vector(15 downto 0);
        -- control signals
        JUMP        : in std_logic;
        PC_SRC      : in std_logic;
        -- outputs
        INSTR       : out std_logic_vector(15 downto 0);
        PC_PLUS_ONE : out std_logic_vector(15 downto 0)
    );
end Instr_Fetch;

architecture Behavioral of Instr_Fetch is

    type rom_type is array (0 to 15) of std_logic_vector(15 downto 0);
    signal ROM : rom_type := (
        -- R-type:   opcode(3) | rs(3) | rt(3) | rd(3) | sa(1) | function(3)
        0  => b"000_001_010_011_0_000",  -- x"0530"      ~ add  $3, $1, $2       
        1  => b"000_001_010_011_0_001",  -- x"0531"      ~ sub  $3, $1, $2
        2  => b"000_000_001_011_1_010",  -- x"00BA"      ~ sll  $3, $1, 1
        3  => b"000_000_001_011_1_011",  -- x"00BB"      ~ srl  $3, $1, 1
        4  => b"000_001_010_011_0_100",  -- x"0534"      ~ and  $3, $1, $2
        5  => b"000_001_010_011_0_101",  -- x"0535"      ~ or   $3, $1, $2
        6  => b"000_001_010_011_0_110",  -- x"0536"      ~ xor  $3, $1, $2
        7  => b"000_001_010_011_0_111",  -- x"0537"      ~ slt  $3, $1, $2
        -- I-type: opcode(3) | rs(3) | rt(3) | addr/immediate(7)
        8  => b"001_001_010_0000101",   -- x"2505"      ~ addi $2, $1, 5
        9  => b"010_001_010_0000010",   -- x"4502"      ~ lw   $2, 2($1)
        10 => b"011_001_010_0000011",   -- x"6503"      ~ sw   $2, 3($1)
        11 => b"100_001_010_0000001",   -- x"8501"      ~ beq  $2, $1, 1
        12 => b"101_001_010_0000011",   -- x"A503"      ~ andi $2, $1, 3
        13 => b"110_001_010_0001000",   -- x"C508"      ~ ori  $2, $1, 8
        -- J-type: opcode(3) | target-addr(13)
        14 => b"111_0000000000010",     -- x"E002"      ~ j    2
        others => x"0000"
    );
    
    signal PC_IN    : std_logic_vector(15 downto 0);
    signal PC_OUT   : std_logic_vector(15 downto 0);
    
begin
            
    PC: process(CLK, PC_RST)
    begin
        if rising_edge(CLK) then
            if PC_RST = '1' then
                PC_OUT <= x"0000";
            elsif PC_EN = '1' then
                PC_OUT <= PC_IN;
            end if;
        end if;
    end process;

    INSTR <= ROM(to_integer(unsigned(PC_OUT(3 downto 0))));
    
    PC_PLUS_ONE <= std_logic_vector(unsigned(PC_OUT) + 1);
    
    PC_IN <= JUMP_ADDR when JUMP = '1' else
             BRANCH_ADDR when PC_SRC = '1' else
             std_logic_vector(unsigned(PC_OUT) + 1);
    
end Behavioral;
