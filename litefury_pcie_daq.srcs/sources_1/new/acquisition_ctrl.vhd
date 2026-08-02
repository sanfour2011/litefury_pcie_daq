----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 11.07.2026 19:55:30
-- Design Name:
-- Module Name: acquisition_ctrl - Behavioral
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

entity acquisition_ctrl is
	generic (
		buffer_size    : integer := 2048;         -- Size of the buffer in samples
		sample_rate_hz : integer := 100_000_000;  -- Rate at which new sawtooth samples are generated
		clk_freq_hz    : integer := 200_000_000;  -- Input CLK_FREQ_HZ
		rst_idx_on_rst : std_logic := '1'
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
end acquisition_ctrl;

architecture Behavioral of acquisition_ctrl is
	signal sample_idx_sig   : std_logic_vector(31 downto 0) := (others => '0');
	signal buffer_full_sig  : std_logic := '0';
	signal sample_valid_sig : std_logic := '0';
	signal enable_sig       : std_logic;

	component sample_gen
	generic (
		SAMPLE_RATE_HZ : integer := 100_000_000;  -- Rate at which new sawtooth samples are generated
		CLK_FREQ_HZ    : integer := 200_000_000   -- Input CLK_FREQ_HZ
	);
	port (
		rst_n  : in std_logic;
		clk    : in std_logic;
		enable : in std_logic;

		sawtooth_out : out std_logic_vector (31 downto 0);
		sample_valid : out std_logic
	);
end component;

begin
sample_gen_inst : sample_gen
generic map (
	SAMPLE_RATE_HZ => sample_rate_hz,
	CLK_FREQ_HZ    => clk_freq_hz      -- Input CLK_FREQ_HZ
)
port map (
	rst_n        => rst_n,
	clk          => clk,
	enable       => enable_sig,       -- Enable sample generation only when acquisition is enabled and buffer is not full
	sawtooth_out => sample_out,
	sample_valid => sample_valid_sig
);

u_process_1 : process (clk, rst_n)
begin
	if rst_n = '0' then
		is_running <= '0';
		buffer_full_sig <= '0';
		if (rst_idx_on_rst = '1') then
			sample_idx_sig <= (others => '0');
		end if;
	elsif rising_edge(clk) then
		if acq_en = '1' and buffer_full_sig = '0' then
			is_running <= '1';
			if sample_valid_sig = '1' then
				sample_idx_sig <= std_logic_vector(unsigned(sample_idx_sig) + 1);
			end if;
			if unsigned(sample_idx_sig) >= buffer_size then
				buffer_full_sig <= '1';
				is_running <= '0';
			end if;
		else
			is_running <= '0';
		end if;
	end if;
end process u_process_1;

sample_ready <= sample_valid_sig;
buffer_full <= buffer_full_sig;
sample_idx <= sample_idx_sig;
enable_sig <= acq_en and not buffer_full_sig; -- Enable sample generation only when acquisition is enabled and buffer is not full

end Behavioral;
