library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity cpu_top is
    generic (
        INIT_FILE     : string   := "../mif/programa_teste.mif";
        ADDR_WIDTH    : positive := 8;
        STABLE_CYCLES : positive := 500_000;
        RUNTIME_MOD   : boolean  := true
    );
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(3 downto 0);
        SW       : in  std_logic_vector(17 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0);
        HEX6     : out std_logic_vector(6 downto 0);
        HEX7     : out std_logic_vector(6 downto 0);
        LEDG     : out std_logic_vector(8 downto 0);
        LEDR     : out std_logic_vector(17 downto 0)
    );
end entity;

architecture rtl of cpu_top is

    signal rst_meta, rst : std_logic := '1';
    signal step          : std_logic;

    signal mem_addr      : word_t;
    signal mem_wdata     : word_t;
    signal mem_rdata     : word_t;
    signal mem_write     : std_logic;

    signal pc            : word_t;
    signal rdm           : word_t;
    signal alu_out       : word_t;
    signal state         : std_logic_vector(3 downto 0);
    signal hex_hi        : word_t;

begin

    process (CLOCK_50)
    begin
        if rising_edge(CLOCK_50) then
            rst_meta <= not KEY(1);
            rst      <= rst_meta;
        end if;
    end process;

    u_debouncer : entity work.debouncer
        generic map (STABLE_CYCLES => STABLE_CYCLES)
        port map (clk => CLOCK_50, rst => rst, btn_n => KEY(0), pulse => step);

    u_cpu : entity work.cpu
        port map (
            clk         => CLOCK_50,
            rst         => rst,
            en          => step,
            mem_addr    => mem_addr,
            mem_wdata   => mem_wdata,
            mem_rdata   => mem_rdata,
            mem_write   => mem_write,
            dbg_pc      => pc,
            dbg_ir      => open,
            dbg_rdm     => rdm,
            dbg_alu_out => alu_out,
            dbg_state   => state
        );

    u_memory : entity work.memory
        generic map (ADDR_WIDTH => ADDR_WIDTH, INIT_FILE => INIT_FILE, RUNTIME_MOD => RUNTIME_MOD)
        port map (
            clk   => CLOCK_50,
            we    => mem_write,
            addr  => mem_addr(ADDR_WIDTH - 1 downto 0),
            wdata => mem_wdata,
            rdata => mem_rdata
        );

    hex_hi <= alu_out when SW(17) = '1' else rdm;

    u_hex0 : entity work.hex_display port map (nibble => pc(3 downto 0),       seg => HEX0);
    u_hex1 : entity work.hex_display port map (nibble => pc(7 downto 4),       seg => HEX1);
    u_hex2 : entity work.hex_display port map (nibble => pc(11 downto 8),      seg => HEX2);
    u_hex3 : entity work.hex_display port map (nibble => pc(15 downto 12),     seg => HEX3);
    u_hex4 : entity work.hex_display port map (nibble => hex_hi(3 downto 0),   seg => HEX4);
    u_hex5 : entity work.hex_display port map (nibble => hex_hi(7 downto 4),   seg => HEX5);
    u_hex6 : entity work.hex_display port map (nibble => hex_hi(11 downto 8),  seg => HEX6);
    u_hex7 : entity work.hex_display port map (nibble => hex_hi(15 downto 12), seg => HEX7);

    LEDG <= "00000" & state;

    process (state)
    begin
        LEDR <= (others => '0');
        LEDR(to_integer(unsigned(state))) <= '1';
    end process;

end architecture;

