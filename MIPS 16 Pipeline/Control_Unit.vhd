-- Description: Main-Control-Unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Control_Unit is
    port(
        -- input
        INSTR_OPCODE    : in std_logic_vector(2 downto 0);
        -- outputs
        REG_DST         : out std_logic;
        REG_WRITE       : out std_logic;
        ALU_SRC         : out std_logic;
        ALU_OP          : out std_logic_vector(2 downto 0);
        MEM_TO_REG      : out std_logic;
        MEM_WRITE       : out std_logic;
        EXT_OP          : out std_logic;
        BRANCH          : out std_logic;
        JUMP            : out std_logic
    );
end Control_Unit;

architecture Behavioral of Control_Unit is

begin
    -- Main Control
    process(INSTR_OPCODE)
    begin
        case INSTR_OPCODE is
            when "000" =>       -- R-type
                REG_DST     <= '1';
                REG_WRITE   <= '1';
                ALU_SRC     <= '0';
                ALU_OP      <= "111";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '0'; -- unused
                BRANCH      <= '0';
                JUMP        <= '0';
            when "001" =>       -- addi
                REG_DST     <= '0';
                REG_WRITE   <= '1';
                ALU_SRC     <= '1';
                ALU_OP      <= "000";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '1';
                BRANCH      <= '0';
                JUMP        <= '0';
            when "010" =>       -- lw
                REG_DST     <= '0';
                REG_WRITE   <= '1';
                ALU_SRC     <= '1';
                ALU_OP      <= "000";
                MEM_TO_REG  <= '1';
                MEM_WRITE   <= '0';
                EXT_OP      <= '1';
                BRANCH      <= '0';
                JUMP        <= '0';
            when "011" =>       -- sw
                REG_DST     <= '0'; --'X';
                REG_WRITE   <= '0';
                ALU_SRC     <= '1';
                ALU_OP      <= "000";
                MEM_TO_REG  <= '0'; --'X';
                MEM_WRITE   <= '1';
                EXT_OP      <= '1';
                BRANCH      <= '0';
                JUMP        <= '0';
            when "100" =>       -- beq
                REG_DST     <= '0'; --'X';
                REG_WRITE   <= '0';
                ALU_SRC     <= '0';
                ALU_OP      <= "001";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '1';
                BRANCH      <= '1';
                JUMP        <= '0';
            when "101" =>       -- andi
                REG_DST     <= '0';
                REG_WRITE   <= '1';
                ALU_SRC     <= '1';
                ALU_OP      <= "100";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '0';
                BRANCH      <= '0';
                JUMP        <= '0';
            when "110" =>       -- ori
                REG_DST     <= '0';
                REG_WRITE   <= '1';
                ALU_SRC     <= '1';
                ALU_OP      <= "101";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '0';
                BRANCH      <= '0';
                JUMP        <= '0';
            when others =>      -- jump/others
                REG_DST     <= '0';
                REG_WRITE   <= '0';
                ALU_SRC     <= '0'; --'X';
                ALU_OP      <= "111";
                MEM_TO_REG  <= '0';
                MEM_WRITE   <= '0';
                EXT_OP      <= '0'; --'X';
                BRANCH      <= '0';
                JUMP        <= '1';
        end case;
    end process;
end Behavioral;
