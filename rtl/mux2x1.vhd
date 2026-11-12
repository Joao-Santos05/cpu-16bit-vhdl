library ieee;
use ieee.std_logic_1164.all;

entity mux2x1 is
    generic (
        WIDTH : positive := 16
    );
    port (
        a   : in  std_logic_vector(WIDTH - 1 downto 0);
        b   : in  std_logic_vector(WIDTH - 1 downto 0);
        sel : in  std_logic;
        y   : out std_logic_vector(WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of mux2x1 is
begin

    y <= a when sel = '0' else b;

end architecture;

