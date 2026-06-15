-- Description: Memory-Unit = Data-Memory (RAM)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Unit is
    port(
        -- inputs
        CLK         : in std_logic;
        RST         : in std_logic;
        ALU_RES     : in std_logic_vector(15 downto 0);
        RD2         : in std_logic_vector(15 downto 0);
        -- control signal
        MEM_WRITE   : in std_logic;
        -- outputs
        MEM_DATA    : out std_logic_vector(15 downto 0)
    );
end Memory_Unit;

architecture Behavioral of Memory_Unit is

    type ram_type is array (0 to 15) of std_logic_vector (15 downto 0);
    constant RAM_INIT : ram_type := (
        0  => x"0000",
        1  => x"1111",
        2  => x"2222",
        3  => x"3333",
        4  => x"4444",
        5  => x"5555",
        6  => x"6666",
        7  => x"0005",
        8  => x"0000",
        9  => x"9999",
        10 => x"AAAA",
        11 => x"BBBB",
        12 => x"CCCC",
        13 => x"DDDD",
        14 => x"EEEE",
        15 => x"FFFF",
        others => x"0000"
    );
    signal RAM : ram_type := RAM_INIT;
    
begin
    
    -- RAM behaviour:
    -- synchronous WRITE
    RAM_WRITE: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                RAM <= RAM_INIT;
            elsif MEM_WRITE = '1' then
                RAM(to_integer(unsigned(ALU_RES(3 downto 0)))) <= RD2;
            end if;
        end if;
    end process;
    
    -- asynchronous READ
    MEM_DATA <= RAM(to_integer(unsigned(ALU_RES(3 downto 0))));

end Behavioral;
