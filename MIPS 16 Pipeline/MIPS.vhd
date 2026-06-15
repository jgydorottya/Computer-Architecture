-- Description: MIPS full implementation

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS is
    port(
        -- inputs
        CLK     : in std_logic;
        SW      : in std_logic_vector(15 downto 0);
        BTN     : in std_logic_vector(4 downto 0);
        -- outputs
        LED     : out std_logic_vector(15 downto 0);
        CAT     : out std_logic_vector(6 downto 0);
        AN      : out std_logic_vector(3 downto 0)
    );
end MIPS;

architecture Behavioral of MIPS is
    
    -- =================================
    --         Single-Cycle I/O
    -- =================================
    
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
    
    -- =================================
    --         Pipeline I/O
    -- =================================
    
    -- IF/ID pipeline register #1
    signal IF_ID_PC_PLUS_ONE    : std_logic_vector(15 downto 0);
    signal IF_ID_INSTR          : std_logic_vector(15 downto 0);
    
    -- ID/EX pipeline register #2
    signal ID_EX_PC_PLUS_ONE    : std_logic_vector(15 downto 0);
    signal ID_EX_RD1            : std_logic_vector(15 downto 0);
    signal ID_EX_RD2            : std_logic_vector(15 downto 0);
    signal ID_EX_EXT_IMM        : std_logic_vector(15 downto 0);
    signal ID_EX_FUNC           : std_logic_vector(2 downto 0);
    signal ID_EX_SA             : std_logic;
    signal ID_EX_WRITE_REG      : std_logic_vector(2 downto 0);
    
    signal ID_EX_ALU_SRC        : std_logic;
    signal ID_EX_ALU_OP         : std_logic_vector(2 downto 0);
    signal ID_EX_MEM_TO_REG     : std_logic;
    signal ID_EX_REG_WRITE      : std_logic;
    signal ID_EX_MEM_WRITE      : std_logic;
    signal ID_EX_BRANCH         : std_logic;
    
    -- EX/MEM pipeline register #3
    signal EX_MEM_BRANCH_ADDR   : std_logic_vector(15 downto 0);
    signal EX_MEM_ZERO          : std_logic;
    signal EX_MEM_ALU_RES       : std_logic_vector(15 downto 0);
    signal EX_MEM_RD2           : std_logic_vector(15 downto 0);
    signal EX_MEM_WRITE_REG     : std_logic_vector(2 downto 0);
    
    signal EX_MEM_MEM_TO_REG    : std_logic;
    signal EX_MEM_REG_WRITE     : std_logic;
    signal EX_MEM_MEM_WRITE     : std_logic;
    signal EX_MEM_BRANCH        : std_logic;
    
    -- MEM/WB pipeline register #4
    signal MEM_WB_MEM_DATA      : std_logic_vector(15 downto 0);
    signal MEM_WB_ALU_RES       : std_logic_vector(15 downto 0);
    signal MEM_WB_WRITE_REG     : std_logic_vector(2 downto 0);
    
    signal MEM_WB_MEM_TO_REG    : std_logic;
    signal MEM_WB_REG_WRITE     : std_logic;
    
    -- destination register selected in ID
    signal ID_WRITE_REG         : std_logic_vector(2 downto 0);    
    
begin

    -- destination-register MUX in ID
    ID_WRITE_REG <= IF_ID_INSTR(6 downto 4) when REG_DST = '1' else
                    IF_ID_INSTR(9 downto 7);
    
    PIPELINE_REGISTERS: process(CLK)
    begin
        if rising_edge(CLK) then
            if PC_RST = '1' then
    
                -- IF/ID reset
                IF_ID_PC_PLUS_ONE <= x"0000";
                IF_ID_INSTR       <= x"0000";
    
                -- ID/EX reset
                ID_EX_PC_PLUS_ONE <= x"0000";
                ID_EX_RD1         <= x"0000";
                ID_EX_RD2         <= x"0000";
                ID_EX_EXT_IMM     <= x"0000";
                ID_EX_FUNC        <= "000";
                ID_EX_SA          <= '0';
                ID_EX_WRITE_REG   <= "000";
    
                ID_EX_ALU_SRC     <= '0';
                ID_EX_ALU_OP      <= "000";
                ID_EX_MEM_TO_REG  <= '0';
                ID_EX_REG_WRITE   <= '0';
                ID_EX_MEM_WRITE   <= '0';
                ID_EX_BRANCH      <= '0';
    
                -- EX/MEM reset
                EX_MEM_BRANCH_ADDR <= x"0000";
                EX_MEM_ZERO        <= '0';
                EX_MEM_ALU_RES     <= x"0000";
                EX_MEM_RD2         <= x"0000";
                EX_MEM_WRITE_REG   <= "000";
    
                EX_MEM_MEM_TO_REG  <= '0';
                EX_MEM_REG_WRITE   <= '0';
                EX_MEM_MEM_WRITE   <= '0';
                EX_MEM_BRANCH      <= '0';
    
                -- MEM/WB reset
                MEM_WB_MEM_DATA   <= x"0000";
                MEM_WB_ALU_RES    <= x"0000";
                MEM_WB_WRITE_REG  <= "000";
    
                MEM_WB_MEM_TO_REG <= '0';
                MEM_WB_REG_WRITE  <= '0';
    
            elsif PC_EN = '1' then
    
                -- IF/ID <= IF outputs
                IF_ID_PC_PLUS_ONE <= PC_PLUS_ONE;
                IF_ID_INSTR       <= INSTR;
    
                -- ID/EX <= ID outputs + control signals
                ID_EX_PC_PLUS_ONE <= IF_ID_PC_PLUS_ONE;
                ID_EX_RD1         <= RD1;
                ID_EX_RD2         <= RD2;
                ID_EX_EXT_IMM     <= EXT_IMM;
                ID_EX_FUNC        <= FUNC;
                ID_EX_SA          <= SA;
                ID_EX_WRITE_REG   <= ID_WRITE_REG;
    
                ID_EX_ALU_SRC     <= ALU_SRC;
                ID_EX_ALU_OP      <= ALU_OP;
                ID_EX_MEM_TO_REG  <= MEM_TO_REG;
                ID_EX_REG_WRITE   <= REG_WRITE;
                ID_EX_MEM_WRITE   <= MEM_WRITE;
                ID_EX_BRANCH      <= BRANCH;
    
                -- EX/MEM <= EX outputs + delayed control signals
                EX_MEM_BRANCH_ADDR <= BRANCH_ADDR;
                EX_MEM_ZERO        <= ZERO;
                EX_MEM_ALU_RES     <= ALU_RES;
                EX_MEM_RD2         <= ID_EX_RD2;
                EX_MEM_WRITE_REG   <= ID_EX_WRITE_REG;
    
                EX_MEM_MEM_TO_REG  <= ID_EX_MEM_TO_REG;
                EX_MEM_REG_WRITE   <= ID_EX_REG_WRITE;
                EX_MEM_MEM_WRITE   <= ID_EX_MEM_WRITE;
                EX_MEM_BRANCH      <= ID_EX_BRANCH;
    
                -- MEM/WB <= MEM outputs + delayed WB control signals
                MEM_WB_MEM_DATA   <= MEM_DATA;
                MEM_WB_ALU_RES    <= EX_MEM_ALU_RES;
                MEM_WB_WRITE_REG  <= EX_MEM_WRITE_REG;
    
                MEM_WB_MEM_TO_REG <= EX_MEM_MEM_TO_REG;
                MEM_WB_REG_WRITE  <= EX_MEM_REG_WRITE;
    
            end if;
        end if;
    end process;
    
    -- branch decision
    PC_SRC  <= EX_MEM_ZERO and EX_MEM_BRANCH;
    
    -- jump address:
    -- opcode = INSTR(15 downto 13)
    -- target = INSTR(12 downto 0)
    JUMP_ADDR <= IF_ID_PC_PLUS_ONE(15 downto 13) & IF_ID_INSTR(12 downto 0);
    
    -- write-back MUX
    WD <= MEM_WB_MEM_DATA when MEM_WB_MEM_TO_REG = '1' else
          MEM_WB_ALU_RES;
    
    ControlUnit: entity work.Control_Unit
        port map(
            INSTR_OPCODE    => IF_ID_INSTR(15 downto 13),
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
            BRANCH_ADDR => EX_MEM_BRANCH_ADDR,
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
            INSTR       => IF_ID_INSTR,
            WD          => WD,
            WA          => MEM_WB_WRITE_REG,
            REG_WRITE   => MEM_WB_REG_WRITE,
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
            PC_PLUS_ONE => ID_EX_PC_PLUS_ONE,
            RD1         => ID_EX_RD1,
            RD2         => ID_EX_RD2,
            EXT_IMM     => ID_EX_EXT_IMM,
            FUNC        => ID_EX_FUNC,
            SA          => ID_EX_SA,
            ALU_SRC     => ID_EX_ALU_SRC,
            ALU_OP      => ID_EX_ALU_OP,
            BRANCH_ADDR => BRANCH_ADDR,
            ALU_RES     => ALU_RES,
            ZERO        => ZERO
        );
    
    MemoryUnit: entity work.Memory_Unit
        port map(
            CLK         => CLK,
            RST         => PC_RST,
            ALU_RES     => EX_MEM_ALU_RES,
            RD2         => EX_MEM_RD2,
            MEM_WRITE   => EX_MEM_MEM_WRITE,
            MEM_DATA    => MEM_DATA
        );
    
    -- BTN(0): single-step pipeline / PC enable
    -- BTN(1): CPU reset pulse: PC + pipeline registers + RF + RAM
    -- BTN(4): MPG and SSD reset only
    
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
    
    -- simple debug MUX
    DISPLAY_DATA <= INSTR           when SW(2 downto 0) = "000" else
                    IF_ID_INSTR     when SW(2 downto 0) = "001" else
                    ID_EX_RD1       when SW(2 downto 0) = "010" else
                    ID_EX_RD2       when SW(2 downto 0) = "011" else
                    ID_EX_EXT_IMM   when SW(2 downto 0) = "100" else
                    EX_MEM_ALU_RES  when SW(2 downto 0) = "101" else
                    MEM_WB_MEM_DATA when SW(2 downto 0) = "110" else
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
