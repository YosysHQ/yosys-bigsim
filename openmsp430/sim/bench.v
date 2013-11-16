
`timescale 1ns/1ps

// for memory layout
`include "../rtl/openMSP430_defines.v"

module testbench;

// UUT OUTPUTs
//============
wire               aclk;              // ASIC ONLY: ACLK
wire               aclk_en;           // FPGA ONLY: ACLK enable
wire               dbg_freeze;        // Freeze peripherals
wire               dbg_i2c_sda_out;   // Debug interface: I2C SDA OUT
wire               dbg_uart_txd;      // Debug interface: UART TXD
wire               dco_enable;        // ASIC ONLY: Fast oscillator enable
wire               dco_wkup;          // ASIC ONLY: Fast oscillator wake-up (asynchronous)
wire [`DMEM_MSB:0] dmem_addr;         // Data Memory address
wire               dmem_cen;          // Data Memory chip enable (low active)
wire        [15:0] dmem_din;          // Data Memory data input
wire         [1:0] dmem_wen;          // Data Memory write enable (low active)
wire        [13:0] irq_acc;           // Interrupt request accepted (one-hot signal)
wire               lfxt_enable;       // ASIC ONLY: Low frequency oscillator enable
wire               lfxt_wkup;         // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
wire               mclk;              // Main system clock
wire        [13:0] per_addr;          // Peripheral address
wire        [15:0] per_din;           // Peripheral data input
wire         [1:0] per_we;            // Peripheral write enable (high active)
wire               per_en;            // Peripheral enable (high active)
wire [`PMEM_MSB:0] pmem_addr;         // Program Memory address
wire               pmem_cen;          // Program Memory chip enable (low active)
wire        [15:0] pmem_din;          // Program Memory data input (optional)
wire         [1:0] pmem_wen;          // Program Memory write enable (low active) (optional)
wire               puc_rst;           // Main system reset
wire               smclk;             // ASIC ONLY: SMCLK
wire               smclk_en;          // FPGA ONLY: SMCLK enable


// UUT INPUTs
//===========
wire                cpu_en;            // Enable CPU code execution (asynchronous and non-glitchy)
wire                dbg_en;            // Debug interface enable (asynchronous and non-glitchy)
wire          [6:0] dbg_i2c_addr;      // Debug interface: I2C Address
wire          [6:0] dbg_i2c_broadcast; // Debug interface: I2C Broadcast Address (for multicore systems)
wire                dbg_i2c_scl;       // Debug interface: I2C SCL
wire                dbg_i2c_sda_in;    // Debug interface: I2C SDA IN
wire                dbg_uart_rxd;      // Debug interface: UART RXD (asynchronous)
wire                dco_clk;           // Fast oscillator (fast clock)
reg          [15:0] dmem_dout;         // Data Memory data output
wire  	     [13:0] irq;               // Maskable interrupts
wire                lfxt_clk;          // Low frequency oscillator (typ 32kHz)
wire  	            nmi;               // Non-maskable interrupt (asynchronous and non-glitchy)
reg          [15:0] per_dout;          // Peripheral data output
reg          [15:0] pmem_dout;         // Program Memory data output
wire                reset_n;           // Reset Pin (active low, asynchronous and non-glitchy)
wire                scan_enable;       // ASIC ONLY: Scan enable (active during scan shifting)
wire                scan_mode;         // ASIC ONLY: Scan mode
wire                wkup;              // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)

openMSP430 UUT (

// OUTPUTs
    aclk,                               // ASIC ONLY: ACLK
    aclk_en,                            // FPGA ONLY: ACLK enable
    dbg_freeze,                         // Freeze peripherals
    dbg_i2c_sda_out,                    // Debug interface: I2C SDA OUT
    dbg_uart_txd,                       // Debug interface: UART TXD
    dco_enable,                         // ASIC ONLY: Fast oscillator enable
    dco_wkup,                           // ASIC ONLY: Fast oscillator wake-up (asynchronous)
    dmem_addr,                          // Data Memory address
    dmem_cen,                           // Data Memory chip enable (low active)
    dmem_din,                           // Data Memory data input
    dmem_wen,                           // Data Memory write enable (low active)
    irq_acc,                            // Interrupt request accepted (one-hot signal)
    lfxt_enable,                        // ASIC ONLY: Low frequency oscillator enable
    lfxt_wkup,                          // ASIC ONLY: Low frequency oscillator wake-up (asynchronous)
    mclk,                               // Main system clock
    per_addr,                           // Peripheral address
    per_din,                            // Peripheral data input
    per_we,                             // Peripheral write enable (high active)
    per_en,                             // Peripheral enable (high active)
    pmem_addr,                          // Program Memory address
    pmem_cen,                           // Program Memory chip enable (low active)
    pmem_din,                           // Program Memory data input (optional)
    pmem_wen,                           // Program Memory write enable (low active) (optional)
    puc_rst,                            // Main system reset
    smclk,                              // ASIC ONLY: SMCLK
    smclk_en,                           // FPGA ONLY: SMCLK enable

// INPUTs
    cpu_en,                             // Enable CPU code execution (asynchronous and non-glitchy)
    dbg_en,                             // Debug interface enable (asynchronous and non-glitchy)
    dbg_i2c_addr,                       // Debug interface: I2C Address
    dbg_i2c_broadcast,                  // Debug interface: I2C Broadcast Address (for multicore systems)
    dbg_i2c_scl,                        // Debug interface: I2C SCL
    dbg_i2c_sda_in,                     // Debug interface: I2C SDA IN
    dbg_uart_rxd,                       // Debug interface: UART RXD (asynchronous)
    dco_clk,                            // Fast oscillator (fast clock)
    dmem_dout,                          // Data Memory data output
    irq,                                // Maskable interrupts
    lfxt_clk,                           // Low frequency oscillator (typ 32kHz)
    nmi,                                // Non-maskable interrupt (asynchronous)
    per_dout,                           // Peripheral data output
    pmem_dout,                          // Program Memory data output
    reset_n,                            // Reset Pin (low active, asynchronous and non-glitchy)
    scan_enable,                        // ASIC ONLY: Scan enable (active during scan shifting)
    scan_mode,                          // ASIC ONLY: Scan mode
    wkup                                // ASIC ONLY: System Wake-up (asynchronous and non-glitchy)
);

// -----------------------------------------------------------------------------------

assign cpu_en = 1, dbg_en = 0;

reg clk, rst;
integer cycles;
initial begin
	clk <= 0;
	rst <= 0;
	cycles = 0;
	while (cycles < 64) begin
		#50; clk <= ~clk;
		#50; clk <= ~clk;
		cycles = cycles + 1;
	end
	rst <= 1;
	forever begin
		#50; clk <= ~clk;
		#50; clk <= ~clk;
		cycles = cycles + 1;
		if (cycles == 512)
			$finish;
	end
end

assign dco_clk = clk;
assign lfxt_clk = 0;
assign irq = 0, nmi = 0;
assign reset_n = rst;
assign scan_enable = 0;
assign scan_mode = 0;
assign wkup = 0;

assign dbg_i2c_addr = 45;
assign dbg_i2c_broadcast = 67;
assign dbg_i2c_scl = 0;
assign dbg_i2c_sda_in = 0;
assign dbg_uart_rxd = 0;

// -----------------------------------------------------------------------------------

reg [15:8] dmem_hi [`DMEM_SIZE-1:0];
reg [ 7:0] dmem_lo [`DMEM_SIZE-1:0];
reg [15:0] pmem    [`PMEM_SIZE-1:0];

integer i;
initial begin
	for (i = 0; i < `DMEM_SIZE; i=i+1) begin
		dmem_hi[i] = 0;
		dmem_lo[i] = 0;
	end
	`include "demo.v"
end

always @(posedge mclk) begin
	dmem_dout <= 'bx;
	pmem_dout <= 'bx;

	if (~dmem_cen) begin
		$display("%t %d -- DR  @%04x %x%x", $time, cycles, dmem_addr, dmem_hi[dmem_addr], dmem_lo[dmem_addr]);
		dmem_dout[15:8] <= dmem_hi[dmem_addr];
		dmem_dout[ 7:0] <= dmem_lo[dmem_addr];
	end

	if (~pmem_cen) begin
		$display("%t %d -- PR  @%04x %x", $time, cycles, pmem_addr, pmem[pmem_addr]);
		pmem_dout <= pmem[pmem_addr];
	end

	if (~dmem_cen && ~dmem_wen)
		$display("%t %d -- DW  @%04x %x%x", $time, cycles, pmem_addr, ~dmem_wen[1] ? dmem_din[15:8] : 8'hzz, ~dmem_wen[0] ? dmem_din[ 7:0] : 8'hzz);
	if (~dmem_cen && ~dmem_wen[1])
		dmem_hi[dmem_addr] <= dmem_din[15:8];
	if (~dmem_cen && ~dmem_wen[0])
		dmem_lo[dmem_addr] <= dmem_din[ 7:0];
end

always @(posedge mclk) begin
	per_dout <= 'bx;
	if (per_en && per_we)
		$display("%t %d -- PER @%04x %x%x  <---", $time, cycles, per_addr, per_we[1] ? per_din[15:8] : 8'hzz, per_we[0] ? per_din[ 7:0] : 8'hzz);
end

initial begin
	// $dumpfile("bench.vcd");
	// $dumpvars(0, UUT);
end

endmodule
