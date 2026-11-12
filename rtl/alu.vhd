library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity alu is
    port (
        a      : in  word_t;
        b      : in  word_t;
        op     : in  std_logic_vector(2 downto 0);
        result : out word_t;
        zero   : out std_logic
    );
end entity;

architecture rtl of alu is
    signal r : word_t;
begin

    process (a, b, op)
    begin
        case op is
            when ALU_ADD => r <= std_logic_vector(unsigned(a) + unsigned(b));
            when ALU_SUB => r <= std_logic_vector(unsigned(a) - unsigned(b));
            when ALU_AND => r <= a and b;
            when ALU_OR  => r <= a or b;
            when ALU_SLT =>
                if signed(a) < signed(b) then
                    r <= x"0001";
                else
                    r <= x"0000";
                end if;
            when others  => r <= (others => '0');
        end case;
    end process;

    result <= r;
    zero   <= '1' when r = x"0000" else '0';

end architecture;

