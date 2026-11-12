library ieee;
use ieee.std_logic_1164.all;

entity mux4x1 is
    generic (
        WIDTH : positive := 16
    );
    port (
        a   : in  std_logic_vector(WIDTH - 1 downto 0);
        b   : in  std_logic_vector(WIDTH - 1 downto 0);
        c   : in  std_logic_vector(WIDTH - 1 downto 0);
        d   : in  std_logic_vector(WIDTH - 1 downto 0);
        sel : in  std_logic_vector(1 downto 0);
        y   : out std_logic_vector(WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of mux4x1 is
begin

    with sel select y <=
        a when "00",
        b when "01",
        c when "10",
        d when others;

end architecture;

