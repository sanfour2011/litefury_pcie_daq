LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY top_level IS
    PORT (
        -- Pins aus deiner top.xdc
        pcie_clkin_clk_n : IN STD_LOGIC_VECTOR(0 TO 0);
        pcie_clkin_clk_p : IN STD_LOGIC_VECTOR(0 TO 0);
        pcie_reset : IN STD_LOGIC;
        pcie_clkreq_l : OUT STD_LOGIC;

        -- Pins aus deiner early.xdc
        pcie_mgt_rxn : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        pcie_mgt_rxp : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
        pcie_mgt_txn : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        pcie_mgt_txp : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

        -- Pins aus deiner normal.xdc
        ledn : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        -- sysclk_p : IN STD_LOGIC;
        -- sysclk_n : IN STD_LOGIC
        sysclk_p : IN STD_LOGIC; -- liteury internal clk 200 MHz
        sysclk_n : IN STD_LOGIC -- liteury internal clk 200 MHz
    );
END top_level;

ARCHITECTURE Behavioral OF top_level IS

    -- JETZT EXAKT: Die Komponente angepasst an deine design_1_wrapper.vhd
    COMPONENT design_1_wrapper IS
        PORT (
            pcie_7x_mgt_rtl_0_rxn : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            pcie_7x_mgt_rtl_0_rxp : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            pcie_7x_mgt_rtl_0_txn : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            pcie_7x_mgt_rtl_0_txp : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            pcie_clkin_clk_clk_n : IN STD_LOGIC_VECTOR (0 TO 0);
            pcie_clkin_clk_clk_p : IN STD_LOGIC_VECTOR (0 TO 0);
            pcie_reset : IN STD_LOGIC;

            --Added by me:
            ledn : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            enable_acquisition : OUT STD_LOGIC;
            is_running : IN STD_LOGIC;
            buffer_full : IN STD_LOGIC
        );
    END COMPONENT design_1_wrapper;

    COMPONENT IBUFDS IS
        PORT (
            O : OUT STD_LOGIC; -- 1-bit output: Buffer output
            I : IN STD_LOGIC; -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
            IB : IN STD_LOGIC
        ); -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    END COMPONENT IBUFDS;

    COMPONENT sample_gen IS
        GENERIC (
            SAMPLE_RATE_HZ : INTEGER := 100_000_000; -- Desired output clk frequency
            CLK_FREQ_HZ : INTEGER := 200_000_000 -- Input CLK_FREQ_HZ
        );
        PORT (
            rst_n : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            sawtooth_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            sample_valid : OUT STD_LOGIC
        );
    END COMPONENT sample_gen;

    COMPONENT tick_gen IS
        GENERIC (
            TICK_RATE_HZ : INTEGER := 1; -- Tick rate in Hz
            CLK_FREQ_HZ : INTEGER := 200_000_000
        );
        PORT (
            rst_n : IN STD_LOGIC;
            tick : OUT STD_LOGIC;
            sysclk : IN STD_LOGIC
        );
    END COMPONENT tick_gen;

--    COMPONENT blk_mem_gen_0 IS
--        PORT (
--            clkb : IN STD_LOGIC;
--            rstb : IN STD_LOGIC;
--            web : IN STD_LOGIC;
--            -- enb : in STD_LOGIC; --Optional, wenn nicht benötigt, kann entfernt werden oder auf '1' gesetzt werden
--            addrb : IN STD_LOGIC_VECTOR (12 DOWNTO 0);
--            dinb : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--            doutb : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
--        );
--    END COMPONENT blk_mem_gen_0;

    SIGNAL sys_clk : STD_LOGIC;
    SIGNAL tick_1Hz : STD_LOGIC;
    SIGNAL count : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- 4-bit counter
    SIGNAL enable_acquisition_sig : STD_LOGIC;
    SIGNAL is_running_sig : STD_LOGIC;
    SIGNAL buffer_full_sig : STD_LOGIC;

    ATTRIBUTE ASYNC_REG : STRING; --könnte man auch im xdc setzen, aber hier ist es einfacher: set_property ASYNC_REG TRUE [get_cells {FF1_reg FF2_reg}]
    SIGNAL FF1_reg : STD_LOGIC := '0';
    SIGNAL enable_acquisition_synced : STD_LOGIC := '0'; -- Synchronisiertes Signal für enable_acquisition (Hint CDC)
    ATTRIBUTE ASYNC_REG OF FF1_reg : SIGNAL IS "TRUE";
    ATTRIBUTE Async_Reg OF enable_acquisition_synced : SIGNAL IS "TRUE";

    SIGNAL bram_addr_counter : STD_LOGIC_VECTOR (12 DOWNTO 0) := (OTHERS => '0'); -- 13-bit counter for BRAM address 
    SIGNAL sawtooth_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- 32-bit sawtooth output
    SIGNAL sawtooth_valid : STD_LOGIC := '0'; -- Signal to indicate when the sawtooth output is valid   
    SIGNAL sample_valid : STD_LOGIC; -- Signal to indicate when the sample is valid

BEGIN

    efury_sys_clk : IBUFDS
    PORT MAP(
        O => sys_clk, -- 1-bit output: Buffer output
        I => sysclk_p, -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
        IB => sysclk_n -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    tick_gen_inst : tick_gen
    GENERIC MAP(
        TICK_RATE_HZ => 1, -- 1 Hz
        CLK_FREQ_HZ => 200_000_000 -- 200 MHz
    )
    PORT MAP(
        rst_n => pcie_reset,
        tick => tick_1Hz,
        sysclk => sys_clk
    );

    sawtooth_gen_inst : sample_gen
    GENERIC MAP(
        SAMPLE_RATE_HZ => 100_000_000, -- Desired output clk frequency
        CLK_FREQ_HZ => 200_000_000 -- Input CLK_FREQ_HZ
    )
    PORT MAP(
        rst_n => pcie_reset,
        clk => sys_clk,
        sawtooth_out => sawtooth_out,
        sample_valid => sample_valid
    );

    bram_inst : blk_mem_gen_0
    PORT MAP(
        clkb => sys_clk,
        rstb => NOT pcie_reset,
        web => sample_valid,
        -- enb => '1', -- optional 
        addrb => bram_addr_counter,
        dinb => sawtooth_out,
        doutb => OPEN
    );

    --ToDo: Siehe PCIe Takt-Anforderung auf Low setzen, sollte nicht immer aktiv sein,
    -- nur bei bedarf, windows treiber können das auch steuern, 
    --aber für die Demo ist es in Ordnung:
    pcie_clkreq_l <= '0';-- PCIe Takt-Anforderung dauerhaft auf Aktiv (Low)

    -- Das Port-Mapping verbindet die Wrapper-Ports mit deinen Top-Level-Pins
    block_design_inst : design_1_wrapper
    PORT MAP(
        pcie_clkin_clk_clk_n => pcie_clkin_clk_n,
        pcie_clkin_clk_clk_p => pcie_clkin_clk_p,
        pcie_7x_mgt_rtl_0_rxn => pcie_mgt_rxn,
        pcie_7x_mgt_rtl_0_rxp => pcie_mgt_rxp,
        pcie_7x_mgt_rtl_0_txn => pcie_mgt_txn,
        pcie_7x_mgt_rtl_0_txp => pcie_mgt_txp,

        pcie_reset => pcie_reset,

        --Added by me:

        ledn => OPEN, --ledn,
        enable_acquisition => enable_acquisition_sig,
        is_running => is_running_sig,
        buffer_full => buffer_full_sig
    );

    PROCESS (sys_clk, pcie_reset)
    BEGIN

        IF pcie_reset = '0' THEN
            is_running_sig <= '0';
            ff1_reg <= '0';
            enable_acquisition_synced <= '0';

        ELSIF rising_edge(sys_clk) THEN
            FF1_reg <= enable_acquisition_sig;
            enable_acquisition_synced <= FF1_reg;
            IF enable_acquisition_synced = '1' AND buffer_full_sig = '0' THEN
                is_running_sig <= '1';
                bram_addr_counter <= STD_LOGIC_VECTOR(unsigned(bram_addr_counter) + 1);
            ELSIF tick_1Hz = '1' THEN
                is_running_sig <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (sys_clk, pcie_reset)
    BEGIN
        IF pcie_reset = '0' THEN
            count <= (OTHERS => '0'); -- Reset: Alle LEDs an

        ELSIF rising_edge(sys_clk) THEN
            IF tick_1Hz = '1' AND enable_acquisition_synced = '1' THEN
                count <= STD_LOGIC_VECTOR(unsigned(count) + 1);
                buffer_full_sig <= NOT buffer_full_sig;
            ELSIF tick_1Hz = '1' THEN
                buffer_full_sig <= NOT buffer_full_sig;
                count <= NOT count;
            END IF;
        END IF;
    END PROCESS;

    ledn <= NOT count; -- LEDs zeigen den Zählerstand an
END Behavioral;