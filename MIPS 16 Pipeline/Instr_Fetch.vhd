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
    
    -- NoOp = add $0, $0, $0
    -- R-type: opcode | rs  | rt  | rd  | sa | func
    -- I-type: opcode | rs  | rt  | immediate/address
    
--    signal ROM : rom_type := (
--        0  => b"000_001_010_011_0_000", -- add  $3, $1, $2
--        1  => b"000_011_010_100_0_001", -- sub  $4, $3, $2   ; RAW on $3
--        2  => b"000_001_010_101_0_100", -- and  $3, $1, $2
--        3  => b"000_011_100_110_0_101", -- or   $6, $4, $5   ; RAW on $4
--        4  => b"000_001_010_111_0_111", -- slt  $7, $1, $2
--        5  => b"010_111_101_0000010",   -- lw   $5, 2($7)    ; uses $7 from slt
--        6  => b"011_100_101_0000011",   -- sw   $5, 3($4)    ; RAW on loaded $5
--        7  => b"111_0000000000010",     -- j    2
--        others => x"0000"
--    );

    signal ROM : rom_type := (
        0  => b"000_001_010_011_0_000", -- add  $3, $1, $2
        1  => x"0000",                  -- NoOp
        2  => x"0000",                  -- NoOp
        3  => b"000_011_010_100_0_001", -- sub  $4, $3, $2
        4  => b"000_001_010_011_0_100", -- and  $3, $1, $2
        5  => x"0000",                  -- NoOp
        6  => b"000_100_101_110_0_101", -- or   $6, $4, $5
        7  => b"000_001_010_111_0_111", -- slt  $7, $1, $2
        8  => x"0000",                  -- NoOp
        9  => x"0000",                  -- NoOp
        10 => b"010_111_101_0000010",   -- lw   $5, 2($7)
        11 => x"0000",                  -- NoOp
        12 => x"0000",                  -- NoOp
        13 => b"011_100_101_0000011",   -- sw   $5, 3($4)
        14 => b"111_0000000000011",     -- j    3
        15 => x"0000",                  -- NoOp
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
