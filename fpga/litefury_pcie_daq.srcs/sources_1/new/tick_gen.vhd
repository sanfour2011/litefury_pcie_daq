----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 14.06.2026 09:13:29
-- Design Name:
-- Module Name: tick_gen - Behavioral
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

entity tick_gen is
	generic (
		TICK_RATE_HZ : integer := 1;           -- Clock frequency in Hz
		CLK_FREQ_HZ  : integer := 200_000_000  -- Clock frequency in Hz
	);
	port (

		rst_n  : in  std_logic;
		tick   : out std_logic;
		sysclk : in  std_logic
	);
end tick_gen;

architecture Behavioral of tick_gen is
	signal count : unsigned(27 downto 0) := (others => '0'); -- 28-bit counter
begin
	u_process_1 : process (sysclk, rst_n)
	begin
		if rst_n = '0' then
			count <= (others => '0');
			tick <= '0';
		elsif rising_edge(sysclk) then
			if count = (CLK_FREQ_HZ / TICK_RATE_HZ - 1) then
				tick <= '1';
				count <= (others => '0');
			else
				tick <= '0';
				count <= count + 1;
			end if;
		end if;
	end process u_process_1;

end Behavioral;
