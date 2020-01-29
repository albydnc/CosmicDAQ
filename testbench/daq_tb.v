
module main;
  reg clk400, rst;
  reg s1,sg,s2;
  wire [15:0] out;
  reg [15:0] D1 = 16'd25;
  reg [15:0] D2 = 16'd25;
  reg [15:0] FS = 16'd4000;
  daq daq1(.clk(clk400),.rst(rst),.s1(s1),.s2(s2),.sg(sg),.delS1_SIZE(D1),.delS2_SIZE(D2),.FAKESTOP_SIZE(FS), .tdc_out(out),.trig_out(), .data_valid());

  initial begin
    $dumpfile("my_dumpfile.vcd");
    $dumpvars(0, main);
    clk400 = 1;
    s1 = 0;
    sg = 0;
    s2 = 0;
    rst = 1;
    #10
    //trigger
    s1 = 1;
    sg = 0;
    s2 = 0;
    #10
    s1 = 0;
    #40
    s1 = 0;
    sg = 1;
    s2 = 0;
    #10
    sg = 0;
    #2000
    s1 = 0;
    sg = 1;
    s2 = 0;
    #10
    sg = 0;
    #10000
    $finish;
  end
  always #1.25 clk400 = ~clk400;
endmodule
