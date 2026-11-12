library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity control_unit is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        en            : in  std_logic;
        opcode        : in  std_logic_vector(3 downto 0);
        zero          : in  std_logic;
        pc_write      : out std_logic;
        pc_src        : out std_logic_vector(1 downto 0);
        end_src       : out std_logic;
        rem_write     : out std_logic;
        rdm_src       : out std_logic;
        rdm_write     : out std_logic;
        ir_write      : out std_logic;
        rega_write    : out std_logic;
        regb_write    : out std_logic;
        reg_src2      : out std_logic;
        alu_src_b     : out std_logic;
        alu_op        : out std_logic_vector(2 downto 0);
        alu_out_write : out std_logic;
        reg_write     : out std_logic;
        mem_to_reg    : out std_logic;
        mem_write     : out std_logic;
        state_code    : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of control_unit is

    signal state, next_state : state_t;

    function r_type_alu_op(op : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case op is
            when OP_SUB => return ALU_SUB;
            when OP_AND => return ALU_AND;
            when OP_OR  => return ALU_OR;
            when OP_SLT => return ALU_SLT;
            when others => return ALU_ADD;
        end case;
    end function;

begin

    process (clk, rst)
    begin
        if rst = '1' then
            state <= S_FETCH;
        elsif rising_edge(clk) then
            if en = '1' then
                state <= next_state;
            end if;
        end if;
    end process;

    process (state, opcode, zero)
    begin
        next_state    <= S_FETCH;
        pc_write      <= '0';
        pc_src        <= PC_SRC_INC;
        end_src       <= END_SRC_PC;
        rem_write     <= '0';
        rdm_src       <= RDM_SRC_MEM;
        rdm_write     <= '0';
        ir_write      <= '0';
        rega_write    <= '0';
        regb_write    <= '0';
        alu_src_b     <= ALU_SRC_B_REG;
        alu_op        <= ALU_ADD;
        alu_out_write <= '0';
        reg_write     <= '0';
        mem_to_reg    <= MEM_TO_REG_ALU;
        mem_write     <= '0';

        case state is
            when S_FETCH =>
                end_src    <= END_SRC_PC;
                rem_write  <= '1';
                pc_src     <= PC_SRC_INC;
                pc_write   <= '1';
                next_state <= S_WAIT_MEM;

            when S_WAIT_MEM =>
                rdm_src    <= RDM_SRC_MEM;
                rdm_write  <= '1';
                ir_write   <= '1';
                next_state <= S_DECODE;

            when S_DECODE =>
                rega_write <= '1';
                regb_write <= '1';
                case opcode is
                    when OP_ADD | OP_SUB | OP_AND | OP_OR | OP_SLT =>
                        next_state <= S_EXEC_R;
                    when OP_ADDI => next_state <= S_EXEC_ADDI;
                    when OP_LD   => next_state <= S_EXEC_LD_ADDR;
                    when OP_ST   => next_state <= S_EXEC_ST_ADDR;
                    when OP_BEQ  => next_state <= S_EXEC_BEQ;
                    when OP_BNE  => next_state <= S_EXEC_BNE;
                    when OP_JMP  => next_state <= S_EXEC_JMP;
                    when others  => next_state <= S_FETCH;
                end case;

            when S_EXEC_R =>
                alu_src_b     <= ALU_SRC_B_REG;
                alu_op        <= r_type_alu_op(opcode);
                alu_out_write <= '1';
                next_state    <= S_WRITE_R;

            when S_WRITE_R =>
                mem_to_reg <= MEM_TO_REG_ALU;
                reg_write  <= '1';
                next_state <= S_FETCH;

            when S_EXEC_ADDI =>
                alu_src_b     <= ALU_SRC_B_IMM;
                alu_op        <= ALU_ADD;
                alu_out_write <= '1';
                next_state    <= S_WRITE_R;

            when S_EXEC_LD_ADDR =>
                alu_src_b  <= ALU_SRC_B_IMM;
                alu_op     <= ALU_ADD;
                end_src    <= END_SRC_ALU;
                rem_write  <= '1';
                next_state <= S_EXEC_LD_MEM;

            when S_EXEC_LD_MEM =>
                rdm_src    <= RDM_SRC_MEM;
                rdm_write  <= '1';
                next_state <= S_EXEC_LD_WB;

            when S_EXEC_LD_WB =>
                mem_to_reg <= MEM_TO_REG_RDM;
                reg_write  <= '1';
                next_state <= S_FETCH;

            when S_EXEC_ST_ADDR =>
                alu_src_b  <= ALU_SRC_B_IMM;
                alu_op     <= ALU_ADD;
                end_src    <= END_SRC_ALU;
                rem_write  <= '1';
                rdm_src    <= RDM_SRC_REGB;
                rdm_write  <= '1';
                next_state <= S_EXEC_ST_MEM;

            when S_EXEC_ST_MEM =>
                mem_write  <= '1';
                next_state <= S_FETCH;

            when S_EXEC_BEQ =>
                alu_src_b  <= ALU_SRC_B_REG;
                alu_op     <= ALU_SUB;
                pc_src     <= PC_SRC_BR;
                pc_write   <= zero;
                next_state <= S_FETCH;

            when S_EXEC_BNE =>
                alu_src_b  <= ALU_SRC_B_REG;
                alu_op     <= ALU_SUB;
                pc_src     <= PC_SRC_BR;
                pc_write   <= not zero;
                next_state <= S_FETCH;

            when S_EXEC_JMP =>
                pc_src     <= PC_SRC_JMP;
                pc_write   <= '1';
                next_state <= S_FETCH;
        end case;
    end process;

    reg_src2 <= REG_SRC2_RI when opcode = OP_ST or opcode = OP_BEQ or opcode = OP_BNE else
                REG_SRC2_RK;

    state_code <= std_logic_vector(to_unsigned(state_t'pos(state), state_code'length));

end architecture;

