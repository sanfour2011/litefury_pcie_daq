LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG IS
	GENERIC (
		-- Users to add parameters here
		-- Control Register Bits: 
		ENABLE_ACQUISITION_BIT : INTEGER := 0;

		-- Status Register Bits:
		IS_RUNNING_BIT : INTEGER := 0;
		BUFFER_FULL_BIT : INTEGER := 1;
		IRQ_PENDING_BIT : INTEGER := 2;

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH : INTEGER := 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH : INTEGER := 4
	);
	PORT (
		-- Users to add ports here
		enable_acquisition : OUT STD_LOGIC;
		irq_pending : OUT STD_LOGIC;
		is_running : IN STD_LOGIC;
		buffer_full : IN STD_LOGIC;
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK : IN STD_LOGIC;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN : IN STD_LOGIC;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR : IN STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Write channel Protection type. This signal indicates the
		-- privilege and security level of the transaction, and whether
		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Write address valid. This signal indicates that the master signaling
		-- valid write address and control information.
		S_AXI_AWVALID : IN STD_LOGIC;
		-- Write address ready. This signal indicates that the slave is ready
		-- to accept an address and associated control signals.
		S_AXI_AWREADY : OUT STD_LOGIC;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA : IN STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0);
		-- Write strobes. This signal indicates which byte lanes hold
		-- valid data. There is one write strobe bit for each eight
		-- bits of the write data bus.    
		S_AXI_WSTRB : IN STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8) - 1 DOWNTO 0);
		-- Write valid. This signal indicates that valid write
		-- data and strobes are available.
		S_AXI_WVALID : IN STD_LOGIC;
		-- Write ready. This signal indicates that the slave
		-- can accept the write data.
		S_AXI_WREADY : OUT STD_LOGIC;
		-- Write response. This signal indicates the status
		-- of the write transaction.
		S_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Write response valid. This signal indicates that the channel
		-- is signaling a valid write response.
		S_AXI_BVALID : OUT STD_LOGIC;
		-- Response ready. This signal indicates that the master
		-- can accept a write response.
		S_AXI_BREADY : IN STD_LOGIC;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR : IN STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 DOWNTO 0);
		-- Protection type. This signal indicates the privilege
		-- and security level of the transaction, and whether the
		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		-- Read address valid. This signal indicates that the channel
		-- is signaling valid read address and control information.
		S_AXI_ARVALID : IN STD_LOGIC;
		-- Read address ready. This signal indicates that the slave is
		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY : OUT STD_LOGIC;
		-- Read data (issued by slave)
		S_AXI_RDATA : OUT STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0);
		-- Read response. This signal indicates the status of the
		-- read transfer.
		S_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		-- Read valid. This signal indicates that the channel is
		-- signaling the required read data.
		S_AXI_RVALID : OUT STD_LOGIC;
		-- Read ready. This signal indicates that the master can
		-- accept the read data and response information.
		S_AXI_RREADY : IN STD_LOGIC
	);
END axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG;

ARCHITECTURE arch_imp OF axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG IS

	-- AXI4LITE signals
	SIGNAL axi_awaddr : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 DOWNTO 0);
	SIGNAL axi_awready : STD_LOGIC;
	SIGNAL axi_wready : STD_LOGIC;
	SIGNAL axi_bresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL axi_bvalid : STD_LOGIC;
	SIGNAL axi_araddr : STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH - 1 DOWNTO 0);
	SIGNAL axi_arready : STD_LOGIC;
	SIGNAL axi_rresp : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL axi_rvalid : STD_LOGIC;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	CONSTANT ADDR_LSB : INTEGER := (C_S_AXI_DATA_WIDTH/32) + 1;
	CONSTANT OPT_MEM_ADDR_BITS : INTEGER := 1;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 4
	SIGNAL slv_reg0 : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0); --Control register
	SIGNAL slv_reg1 : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0); --Status register
	SIGNAL slv_reg2 : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0); --Reserved
	SIGNAL slv_reg3 : STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH - 1 DOWNTO 0); --Reserved
	SIGNAL byte_index : INTEGER;
	SIGNAL irq_pending_sig : STD_LOGIC;
	SIGNAL mem_logic : STD_LOGIC_VECTOR(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB);

	--State machine local parameters
	CONSTANT Idle : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
	CONSTANT Raddr : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	CONSTANT Rdata : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	CONSTANT Waddr : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";
	CONSTANT Wdata : STD_LOGIC_VECTOR(1 DOWNTO 0) := "11";
	--State machine variables
	SIGNAL state_read : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL state_write : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
	-- I/O Connections assignments

	S_AXI_AWREADY <= axi_awready;
	S_AXI_WREADY <= axi_wready;
	S_AXI_BRESP <= axi_bresp;
	S_AXI_BVALID <= axi_bvalid;
	S_AXI_ARREADY <= axi_arready;
	S_AXI_RRESP <= axi_rresp;
	S_AXI_RVALID <= axi_rvalid;
	mem_logic <= S_AXI_AWADDR(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB) WHEN (S_AXI_AWVALID = '1') ELSE
		axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB);

	-- Implement Write state machine
	-- Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	PROCESS (S_AXI_ACLK)
	BEGIN
		IF rising_edge(S_AXI_ACLK) THEN
			IF S_AXI_ARESETN = '0' THEN
				--asserting initial values to all 0's during reset                                       
				axi_awready <= '0';
				axi_wready <= '0';
				axi_bvalid <= '0';
				axi_bresp <= (OTHERS => '0');
				state_write <= Idle;
			ELSE
				CASE (state_write) IS
					WHEN Idle => --Initial state inidicating reset is done and ready to receive read/write transactions                                       
						IF (S_AXI_ARESETN = '1') THEN
							axi_awready <= '1';
							axi_wready <= '1';
							state_write <= Waddr;
						ELSE
							state_write <= state_write;
						END IF;
					WHEN Waddr => --At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                       
						IF (S_AXI_AWVALID = '1' AND axi_awready = '1') THEN
							axi_awaddr <= S_AXI_AWADDR;
							IF (S_AXI_WVALID = '1') THEN
								axi_awready <= '1';
								state_write <= Waddr;
								axi_bvalid <= '1';
							ELSE
								axi_awready <= '0';
								state_write <= Wdata;
								IF (S_AXI_BREADY = '1' AND axi_bvalid = '1') THEN
									axi_bvalid <= '0';
								END IF;
							END IF;
						ELSE
							state_write <= state_write;
							IF (S_AXI_BREADY = '1' AND axi_bvalid = '1') THEN
								axi_bvalid <= '0';
							END IF;
						END IF;
					WHEN Wdata => --At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
						IF (S_AXI_WVALID = '1') THEN
							state_write <= Waddr;
							axi_bvalid <= '1';
							axi_awready <= '1';
						ELSE
							state_write <= state_write;
							IF (S_AXI_BREADY = '1' AND axi_bvalid = '1') THEN
								axi_bvalid <= '0';
							END IF;
						END IF;
					WHEN OTHERS => --reserved                                       
						axi_awready <= '0';
						axi_wready <= '0';
						axi_bvalid <= '0';
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	PROCESS (S_AXI_ACLK)
		VARIABLE buffer_full_prev : STD_LOGIC := '0';
		VARIABLE irq_pending_cleared : STD_LOGIC := '0';
	BEGIN
		IF rising_edge(S_AXI_ACLK) THEN
			IF S_AXI_ARESETN = '0' THEN
				slv_reg0 <= (OTHERS => '0');
				slv_reg1 <= (OTHERS => '0');
				slv_reg2 <= (OTHERS => '0');
				slv_reg3 <= (OTHERS => '0');
			ELSE
				IF (S_AXI_WVALID = '1') THEN
					CASE (mem_logic) IS
						WHEN b"00" =>
							FOR byte_index IN 0 TO (C_S_AXI_DATA_WIDTH/8 - 1) LOOP
								IF (S_AXI_WSTRB(byte_index) = '1') THEN
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 0
									slv_reg0(byte_index * 8 + 7 DOWNTO byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 DOWNTO byte_index * 8);
								END IF;
							END LOOP;
						WHEN b"01" =>

							--NULL; -- No write operation for status register, it is read-only
							-- for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
							--   if ( S_AXI_WSTRB(byte_index) = '1' ) then
							--     -- Respective byte enables are asserted as per write strobes                   
							--     -- slave registor 1
							--    -- slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
							--   end if;
							-- end loop;

							-- No loop needed! and No read modify operation!
							-- Only the first byte contains the irq_pending bit. 0 -> do nothing, 1 -> clears irq_pending bit
							IF (S_AXI_WDATA(IRQ_PENDING_BIT) = '1' AND slv_reg1(IRQ_PENDING_BIT) = '1') THEN
								irq_pending_cleared := '1';
							END IF;

						WHEN b"10" =>
							FOR byte_index IN 0 TO (C_S_AXI_DATA_WIDTH/8 - 1) LOOP
								IF (S_AXI_WSTRB(byte_index) = '1') THEN
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 2
									slv_reg2(byte_index * 8 + 7 DOWNTO byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 DOWNTO byte_index * 8);
								END IF;
							END LOOP;
						WHEN b"11" =>
							FOR byte_index IN 0 TO (C_S_AXI_DATA_WIDTH/8 - 1) LOOP
								IF (S_AXI_WSTRB(byte_index) = '1') THEN
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 3
									slv_reg3(byte_index * 8 + 7 DOWNTO byte_index * 8) <= S_AXI_WDATA(byte_index * 8 + 7 DOWNTO byte_index * 8);
								END IF;
							END LOOP;
						WHEN OTHERS =>
							slv_reg0 <= slv_reg0;
							-- slv_reg1 <= slv_reg1; -- Card side status register. host readonly!
							slv_reg2 <= slv_reg2;
							slv_reg3 <= slv_reg3;
					END CASE;
				END IF;

				slv_reg1 <= (OTHERS => '0');
				slv_reg1(IS_RUNNING_BIT) <= is_running;
				slv_reg1(BUFFER_FULL_BIT) <= buffer_full;

				IF (irq_pending_cleared = '1' AND irq_pending_sig = '1') THEN
					irq_pending_cleared := '0';
					irq_pending_sig <= '0';
				END IF;

				IF (buffer_full = '1' AND buffer_full_prev = '0') THEN
					irq_pending_sig <= buffer_full;
				END IF;
				buffer_full_prev := buffer_full;

				slv_reg1(IRQ_PENDING_BIT) <= irq_pending_sig;
				irq_pending <= irq_pending_sig;
			END IF;
		END IF;
	END PROCESS;

	-- Implement read state machine
	PROCESS (S_AXI_ACLK)
	BEGIN
		IF rising_edge(S_AXI_ACLK) THEN
			IF S_AXI_ARESETN = '0' THEN
				--asserting initial values to all 0's during reset                                          
				axi_arready <= '0';
				axi_rvalid <= '0';
				axi_rresp <= (OTHERS => '0');
				state_read <= Idle;
			ELSE
				CASE (state_read) IS
					WHEN Idle => --Initial state inidicating reset is done and ready to receive read/write transactions                                          
						IF (S_AXI_ARESETN = '1') THEN
							axi_arready <= '1';
							state_read <= Raddr;
						ELSE
							state_read <= state_read;
						END IF;
					WHEN Raddr => --At this state, slave is ready to receive address along with corresponding control signals                                          
						IF (S_AXI_ARVALID = '1' AND axi_arready = '1') THEN
							state_read <= Rdata;
							axi_rvalid <= '1';
							axi_arready <= '0';
							axi_araddr <= S_AXI_ARADDR;
						ELSE
							state_read <= state_read;
						END IF;
					WHEN Rdata => --At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
						IF (axi_rvalid = '1' AND S_AXI_RREADY = '1') THEN
							axi_rvalid <= '0';
							axi_arready <= '1';
							state_read <= Raddr;
						ELSE
							state_read <= state_read;
						END IF;
					WHEN OTHERS => --reserved                                          
						axi_arready <= '0';
						axi_rvalid <= '0';
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	-- Implement memory mapped register select and read logic generation
	S_AXI_RDATA <= slv_reg0 WHEN (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB) = "00") ELSE
		slv_reg1 WHEN (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB) = "01") ELSE
		slv_reg2 WHEN (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB) = "10") ELSE
		slv_reg3 WHEN (axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS DOWNTO ADDR_LSB) = "11") ELSE
		(OTHERS => '0');

	-- Add user logic here
	enable_acquisition <= slv_reg0(ENABLE_ACQUISITION_BIT);

	-- User logic ends

END arch_imp;