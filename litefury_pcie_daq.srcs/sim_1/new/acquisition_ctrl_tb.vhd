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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY acquisition_ctrl_tb IS
    --  Port ( );
END acquisition_ctrl_tb;

ARCHITECTURE Behavioral OF acquisition_ctrl_tb IS

    CONSTANT BRAM_size : INTEGER := 1024 * 8; -- Size of the buffer in samples
    CONSTANT sample_rate_hz : INTEGER := 100_000_000; -- Rate at which new sawtooth samples are generated
    CONSTANT clk_freq_hz : INTEGER := 200_000_000; -- Input CLK_FREQ_HZ

    TYPE BRAM_type IS ARRAY (0 TO BRAM_size - 1) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    COMPONENT acquisition_ctrl
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
    END COMPONENT;

    SIGNAL clk_sig : STD_LOGIC := '0';
    SIGNAL rst_n_sig : STD_LOGIC := '0';
    SIGNAL acq_en_sig : STD_LOGIC := '0';
    SIGNAL is_running_sig : STD_LOGIC;
    SIGNAL buffer_full_sig : STD_LOGIC;
    SIGNAL sample_ready_sig : STD_LOGIC;
    SIGNAL sample_out_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sample_idx_sig : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL next_test_nr : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- Test number for the testbench: 0 = reset, 1 = enable acquisition, 2 = check sample index and output
    SIGNAL reset_test_done : STD_LOGIC := '0'; -- Flag to indicate that the reset test is done
    SIGNAL enable_acquisition_test_done : STD_LOGIC := '0'; -- Flag to indicate that the enable acquisition test is done
    SIGNAL BRAM_sim_sig : BRAM_type := (OTHERS => (OTHERS => '0')); -- Simulated BRAM for storing samples
BEGIN
    UUT : acquisition_ctrl
    GENERIC MAP(
        buffer_size => BRAM_size, -- Size of the buffer in samples
        sample_rate_hz => sample_rate_hz, -- Rate at which new sawtooth samples are generated
        clk_freq_hz => clk_freq_hz -- Input CLK_FREQ_HZ
    )
    PORT MAP(
        clk => clk_sig,
        rst_n => rst_n_sig,
        acq_en => acq_en_sig,
        is_running => is_running_sig,
        buffer_full => buffer_full_sig,
        sample_ready => sample_ready_sig,
        sample_out => sample_out_sig,
        sample_idx => sample_idx_sig
    );
    clk_process : PROCESS
    BEGIN
        WHILE true LOOP
            clk_sig <= '1';
            WAIT FOR 2.5 ns;
            clk_sig <= '0';
            WAIT FOR 2.5 ns;
        END LOOP;
    END PROCESS;

    reset_process : PROCESS
    BEGIN
        rst_n_sig <= '0';
        WAIT FOR 10 ns;
        reset_test_done <= '0'; -- Reset the flag for the reset test
        ASSERT is_running_sig = '0' REPORT "is_running_sig should be low after reset!" SEVERITY error;
        ASSERT buffer_full_sig = '0' REPORT "buffer_full_sig should be low after reset!" SEVERITY error;
        ASSERT sample_ready_sig = '0' REPORT "sample_ready_sig should be low after reset!" SEVERITY error;
        ASSERT sample_out_sig = (sample_out_sig'RANGE => '0') REPORT "sample_out_sig should be zero after reset!" SEVERITY error;
        ASSERT sample_idx_sig = (sample_idx_sig'RANGE => '0') REPORT "sample_idx_sig should be zero after reset!" SEVERITY error;
        rst_n_sig <= '1';
        reset_test_done <= '1'; -- Mark the reset test as done
        WAIT; --wait forever
    END PROCESS;

    Enable_acquisition : PROCESS
    BEGIN
        WAIT UNTIL next_test_nr = "01";
        --
        WAIT UNTIL rising_edge(clk_sig);

        ASSERT is_running_sig = '0' REPORT "1- is_running_sig should be low before enabling acquisition!" SEVERITY error;
        WAIT UNTIL rising_edge(clk_sig);
        acq_en_sig <= '1';
        WAIT UNTIL rising_edge(clk_sig);
        WAIT FOR 1 ns; -- Wait for some time to observe the output
        ASSERT is_running_sig = '1' REPORT "2- is_running_sig should be high when acquisition is enabled!" SEVERITY error;
        WAIT FOR 100 ns; -- Wait for some time to observe the output
        WAIT UNTIL rising_edge(clk_sig);
        acq_en_sig <= '0';
        WAIT UNTIL rising_edge(clk_sig);
        WAIT FOR 1 ns; -- Wait for some time to observe the output
        ASSERT is_running_sig = '0' REPORT "3- is_running_sig should be low after disabling acquisition!" SEVERITY error;
        acq_en_sig <= '1';
        WAIT UNTIL rising_edge(clk_sig);

        enable_acquisition_test_done <= '1'; -- Mark the enable acquisition test as done
        WAIT; --wait forever
    END PROCESS;

    aquisition_ctrl_check : PROCESS
        VARIABLE previous_sample_idx : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
        VARIABLE previous_sample_out : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        WAIT UNTIL next_test_nr = "11";
        -- Since sample_gen keeps running from the previous test, initialize
        -- the variables here so this check is independent of prior test timing
        previous_sample_idx := sample_idx_sig;
        previous_sample_out := sample_out_sig;
        WHILE true LOOP
            WAIT UNTIL rising_edge(clk_sig);
            -- acq_en_sig ist set to 1 in previous test "Enable_acquisition"
            IF buffer_full_sig = '0' THEN
                ASSERT is_running_sig = '1' REPORT "4- is_running_sig should be high when acquisition is enabled!" SEVERITY error;
                IF sample_ready_sig = '1' THEN
                    WAIT FOR 1 ns; -- Wait for some time to observe the output
                    ASSERT sample_idx_sig = STD_LOGIC_VECTOR(unsigned(previous_sample_idx) + 1) REPORT "sample_idx_sig should increment by 1 when sample_ready_sig is high!" SEVERITY error;
                    ASSERT sample_out_sig = STD_LOGIC_VECTOR(unsigned(previous_sample_out) + 1) REPORT "sample_out_sig should increment by 1 when sample_ready_sig is high!" SEVERITY error;

                    previous_sample_idx := sample_idx_sig;
                    previous_sample_out := sample_out_sig;
                END IF;
            END IF;
        END LOOP;

    END PROCESS;

    populate_BRAM : PROCESS
        VARIABLE sample_count : INTEGER := 0;
    BEGIN
        WAIT UNTIL next_test_nr = "11";
        WHILE sample_count < BRAM_size LOOP
            WAIT UNTIL rising_edge(clk_sig);
            IF sample_ready_sig = '1' AND buffer_full_sig = '0' THEN
                BRAM_sim_sig(sample_count) <= sample_out_sig;
                sample_count := sample_count + 1;
            END IF;
        END LOOP;
        WAIT UNTIL rising_edge(clk_sig);
        ASSERT buffer_full_sig = '1' REPORT "buffer_full_sig should be high when the buffer is full!" SEVERITY error;
        WAIT UNTIL rising_edge(clk_sig);
        ASSERT sample_idx_sig = STD_LOGIC_VECTOR(to_unsigned(BRAM_size, 32)) REPORT "sample_idx_sig should be equal to buffer size when the buffer is full!" SEVERITY error;
        WAIT UNTIL rising_edge(clk_sig);
        ASSERT sample_ready_sig = '0' REPORT "sample_ready_sig should be low when the buffer is full!" SEVERITY error;
        WAIT UNTIL rising_edge(clk_sig);
        ASSERT is_running_sig = '0' REPORT "5- is_running_sig should be low when the buffer is full!" SEVERITY error;
    END PROCESS;
    next_test_nr <= (enable_acquisition_test_done, reset_test_done);
END Behavioral;