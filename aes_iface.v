
module aes_iface(ctrlIn, bufferIn, bufferOut); //hardware/software interface

	input [31:0] bufferIn;
	input [7:0] ctrlIn;
	output reg [31:0] bufferOut;
	reg [127:0] tempBuf;
	reg Clk;
	reg rst;
	reg readFlag;
	reg writeFlag;
	reg [31:0] keyIn;
	reg [31:0] wordIn;
	wire done;
	reg loadKey = 0;
	
	integer readCount = 0;
	
	aes_encrypt uut(keyIn, wordIn, Clk, rst, readFlag, writeFlag, done, outBuf);
	
	always @(posedge Clk) begin
		
		if(ctrlIn == 0) begin //idle
			if(readCount == 4) begin
				readCount = 0;
			end
		end else if (ctrlIn == 1) begin //reset
			rst = 1;
			#100;
			rst = 0;
		end else if (ctrlIn == 2) begin //load from buffer
			
			if(readCount == 0) begin
				tempBuf[127:96] = bufferIn;
			end else if (readCount == 1) begin
				tempBuf[95:64] = bufferIn;
			end else if (readCount == 2) begin
				tempBuf[63:32] = bufferIn;
			end else if (readCount == 3) begin
				tempBuf[31:00] = bufferIn;
			end
			readCount = readCount + 1;
			
		end else if (ctrlIn == 3) begin //in key
		
			readFlag = 1;
			if(readCount == 0) begin
				keyIn = tempBuf[127:96];
			end else if (readCount == 1) begin
				keyIn = tempBuf[95:64];
			end else if (readCount == 2) begin
				keyIn = tempBuf[63:32];
			end else if (readCount == 3) begin
				keyIn = tempBuf[31:00];
				readFlag = 0;
			end
			readCount = readCount + 1;
			
		
		end else if (ctrlIn == 4) begin //in text
			readFlag = 1;
			if(readCount == 0) begin
				wordIn = tempBuf[127:96];
			end else if (readCount == 1) begin
				wordIn = tempBuf[95:64];
			end else if (readCount == 2) begin
				wordIn = tempBuf[63:32];
			end else if (readCount == 3) begin
				wordIn = tempBuf[31:00];
				readFlag = 0;
			end
			readCount = readCount + 1;
		
		end else if (ctrlIn == 5) begin //encrypt
			readCount = 0;
		end else if (ctrlIn == 6) begin //out text
			writeFlag = 1;
			bufferOut = outBuf;
			readCount = readCount + 1;
		end else if (ctrlIn == 7) begin //read
			bufferOut = outBuf;
			readCount = readCount + 1;
			if (readCount >= 3) begin
				writeFlag = 0;
				readCount = 0;
			end
		end
		
	end
	
	
	always #10 Clk = ~Clk;
	

endmodule
