module SME(clk,reset,chardata,isstring,ispattern,valid,match,match_index);
input clk;
input reset;
input [7:0] chardata;
input isstring;
input ispattern;
output match;
output [4:0] match_index;
output valid;
reg match;
reg [4:0] match_index;
reg valid;

reg [7:0] str [31:0];
reg [7:0] pattern [7:0];

reg [2:0] cState;
reg [2:0] nState;

parameter idle = 3'd0;
parameter inStr = 3'd1;
parameter inPat = 3'd2;
parameter compare = 3'd3;
parameter outputS = 3'd4;
parameter outputF = 3'd5;
integer i = 0;

reg [5:0] strLen;
reg [5:0] nstrLen;//next
reg [3:0] patLen;
reg [3:0] npatLen;//next
reg [5:0] strIndex;
reg [5:0] nstrIndex;
reg [3:0] patIndex;
reg [3:0] npatIndex;
reg [4:0] result;
//reg [7:0] nchardata;
//clk & reset
always @(posedge clk or posedge reset)
begin
  if(reset)
    begin
      match <= 1'b0;
      match_index <= 5'b0;
      valid <= 1'b0;
      cState <= 3'b0;
      strLen <= 6'b0;
      patLen <= 4'b0;
      strIndex <= 6'b0;
      patIndex <= 4'b0;
	  nstrIndex <= 6'b0;
      npatIndex <= 4'b0;
	  result <= 5'b0;
    end
  else
    begin
      //nextstate place into currunt state
      cState <= nState;
      //strLen <= nstrLen;
      //patLen <= npatLen;
      //strIndex <= nstrIndex;
      //patIndex <= npatIndex;
	  
	  //input chardata
	  if(isstring == 1)
		begin
		  str[strLen] <= chardata;
		  strLen <= strLen + 1;
		end
	  else if(ispattern == 1)
	    begin
		  pattern[patLen] <= chardata;
		  patLen <= patLen + 1;
		end
    end
end

//next state logic
always @(*)
begin
  //nchardata <= chardata;
  case(cState)
	idle:
	  begin
	    if(isstring == 1) nState <= inStr;
        else if(ispattern == 1) nState <= inPat;
		else nState <= idle;
	  end
    inStr: //string input
      begin
	    nstrIndex <= 0;
		npatIndex <= 0;
	    if(isstring == 1) nState <= inStr;
        else 
		  begin
		    nState <= inPat;
			patLen <= 0;
		  end
	  end
    inPat: //pattern input
      begin
	    nstrIndex <= 0;
		npatIndex <= 0;
	    if(ispattern == 1) nState <= inPat;
        else nState <= compare;
	  end
    compare: //compare
      begin
	    if(pattern[0] == 8'h5e && pattern[patLen-1] != 8'h24)//^, initializes patIndex as 1
		  begin
			patIndex = 1;
			result = 0;
			nState = outputF;
			for(i = 0; i <= strLen-patLen+1; i = i+1)
			  begin
			    if((i == 0 && str[0] == pattern[1]) || (i > 0 && str[i-1] == 8'b00100000 && (str[i] == pattern[1] || pattern[1] == 8'h2e)) && nState != outputS)//8'b00100000 = space
				  begin
					  for(strIndex = i; strIndex < i+patLen-1; strIndex = strIndex+1)
						begin
						  if(pattern[patIndex] == str[strIndex] || pattern[patIndex] == 8'h2e) patIndex = patIndex + 1;
						  else patIndex = 1;
						  if(patIndex >= patLen && nState != outputS) 
							begin
							  nState = outputS;
							  result = i;
							end
						end
						patIndex = 1;
				  end
			  end
		  end//end of ^
		else if(pattern[patLen-1] == 8'h24 && pattern[0] != 8'h5e)//$
		  begin
		    patIndex = 0;
			result = 0;
			nState = outputF;
			for(i = 0; i <= strLen-patLen+1; i = i+1)
			  begin
				if((pattern[0] == str[i] || pattern[0] == 8'h2e) && nState != outputS)
				  begin
				    for(strIndex = i; strIndex < i+patLen-1; strIndex = strIndex+1)
					  begin
						if(pattern[patIndex] == str[strIndex] || pattern[patIndex] == 8'h2e) patIndex = patIndex + 1;
						else patIndex = 0;
						if(patIndex >= patLen-1 && nState != outputS && (strIndex == strLen-1 || str[strIndex+1] == 8'b00100000)) 
						  begin
							nState = outputS;
							result = i;
						  end
					  end
					  patIndex = 0;
				  end
			  end
		  end//end of $
		else if(pattern[0] == 8'h5e && pattern[patLen-1] == 8'h24)//^$
		  begin
			patIndex = 1;
			result = 0;
			nState = outputF;
			for(i = 0; i <= strLen-patLen+2; i = i+1)
			  begin
			    if((i == 0 && str[0] == pattern[1]) || (i > 0 && str[i-1] == 8'b00100000 && (str[i] == pattern[1] || pattern[1] == 8'h2e)) && nState != outputS)//8'b00100000 = space
				  begin
					  for(strIndex = i; strIndex < i+patLen-2; strIndex = strIndex+1)
						begin
						  if(pattern[patIndex] == str[strIndex] || pattern[patIndex] == 8'h2e) patIndex = patIndex + 1;
						  else patIndex = 1;
						  if(patIndex >= patLen-1 && nState != outputS && (strIndex == strLen-1 || str[strIndex+1] == 8'b00100000)) 
							begin
							  nState = outputS;
							  result = i;
							end
						end
						patIndex = 1;
				  end
			  end
		  end//end of ^$
		else//regular
		  begin
		    patIndex = 0;
			result = 0;
			nState = outputF;
			for(i = 0; i <= strLen-patLen; i = i+1)
			  begin
				if((pattern[0] == str[i] || pattern[0] == 8'h2e) && nState != outputS)
				  begin
				    for(strIndex = i; strIndex < i+patLen; strIndex = strIndex+1)
					  begin
						if(pattern[patIndex] == str[strIndex] || pattern[patIndex] == 8'h2e) patIndex = patIndex + 1;
						else patIndex = 0;
						if(patIndex >= patLen && nState != outputS) 
						  begin
							nState = outputS;
							result = i;
						  end
					  end
					  patIndex = 0;
				  end
			  end
		  end//end of regular
        //if(success) nState <= outputS;
		//else if(fail) nState <= outputF;
		//else nState <= compare;
		//nState <= outputF;
      end//end of compare state
    outputS:
      begin
	    nstrIndex <= 0;
		npatIndex <= 0;
	    if(isstring == 1) 
		  begin
		    nState <= inStr;
			strLen <= 6'b0;
		  end
        else if(ispattern == 1)
		  begin 
			nState <= inPat;
			patLen <= 4'b0;
		  end
		else nState <= idle;
	  end
    outputF:
      begin
	    nstrIndex <= 0;
		npatIndex <= 0;
	    if(isstring == 1) 
		  begin
		    nState <= inStr;
			strLen <= 6'b0;
		  end
        else if(ispattern == 1)
		  begin 
			nState <= inPat;
			patLen <= 4'b0;
		  end
		else nState <= idle;
	  end
    default:
      begin
	    if(isstring == 1) nState <= inStr;
        else if(ispattern == 1) nState <= inPat;
		else nState <= idle;
	  end
  endcase
end

//output logic
always @(*)
  begin
    if(cState == outputS)
      begin
        match = 1;
        valid = 1;
        match_index = result;//the answer index
      end
    else if(cState == outputF)
      begin
        match = 0;
        match_index = 0;
        valid = 1;
      end
    else
      begin
        match = 0;
        match_index = 0;
        valid = 0;
      end
  end
endmodule