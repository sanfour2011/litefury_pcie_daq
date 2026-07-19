----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05.07.2026 17:37:44
-- Design Name:
-- Module Name: sample_gen_tb - Behavioral
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

entity sample_gen_tb is
	--  Port ( );
end sample_gen_tb;

architecture Behavioral of sample_gen_tb is

	constant SAMPLE_RATE_HZ : integer := 100_000_000;
	constant CLK_FREQ_HZ    : integer := 200_000_000;
	constant CLK_PERIOD_NS  : time := 1_000_000_000 ns / CLK_FREQ_HZ;  -- Clock period in nanoseconds

	signal clk_sig          : std_logic := '0';
	signal rst_n_sig        : std_logic := '0';
	signal sawtooth_out_sig : std_logic_vector(31 downto 0);
	signal sample_valid_sig : std_logic;

	component sample_gen
	generic (
		SAMPLE_RATE_HZ : integer := SAMPLE_RATE_HZ;  -- Desired output clk frequency
		CLK_FREQ_HZ    : integer := CLK_FREQ_HZ      -- Input CLK_FREQ_HZ
	);
	port (
		rst_n        : in  std_logic;
		clk          : in  std_logic;
		enable       : in  std_logic;
		sawtooth_out : out std_logic_vector (31 downto 0);
		sample_valid : out std_logic
	);
end component;
begin

UUT : sample_gen
generic map (
	SAMPLE_RATE_HZ => SAMPLE_RATE_HZ,  -- Desired output clk frequency
	CLK_FREQ_HZ    => CLK_FREQ_HZ      -- Input CLK_FREQ_HZ
)
port map (
	rst_n        => rst_n_sig,
	clk          => clk_sig,
	enable       => '1',               -- Always enable for this test
	sawtooth_out => sawtooth_out_sig,
	sample_valid => sample_valid_sig
);

clk_process : process
begin
	while true loop
		clk_sig <= '0';
		wait for 2.5 ns;
		clk_sig <= '1';
		wait for 2.5 ns;
	end loop;
	end process clk_process;

	reset_process : process
	begin
		rst_n_sig <= '0';
		wait for 20 ns;
		rst_n_sig <= '1';
		wait for 1 ns; -- Wait for some time to observe the output
		assert sawtooth_out_sig = x"00000000" report "Sawtooth output is not zero after reset!" severity error;
		assert sample_valid_sig = '0' report "Sample valid is not low after reset!" severity error;
		wait;
	end process reset_process;

	sawtooth_check : process
	variable expected_value : unsigned(31 downto 0) := (others => '0');
	variable last_time      : time := 0 ns;
	variable first_sample   : boolean := true;

	begin
		while true loop
			wait until rising_edge (clk_sig);
			if sample_valid_sig = '1' then
				expected_value := expected_value + 1;
				assert sawtooth_out_sig = std_logic_vector(expected_value) report "Sawtooth output does not match expected value!" severity error;

				if first_sample then
					first_sample := false;
				else
					assert (now - last_time) = (CLK_FREQ_HZ/SAMPLE_RATE_HZ) * CLK_PERIOD_NS report "Time interval between samples is not as expected!" severity error;
				end if;
				last_time := now;
			end if;
		end loop;
		end process sawtooth_check;
	end Behavioral;
