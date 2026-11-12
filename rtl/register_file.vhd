library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu_pkg.all;

entity register_file is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        reg_write  : in  std_logic;
        read_reg1  : in  std_logic_vector(2 downto 0);
        read_reg2  : in  std_logic_vector(2 downto 0);
        write_reg  : in  std_logic_vector(2 downto 0);
        write_data : in  word_t;
        read_data1 : out word_t;
        read_data2 : out word_t
    );
end entity;

architecture rtl of register_file is
    signal regs : reg_array_t := (others => (others => '0'));
begin

    process (clk, rst)
    begin
        if rst = '1' then
            regs <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = '1' and write_reg /= "000" then
                regs(to_integer(unsigned(write_reg))) <= write_data;
            end if;
        end if;
    end process;

    read_data1 <= regs(to_integer(unsigned(read_reg1)));
    read_data2 <= regs(to_integer(unsigned(read_reg2)));

end architecture;

