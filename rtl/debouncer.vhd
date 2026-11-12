library ieee;
use ieee.std_logic_1164.all;

-- Active-low button in, one-clock pulse out on each press.
entity debouncer is
    generic (
        STABLE_CYCLES : positive := 500_000
    );
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        btn_n : in  std_logic;
        pulse : out std_logic
    );
end entity;

architecture rtl of debouncer is
    signal sync     : std_logic_vector(1 downto 0);
    signal stable   : std_logic;
    signal stable_d : std_logic;
    signal count    : natural range 0 to STABLE_CYCLES - 1;
begin

    process (clk, rst)
    begin
        if rst = '1' then
            sync     <= (others => '1');
            stable   <= '1';
            stable_d <= '1';
            count    <= 0;
        elsif rising_edge(clk) then
            sync     <= sync(0) & btn_n;
            stable_d <= stable;

            if sync(1) = stable then
                count <= 0;
            elsif count = STABLE_CYCLES - 1 then
                stable <= sync(1);
                count  <= 0;
            else
                count <= count + 1;
            end if;
        end if;
    end process;

    pulse <= stable_d and not stable;

end architecture;

