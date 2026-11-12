library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sign_extend is
    port (
        a : in  std_logic_vector(5 downto 0);
        y : out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of sign_extend is
begin

    y <= std_logic_vector(resize(signed(a), y'length));

end architecture;

