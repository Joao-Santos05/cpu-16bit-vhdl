library ieee;
use ieee.std_logic_1164.all;

entity reg16 is
    generic (
        WIDTH : positive := 16
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        en  : in  std_logic;
        d   : in  std_logic_vector(WIDTH - 1 downto 0);
        q   : out std_logic_vector(WIDTH - 1 downto 0)
    );
end entity;

architecture rtl of reg16 is
begin

    process (clk, rst)
    begin
        if rst = '1' then
            q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;

end architecture;

