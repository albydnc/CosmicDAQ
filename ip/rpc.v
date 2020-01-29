module RPCinterface(clk,rst,cmd,data,data_valid);
  input clk, rst;
  input [2:0] cmd;

  inout [15:0] data;
  inout data_valid;
  wire [15:0] datarx;
  wire validrx;
  reg [15:0] datatx;
  reg validtx;
  reg datatri = 1'b0;
  reg validtri = 1'b0;
  reg run;
  //testbench stuff
  reg [15:0] tdc_out = 16'hBAD;
  reg [15:0] delS1_SIZE = 16'b0;
  reg [15:0] delS2_SIZE = 16'b0;
  reg [15:0] FAKESTOP_SIZE = 16'b0;
  reg [1:0] FSM = 2'b0;
  assign data = (datatri) ? datatx:16'bZ;
  assign datarx = data;
  assign data_valid = (validtri) ? validtx : 1'bZ;
  assign validrx = data_valid;

  always @ ( posedge clk ) begin
      case (cmd)
        3'h0: begin
          if(validrx) delS1_SIZE = data; //SET SCINTILLATOR 1 DELAY
        end
        3'h1: begin
          if(validrx) delS2_SIZE = data; //SET SCINTILLATOR 2 DELAY
        end
        3'h2: begin
          if(validrx) FAKESTOP_SIZE = data; //SET GATE SIZE
        end
        3'h3: begin
        //FIFO DUMP STUFF
          case (FSM)
          2'h0: begin
            if(validrx) FSM <= 2'h1;
          end
            2'h1: begin
            datatri <= 1;
            validtri <= 1; //GET TDC READING
            datatx <= tdc_out;
            validtx<= 1;
            FSM <= 2'h2;
            end
            2'h2: begin
              validtx <= 0;
              validtri <= 0;
              datatri <= 0;
              FSM <= 2'h0;
            end
          endcase
        end
        3'h4: begin
            if(validrx) run <= 1'b1; // START ACQUISITION
        end
        3'h5: begin
            if(validrx) run <= 1'b0; // STOP ACQUISITION
        end
      endcase
  end
endmodule
