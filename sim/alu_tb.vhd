library ieee;
use ieee.std_logic_1164.all;
use work.cpu_pkg.all;

entity alu_tb is
end entity;

architecture sim of alu_tb is

    signal a, b, result : word_t;
    signal op           : std_logic_vector(2 downto 0);
    signal zero         : std_logic;

    type vector_t is record
        op   : std_logic_vector(2 downto 0);
        a, b : word_t;
        r    : word_t;
        z    : std_logic;
    end record;

    type vectors_t is array (natural range <>) of vector_t;

    constant VECTORS : vectors_t := (
        (ALU_ADD, x"0005", x"0003", x"0008", '0'),
        (ALU_ADD, x"FFFF", x"0001", x"0000", '1'),
        (ALU_ADD, x"7FFF", x"0001", x"8000", '0'),
        (ALU_SUB, x"0008", x"0003", x"0005", '0'),
        (ALU_SUB, x"0003", x"0008", x"FFFB", '0'),
        (ALU_SUB, x"1234", x"1234", x"0000", '1'),
        (ALU_AND, x"F0F0", x"FF00", x"F000", '0'),
        (ALU_AND, x"0F0F", x"F0F0", x"0000", '1'),
        (ALU_OR,  x"F0F0", x"0F00", x"FFF0", '0'),
        (ALU_OR,  x"0000", x"0000", x"0000", '1'),
        (ALU_SLT, x"0003", x"0008", x"0001", '0'),
        (ALU_SLT, x"0008", x"0003", x"0000", '1'),
        (ALU_SLT, x"0008", x"0008", x"0000", '1'),
        (ALU_SLT, x"FFFF", x"0001", x"0001", '0'),
        (ALU_SLT, x"0001", x"FFFF", x"0000", '1'),
        (ALU_SLT, x"8000", x"7FFF", x"0001", '0')
    );

begin

    dut : entity work.alu
        port map (a => a, b => b, op => op, result => result, zero => zero);

    process
        variable errors : natural := 0;
    begin
        for i in VECTORS'range loop
            a  <= VECTORS(i).a;
            b  <= VECTORS(i).b;
            op <= VECTORS(i).op;
            wait for 10 ns;
            if result /= VECTORS(i).r or zero /= VECTORS(i).z then
                errors := errors + 1;
                report "vector " & integer'image(i) & " failed: result=" & to_hstring(result)
                     & " zero=" & std_logic'image(zero) severity error;
            end if;
        end loop;

        assert errors = 0 report "alu_tb: " & integer'image(errors) & " failure(s)" severity failure;
        report "alu_tb: PASS";
        wait;
    end process;

end architecture;

