// The code is written based on my underestanding of AXI4-Stream handshake
// My 1st reference:  https://lauri.xn--vsandi-pxa.com/hdl/zynq/axi-stream.html
//My 2nd reference:   https://www.youtube.com/channel/UC8qv9c4Ruu0mycMVjI7R48w
//My 3rd reference:   https://www.arm.com/products/silicon-ip-system/embedded-system-design/amba-specifications
`timescale 1ns/100ps
// Code your design here
module arbiter(
    input   clk,
    input   reset,
    input   A_tvalid,
    input   A_tlast,
    output  A_tready,
    input   [7:0] A_tdata,
    input   B_tvalid,
    input   B_tlast,
    output  B_tready,
    input   [7:0] B_tdata,
    output  K_tvalid,
    output  K_tlast,
    input   K_tready,
    output  [7:0] K_tdata
    );

//////////////////////////////////////
    reg	A_tready;
    reg B_tready;
    reg K_tvalid;
    reg K_tlast;
    reg [7:0] K_tdata;

  ////////////////////////////////////
    reg	rotate_RR = 1'b0;
    reg temp_out_tvalid = 1'b0;
    reg temp_out_tlast  = 1'b0;
    reg temp_out_tready = 1'b0;
    reg [7:0] temp_out_tdata = 8'b0;
    reg flag = 1'b0;
///////////////////////////////////////
// update the rotation value
// rotatation will move to the another one afeter the first one is finished.
//The allocation is preemptive based. It means that we rotate to another one
//after the first one is finished (tlast == 1'b1)
always @ (posedge clk or posedge reset)
if (reset) begin
		rotate_RR <= 1'b0;
end else if ((rotate_RR == 1'b0) && (A_tlast == 1'b1)) begin
         rotate_RR <= 1'b1;
end else if ((rotate_RR == 1'b1) && (B_tlast == 1'b1)) begin
        rotate_RR <= 1'b0;
end

// shift req to round robin the current priority
  always @ (*) 
begin
	case (rotate_RR)
		1'b0: begin
        temp_out_tvalid = A_tvalid;
        temp_out_tlast  = A_tlast;
        temp_out_tdata  = A_tdata;
        temp_out_tready = K_tready;
        flag = 1'b0;
        end
    1'b1: begin
        temp_out_tvalid =  B_tvalid;
        temp_out_tlast  = B_tlast;
        temp_out_tdata  = B_tdata;
        temp_out_tready = K_tready;
        flag = 1'b1;
        end
	endcase
end
////////////////////////////////////////////////////////
//to capture all event happened to values, clk is sensetive to both edges.
always @ (posedge clk or negedge clk or posedge reset)
if (reset || (A_tvalid == 1'b0 && B_tvalid == 1'b0)) begin
        K_tvalid =1'b0;
        K_tlast = 1'b0;
        K_tdata = 8'b0;
        A_tready =1'b0;
        B_tready =1'b0;
end else if (A_tvalid == 1'b1 && B_tvalid == 1'b0) begin
        K_tvalid = A_tvalid;
        K_tlast  = A_tlast;
        K_tdata  = A_tdata;
        A_tready = K_tready;
        B_tready = 1'b0;
end else if (A_tvalid == 1'b0 && B_tvalid == 1'b1) begin
        K_tvalid = B_tvalid;
        K_tlast  = B_tlast;
        K_tdata  = B_tdata;
        B_tready = K_tready;
        A_tready = 1'b0;
end else begin
        K_tvalid = temp_out_tvalid;
        K_tlast  = temp_out_tlast;
        K_tdata  = temp_out_tdata;
        if (flag == 1'b0) begin  A_tready = K_tready;   B_tready = 1'b0; end
        if (flag == 1'b1) begin  B_tready = K_tready;   A_tready = 1'b0; end
end

endmodule
