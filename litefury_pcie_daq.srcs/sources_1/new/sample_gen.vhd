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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
-- LIBRARY UNISIM;
-- USE UNISIM.VComponents.ALL;

ENTITY sample_gen IS
    GENERIC (
        SAMPLE_RATE_HZ : INTEGER := 1; -- Rate at which new sawtooth samples are generated
        CLK_FREQ_HZ : INTEGER := 200_000_000-- Input CLK_FREQ_HZ

    );
    PORT (
        rst_n : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        sawtooth_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        sample_valid : OUT STD_LOGIC
    );
END sample_gen;

ARCHITECTURE Behavioral OF sample_gen IS
    SIGNAL count : unsigned (27 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sawtooth_value : unsigned (31 DOWNTO 0) := (OTHERS => '0'); -- 32-bit sawtooth value

BEGIN

    PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            count <= (OTHERS => '0');
            sawtooth_value <= (OTHERS => '0');
            sample_valid <= '0';
        ELSIF rising_edge(clk) THEN
            IF enable = '1' THEN
                IF count = (CLK_FREQ_HZ / SAMPLE_RATE_HZ - 1) THEN
                    count <= (OTHERS => '0');
                    sawtooth_value <= sawtooth_value + 1; -- Increment sawtooth value and wrap around at 2^32
                    sample_valid <= '1'; -- Set sample_valid high for one clock cycle
                ELSE
                    sample_valid <= '0'; -- Set sample_valid low
                    count <= count + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    sawtooth_out <= STD_LOGIC_VECTOR(UNSIGNED (sawtooth_value));

END Behavioral;