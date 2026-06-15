-- Description: MIPS full implementation

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS is
    port(
        -- inputs
        CLK     : in std_logic;
        SW      : in std_logic_vector(15 downto 0);
        BTN     : in std_logic_vector (4 downto 0);
        -- outputs
        LED     : out std_logic_vector(15 downto 0);
        CAT     : out std_logic_vector(6 downto 0);
        AN      : out std_logic_vector(3 downto 0)
    );
end MIPS;

architecture Behavioral of MIPS is
    
    -- MPG outputs
    signal PC_EN        : std_logic;
    signal PC_RST       : std_logic;
    
    -- Control_Unit I/O
    signal REG_DST      : std_logic;
    signal REG_WRITE    : std_logic;
    signal ALU_SRC      : std_logic;
    signal ALU_OP       : std_logic_vector(2 downto 0);
    signal MEM_TO_REG   : std_logic;
    signal MEM_WRITE    : std_logic;
    signal EXT_OP       : std_logic;
    signal BRANCH       : std_logic;
    signal JUMP         : std_logic;
    
    -- Instr_Fetch I/O
    signal BRANCH_ADDR  : std_logic_vector(15 downto 0);
    signal JUMP_ADDR    : std_logic_vector(15 downto 0);
    signal PC_SRC       : std_logic;
    signal INSTR        : std_logic_vector(15 downto 0);
    signal PC_PLUS_ONE  : std_logic_vector(15 downto 0);    
    
    -- Instr_Decode & Write-Back I/O
    signal WD           : std_logic_vector(15 downto 0);
    signal RD1          : std_logic_vector(15 downto 0);
    signal RD2          : std_logic_vector(15 downto 0);
    signal EXT_IMM      : std_logic_vector(15 downto 0);
    signal FUNC         : std_logic_vector(2 downto 0);
    signal SA           : std_logic;
    
    -- Execute_Unit I/O
    signal ALU_RES      : std_logic_vector(15 downto 0);
    signal ZERO         : std_logic;
    
    -- Memory_Unit I/O
    signal MEM_DATA     : std_logic_vector(15 downto 0);
    
    -- debug display signal
    signal DISPLAY_DATA : std_logic_vector(15 downto 0);
    
begin
    
    -- MPG1 for PC step
    MPG_PC_EN: entity work.MPG
        port map(
            CLK     => CLK,
            BTN     => BTN(0),
            RST     => BTN(4),
            ENABLE  => PC_EN
        );
    
    -- MPG2 for PC reset
    MPG_PC_RST: entity work.MPG
        port map(
            CLK     => CLK,
            BTN     => BTN(1),
            RST     => BTN(4),
            ENABLE  => PC_RST
        );
    
    -- branch decision
    PC_SRC  <= ZERO and BRANCH;
    
    -- jump address:
    -- opcode = INSTR(15 downto 13)
    -- target = INSTR(12 downto 0)
    JUMP_ADDR <= PC_PLUS_ONE(15 downto 13) & INSTR(12 downto 0);
    
    -- write-back MUX
    WD <= MEM_DATA when MEM_TO_REG = '1' else ALU_RES;
    
    ControlUnit: entity work.Control_Unit
        port map(
            INSTR_OPCODE    => INSTR(15 downto 13),
            REG_DST         => REG_DST,
            REG_WRITE       => REG_WRITE,
            ALU_SRC         => ALU_SRC,
            ALU_OP          => ALU_OP,
            MEM_TO_REG      => MEM_TO_REG,
            MEM_WRITE       => MEM_WRITE,
            EXT_OP          => EXT_OP,
            BRANCH          => BRANCH,
            JUMP            => JUMP
        );
    
    InstrFetch: entity work.Instr_Fetch
        port map(
            CLK         => CLK,
            PC_EN       => PC_EN,
            PC_RST      => PC_RST,
            BRANCH_ADDR => BRANCH_ADDR,
            JUMP_ADDR   => JUMP_ADDR,
            JUMP        => JUMP,
            PC_SRC      => PC_SRC,
            INSTR       => INSTR,
            PC_PLUS_ONE => PC_PLUS_ONE
        );
    
    InstrDecode: entity work.Instr_Decode
        port map(
            CLK         => CLK,
            RST         => PC_RST,
            INSTR       => INSTR,
            WD          => WD,
            REG_WRITE   => REG_WRITE,
            REG_DST     => REG_DST,
            EXT_OP      => EXT_OP,
            RD1         => RD1,
            RD2         => RD2,
            EXT_IMM     => EXT_IMM,
            FUNC        => FUNC,
            SA          => SA
        );
    
    ExecuteUnit: entity work.Execute_Unit
        port map(
            PC_PLUS_ONE => PC_PLUS_ONE,
            RD1         => RD1,
            RD2         => RD2,
            EXT_IMM     => EXT_IMM,
            FUNC        => FUNC,
            SA          => SA,
            ALU_SRC     => ALU_SRC,
            ALU_OP      => ALU_OP,
            BRANCH_ADDR => BRANCH_ADDR,
            ALU_RES     => ALU_RES,
            ZERO        => ZERO
        );
    
    MemoryUnit: entity work.Memory_Unit
        port map(
            CLK         => CLK,
            RST         => PC_RST,
            ALU_RES     => ALU_RES,
            RD2         => RD2,
            MEM_WRITE   => MEM_WRITE,
            MEM_DATA    => MEM_DATA
        );
    
    -- simple debug MUX
    DISPLAY_DATA <= INSTR       when SW(2 downto 0) = "000" else
                    PC_PLUS_ONE when SW(2 downto 0) = "001" else
                    RD1         when SW(2 downto 0) = "010" else
                    RD2         when SW(2 downto 0) = "011" else
                    EXT_IMM     when SW(2 downto 0) = "100" else
                    ALU_RES     when SW(2 downto 0) = "101" else
                    MEM_DATA    when SW(2 downto 0) = "110" else
                    WD;
    
    LED <= DISPLAY_DATA;
    
    SSD_Display: entity work.SSD
        port map(
            CLK     => CLK,
            RST     => BTN(4),
            DIGITS  => DISPLAY_DATA,
            CAT     => CAT,
            AN      => AN
        );                  
        
end Behavioral;
