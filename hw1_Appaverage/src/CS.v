`timescale 1ns/10ps
module CS(Y, X, reset, clk);

input clk, reset; 
input 	[7:0] X;
output 	[9:0] Y;

//--------------------------------------
//  \^o^/   Write your code here~  \^o^/
//--------------------------------------
reg [71:0] data;//8*9 72-bit
wire [10:0] sum;//11-bit
wire [10:0] avg;
wire [10:0] xavg;
reg [10:0] max;

always @(posedge clk or posedge reset) begin
  if(reset) begin
    data <= 72'b0;// set to 0
  end
  else begin
    data <= {data[63:0], X};// push new X to rear of data
  end
end

//add
assign sum = {2'b0, data[71:64]} + {2'b0, data[63:56]}
          + {2'b0, data[55:48]} + {2'b0, data[47:40]}
          + {2'b0, data[39:32]} + {2'b0, data[31:24]}
          + {2'b0, data[23:16]} + {2'b0, data[15:8]}
          + {2'b0, data[7:0]};

//get average
assign avg = sum / 9; //sum / 9

//find approximate average
always @(*)begin
  max = 0;
  if(data[71:64] <= avg)begin
    if(!max) max = data[71:64];
    else if(max<data[71:64]) max = data[71:64];
  end
  if(data[63:56] <= avg)begin
    if(!max) max = data[63:56];
    else if(max<data[63:56]) max = data[63:56];
  end
  if(data[55:48] <= avg)begin
    if(!max) max = data[55:48];
    else if(max<data[55:48]) max = data[55:48];
  end
  if(data[47:40] <= avg)begin
    if(!max) max = data[47:40];
    else if(max<data[47:40]) max = data[47:40];
  end
  if(data[39:32] <= avg)begin
    if(!max) max = data[39:32];
    else if(max<data[39:32]) max = data[39:32];
  end
  if(data[31:24] <= avg)begin
    if(!max) max = data[31:24];
    else if(max<data[31:24]) max = data[31:24];
  end
  if(data[23:16] <= avg)begin
    if(!max) max = data[23:16];
    else if(max<data[23:16]) max = data[23:16];
  end
  if(data[15:8] <= avg)begin
    if(!max) max = data[15:8];
    else if(max<data[15:8]) max = data[15:8];
  end
  if(data[7:0] <= avg)begin
    if(!max) max = data[7:0];
    else if(max<data[7:0]) max = data[7:0];
  end
end
assign xavg = max;
//calculate Y{xavg, 3'b000} + xavg

assign Y = ({2'b0, data[71:64]} + {2'b0, data[63:56]}
          + {2'b0, data[55:48]} + {2'b0, data[47:40]}
          + {2'b0, data[39:32]} + {2'b0, data[31:24]}
          + {2'b0, data[23:16]} + {2'b0, data[15:8]}
          + {2'b0, data[7:0]}+ {xavg, 3'b000} + xavg)/ 8;

endmodule