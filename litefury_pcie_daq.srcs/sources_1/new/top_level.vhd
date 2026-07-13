LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY top_level IS
    CONSTANT BRAM_SIZE : INTEGER 2048 * 4;
    CONSTANT SAMPLE_RATE_Hz : INTEGER 136;  -- 136 for a BRAM size of 8192 KB it well take aprox. 1 min to fill the entire BRAM
    CONSTANT CLK_FREQ_Hz : INTEGER 200_000_000;

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
            buffer_full : IN STD_LOGIC;

            rsta_busy_0 : OUT STD_LOGIC;
            rstb_busy_0 : OUT STD_LOGIC;
            BRAM_PORTB_0_addr : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            BRAM_PORTB_0_clk : IN STD_LOGIC;
            BRAM_PORTB_0_din : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            BRAM_PORTB_0_dout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            BRAM_PORTB_0_en : IN STD_LOGIC;
            BRAM_PORTB_0_rst : IN STD_LOGIC;
            BRAM_PORTB_0_we : IN STD_LOGIC_VECTOR (3 DOWNTO 0)

        );
    END COMPONENT design_1_wrapper;

    COMPONENT IBUFDS IS
        PORT (
            O : OUT STD_LOGIC; -- 1-bit output: Buffer output
            I : IN STD_LOGIC; -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
            IB : IN STD_LOGIC
        ); -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    END COMPONENT IBUFDS;

    COMPONENT tick_gen IS
        GENERIC (
            TICK_RATE_HZ : INTEGER := SAMPLE_RATE_Hz; -- Tick rate in Hz
            CLK_FREQ_HZ : INTEGER := CLK_FREQ_Hz
        );
        PORT (
            rst_n : IN STD_LOGIC;
            tick : OUT STD_LOGIC;
            sysclk : IN STD_LOGIC
        );
    END COMPONENT tick_gen;

    COMPONENT acquisition_ctrl IS
        GENERIC (
            buffer_size : INTEGER := BRAM_SIZE; -- Size of the buffer in samples
            sample_rate_hz : INTEGER := SAMPLE_RATE_Hz; -- Rate at which new sawtooth samples are generated
            clk_freq_hz : INTEGER := CLK_FREQ_Hz -- Input CLK_FREQ_HZ
        );
        PORT (
            clk : IN STD_LOGIC;
            rst_n : IN STD_LOGIC;
            acq_en : IN STD_LOGIC;
            is_running : OUT STD_LOGIC;
            buffer_full : OUT STD_LOGIC;
            sample_ready : OUT STD_LOGIC;
            sample_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            sample_idx : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT acquisition_ctrl;

    SIGNAL sys_clk : STD_LOGIC;
    SIGNAL tick_1Hz : STD_LOGIC;
    SIGNAL count : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- 4-bit counter
    SIGNAL enable_acquisition_sig : STD_LOGIC;
    SIGNAL is_running_sig : STD_LOGIC;
    SIGNAL buffer_full_sig : STD_LOGIC;

    ATTRIBUTE ASYNC_REG : STRING; --könnte man auch im xdc setzen, aber hier ist es einfacher: set_property ASYNC_REG TRUE [get_cells {FF1_reg FF2_reg}]
    SIGNAL FF1_reg : STD_ULOGIC := '0';
    SIGNAL enable_acquisition_synced : STD_ULOGIC := '0'; -- Synchronisiertes Signal für enable_acquisition (Hint CDC)
    ATTRIBUTE ASYNC_REG OF FF1_reg : SIGNAL IS "TRUE";
    ATTRIBUTE Async_Reg OF enable_acquisition_synced : SIGNAL IS "TRUE";

    SIGNAL bram_addr_counter_sig : STD_LOGIC_VECTOR (12 DOWNTO 0) := (OTHERS => '0'); -- 13-bit counter for BRAM address 
    SIGNAL BRAM_PORTB_0_addr_sig : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL BRAM_PORTB_0_we_sig : STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL BRAM_PORTB_0_rst_sig : STD_LOGIC; -- unfortnattly we need a reset signal for the BRAM, because its reset
    SIGNAL sample_valid_sig : STD_LOGIC; -- Signal to indicate when the sample is valid
    SIGNAL sawtooth_out_sig : STD_LOGIC_VECTOR (31 DOWNTO 0) := (OTHERS => '0'); -- 32-bit sawtooth output
    SIGNAL sample_idx_sig : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0'); -- 32-bit sample index

BEGIN

    efury_sys_clk : IBUFDS
    PORT MAP(
        O => sys_clk, -- 1-bit output: Buffer output
        I => sysclk_p, -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
        IB => sysclk_n -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
    );

    tick_gen_inst : tick_gen
    GENERIC MAP(
        TICK_RATE_HZ => SAMPLE_RATE_Hz, -- 1 Hz
        CLK_FREQ_HZ => CLK_FREQ_Hz -- 200 MHz
    )
    PORT MAP(
        rst_n => pcie_reset,
        tick => tick_1Hz,
        sysclk => sys_clk
    );
    acquisition_ctrl_inst : acquisition_ctrl
    GENERIC MAP(
        buffer_size => BRAM_SIZE,
        sample_rate_hz => SAMPLE_RATE_Hz,
        clk_freq_hz => CLK_FREQ_Hz
    )
    PORT MAP(
        clk => sys_clk,
        rst_n => pcie_reset,
        acq_en => enable_acquisition_synced,
        is_running => is_running_sig,
        buffer_full => buffer_full_sig,
        sample_ready => sample_valid_sig,
        sample_out => sawtooth_out_sig,
        sample_idx => sample_idx_sig
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
        --GPIOs:
        ledn => OPEN, --ledn,

        --CSR Control status Register:
        enable_acquisition => enable_acquisition_sig,
        is_running => is_running_sig,
        buffer_full => buffer_full_sig,

        --Bram Port B:
        rsta_busy_0 => OPEN,
        rstb_busy_0 => OPEN,
        BRAM_PORTB_0_addr => BRAM_PORTB_0_addr_sig,
        BRAM_PORTB_0_clk => sys_clk,
        BRAM_PORTB_0_din => sawtooth_out_sig,
        BRAM_PORTB_0_dout => OPEN,
        BRAM_PORTB_0_en => '1', -- optional
        BRAM_PORTB_0_rst => BRAM_PORTB_0_rst_sig,
        BRAM_PORTB_0_we => BRAM_PORTB_0_we_sig

    );

    PROCESS (sys_clk, pcie_reset)
    BEGIN

        IF pcie_reset = '0' THEN
            ff1_reg <= '0';
            enable_acquisition_synced <= '0';
            bram_addr_counter_sig <= (OTHERS => '0');

        ELSIF rising_edge(sys_clk) THEN
            FF1_reg <= enable_acquisition_sig;
            enable_acquisition_synced <= FF1_reg;
            -- Byte address: 11-bit word index shifted left by 2 (×4) for 4-byte words, giving 13-bit byte address (2^13 = 8192 bytes)
            bram_addr_counter_sig <= sample_idx_sig(10 DOWNTO 0) & "00";
        END IF;
    END PROCESS;
    BRAM_PORTB_0_addr_sig <= (18 DOWNTO 0 => '0') & bram_addr_counter_sig;
    BRAM_PORTB_0_we_sig <= (3 DOWNTO 0 => sample_valid_sig);
    BRAM_PORTB_0_rst_sig <= NOT pcie_reset;

    -- heart beat process for LEDs, shows that every thing is working
    PROCESS (sys_clk, pcie_reset)
    BEGIN
        IF pcie_reset = '0' THEN
            count <= (OTHERS => '0'); -- Reset: Alle LEDs an
        ELSIF rising_edge(sys_clk) THEN
            IF tick_1Hz = '1' AND enable_acquisition_synced = '1' THEN
                count <= STD_LOGIC_VECTOR(unsigned(count) + 1);
            ELSIF tick_1Hz = '1' THEN
                count <= NOT count;
            END IF;
        END IF;
    END PROCESS;

    ledn <= NOT count; -- LEDs zeigen den Zählerstand an
END Behavioral;