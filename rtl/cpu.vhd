library ieee;
use ieee.std_logic_1164.all;
use work.cpu_pkg.all;

entity cpu is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        en          : in  std_logic;

        mem_addr    : out word_t;
        mem_wdata   : out word_t;
        mem_rdata   : in  word_t;
        mem_write   : out std_logic;

        dbg_pc      : out word_t;
        dbg_ir      : out word_t;
        dbg_rdm     : out word_t;
        dbg_alu_out : out word_t;
        dbg_state   : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of cpu is

    signal opcode        : std_logic_vector(3 downto 0);
    signal zero          : std_logic;
    signal pc_write      : std_logic;
    signal pc_src        : std_logic_vector(1 downto 0);
    signal end_src       : std_logic;
    signal rem_write     : std_logic;
    signal rdm_src       : std_logic;
    signal rdm_write     : std_logic;
    signal ir_write      : std_logic;
    signal rega_write    : std_logic;
    signal regb_write    : std_logic;
    signal reg_src2      : std_logic;
    signal alu_src_b     : std_logic;
    signal alu_op        : std_logic_vector(2 downto 0);
    signal alu_out_write : std_logic;
    signal reg_write     : std_logic;
    signal mem_to_reg    : std_logic;

begin

    u_control : entity work.control_unit
        port map (
            clk           => clk,
            rst           => rst,
            en            => en,
            opcode        => opcode,
            zero          => zero,
            pc_write      => pc_write,
            pc_src        => pc_src,
            end_src       => end_src,
            rem_write     => rem_write,
            rdm_src       => rdm_src,
            rdm_write     => rdm_write,
            ir_write      => ir_write,
            rega_write    => rega_write,
            regb_write    => regb_write,
            reg_src2      => reg_src2,
            alu_src_b     => alu_src_b,
            alu_op        => alu_op,
            alu_out_write => alu_out_write,
            reg_write     => reg_write,
            mem_to_reg    => mem_to_reg,
            mem_write     => mem_write,
            state_code    => dbg_state
        );

    u_datapath : entity work.datapath
        port map (
            clk           => clk,
            rst           => rst,
            en            => en,
            pc_write      => pc_write,
            pc_src        => pc_src,
            end_src       => end_src,
            rem_write     => rem_write,
            rdm_src       => rdm_src,
            rdm_write     => rdm_write,
            ir_write      => ir_write,
            rega_write    => rega_write,
            regb_write    => regb_write,
            reg_src2      => reg_src2,
            alu_src_b     => alu_src_b,
            alu_op        => alu_op,
            alu_out_write => alu_out_write,
            reg_write     => reg_write,
            mem_to_reg    => mem_to_reg,
            opcode        => opcode,
            zero          => zero,
            mem_addr      => mem_addr,
            mem_wdata     => mem_wdata,
            mem_rdata     => mem_rdata,
            dbg_pc        => dbg_pc,
            dbg_ir        => dbg_ir,
            dbg_rdm       => dbg_rdm,
            dbg_alu_out   => dbg_alu_out
        );

end architecture;

