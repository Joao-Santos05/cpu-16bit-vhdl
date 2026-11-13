library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.cpu_pkg.all;

-- Behavioral replacement for rtl/memory.vhd, for simulators without altera_mf.
-- Same timing (address registered on the falling edge). The .mif loader only
-- understands "<dec addr> : <16-bit bin>;" lines; anything else is ignored.
entity memory is
    generic (
        ADDR_WIDTH  : positive := 8;
        INIT_FILE   : string   := "programa_teste.mif";
        RUNTIME_MOD : boolean  := false
    );
    port (
        clk   : in  std_logic;
        we    : in  std_logic;
        addr  : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
        wdata : in  word_t;
        rdata : out word_t
    );
end entity;

architecture sim of memory is

    type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

    impure function load_mif(path : string) return ram_t is
        file     f    : text open read_mode is path;
        variable l    : line;
        variable c    : character;
        variable a    : integer;
        variable data : word_t;
        variable ram  : ram_t := (others => (others => '0'));

        procedure skip_blanks is
        begin
            while l'length > 0 and (l(l'low) = ' ' or l(l'low) = HT) loop
                read(l, c);
            end loop;
        end procedure;
    begin
        while not endfile(f) loop
            readline(f, l);
            skip_blanks;
            if l'length > 0 and l(l'low) >= '0' and l(l'low) <= '9' then
                read(l, a);
                loop
                    read(l, c);
                    exit when c = ':';
                end loop;
                skip_blanks;
                for i in data'range loop
                    read(l, c);
                    if c = '1' then
                        data(i) := '1';
                    else
                        data(i) := '0';
                    end if;
                end loop;
                if a <= ram'high then
                    ram(a) := data;
                end if;
            end if;
        end loop;
        return ram;
    end function;

    signal ram    : ram_t := load_mif(INIT_FILE);
    signal addr_q : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');

begin

    process (clk)
    begin
        if falling_edge(clk) then
            if we = '1' then
                ram(to_integer(unsigned(addr))) <= wdata;
            end if;
            addr_q <= addr;
        end if;
    end process;

    rdata <= ram(to_integer(unsigned(addr_q)));

end architecture;

