//`include "Arbiter_Payman2.v"

`timescale 1ns/100ps

module tb;

reg   clk;
reg   reset;
reg   A_tvalid;
reg   A_tlast;
reg   [7:0] A_tdata;
reg   B_tvalid;
reg   B_tlast;
reg   [7:0] B_tdata;
reg   K_tready;
wire  A_tready;
wire  B_tready;
wire  K_tvalid;
wire  K_tlast;
wire  [7:0] K_tdata;


always	#1 clk = ~clk;



initial
begin
   $dumpfile ("arbiter.vcd");
   $dumpvars ();
	clk = 0;
	reset = 0;
	A_tvalid = 0;
	A_tlast = 0;
    A_tdata = 8'b01010101;
    B_tvalid = 0;
    B_tlast = 0;
    B_tdata = 8'b00001111;
    K_tready = 0;
  #5 A_tvalid = 0; B_tvalid = 1; #2 K_tready = 1;
  #8 B_tlast = 1;
  #1 B_tlast = 0; B_tvalid = 0; K_tready = 0;
  #5 A_tvalid = 1; B_tvalid = 0; #2 K_tready = 1;
  #8 A_tlast = 1;
  #1 A_tlast = 0; A_tvalid = 0; K_tready = 0;
  #5 A_tvalid = 1; B_tvalid = 1; K_tready = 1;
  #4 B_tlast = 1;
  #1 A_tvalid = 0; B_tvalid = 1; B_tlast = 0; K_tready = 0;


  #5 reset = 1;


  #100  $finish;

end

arbiter dut (
.clk(clk),
.reset(reset),
.A_tvalid(A_tvalid),
.A_tlast(A_tlast),
.A_tdata(A_tdata),
.A_tready(A_tready),
.B_tvalid(B_tvalid),
.B_tlast(B_tlast),
.B_tdata(B_tdata),
.B_tready(B_tready),
.K_tvalid(K_tvalid),
.K_tlast(K_tlast),
.K_tdata(K_tdata),
.K_tready(K_tready)
);

endmodule
