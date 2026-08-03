# Scripts

Tcl helper scripts for the Vivado project.

## parse_log.tcl

Scans a behavioral simulation log and prints every line containing error or assert, plus a final count - saves scrolling through the full Vivado sim log by hand.

### Usage

From the Tcl console in Vivado

```tcl
source Scriptsparse_log.tcl
```

Expects the log at `project_dirlitefury_pcie_daq.simsim_1behavxsimsimulate.log` (the default location for a behavioral simulation run). Adjust the `log_file` path in the script if yours differs. Run the simulation first - the script just warns and exits if the log doesn't exist yet.

Based on the log format described in [UG900](httpswww.xilinx.comsupportdocumentssw_manualsxilinx2022_1ug900-vivado-logic-simulation.pdf).
