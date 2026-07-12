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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY acquisition_ctrl IS
    GENERIC (
        buffer_size : INTEGER := 1024; -- Size of the buffer in samples
        sample_rate_hz : INTEGER := 100_000_000; -- Rate at which new sawtooth samples are generated
        clk_freq_hz : INTEGER := 200_000_000 -- Input CLK_FREQ_HZ
    );
    PORT (
        clk : IN STD_LOGIC;
        rst_n : IN STD_LOGIC;
        acq_en : IN STD_LOGIC; -- Acquisition enable signal, to start/stop generating samples
        is_running : OUT STD_LOGIC;
        buffer_full : OUT STD_LOGIC;
        sample_ready : OUT STD_LOGIC; -- Signal indicating that a new sample is ready
        sample_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sample_idx : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END acquisition_ctrl;

ARCHITECTURE Behavioral OF acquisition_ctrl IS
    SIGNAL sample_idx_sig : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL buffer_full_sig : STD_LOGIC := '0';
    SIGNAL sample_valid_sig : STD_LOGIC := '0';
    COMPONENT sample_gen
        GENERIC (
            SAMPLE_RATE_HZ : INTEGER := 100_000_000; -- Rate at which new sawtooth samples are generated
            CLK_FREQ_HZ : INTEGER := 200_000_000-- Input CLK_FREQ_HZ
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
    sample_gen_inst : sample_gen
    GENERIC MAP(
        SAMPLE_RATE_HZ => sample_rate_hz,
        CLK_FREQ_HZ => clk_freq_hz -- Input CLK_FREQ_HZ
    )
    PORT MAP(
        rst_n => rst_n,
        clk => clk,
        enable => acq_en,
        sawtooth_out => sample_out,
        sample_valid => sample_valid_sig
    );

    PROCESS (clk, rst_n)
    BEGIN
        IF rst_n = '0' THEN
            is_running <= '0';
            sample_idx_sig <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF acq_en = '1' AND buffer_full_sig = '0' THEN
                is_running <= '1';
                IF sample_valid_sig = '1' THEN
                    sample_idx_sig <= STD_LOGIC_VECTOR(unsigned(sample_idx_sig) + 1);
                END IF;
                IF unsigned(sample_idx_sig) >= buffer_size THEN
                    buffer_full_sig <= '1';
                ELSE
                    buffer_full_sig <= '0';
                END IF;
            ELSE
                is_running <= '0';
            END IF;
        END IF;
    END PROCESS;

    sample_ready <= sample_valid_sig;
    buffer_full <= buffer_full_sig;
    sample_idx <= sample_idx_sig;

END Behavioral;