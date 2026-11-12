library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity register_file_tb is
end entity;

architecture sim of register_file_tb is

    constant CLK_PERIOD : time := 20 ns;

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '1';
    signal reg_write  : std_logic := '0';
    signal read_reg1  : std_logic_vector(2 downto 0) := "000";
    signal read_reg2  : std_logic_vector(2 downto 0) := "000";
    signal write_reg  : std_logic_vector(2 downto 0) := "000";
    signal write_data : word_t := (others => '0');
    signal read_data1 : word_t;
    signal read_data2 : word_t;
    signal done       : boolean := false;

    function pattern(i : natural) return word_t is
    begin
        return std_logic_vector(to_unsigned(16#1111# * i, 16));
    end function;

begin

    clk <= not clk after CLK_PERIOD / 2 when not done;

    dut : entity work.register_file
        port map (
            clk        => clk,
            rst        => rst,
            reg_write  => reg_write,
            read_reg1  => read_reg1,
            read_reg2  => read_reg2,
            write_reg  => write_reg,
            write_data => write_data,
            read_data1 => read_data1,
            read_data2 => read_data2
        );

    process
        variable errors : natural := 0;

        procedure do_write(r : natural; v : word_t; we : std_logic := '1') is
        begin
            write_reg  <= std_logic_vector(to_unsigned(r, 3));
            write_data <= v;
            reg_write  <= we;
            wait until rising_edge(clk);
            wait for 1 ns;
            reg_write  <= '0';
        end procedure;

        procedure check(r : natural; expected : word_t) is
        begin
            read_reg1 <= std_logic_vector(to_unsigned(r, 3));
            read_reg2 <= std_logic_vector(to_unsigned(r, 3));
            wait for 1 ns;
            if read_data1 /= expected or read_data2 /= expected then
                errors := errors + 1;
                report "R" & integer'image(r) & ": got " & to_hstring(read_data1) & "/" & to_hstring(read_data2)
                     & ", expected " & to_hstring(expected) severity error;
            end if;
        end procedure;
    begin
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait until rising_edge(clk);

        for r in 1 to 7 loop
            do_write(r, pattern(r));
        end loop;
        for r in 1 to 7 loop
            check(r, pattern(r));
        end loop;

        do_write(0, x"FFFF");
        check(0, x"0000");

        do_write(3, x"DEAD", '0');
        check(3, pattern(3));

        read_reg1 <= "010";
        read_reg2 <= "101";
        wait for 1 ns;
        if read_data1 /= pattern(2) or read_data2 /= pattern(5) then
            errors := errors + 1;
            report "independent read ports failed" severity error;
        end if;

        rst <= '1';
        wait for 1 ns;
        rst <= '0';
        for r in 0 to 7 loop
            check(r, x"0000");
        end loop;

        assert errors = 0 report "register_file_tb: " & integer'image(errors) & " failure(s)" severity failure;
        report "register_file_tb: PASS";
        done <= true;
        wait;
    end process;

end architecture;
