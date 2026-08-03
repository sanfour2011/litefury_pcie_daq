----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 05.07.2026 11:25:11
-- Design Name:
-- Module Name: sample_gen - Behavioral
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
-- LIBRARY UNISIM;
-- USE UNISIM.VComponents.ALL;

entity sample_gen is
	generic (
		SAMPLE_RATE_HZ : integer := 1;           -- Rate at which new sawtooth samples are generated
		CLK_FREQ_HZ    : integer := 200_000_000  -- Input CLK_FREQ_HZ

	);
	port (
		rst_n        : in  std_logic;
		clk          : in  std_logic;
		enable       : in  std_logic;
		sawtooth_out : out std_logic_vector (31 downto 0);
		sample_valid : out std_logic
	);
end sample_gen;

architecture Behavioral of sample_gen is
	signal count          : unsigned (27 downto 0) := (others => '0');
	signal sawtooth_value : unsigned (31 downto 0) := (others => '0');  -- 32-bit sawtooth value

begin

	u_process_1 : process (clk, rst_n)
	begin
		if rst_n = '0' then
			count <= (others => '0');
			sawtooth_value <= (others => '0');
			sample_valid <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then
				if count = (CLK_FREQ_HZ / SAMPLE_RATE_HZ - 1) then
					count <= (others => '0');
					sawtooth_value <= sawtooth_value + 1; -- Increment sawtooth value and wrap around at 2^32
					sample_valid <= '1'; -- Set sample_valid high for one clock cycle
				else
					sample_valid <= '0'; -- Set sample_valid low
					count <= count + 1;
				end if;
			end if;
		end if;
	end process u_process_1;
	sawtooth_out <= std_logic_vector(unsigned (sawtooth_value));

end Behavioral;
