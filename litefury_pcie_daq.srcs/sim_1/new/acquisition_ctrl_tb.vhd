----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.07.2026 09:59:13
-- Design Name: 
-- Module Name: acquisition_ctrl_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library ieee;
use ieee.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use ieee.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity acquisition_ctrl_tb is
	--  Port ( );
end acquisition_ctrl_tb;

architecture Behavioral of acquisition_ctrl_tb is

	constant BRAM_size      : integer := 1024 * 8;     -- Size of the buffer in samples
	constant sample_rate_hz : integer := 100_000_000;  -- Rate at which new sawtooth samples are generated
	constant clk_freq_hz    : integer := 200_000_000;  -- Input CLK_FREQ_HZ

	type BRAM_type is array (0 to BRAM_size - 1) of std_logic_vector(31 downto 0);
	component acquisition_ctrl
	generic (
		buffer_size    : integer := 1024;         -- Size of the buffer in samples
		sample_rate_hz : integer := 100_000_000;  -- Rate at which new sawtooth samples are generated
		clk_freq_hz    : integer := 200_000_000   -- Input CLK_FREQ_HZ
	);
	port (
		clk          : in  std_logic;
		rst_n        : in  std_logic;
		acq_en       : in  std_logic;                      -- Acquisition enable signal, to start/stop generating samples
		is_running   : out std_logic;
		buffer_full  : out std_logic;
		sample_ready : out std_logic;                      -- Signal indicating that a new sample is ready
		sample_out   : out std_logic_vector(31 downto 0);
		sample_idx   : out std_logic_vector(31 downto 0)

	);
end component;

signal clk_sig                      : std_logic := '0';
signal rst_n_sig                    : std_logic := '0';
signal acq_en_sig                   : std_logic := '0';
signal is_running_sig               : std_logic;
signal buffer_full_sig              : std_logic;
signal sample_ready_sig             : std_logic;
signal sample_out_sig               : std_logic_vector(31 downto 0);
signal sample_idx_sig               : std_logic_vector(31 downto 0);
signal next_test_nr                 : std_logic_vector(1 downto 0) := (others => '0');  -- Test number for the testbench: 0 = reset, 1 = enable acquisition, 2 = check sample index and output
signal reset_test_done              : std_logic := '0';                                 -- Flag to indicate that the reset test is done
signal enable_acquisition_test_done : std_logic := '0';                                 -- Flag to indicate that the enable acquisition test is done
signal BRAM_sim_sig                 : BRAM_type := (others => (others => '0'));         -- Simulated BRAM for storing samples
begin
UUT : acquisition_ctrl
generic map (
	buffer_size    => BRAM_size,       -- Size of the buffer in samples
	sample_rate_hz => sample_rate_hz,  -- Rate at which new sawtooth samples are generated
	clk_freq_hz    => clk_freq_hz      -- Input CLK_FREQ_HZ
)
port map (
	clk          => clk_sig,
	rst_n        => rst_n_sig,
	acq_en       => acq_en_sig,
	is_running   => is_running_sig,
	buffer_full  => buffer_full_sig,
	sample_ready => sample_ready_sig,
	sample_out   => sample_out_sig,
	sample_idx   => sample_idx_sig
);
clk_process : process
begin
	while true loop
		clk_sig <= '1';
		wait for 2.5 ns;
		clk_sig <= '0';
		wait for 2.5 ns;
	end loop;
	end process clk_process;

	reset_process : process
	begin
		rst_n_sig <= '0';
		wait for 10 ns;
		reset_test_done <= '0'; -- Reset the flag for the reset test
		assert is_running_sig = '0' report "is_running_sig should be low after reset!" severity error;
		assert buffer_full_sig = '0' report "buffer_full_sig should be low after reset!" severity error;
		assert sample_ready_sig = '0' report "sample_ready_sig should be low after reset!" severity error;
		assert sample_out_sig = (sample_out_sig'range => '0') report "sample_out_sig should be zero after reset!" severity error;
		assert sample_idx_sig = (sample_idx_sig'range => '0') report "sample_idx_sig should be zero after reset!" severity error;
		rst_n_sig <= '1';
		reset_test_done <= '1'; -- Mark the reset test as done
		wait; --wait forever
	end process reset_process;

	Enable_acquisition : process
	begin
		wait until next_test_nr = "01";
		--
		wait until rising_edge(clk_sig);

		assert is_running_sig = '0' report "1- is_running_sig should be low before enabling acquisition!" severity error;
		wait until rising_edge(clk_sig);
		acq_en_sig <= '1';
		wait until rising_edge(clk_sig);
		wait for 1 ns; -- Wait for some time to observe the output
		assert is_running_sig = '1' report "2- is_running_sig should be high when acquisition is enabled!" severity error;
		wait for 100 ns; -- Wait for some time to observe the output
		wait until rising_edge(clk_sig);
		acq_en_sig <= '0';
		wait until rising_edge(clk_sig);
		wait for 1 ns; -- Wait for some time to observe the output
		assert is_running_sig = '0' report "3- is_running_sig should be low after disabling acquisition!" severity error;
		acq_en_sig <= '1';
		wait until rising_edge(clk_sig);

		enable_acquisition_test_done <= '1'; -- Mark the enable acquisition test as done
		wait; --wait forever
	end process Enable_acquisition;

	aquisition_ctrl_check : process
	variable previous_sample_idx : std_logic_vector(31 downto 0) := (others => '0');
	variable previous_sample_out : std_logic_vector(31 downto 0) := (others => '0');
	begin
		wait until next_test_nr = "11";
		-- Since sample_gen keeps running from the previous test, initialize
		-- the variables here so this check is independent of prior test timing
		previous_sample_idx := sample_idx_sig;
		previous_sample_out := sample_out_sig;
		while true loop
			wait until rising_edge(clk_sig);
			-- acq_en_sig ist set to 1 in previous test "Enable_acquisition"
			if buffer_full_sig = '0' then
				assert is_running_sig = '1' report "4- is_running_sig should be high when acquisition is enabled!" severity error;
				if sample_ready_sig = '1' then
					wait for 1 ns; -- Wait for some time to observe the output
					assert sample_idx_sig = std_logic_vector(unsigned(previous_sample_idx) + 1) report "sample_idx_sig should increment by 1 when sample_ready_sig is high!" severity error;
					assert sample_out_sig = std_logic_vector(unsigned(previous_sample_out) + 1) report "sample_out_sig should increment by 1 when sample_ready_sig is high!" severity error;

					previous_sample_idx := sample_idx_sig;
					previous_sample_out := sample_out_sig;
				end if;
			end if;
		end loop;

		end process aquisition_ctrl_check;

		populate_BRAM : process
		variable sample_count : integer := 0;
		begin
			wait until next_test_nr = "11";
			while sample_count < BRAM_size loop
				wait until rising_edge(clk_sig);
				if sample_ready_sig = '1' and buffer_full_sig = '0' then
					BRAM_sim_sig(sample_count) <= sample_out_sig;
					sample_count := sample_count + 1;
				end if;
			end loop;
				wait until rising_edge(clk_sig);
				assert buffer_full_sig = '1' report "buffer_full_sig should be high when the buffer is full!" severity error;
				wait until rising_edge(clk_sig);
				assert sample_idx_sig = std_logic_vector(to_unsigned(BRAM_size, 32)) report "sample_idx_sig should be equal to buffer size when the buffer is full!" severity error;
				wait until rising_edge(clk_sig);
				assert sample_ready_sig = '0' report "sample_ready_sig should be low when the buffer is full!" severity error;
				wait until rising_edge(clk_sig);
				assert is_running_sig = '0' report "5- is_running_sig should be low when the buffer is full!" severity error;
			end process populate_BRAM;
			next_test_nr <= (enable_acquisition_test_done, reset_test_done);
		end Behavioral;
