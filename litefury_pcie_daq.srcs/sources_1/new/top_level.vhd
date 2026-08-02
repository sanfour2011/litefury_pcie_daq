library ieee;
use ieee.NUMERIC_STD.all;
use ieee.STD_LOGIC_1164.all;

entity top_level is
	port (
		-- Pins aus deiner top.xdc
		pcie_clkin_clk_n : in  std_logic_vector(0 to 0);
		pcie_clkin_clk_p : in  std_logic_vector(0 to 0);
		pcie_reset       : in  std_logic;
		pcie_clkreq_l    : out std_logic;

		-- Pins aus deiner early.xdc
		pcie_mgt_rxn : in  std_logic_vector (3 downto 0);
		pcie_mgt_rxp : in  std_logic_vector (3 downto 0);
		pcie_mgt_txn : out std_logic_vector (3 downto 0);
		pcie_mgt_txp : out std_logic_vector (3 downto 0);

		-- Pins aus deiner normal.xdc
		ledn : out std_logic_vector (3 downto 0);
		-- sysclk_p : IN STD_LOGIC;
		-- sysclk_n : IN STD_LOGIC
		sysclk_p : in std_logic;  -- liteury internal clk 200 MHz
		sysclk_n : in std_logic   -- liteury internal clk 200 MHz
	);
end top_level;

architecture Behavioral of top_level is
	constant BRAM_SIZE      : integer := 2048;         -- number of 32-bit samples (words) that the BRAM is holding and NOT bytes: 2048 words x 4 bytes = 8192 bytes total.
	constant SAMPLE_RATE_Hz : integer := 30;           -- at 30 samples/s, filling 2048 samples takes ~1 min , convenient for manual hardware tests via RWEverything.
	constant CLK_FREQ_Hz    : integer := 200_000_000;

	-- JETZT EXAKT: Die Komponente angepasst an deine design_1_wrapper.vhd
	component design_1_wrapper is
	port (
		pcie_7x_mgt_rtl_0_rxn : in  std_logic_vector (3 downto 0);
		pcie_7x_mgt_rtl_0_rxp : in  std_logic_vector (3 downto 0);
		pcie_7x_mgt_rtl_0_txn : out std_logic_vector (3 downto 0);
		pcie_7x_mgt_rtl_0_txp : out std_logic_vector (3 downto 0);
		pcie_clkin_clk_clk_n  : in  std_logic_vector (0 to 0);
		pcie_clkin_clk_clk_p  : in  std_logic_vector (0 to 0);
		pcie_reset            : in  std_logic;

		--Added by me:
		ledn               : out std_logic_vector (3 downto 0);
		enable_acquisition : out std_logic;
		is_running         : in  std_logic;
		buffer_full        : in  std_logic;
		irq_pending        : out std_logic;

		rsta_busy_0       : out std_logic;
		rstb_busy_0       : out std_logic;
		BRAM_PORTB_0_addr : in  std_logic_vector (31 downto 0);
		BRAM_PORTB_0_clk  : in  std_logic;
		BRAM_PORTB_0_din  : in  std_logic_vector (31 downto 0);
		BRAM_PORTB_0_dout : out std_logic_vector (31 downto 0);
		BRAM_PORTB_0_en   : in  std_logic;
		BRAM_PORTB_0_rst  : in  std_logic;
		BRAM_PORTB_0_we   : in  std_logic_vector (3 downto 0);

		usr_irq_req      : in  std_logic_vector (0 downto 0);
		usr_irq_ack      : out std_logic_vector (0 downto 0);
		msi_enable       : out std_logic;
		msi_vector_width : out std_logic_vector (2 downto 0)

	);
end component design_1_wrapper;

component IBUFDS is
port (
	O  : out std_logic;  -- 1-bit output: Buffer output
	I  : in  std_logic;  -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
	IB : in  std_logic
); -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
end component IBUFDS;

component tick_gen is
generic (
	TICK_RATE_HZ : integer := SAMPLE_RATE_Hz;  -- Tick rate in Hz
	CLK_FREQ_HZ  : integer := CLK_FREQ_Hz
);
port (
	rst_n  : in  std_logic;
	tick   : out std_logic;
	sysclk : in  std_logic
);
end component tick_gen;

component acquisition_ctrl is
generic (
	buffer_size    : integer := BRAM_SIZE;       -- Size of the buffer in samples
	sample_rate_hz : integer := SAMPLE_RATE_Hz;  -- Rate at which new sawtooth samples are generated
	clk_freq_hz    : integer := CLK_FREQ_Hz      -- Input CLK_FREQ_HZ
);
port (
	clk          : in  std_logic;
	rst_n        : in  std_logic;
	acq_en       : in  std_logic;
	is_running   : out std_logic;
	buffer_full  : out std_logic;
	sample_ready : out std_logic;
	sample_out   : out std_logic_vector(31 downto 0);
	sample_idx   : out std_logic_vector(31 downto 0)
);
end component acquisition_ctrl;

attribute ASYNC_REG : string;             --könnte man auch im xdc setzen, aber hier ist es einfacher: set_property ASYNC_REG TRUE [get_cells {FF1_reg FF2_reg}]

signal sys_clk               : std_logic;
signal soft_rst_acq_ctrl_sig : std_logic := '1';
signal tick_1Hz              : std_logic;
signal count                 : std_logic_vector(3 downto 0) := (others => '0');  -- 4-bit counter

--CSR
signal enable_acquisition_sig                 : std_logic;
signal irq_pending_sig                        : std_logic;
signal irq_pending_sig_synced                 : std_logic;
signal irq_pending_FF1                        : std_ulogic := '0';
attribute ASYNC_REG of irq_pending_FF1        : signal is "TRUE";
attribute ASYNC_REG of irq_pending_sig_synced : signal  is "TRUE";

signal is_running_sig     : std_logic;
signal buffer_full_sig    : std_logic;
signal acq_ctrl_rst_n_sig : std_logic;

signal FF1_reg                                   : std_ulogic := '0';
signal enable_acquisition_synced                 : std_ulogic := '0';  -- Synchronisiertes Signal für enable_acquisition (Hint CDC)
attribute ASYNC_REG of FF1_reg                   : signal is "TRUE";
attribute ASYNC_REG of enable_acquisition_synced : signal is "TRUE";

-- BRAM
signal bram_addr_counter_sig : std_logic_vector (12 downto 0) := (others => '0');  -- 13-bit counter for BRAM address
signal BRAM_PORTB_0_addr_sig : std_logic_vector (31 downto 0) := (others => '0');
signal BRAM_PORTB_0_we_sig   : std_logic_vector (3 downto 0) := (others => '0');
signal BRAM_PORTB_0_rst_sig  : std_logic;                                          -- unfortnattly we need a reset signal for the BRAM, because its reset
signal sample_valid_sig      : std_logic;                                          -- Signal to indicate when the sample is valid
signal sawtooth_out_sig      : std_logic_vector (31 downto 0) := (others => '0');  -- 32-bit sawtooth output
signal sample_idx_sig        : std_logic_vector(31 downto 0) := (others => '0');   -- 32-bit sample index

-- ATTRIBUTE mark_debug : STRING;
-- ATTRIBUTE mark_debug OF BRAM_PORTB_0_addr_sig : SIGNAL IS "TRUE";
-- ATTRIBUTE mark_debug OF sawtooth_out_sig : SIGNAL IS "TRUE";
-- ATTRIBUTE mark_debug OF sample_valid_sig : SIGNAL IS "TRUE";
-- ATTRIBUTE mark_debug OF sample_idx_sig : SIGNAL IS "TRUE";
-- ATTRIBUTE mark_debug OF BRAM_PORTB_0_we_sig : SIGNAL IS "TRUE";

signal usr_irq_req_sig                        : std_logic_vector (0 downto 0);
signal usr_irq_ack_sig                        : std_logic_vector (0 downto 0);
signal msi_enable_sig                         : std_logic;
signal msi_vector_width_sig                   : std_logic_vector (2 downto 0);
signal usr_irq_ack_FF1                        : std_ulogic := '0';
signal usr_irq_ack_sig_sycend                 : std_logic_vector (0 downto 0);
attribute ASYNC_REG of usr_irq_ack_FF1        : signal is "TRUE";
attribute ASYNC_REG of usr_irq_ack_sig_sycend : signal is "TRUE";

constant IDLE                         : std_logic_vector(2 downto 0) := "000";
constant WAIT_FOR_HOST_ACK            : std_logic_vector(2 downto 0) := "010";
constant WAIT_FOR_IRQ_PENDING_CLEARED : std_logic_vector(2 downto 0) := "100";
signal  next_state_sig                : std_logic_vector(2 downto 0) := IDLE;

begin

efury_sys_clk : IBUFDS
port map (
	O  => sys_clk,   -- 1-bit output: Buffer output
	I  => sysclk_p,  -- 1-bit input: Diff_p buffer input (connect directly to top-level port)
	IB => sysclk_n   -- 1-bit input: Diff_n buffer input (connect directly to top-level port)
);

tick_gen_inst : tick_gen
generic map (
	TICK_RATE_HZ => 1,           -- 1 Hz
	CLK_FREQ_HZ  => CLK_FREQ_Hz  -- 200 MHz
)
port map (
	rst_n  => pcie_reset,
	tick   => tick_1Hz,
	sysclk => sys_clk
);
acquisition_ctrl_inst : acquisition_ctrl
generic map (
	buffer_size    => BRAM_SIZE,
	sample_rate_hz => SAMPLE_RATE_Hz,
	clk_freq_hz    => CLK_FREQ_Hz
)
port map (
	clk          => sys_clk,
	rst_n        => soft_rst_acq_ctrl_sig,
	acq_en       => enable_acquisition_synced,
	is_running   => is_running_sig,
	buffer_full  => buffer_full_sig,
	sample_ready => sample_valid_sig,
	sample_out   => sawtooth_out_sig,
	sample_idx   => sample_idx_sig
);
--ToDo: Siehe PCIe Takt-Anforderung auf Low setzen, sollte nicht immer aktiv sein,
-- nur bei bedarf, windows treiber können das auch steuern, 
--aber für die Demo ist es in Ordnung:
pcie_clkreq_l <= '0';-- PCIe Takt-Anforderung dauerhaft auf Aktiv (Low)

-- Das Port-Mapping verbindet die Wrapper-Ports mit deinen Top-Level-Pins
block_design_inst : design_1_wrapper
port map (
	pcie_clkin_clk_clk_n  => pcie_clkin_clk_n,
	pcie_clkin_clk_clk_p  => pcie_clkin_clk_p,
	pcie_7x_mgt_rtl_0_rxn => pcie_mgt_rxn,
	pcie_7x_mgt_rtl_0_rxp => pcie_mgt_rxp,
	pcie_7x_mgt_rtl_0_txn => pcie_mgt_txn,
	pcie_7x_mgt_rtl_0_txp => pcie_mgt_txp,

	pcie_reset => pcie_reset,

	--Added by me:
	--GPIOs:
	ledn => open, --ledn,

	--CSR Control status Register:
	enable_acquisition => enable_acquisition_sig,
	is_running         => is_running_sig,
	buffer_full        => buffer_full_sig,
	irq_pending        => irq_pending_sig,

	--Bram Port B:
	rsta_busy_0       => open,
	rstb_busy_0       => open,
	BRAM_PORTB_0_addr => BRAM_PORTB_0_addr_sig,
	BRAM_PORTB_0_clk  => sys_clk,
	BRAM_PORTB_0_din  => sawtooth_out_sig,
	BRAM_PORTB_0_dout => open,
	BRAM_PORTB_0_en   => '1',                    -- optional
	BRAM_PORTB_0_rst  => BRAM_PORTB_0_rst_sig,
	BRAM_PORTB_0_we   => BRAM_PORTB_0_we_sig,

	-- Interrupt
	usr_irq_req      => usr_irq_req_sig,
	usr_irq_ack      => usr_irq_ack_sig,
	msi_enable       => msi_enable_sig,
	msi_vector_width => msi_vector_width_sig
);

u_process_1 : process (sys_clk, pcie_reset)
begin

	if pcie_reset = '0' then
		ff1_reg <= '0';
		enable_acquisition_synced <= '0';
		bram_addr_counter_sig <= (others => '0');

	elsif rising_edge(sys_clk) then
		FF1_reg <= enable_acquisition_sig;
		enable_acquisition_synced <= FF1_reg;
		-- Byte address: 11-bit word index shifted left by 2 (×4) for 4-byte words, giving 13-bit byte address (2^13 = 8192 bytes)
		bram_addr_counter_sig <= sample_idx_sig(10 downto 0) & "00";
	end if;
end process u_process_1;

irq_handler : process (sys_clk, pcie_reset)
begin
	if pcie_reset = '0' then
		next_state_sig <= IDLE;
		acq_ctrl_rst_n_sig <= '1';
		usr_irq_req_sig <= (others => '0');

	elsif rising_edge(sys_clk) then
		acq_ctrl_rst_n_sig <= '1'; -- return acquisition controller reset to back after reset is released in WAIT_FOR_IRQ_PENDING_CLEARED state
		usr_irq_ack_FF1 <= usr_irq_ack_sig(0) ;
		usr_irq_ack_sig_sycend <= (others => usr_irq_ack_FF1);
		irq_pending_FF1 <= irq_pending_sig;
		irq_pending_sig_synced <= irq_pending_FF1;
		case next_state_sig is
			when IDLE =>
				if (buffer_full_sig = '1') then
					usr_irq_req_sig <= "1";			
					next_state_sig <= WAIT_FOR_HOST_ACK;
				end if;
			when WAIT_FOR_HOST_ACK =>
				if (usr_irq_ack_sig_sycend = "1") then 
					next_state_sig <= WAIT_FOR_IRQ_PENDING_CLEARED;
				end if;
			when WAIT_FOR_IRQ_PENDING_CLEARED =>
				if (irq_pending_sig_synced = '0') then
					usr_irq_req_sig <= "0";
					acq_ctrl_rst_n_sig <= '0';					
					next_state_sig <= IDLE;
				end if;
			when others =>
				null;
		end case;		
	end if;
	-- buffer = 1 -> usr_irq_req_sig <= '1' -> wait usr_irq_ack_sig = 1 -> wait irq_pending =1 -> irq_reg_sig = 0
end process irq_handler;

-- heart beat process for LEDs, shows that every thing is working
u_process_3 : process (sys_clk, pcie_reset)
begin
	if pcie_reset = '0' then
		count <= (others => '0'); -- Reset: Alle LEDs an
	elsif rising_edge(sys_clk) then
		if tick_1Hz = '1' and enable_acquisition_synced = '1' then
			count <= std_logic_vector(unsigned(count) + 1);
		elsif tick_1Hz = '1' then
			count <= not count;
		end if;
	end if;
end process u_process_3;

BRAM_PORTB_0_addr_sig <= (18 downto 0 => '0') & bram_addr_counter_sig;
BRAM_PORTB_0_we_sig <= (3 downto 0 => sample_valid_sig);
BRAM_PORTB_0_rst_sig <= not pcie_reset;

soft_rst_acq_ctrl_sig <= pcie_reset and acq_ctrl_rst_n_sig;
ledn <= not count; -- LEDs zeigen den Zählerstand an
end Behavioral;
