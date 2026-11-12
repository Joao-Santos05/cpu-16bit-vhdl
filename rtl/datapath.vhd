library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity datapath is
    port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        en            : in  std_logic;

        pc_write      : in  std_logic;
        pc_src        : in  std_logic_vector(1 downto 0);
        end_src       : in  std_logic;
        rem_write     : in  std_logic;
        rdm_src       : in  std_logic;
        rdm_write     : in  std_logic;
        ir_write      : in  std_logic;
        rega_write    : in  std_logic;
        regb_write    : in  std_logic;
        reg_src2      : in  std_logic;
        alu_src_b     : in  std_logic;
        alu_op        : in  std_logic_vector(2 downto 0);
        alu_out_write : in  std_logic;
        reg_write     : in  std_logic;
        mem_to_reg    : in  std_logic;

        opcode        : out std_logic_vector(3 downto 0);
        zero          : out std_logic;

        mem_addr      : out word_t;
        mem_wdata     : out word_t;
        mem_rdata     : in  word_t;

        dbg_pc        : out word_t;
        dbg_ir        : out word_t;
        dbg_rdm       : out word_t;
        dbg_alu_out   : out word_t
    );
end entity;

architecture rtl of datapath is

    signal pc_q, pc_d, pc_inc, pc_br, pc_jmp : word_t;
    signal rem_q, rem_d                      : word_t;
    signal rdm_q, rdm_d                      : word_t;
    signal ir_q                              : word_t;
    signal rega_q, regb_q                    : word_t;
    signal alu_out_q                         : word_t;

    signal rs2_addr                          : std_logic_vector(2 downto 0);
    signal rf_data1, rf_data2, wb_data       : word_t;
    signal imm_ext, alu_b, alu_result        : word_t;

    signal pc_en, rem_en, rdm_en, ir_en      : std_logic;
    signal rega_en, regb_en, alu_out_en      : std_logic;
    signal rf_we                             : std_logic;

    alias ir_op  : std_logic_vector(3 downto 0)  is ir_q(15 downto 12);
    alias ir_ri  : std_logic_vector(2 downto 0)  is ir_q(11 downto 9);
    alias ir_rj  : std_logic_vector(2 downto 0)  is ir_q(8 downto 6);
    alias ir_rk  : std_logic_vector(2 downto 0)  is ir_q(5 downto 3);
    alias ir_imm : std_logic_vector(5 downto 0)  is ir_q(5 downto 0);
    alias ir_adr : std_logic_vector(11 downto 0) is ir_q(11 downto 0);

begin

    pc_en      <= en and pc_write;
    rem_en     <= en and rem_write;
    rdm_en     <= en and rdm_write;
    ir_en      <= en and ir_write;
    rega_en    <= en and rega_write;
    regb_en    <= en and regb_write;
    alu_out_en <= en and alu_out_write;
    rf_we      <= en and reg_write;

    -- PC

    pc_inc <= std_logic_vector(unsigned(pc_q) + 1);
    pc_br  <= std_logic_vector(unsigned(pc_q) + unsigned(imm_ext));
    pc_jmp <= "0000" & ir_adr;

    u_pc_mux : entity work.mux4x1
        port map (a => pc_inc, b => pc_br, c => pc_jmp, d => pc_inc, sel => pc_src, y => pc_d);

    u_pc : entity work.reg16
        port map (clk => clk, rst => rst, en => pc_en, d => pc_d, q => pc_q);

    -- Memory interface

    u_rem_mux : entity work.mux2x1
        port map (a => pc_q, b => alu_result, sel => end_src, y => rem_d);

    u_rem : entity work.reg16
        port map (clk => clk, rst => rst, en => rem_en, d => rem_d, q => rem_q);

    u_rdm_mux : entity work.mux2x1
        port map (a => mem_rdata, b => regb_q, sel => rdm_src, y => rdm_d);

    u_rdm : entity work.reg16
        port map (clk => clk, rst => rst, en => rdm_en, d => rdm_d, q => rdm_q);

    u_ir : entity work.reg16
        port map (clk => clk, rst => rst, en => ir_en, d => mem_rdata, q => ir_q);

    -- Register file

    u_rs2_mux : entity work.mux2x1
        generic map (WIDTH => 3)
        port map (a => ir_rk, b => ir_ri, sel => reg_src2, y => rs2_addr);

    u_wb_mux : entity work.mux2x1
        port map (a => alu_out_q, b => rdm_q, sel => mem_to_reg, y => wb_data);

    u_regfile : entity work.register_file
        port map (
            clk        => clk,
            rst        => rst,
            reg_write  => rf_we,
            read_reg1  => ir_rj,
            read_reg2  => rs2_addr,
            write_reg  => ir_ri,
            write_data => wb_data,
            read_data1 => rf_data1,
            read_data2 => rf_data2
        );

    u_rega : entity work.reg16
        port map (clk => clk, rst => rst, en => rega_en, d => rf_data1, q => rega_q);

    u_regb : entity work.reg16
        port map (clk => clk, rst => rst, en => regb_en, d => rf_data2, q => regb_q);

    -- ALU

    u_sext : entity work.sign_extend
        port map (a => ir_imm, y => imm_ext);

    u_alu_b_mux : entity work.mux2x1
        port map (a => regb_q, b => imm_ext, sel => alu_src_b, y => alu_b);

    u_alu : entity work.alu
        port map (a => rega_q, b => alu_b, op => alu_op, result => alu_result, zero => zero);

    u_alu_out : entity work.reg16
        port map (clk => clk, rst => rst, en => alu_out_en, d => alu_result, q => alu_out_q);

    opcode      <= ir_op;
    mem_addr    <= rem_q;
    mem_wdata   <= rdm_q;
    dbg_pc      <= pc_q;
    dbg_ir      <= ir_q;
    dbg_rdm     <= rdm_q;
    dbg_alu_out <= alu_out_q;

end architecture;

