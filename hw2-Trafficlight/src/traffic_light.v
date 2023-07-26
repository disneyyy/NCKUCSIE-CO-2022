module traffic_light (
    input  clk,
    input  rst,
    input  pass,
    output reg R,
    output reg G,
    output reg Y
);

//write your code here
reg[2:0] currentState;
reg[2:0] nextState;
reg[9:0] currentCount;
reg[9:0] nextCount;
always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
      currentState <= 3'b0;
      currentCount <= 10'b1;
    end
  else
    begin 
      if(pass && currentState > 0)
        begin
          currentState <= 3'b0;
          currentCount <= 10'b1;
        end
      else
        begin
          currentCount <= nextCount;
          currentState <= nextState;
        end
    end
end

always @(*)
begin
  case(currentState)
    3'b000://G 512 cycles
    begin
      if(currentCount < 512)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b001://Non 64 cycles?
    begin
      if(currentCount < 64)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b010://G 64 cycles
    begin
      if(currentCount < 64)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b011://Non 64 cycles
    begin
      if(currentCount < 64)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b100://G 64 cycles
    begin
      if(currentCount < 64)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b101://Y 256 cycles
    begin
      if(currentCount < 256)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = currentState + 1;
        end
    end
    3'b110://R 512 cycles
    begin
      if(currentCount < 512)
        begin
          nextCount = currentCount + 1;
          nextState = currentState;
        end
      else
        begin
          nextCount = 10'b1;
          nextState = 3'b0;
        end
    end
    endcase
end

always @(*)
begin
  if(currentState == 3'b000 || currentState == 3'b010 || currentState == 3'b100)
    begin//G
      G = 1;
      R = 0;
      Y = 0;
    end
  else if(currentState == 3'b101)
    begin//Y
      G = 0;
      R = 0;
      Y = 1;
    end
  else if(currentState == 3'b110)
    begin//R
      G = 0;
      R = 1;
      Y = 0;
    end
  else
    begin//Non
      G = 0;
      R = 0;
      Y = 0;
    end   
end
endmodule

