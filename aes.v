`timescale 1ps / 1ps

module aes(outWord); //testbench

	//ins
	reg Clk;
	reg rst;
	reg readFlag;
	reg writeFlag = 0;
	reg [31:0] keyIn;
	reg [31:0] wordIn;
	wire done;
	integer wCount = 0;

	//outs
	wire [31:0] outBuf;

	output reg [127:0] outWord;


	// unit under test 

	aes_encrypt uut(keyIn, wordIn, Clk, rst, readFlag, writeFlag, done, outBuf);
	
//	aes_decrypt_new uut(keyIn, wordIn, Clk, rst, readFlag, writeFlag, done, outBuf);

	
	reg [127:000] wordVec = 128'h58c8e00b2631686d54eab84b91f0aca1;
	reg [127:000] keyVec = 128'h00000000000000000000000000000000;
//	reg [127:0] wordVec  = 128'h08a4e2ef12ca7460b9040bbfb9040bbf;
//	reg [127:0] keyVec = 128'h2b7e151628aed2a6abf7158809cf4f3c;


	initial begin
	Clk = 1'b0;
	wordIn = 32'h0;
	keyIn = 32'h0;
	readFlag = 1'b0;
	rst = 1'b1;

	//wait for reset
	#100;

	rst = 1'b1;

	#20; //first chunk

	rst = 1'b0;
	readFlag = 1'b1;
	keyIn = keyVec[127:96];

	#20; //second chunk

	keyIn = keyVec[95:64];

	#20; //third chunk

	keyIn = keyVec[63:32];

	#20; //fourth chunk

	keyIn = keyVec[31:00];
	
	#20
	wordIn = wordVec[127:96];

	#20
	
	wordIn = wordVec[95:64];
	
	#20
	
	wordIn = wordVec[63:32];

	#20
	
	wordIn = wordVec[31:00];

	#20
	
	readFlag = 1'b0;
	wCount = 0;

	end

		always #10 Clk = ~Clk;
		
	always @(posedge Clk) begin
		if(done == 0);
		else if (done) begin
			writeFlag = 1;
			#40 //wait two clocks for response
			if(wCount == 0) begin
				outWord[127:96] = outBuf[31:0];
			end else if(wCount == 1) begin
				outWord[95:64] = outBuf[31:0];
			end else if (wCount == 2) begin
				outWord[63:32] = outBuf[31:0];
			end else if (wCount == 3) begin
				outWord[31:0] = outBuf[31:0];
				$timeformat(-9, 2, " ns", 20);
				$display("CipherText: outword %h, buffer %h, sim time %0t", outWord, outBuf, $time);

			end
			if(wCount <= 3) begin
				wCount = wCount + 1;
			end else begin
				writeFlag = 0;
			end
		end

	end
endmodule
