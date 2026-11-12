library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity cpu_tb is
    generic (
        TEST    : natural := 0;
        MIF_DIR : string  := "../mif/"
    );
end entity;

architecture sim of cpu_tb is

    constant CLK_PERIOD : time    := 20 ns;
    constant MAX_CYCLES : natural := 5000;

    function mif_name(t : natural) return string is
    begin
        case t is
            when 0      => return "programa_teste.mif";
            when 1      => return "t1_aritmetica.mif";
            when 2      => return "t2_logica.mif";
            when 3      => return "t3_memoria.mif";
            when 4      => return "t4_branch.mif";
            when 5      => return "t5_jmp.mif";
            when 6      => return "t6_soma_array.mif";
            when others => return "invalid.mif";
        end case;
    end function;

    -- Golden values from the ISA reference model (R0..R7 at halt).
    function expected_regs(t : natural) return reg_array_t is
    begin
        case t is
            when 0 => return (x"0000", x"0005", x"0003", x"0008", x"0005", x"0008", x"0000", x"0000");
            when 1 => return (x"0000", x"000A", x"FFFD", x"0007", x"FFF3", x"0029", x"FFE0", x"0000");
            when 2 => return (x"0000", x"000C", x"000A", x"0008", x"000E", x"0001", x"0000", x"0001");
            when 3 => return (x"0000", x"0019", x"FFF9", x"0019", x"FFF9", x"000A", x"FFF9", x"5219");
            when 4 => return (x"0000", x"0005", x"0005", x"0007", x"0000", x"0002", x"0000", x"0004");
            when 5 => return (x"0000", x"0001", x"0000", x"0003", x"0004", x"0000", x"0000", x"0000");
            when 6 => return (x"0000", x"0019", x"0019", x"0027", x"000D", x"0027", x"0000", x"0000");
            when others => return (others => (others => 'X'));
        end case;
    end function;

    constant FETCH_CODE : std_logic_vector(3 downto 0) :=
        std_logic_vector(to_unsigned(state_t'pos(S_FETCH), 4));

    signal clk       : std_logic := '0';
    signal rst       : std_logic := '1';
    signal done      : boolean   := false;

    signal mem_addr  : word_t;
    signal mem_wdata : word_t;
    signal mem_rdata : word_t;
    signal mem_write : std_logic;
    signal dbg_pc    : word_t;
    signal dbg_state : std_logic_vector(3 downto 0);

begin

    clk <= not clk after CLK_PERIOD / 2 when not done;

    dut : entity work.cpu
        port map (
            clk         => clk,
            rst         => rst,
            en          => '1',
            mem_addr    => mem_addr,
            mem_wdata   => mem_wdata,
            mem_rdata   => mem_rdata,
            mem_write   => mem_write,
            dbg_pc      => dbg_pc,
            dbg_ir      => open,
            dbg_rdm     => open,
            dbg_alu_out => open,
            dbg_state   => dbg_state
        );

    u_memory : entity work.memory
        generic map (ADDR_WIDTH => 8, INIT_FILE => MIF_DIR & mif_name(TEST))
        port map (
            clk   => clk,
            we    => mem_write,
            addr  => mem_addr(7 downto 0),
            wdata => mem_wdata,
            rdata => mem_rdata
        );

    process
        alias regs is <<signal .cpu_tb.dut.u_datapath.u_regfile.regs : reg_array_t>>;

        constant expected : reg_array_t := expected_regs(TEST);
        variable last_pc  : word_t      := (others => 'X');
        variable cycles   : natural     := 0;
        variable errors   : natural     := 0;
    begin
        wait for 2 * CLK_PERIOD;
        wait until falling_edge(clk);
        rst <= '0';

        -- Halt = two consecutive fetches from the same address (JMP-to-self).
        loop
            wait until rising_edge(clk);
            cycles := cycles + 1;
            assert cycles < MAX_CYCLES report "timeout: CPU did not halt" severity failure;
            if dbg_state = FETCH_CODE then
                exit when dbg_pc = last_pc;
                last_pc := dbg_pc;
            end if;
        end loop;

        for r in reg_array_t'range loop
            if regs(r) /= expected(r) then
                errors := errors + 1;
                report "R" & integer'image(r) & " = " & to_hstring(regs(r))
                     & ", expected " & to_hstring(expected(r)) severity error;
            end if;
        end loop;

        assert errors = 0
            report "cpu_tb[" & mif_name(TEST) & "]: " & integer'image(errors) & " failure(s)"
            severity failure;
        report "cpu_tb[" & mif_name(TEST) & "]: PASS (halted at PC=" & to_hstring(dbg_pc)
             & " after " & integer'image(cycles) & " cycles)";

        done <= true;
        wait;
    end process;

end architecture;

