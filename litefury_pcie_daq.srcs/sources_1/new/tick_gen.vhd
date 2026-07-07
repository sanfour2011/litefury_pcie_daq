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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- LIBRARY UNISIM;
-- USE UNISIM.VComponents.ALL;

ENTITY tick_gen IS
    GENERIC (
        TICK_RATE_HZ : INTEGER := 1; -- Clock frequency in Hz
        CLK_FREQ_HZ : INTEGER := 200_000_000 -- Clock frequency in Hz
    );
    PORT (

        rst_n : IN STD_LOGIC;
        tick : OUT STD_LOGIC;
        sysclk : IN STD_LOGIC
    );
END tick_gen;

ARCHITECTURE Behavioral OF tick_gen IS
    SIGNAL count : UNSIGNED(27 DOWNTO 0) := (OTHERS => '0'); -- 28-bit counter
BEGIN
    PROCESS (sysclk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            count <= (OTHERS => '0');
            tick <= '0';
        ELSIF rising_edge(sysclk) THEN
            IF count = (CLK_FREQ_HZ / TICK_RATE_HZ - 1) THEN
                tick <= '1';
                count <= (OTHERS => '0');
            ELSE
                tick <= '0';
                count <= count + 1;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;