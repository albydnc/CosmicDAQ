`timescale 1ns/10ps

module tdc(clk, rst, start, stop, out, data_valid);
  input clk, rst;
  input start, stop;
  output reg [15:0] out  = 15'h0;
  output reg data_valid = 1'b0;
  reg [2:0] FSM = 3'h0;
  always@(posedge clk)
  begin
    case(FSM)
    3'h0:
        begin
      out = 15'h0;
      if(start == 1) FSM <= 3'h1;
      end
    3'h1:
        begin
      out <= out+1;
      if(~stop) FSM<= 3'h2;
      end
    3'h2:
      begin
      out <= out+1;
      if(stop)
      begin
        FSM <=3'h3;
        data_valid <= 1'b1;
        end
      end
    3'h3:
        begin
      FSM <= 3'h0;
      data_valid <= 1'b0;
      end
  endcase
  end
endmodule

module delay(clk, rst,start,out,delay_size);
input clk;
input rst;
input start;
input [15:0] delay_size;
output reg out = 1'b0;
reg [15:0] counter = 16'h0;
reg [2:0] FSM = 3'h0;
always @ ( posedge clk ) begin
  case (FSM)
    3'h0:
      begin
      out <= 1'b0;
      if(start) begin
       counter <= delay_size; // priming the delay unit
       FSM <= 3'h1;
       end
      end
    3'h1:
    begin
      counter <= counter - 1;
      if(counter == 15'h1) begin
        out <= 1'b1;
        FSM <= 3'h0;
      end
      if(~rst) FSM <= 3'h0;
    end
  endcase
end
endmodule

module daq(clk, rst, s1, s2, sg, delS1_SIZE, delS2_SIZE, FAKESTOP_SIZE, tdc_out, trig_out, data_valid);
  input clk, rst;
  input s1, s2, sg;
  input [15:0] delS1_SIZE;
  input [15:0] delS2_SIZE;
  input [15:0] FAKESTOP_SIZE;
  output [15:0] tdc_out;
  output [15:0] trig_out;
  output data_valid;

  wire trigger;
  wire true_stop,fake_stop,stop;
  wire sync_s1,sync_s2,sync_sg;

  reg [15:0] delSG_SIZE = 16'd5;

  assign trigger = sync_s1 && sync_sg && ~sync_s2;
  assign true_stop = ~sync_s1 && ~sync_s2 && sync_sg;
  assign stop = true_stop || fake_stop;

  delay delayS1(.clk(clk), .rst(rst), .start(s1), .out(sync_s1), .delay_size(delS1_SIZE));
  delay delayS2(.clk(clk), .rst(rst), .start(s2), .out(sync_s2), .delay_size(delS2_SIZE));
  delay delaySG(.clk(clk), .rst(rst), .start(sg), .out(sync_sg), .delay_size(delSG_SIZE));
  delay gate_stop(.clk(clk), .rst(rst || ~true_stop), .start(trigger), .out(fake_stop), .delay_size(FAKESTOP_SIZE));
  tdc tdc1(.clk(clk),.rst(rst),.start(trigger),.stop(stop),.out(tdc_out),.data_valid(data_valid));

endmodule
