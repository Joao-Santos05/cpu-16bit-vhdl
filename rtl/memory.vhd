library ieee;
use ieee.std_logic_1164.all;
use work.cpu_pkg.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

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

architecture rtl of memory is

    signal clk_n : std_logic;

    -- RUNTIME_MOD exposes the RAM to the In-System Memory Content Editor (JTAG),
    -- so a program can be loaded without recompiling.
    function ram_hint(runtime_mod : boolean) return string is
    begin
        if runtime_mod then
            return "ENABLE_RUNTIME_MOD=YES,INSTANCE_ID=RAM";
        else
            return "ENABLE_RUNTIME_MOD=NO";
        end if;
    end function;

begin

    -- Address is registered on the falling edge so a read completes within a
    -- single CPU state (REM loads on the rising edge, RDM/RI sample q on the next).
    clk_n <= not clk;

    u_ram : altsyncram
        generic map (
            operation_mode                => "SINGLE_PORT",
            width_a                       => word_t'length,
            widthad_a                     => ADDR_WIDTH,
            numwords_a                    => 2 ** ADDR_WIDTH,
            outdata_reg_a                 => "UNREGISTERED",
            outdata_aclr_a                => "NONE",
            clock_enable_input_a          => "BYPASS",
            clock_enable_output_a         => "BYPASS",
            read_during_write_mode_port_a => "NEW_DATA_NO_NBE_READ",
            power_up_uninitialized        => "FALSE",
            init_file                     => INIT_FILE,
            intended_device_family        => "Cyclone IV E",
            lpm_hint                      => ram_hint(RUNTIME_MOD),
            lpm_type                      => "altsyncram",
            width_byteena_a               => 1
        )
        port map (
            clock0    => clk_n,
            address_a => addr,
            data_a    => wdata,
            wren_a    => we,
            q_a       => rdata
        );

end architecture;

