module main;
reg clk = 1;
reg rst = 1;
reg [2:0] cmd = 3'b0;
wire [15:0] data;
reg [15:0] datatx;
reg datatri;
reg validtx;
reg validtri;
wire data_valid;

assign data = (datatri) ? datatx:16'bZ;
assign data_valid = (validtri) ? validtx : 1'bZ;

RPCinterface rpc(.clk(clk),.rst(rst),.cmd(cmd),.data(data),.data_valid(data_valid));

initial begin
$dumpfile("RPC.vcd");
$dumpvars(0, main);
  #10
  datatri = 1'b1;
  validtri = 1'b1;
  datatx <= 16'h1234;
  #3
  validtx <= 1'b1;
  #1
  validtx <= 1'b0;
  validtri <= 1'b0;
  #10
  cmd <= 3'h3;
  datatri <= 0;
  validtri <= 1;
  #3
  validtx <= 1'b1;
  #1
  validtri <= 1'b0;
  #10
  cmd = 3'h1;
  datatri = 1'b1;
  validtri = 1'b1;
  datatx <= 16'h1234;
  #3
  validtx <= 1'b1;
  #1
  #1000;
  $finish;
end
always #1 clk = ~clk;
endmodule
