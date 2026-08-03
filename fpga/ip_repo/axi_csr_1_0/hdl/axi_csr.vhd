library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity axi_csr is
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
end axi_csr;

architecture arch_imp of axi_csr is

	-- component declaration
	component axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG is
	generic (
		C_S_AXI_DATA_WIDTH : integer := 32;
		C_S_AXI_ADDR_WIDTH : integer := 4
	);
	port (

		enable_acquisition : out std_logic;
		irq_pending        : out std_logic;
		is_running         : in  std_logic;
		buffer_full        : in  std_logic;

		S_AXI_ACLK    : in  std_logic;
		S_AXI_ARESETN : in  std_logic;
		S_AXI_AWADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		S_AXI_AWPROT  : in  std_logic_vector(2 downto 0);
		S_AXI_AWVALID : in  std_logic;
		S_AXI_AWREADY : out std_logic;
		S_AXI_WDATA   : in  std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		S_AXI_WSTRB   : in  std_logic_vector((C_S_AXI_DATA_WIDTH/8) - 1 downto 0);
		S_AXI_WVALID  : in  std_logic;
		S_AXI_WREADY  : out std_logic;
		S_AXI_BRESP   : out std_logic_vector(1 downto 0);
		S_AXI_BVALID  : out std_logic;
		S_AXI_BREADY  : in  std_logic;
		S_AXI_ARADDR  : in  std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
		S_AXI_ARPROT  : in  std_logic_vector(2 downto 0);
		S_AXI_ARVALID : in  std_logic;
		S_AXI_ARREADY : out std_logic;
		S_AXI_RDATA   : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
		S_AXI_RRESP   : out std_logic_vector(1 downto 0);
		S_AXI_RVALID  : out std_logic;
		S_AXI_RREADY  : in  std_logic
	);
end component axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG;

begin

-- Instantiation of Axi Bus Interface CONTROL_STATUS_REG
axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG_inst : axi_csr_slave_lite_v1_0_CONTROL_STATUS_REG
generic map (
	C_S_AXI_DATA_WIDTH => C_CONTROL_STATUS_REG_DATA_WIDTH,
	C_S_AXI_ADDR_WIDTH => C_CONTROL_STATUS_REG_ADDR_WIDTH
)
port map (

	enable_acquisition => enable_acquisition,
	irq_pending        => irq_pending,
	is_running         => is_running,
	buffer_full        => buffer_full,

	S_AXI_ACLK    => control_status_reg_aclk,
	S_AXI_ARESETN => control_status_reg_aresetn,
	S_AXI_AWADDR  => control_status_reg_awaddr,
	S_AXI_AWPROT  => control_status_reg_awprot,
	S_AXI_AWVALID => control_status_reg_awvalid,
	S_AXI_AWREADY => control_status_reg_awready,
	S_AXI_WDATA   => control_status_reg_wdata,
	S_AXI_WSTRB   => control_status_reg_wstrb,
	S_AXI_WVALID  => control_status_reg_wvalid,
	S_AXI_WREADY  => control_status_reg_wready,
	S_AXI_BRESP   => control_status_reg_bresp,
	S_AXI_BVALID  => control_status_reg_bvalid,
	S_AXI_BREADY  => control_status_reg_bready,
	S_AXI_ARADDR  => control_status_reg_araddr,
	S_AXI_ARPROT  => control_status_reg_arprot,
	S_AXI_ARVALID => control_status_reg_arvalid,
	S_AXI_ARREADY => control_status_reg_arready,
	S_AXI_RDATA   => control_status_reg_rdata,
	S_AXI_RRESP   => control_status_reg_rresp,
	S_AXI_RVALID  => control_status_reg_rvalid,
	S_AXI_RREADY  => control_status_reg_rready
);

-- Add user logic here

-- User logic ends

end arch_imp;
