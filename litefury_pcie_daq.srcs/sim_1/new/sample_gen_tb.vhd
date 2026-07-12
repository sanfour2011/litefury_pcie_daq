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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY sample_gen_tb IS
    --  Port ( );
END sample_gen_tb;

ARCHITECTURE Behavioral OF sample_gen_tb IS

    CONSTANT SAMPLE_RATE_HZ : INTEGER := 100_000_000;
    CONSTANT CLK_FREQ_HZ : INTEGER := 200_000_000;
    CONSTANT CLK_PERIOD_NS : TIME := 1_000_000_000 ns / CLK_FREQ_HZ; -- Clock period in nanoseconds

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst_n : STD_LOGIC := '0';
    SIGNAL sawtooth_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sample_valid : STD_LOGIC;

    COMPONENT sample_gen
        GENERIC (
            SAMPLE_RATE_HZ : INTEGER := SAMPLE_RATE_HZ; -- Desired output clk frequency
            CLK_FREQ_HZ : INTEGER := CLK_FREQ_HZ-- Input CLK_FREQ_HZ
        );
        PORT (
            rst_n : IN STD_LOGIC;
            clk : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            sawtooth_out : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            sample_valid : OUT STD_LOGIC
        );
    END COMPONENT;
BEGIN

    UUT : sample_gen
    GENERIC MAP(
        SAMPLE_RATE_HZ => 100_000_000, -- Desired output clk frequency
        CLK_FREQ_HZ => 200_000_000 -- Input CLK_FREQ_HZ
    )
    PORT MAP(
        rst_n => rst_n,
        clk => clk,
        enable => '1', -- Always enable for this test
        sawtooth_out => sawtooth_out,
        sample_valid => sample_valid
    );

    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk <= '0';
            WAIT FOR 2.5 ns;
            clk <= '1';
            WAIT FOR 2.5 ns;
        END LOOP;
    END PROCESS;

    reset_process : PROCESS
    BEGIN
        rst_n <= '0';
        WAIT FOR 20 ns;
        rst_n <= '1';
        WAIT FOR 1 ns; -- Wait for some time to observe the output
        ASSERT sawtooth_out = x"00000000" REPORT "Sawtooth output is not zero after reset!" SEVERITY error;
        ASSERT sample_valid = '0' REPORT "Sample valid is not low after reset!" SEVERITY error;
        WAIT;
    END PROCESS;

    sawtooth_check : PROCESS
        VARIABLE expected_value : unsigned(31 DOWNTO 0) := (OTHERS => '0');
        VARIABLE last_time : TIME := 0 ns;
        VARIABLE first_sample : BOOLEAN := true;

    BEGIN
        WHILE true LOOP
            WAIT UNTIL rising_edge (clk);
            IF sample_valid = '1' THEN
                expected_value := expected_value + 1;
                ASSERT sawtooth_out = STD_LOGIC_VECTOR(expected_value) REPORT "Sawtooth output does not match expected value!" SEVERITY error;

                IF first_sample THEN
                    first_sample := false;
                ELSE
                    ASSERT (now - last_time) = (CLK_FREQ_HZ/SAMPLE_RATE_HZ) * CLK_PERIOD_NS REPORT "Time interval between samples is not as expected!" SEVERITY error;
                END IF;
                last_time := now;
            END IF;
        END LOOP;
    END PROCESS;
END Behavioral;