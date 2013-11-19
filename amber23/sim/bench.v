
module testbench;

// Generic Inputs
reg clk;
reg i_irq;              // Interrupt request, active high
reg i_firq;             // Fast Interrupt request, active high
reg i_system_rdy;       // Amber is stalled when this is low

// Wishbone Inputs
reg [31:0] i_wb_dat;
wire       i_wb_ack;
wire       i_wb_err;

// Wishbone Outputs
wire [31:0] o_wb_adr;
wire [ 3:0] o_wb_sel;
wire        o_wb_we;
wire [31:0] o_wb_dat;
wire        o_wb_cyc;
wire        o_wb_stb;

a23_core UUT (
	clk,
	i_irq,
	i_firq,
	i_system_rdy,
	o_wb_adr,
	o_wb_sel,
	o_wb_we,
	i_wb_dat,
	o_wb_dat,
	o_wb_cyc,
	o_wb_stb,
	i_wb_ack,
	i_wb_err
);

initial begin
	clk <= 0;
	#100;
	forever begin
		clk <= ~clk;
		#50;
	end
end

initial begin
	i_irq <= 0;
	i_firq <= 0;
	i_wb_dat <= 0;
	i_system_rdy <= 0;
	repeat (10) @(posedge clk);
	i_system_rdy <= 1;
	repeat (5000) @(posedge clk);
	$display("Reached limit of 5000 cpu cycles.");
	$finish;
end

integer output_idx;
reg [7:0] output_buf [1023:0];
event output_eof;

localparam mem_size = 16*1024; // = 64kB
reg [31:0] mem [0:mem_size-1];
reg [31:0] tmp;
integer i;

initial begin
	output_idx = 0;
	for (i=0; i<mem_size; i=i+1)
		mem[i] = 0;
`include "sieve.v"
end

reg wb_start_read_d1;
wire wb_start_write = o_wb_stb &&  o_wb_we && !wb_start_read_d1;
wire wb_start_read  = o_wb_stb && !o_wb_we && !i_wb_ack;
assign i_wb_ack = o_wb_stb && ( wb_start_write || wb_start_read_d1 );
assign i_wb_err = 0;

always @(posedge clk)
	wb_start_read_d1 <= wb_start_read;

always @(posedge clk) begin
	if (wb_start_write || wb_start_read) begin
		if (o_wb_adr < mem_size*4) begin
			tmp = mem[o_wb_adr >> 2];
			if (wb_start_write) begin
				if (o_wb_sel[0]) tmp = { tmp[31:24], tmp[23:16], tmp[15:8], o_wb_dat[7:0] };
				if (o_wb_sel[1]) tmp = { tmp[31:24], tmp[23:16], o_wb_dat[15:8], tmp[7:0] };
				if (o_wb_sel[2]) tmp = { tmp[31:24], o_wb_dat[23:16], tmp[15:8], tmp[7:0] };
				if (o_wb_sel[3]) tmp = { o_wb_dat[31:24], tmp[23:16], tmp[15:8], tmp[7:0] };
				mem[o_wb_adr >> 2] <= tmp;
			end
			if (wb_start_read)
				i_wb_dat <= tmp;
			$display("%t MEM %s ADDR %08x: %08x (%b)", $time, o_wb_we ? "WRITE" : "READ ", o_wb_adr, tmp, o_wb_sel);
		end
		if (wb_start_write && o_wb_adr == 32'h10000000) begin
			$display("%t OUTPUT %d", $time, o_wb_dat);
			if (o_wb_dat == 0) begin
				-> output_eof;
			end else begin
				output_buf[output_idx] = o_wb_dat;
				output_idx = output_idx + 1;
			end
		end
	end
end

always @(output_eof) begin
	#1001;
	$display("Got EOF marker on IO port.");
	for (i = 0; i < output_idx; i = i + 1) begin
		$display("+OUT+ %d", output_buf[i]);
	end
	$finish;
end

initial begin
	// $dumpfile("bench.vcd");
	// $dumpvars(0, testbench);
end

endmodule
