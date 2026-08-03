----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 19.07.2026 13:43:03
-- Design Name:
-- Module Name: CSR_tb - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CSR_tb is
	--  Port ( );
end CSR_tb;

architecture Behavioral of CSR_tb is
	constant    C_CONTROL_STATUS_REG_DATA_WIDTH : integer := 32;
	constant 	C_CONTROL_STATUS_REG_ADDR_WIDTH   : integer := 4;
	constant 	IS_RUNNING_BIT                    : integer := 0;
	constant	BUFFER_FULL_BIT                    : integer := 1;
	constant	IRQ_PENDING_BIT                    : integer := 2;

	signal clk_sig                        : std_logic  ;
	signal reset_sig                      : std_logic ;
	signal enable_acquisition_sig         : std_logic := '0';
	signal irq_pending_sig                : std_logic := '0';
	signal is_running_sig                 : std_logic := '0';
	signal buffer_full_sig                : std_logic := '0';
	signal control_status_reg_awvalid_sig : std_logic := '0';
	signal control_status_reg_awaddr_sig  : std_logic_vector(C_CONTROL_STATUS_REG_ADDR_WIDTH - 1 downto 0);
	signal control_status_reg_awready_sig : std_logic := '0';
	signal control_status_reg_wdata_sig   : std_logic_vector(C_CONTROL_STATUS_REG_DATA_WIDTH - 1 downto 0);
	signal control_status_reg_wvalid_sig  : std_logic := '0';
	signal control_status_reg_wready_sig  : std_logic := '0';
	signal control_status_reg_bresp_sig   : std_logic_vector (1 downto 0);
	signal control_status_reg_bvalid_sig  : std_logic := '0';
	component axi_csr is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line
		-- Parameters of Axi Slave Bus Interface CONTROL_STATUS_REG
		C_CONTROL_STATUS_REG_DATA_WIDTH : integer := 32;
		C_CONTROL_STATUS_REG_ADDR_WIDTH : integer := 4
	);
	port (
		-- Users to add ports here
		enable_acquisition : out std_logic;
		irq_pending        : out std_logic;
		is_running         : in  std_logic;
		buffer_full        : in  std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line
		-- Ports of Axi Slave Bus Interface CONTROL_STATUS_REG
		control_status_reg_aclk    : in  std_logic;
		control_status_reg_aresetn : in  std_logic;
		control_status_reg_awaddr  : in  std_logic_vector(C_CONTROL_STATUS_REG_ADDR_WIDTH - 1 downto 0);
		control_status_reg_awprot  : in  std_logic_vector(2 downto 0);
		control_status_reg_awvalid : in  std_logic;
		control_status_reg_awready : out std_logic;
		control_status_reg_wdata   : in  std_logic_vector(C_CONTROL_STATUS_REG_DATA_WIDTH - 1 downto 0);
		control_status_reg_wstrb   : in  std_logic_vector((C_CONTROL_STATUS_REG_DATA_WIDTH/8) - 1 downto 0);
		control_status_reg_wvalid  : in  std_logic;
		control_status_reg_wready  : out std_logic;
		control_status_reg_bresp   : out std_logic_vector(1 downto 0);
		control_status_reg_bvalid  : out std_logic;
		control_status_reg_bready  : in  std_logic;
		control_status_reg_araddr  : in  std_logic_vector(C_CONTROL_STATUS_REG_ADDR_WIDTH - 1 downto 0);
		control_status_reg_arprot  : in  std_logic_vector(2 downto 0);
		control_status_reg_arvalid : in  std_logic;
		control_status_reg_arready : out std_logic;
		control_status_reg_rdata   : out std_logic_vector(C_CONTROL_STATUS_REG_DATA_WIDTH - 1 downto 0);
		control_status_reg_rresp   : out std_logic_vector(1 downto 0);
		control_status_reg_rvalid  : out std_logic;
		control_status_reg_rready  : in  std_logic
	);
end component;

procedure axi_write (
	data : std_logic_vector(C_CONTROL_STATUS_REG_DATA_WIDTH - 1 downto 0);
	addr : std_logic_vector(C_CONTROL_STATUS_REG_ADDR_WIDTH - 1 downto 0);
	signal awddr   : out std_logic_vector(C_CONTROL_STATUS_REG_ADDR_WIDTH - 1 downto 0);
	signal awvalid : out std_logic;
	signal wdata   : out std_logic_vector(C_CONTROL_STATUS_REG_DATA_WIDTH - 1 downto 0);
	signal wvalid  : out std_logic

) is
begin
	-- AMBA AXI and ACE Protocol Specification: "Document number ARM IHI 0022"
	-- (https://developer.arm.com/documentation/ihi0022/e)

	-- Write destination address
	awddr <= addr;
	awvalid <= '1';
	wait until rising_edge(clk_sig) and control_status_reg_awready_sig = '1';
	wait for 1 ns;
	awvalid <= '0';
	awddr <= (others => '0');
	-- Write data
	wdata <= data;
	wvalid <= '1';
	wait until rising_edge(clk_sig) and control_status_reg_wready_sig = '1';
	wait for 1 ns;
	wvalid <= '0';

	-- Read response
	wait until rising_edge(clk_sig) and control_status_reg_bvalid_sig = '1';
	assert control_status_reg_bresp_sig = "00" report "error bresp != 00" severity error;
end procedure axi_write;

begin

UUT : axi_csr
generic map (
	C_CONTROL_STATUS_REG_DATA_WIDTH => C_CONTROL_STATUS_REG_DATA_WIDTH,
	C_CONTROL_STATUS_REG_ADDR_WIDTH => C_CONTROL_STATUS_REG_ADDR_WIDTH
)
port map (
	-- Users to add ports here
	enable_acquisition => enable_acquisition_sig,
	irq_pending        => irq_pending_sig,
	is_running         => is_running_sig,
	buffer_full        => buffer_full_sig,

	-- AMBA AXI and ACE Protocol Specification: "Document number ARM IHI 0022"
	-- (https://developer.arm.com/documentation/ihi0022/e)

	control_status_reg_aclk    => clk_sig,
	control_status_reg_aresetn => reset_sig,
	control_status_reg_awprot  => "000",
	-- Destination Address:
	control_status_reg_awaddr  => control_status_reg_awaddr_sig,
	control_status_reg_awvalid => control_status_reg_awvalid_sig,
	control_status_reg_awready => control_status_reg_awready_sig,
	-- Data:
	control_status_reg_wdata  => control_status_reg_wdata_sig,
	control_status_reg_wvalid => control_status_reg_wvalid_sig,
	control_status_reg_wready => control_status_reg_wready_sig,
	control_status_reg_wstrb  => "1111",                         -- to write all 4 bytes otherwise no write is performed
	-- Responce:
	control_status_reg_bresp  => control_status_reg_bresp_sig,
	control_status_reg_bvalid => control_status_reg_bvalid_sig,
	-- all read operation no need to test:
	control_status_reg_bready  => '1',
	control_status_reg_araddr  => (others => '0'),
	control_status_reg_arprot  => "000",
	control_status_reg_arvalid => '1',
	control_status_reg_arready => open,
	control_status_reg_rdata   => open,
	control_status_reg_rresp   => open,
	control_status_reg_rvalid  => open,
	control_status_reg_rready  => '1'
);

clk_process : process
begin
	while true loop
		clk_sig <= '0';
		wait for 2 ns;
		clk_sig <= '1';
		wait for 2 ns;
	end loop;
	end process clk_process;

	reset_process : process
	begin
		reset_sig <= '0';
		wait for 5 ns;
		reset_sig <= '1';
		wait for 1 ns;
		assert irq_pending_sig = '0' report "irq_pending_sig must be '0' after reset" severity error;
		wait;
	end process reset_process;

	test_irq_pending_w1c : process
	begin
		wait until rising_edge(clk_sig);
		is_running_sig <= '1';
		buffer_full_sig <= '1';
		wait until rising_edge(clk_sig);
		wait for 1 ns;
		assert irq_pending_sig = '1' report "Error buffer_full, but irq_pending_sig not set!" severity error;
		wait until rising_edge(clk_sig);
		buffer_full_sig <= '0';
		wait until rising_edge(clk_sig);
		assert irq_pending_sig = '1' report "Error buffer_full set to 0, irq_pending_sig should be 1 until W1C!" severity error;
		wait until rising_edge(clk_sig);
		buffer_full_sig <= '1';
		wait for 1 ns;
		assert irq_pending_sig = '1' report "Toggeling buffer_full_sig 1->0 and then 0->1 should not afffect irq_pending_sig" severity error;
		wait until rising_edge(clk_sig);
		--irq_pending_sig <= '0';
		wait for 1 ns;
		assert irq_pending_sig = '1' report "irq_pending_sig should be only cleared by reset or by host through W1C" severity error;
		wait until rising_edge(clk_sig);
		-- "01"&"00" address for slv_reg1, ignoring tow LSBs that for adressing the bytes in a 32 bit vector
		axi_write((IRQ_PENDING_BIT => '1', others => '0'), "01"&"00", control_status_reg_awaddr_sig, control_status_reg_awvalid_sig, control_status_reg_wdata_sig, control_status_reg_wvalid_sig);
		wait for 2 ns;
		assert irq_pending_sig = '0' report "irq_pending should be cleared!" severity error;
		buffer_full_sig <= '0';
		wait until rising_edge(clk_sig);
		buffer_full_sig <= '1';
		wait until rising_edge(clk_sig);
		wait for 1 ns;
		assert irq_pending_sig = '1' report "Resetting irq_pending_sig after clearing failed" severity error;
		
		wait;
	end process test_irq_pending_w1c;

end Behavioral;
