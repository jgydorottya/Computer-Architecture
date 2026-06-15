-- Description: Instruction-Decode-Unit = Register-File + Extension-Unit

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Instr_Decode is
    port(
        -- inputs
        CLK         : in std_logic;
        RST         : in std_logic;
        INSTR       : in std_logic_vector(15 downto 0);
        WD          : in std_logic_vector(15 downto 0);
        WA          : in std_logic_vector(2 downto 0);
        -- control signals
        REG_WRITE   : in std_logic;
        REG_DST     : in std_logic;
        EXT_OP      : in std_logic;
        -- outputs
        RD1         : out std_logic_vector(15 downto 0);
        RD2         : out std_logic_vector(15 downto 0);
        EXT_IMM     : out std_logic_vector(15 downto 0);
        FUNC        : out std_logic_vector(2 downto 0);
        SA          : out std_logic
    );
end Instr_Decode;

architecture Behavioral of Instr_Decode is

    type rf_type is array (0 to 7) of std_logic_vector (15 downto 0);
    constant RF_INIT : rf_type := (
        0 => x"0000",
        1 => x"0005",
        2 => x"0003",
        others => x"0000"
    );
    signal RF   : rf_type := RF_INIT;
           
    signal RA1  : std_logic_vector(2 downto 0);
    signal RA2  : std_logic_vector(2 downto 0);
 
begin
    
    RA1 <= INSTR(12 downto 10);
    RA2 <= INSTR(9 downto 7);
           
    REG_FILE: process(CLK)
    begin
        if falling_edge(CLK) then
            if RST = '1' then
                RF <= RF_INIT;
            elsif REG_WRITE = '1' then
                RF(to_integer(unsigned(WA))) <= WD;
            end if;
        end if;
    end process;
    
    RD1 <= RF(to_integer(unsigned(RA1)));
    RD2 <= RF(to_integer(unsigned(RA2)));
    
    EXT_IMM <= "000000000" & INSTR(6 downto 0) when EXT_OP = '0' else
               "111111111" & INSTR(6 downto 0) when INSTR(6) = '1' else
               "000000000" & INSTR(6 downto 0);
    FUNC    <= INSTR(2 downto 0);
    SA      <= INSTR(3);
    
end Behavioral;
