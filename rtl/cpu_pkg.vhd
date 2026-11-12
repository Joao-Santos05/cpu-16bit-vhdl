library ieee;
use ieee.std_logic_1164.all;

package cpu_pkg is

    subtype word_t is std_logic_vector(15 downto 0);
    type reg_array_t is array (0 to 7) of word_t;

    constant OP_ADD  : std_logic_vector(3 downto 0) := "0000";
    constant OP_SUB  : std_logic_vector(3 downto 0) := "0001";
    constant OP_AND  : std_logic_vector(3 downto 0) := "0010";
    constant OP_OR   : std_logic_vector(3 downto 0) := "0011";
    constant OP_SLT  : std_logic_vector(3 downto 0) := "0100";
    constant OP_ADDI : std_logic_vector(3 downto 0) := "0101";
    constant OP_LD   : std_logic_vector(3 downto 0) := "0110";
    constant OP_ST   : std_logic_vector(3 downto 0) := "0111";
    constant OP_BEQ  : std_logic_vector(3 downto 0) := "1000";
    constant OP_BNE  : std_logic_vector(3 downto 0) := "1001";
    constant OP_JMP  : std_logic_vector(3 downto 0) := "1010";

    constant ALU_ADD : std_logic_vector(2 downto 0) := "000";
    constant ALU_SUB : std_logic_vector(2 downto 0) := "001";
    constant ALU_AND : std_logic_vector(2 downto 0) := "010";
    constant ALU_OR  : std_logic_vector(2 downto 0) := "011";
    constant ALU_SLT : std_logic_vector(2 downto 0) := "100";

    constant PC_SRC_INC : std_logic_vector(1 downto 0) := "00";
    constant PC_SRC_BR  : std_logic_vector(1 downto 0) := "01";
    constant PC_SRC_JMP : std_logic_vector(1 downto 0) := "10";

    constant END_SRC_PC     : std_logic := '0';
    constant END_SRC_ALU    : std_logic := '1';
    constant RDM_SRC_MEM    : std_logic := '0';
    constant RDM_SRC_REGB   : std_logic := '1';
    constant REG_SRC2_RK    : std_logic := '0';
    constant REG_SRC2_RI    : std_logic := '1';
    constant ALU_SRC_B_REG  : std_logic := '0';
    constant ALU_SRC_B_IMM  : std_logic := '1';
    constant MEM_TO_REG_ALU : std_logic := '0';
    constant MEM_TO_REG_RDM : std_logic := '1';

    -- Declaration order defines the 4-bit state code shown on the LEDs.
    type state_t is (
        S_FETCH,
        S_WAIT_MEM,
        S_DECODE,
        S_EXEC_R,
        S_WRITE_R,
        S_EXEC_ADDI,
        S_EXEC_LD_ADDR,
        S_EXEC_LD_MEM,
        S_EXEC_LD_WB,
        S_EXEC_ST_ADDR,
        S_EXEC_ST_MEM,
        S_EXEC_BEQ,
        S_EXEC_BNE,
        S_EXEC_JMP
    );

end package;

