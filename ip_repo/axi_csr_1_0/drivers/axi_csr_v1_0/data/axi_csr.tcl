

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "axi_csr" "NUM_INSTANCES" "DEVICE_ID"  "C_CONTROL_STATUS_REG_BASEADDR" "C_CONTROL_STATUS_REG_HIGHADDR"
}
