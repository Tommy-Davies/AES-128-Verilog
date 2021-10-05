`timescale 1ps / 1ps

module aes_encrypt (keyBuf, wordBuf, Clk, rst, readFlag, writeFlag, encryptFinished, outBuf);

	input [31:0] keyBuf;
	input [31:0] wordBuf;
	input Clk;
	input rst;
	input readFlag;
	input writeFlag;
	output reg [31:0] outBuf;
	output reg encryptFinished;

	reg [127:0] key, prevKey, inputWord;
	reg keyDone = 1'b0;
	reg readin = 1'b0;
	integer readCount = 0;
	integer writeCount = 0;
	
	reg [319:0] rConMatrix;
	reg [2047:0] sboxMat;

	
	integer idx1, idx2, idx3, idx4, idx5, idx6, idx7, idx8, idx9, idxa, idxb, idxc, idxd, idxe, idxf, idx10;
	integer i, round;

	
	reg [127 : 0] firstMat, subMat, rowMat, colMat, roundKeyMat, roundKey, tempSubBytesMat, mat, newMat, columnMat;
	
	reg [31 : 0] col1, col2, col3, col4, subCol1, subCol2, subCol3, subCol4;
	
	
	reg [127:0] key1, key2, key3, key4, key5, key6, key7, key8, key9, key10;



	
	
	localparam rconRow0 = 319;
	localparam rconRow1 = 287;
	localparam rconRow2 = 255;
	localparam rconRow3 = 223;
	localparam rconRow4 = 191;
	localparam rconRow5 = 159;
	localparam rconRow6 = 127;
	localparam rconRow7 = 95;
	localparam rconRow8 = 63;
	localparam rconRow9 = 31;
	localparam colIdx1 = 127;
	localparam colIdx2 = 95;
	localparam colIdx3 = 63;
	localparam colIdx4 = 31;
	localparam colWidth = 31;
	
	
	//FIFO buffer loading
	always @(posedge Clk) begin
		if(readFlag == 0);
		else begin
			if (rst) begin 
				readCount = 0; 
			end 
			
			if(readCount == 0) begin
				key[127:96] = keyBuf;
			end
			else if(readCount == 1) begin
				key[95:64] = keyBuf;
			end
			else if(readCount == 2) begin
				key[63:32] = keyBuf;
			end
			else if(readCount == 3) begin
				key[31:00] = keyBuf;
			end else if(readCount == 4) begin
				inputWord[127:96] = wordBuf[31:00];
			end else if (readCount == 5) begin
				inputWord[95:64] = wordBuf[31:00];
			end else if (readCount == 6) begin
				inputWord[63:32] = wordBuf[31:00];
			end else if (readCount == 7) begin
				inputWord[31:00] = wordBuf[31:00];
				readin = 1'b1;
			end
			
		   
			readCount = readCount + 1;

		end
		
	end
		
		


	
	always @* begin
		mat = inputWord;
		sboxMat[2047:2040] = 8'h63;
		sboxMat[2039:2032] = 8'h7c;
		sboxMat[2031:2024] = 8'h77;
		sboxMat[2023:2016] = 8'h7b;
		sboxMat[2015:2008] = 8'hf2;
		sboxMat[2007:2000] = 8'h6b;
		sboxMat[1999:1992] = 8'h6f;
		sboxMat[1991:1984] = 8'hc5;
		sboxMat[1983:1976] = 8'h30;
		sboxMat[1975:1968] = 8'h1;
		sboxMat[1967:1960] = 8'h67;
		sboxMat[1959:1952] = 8'h2b;
		sboxMat[1951:1944] = 8'hfe;
		sboxMat[1943:1936] = 8'hd7;
		sboxMat[1935:1928] = 8'hab;
		sboxMat[1927:1920] = 8'h76;
		sboxMat[1919:1912] = 8'hca;
		sboxMat[1911:1904] = 8'h82;
		sboxMat[1903:1896] = 8'hc9;
		sboxMat[1895:1888] = 8'h7d;
		sboxMat[1887:1880] = 8'hfa;
		sboxMat[1879:1872] = 8'h59;
		sboxMat[1871:1864] = 8'h47;
		sboxMat[1863:1856] = 8'hf0;
		sboxMat[1855:1848] = 8'had;
		sboxMat[1847:1840] = 8'hd4;
		sboxMat[1839:1832] = 8'ha2;
		sboxMat[1831:1824] = 8'haf;
		sboxMat[1823:1816] = 8'h9c;
		sboxMat[1815:1808] = 8'ha4;
		sboxMat[1807:1800] = 8'h72;
		sboxMat[1799:1792] = 8'hc0;
		sboxMat[1791:1784] = 8'hb7;
		sboxMat[1783:1776] = 8'hfd;
		sboxMat[1775:1768] = 8'h93;
		sboxMat[1767:1760] = 8'h26;
		sboxMat[1759:1752] = 8'h36;
		sboxMat[1751:1744] = 8'h3f;
		sboxMat[1743:1736] = 8'hf7;
		sboxMat[1735:1728] = 8'hcc;
		sboxMat[1727:1720] = 8'h34;
		sboxMat[1719:1712] = 8'ha5;
		sboxMat[1711:1704] = 8'he5;
		sboxMat[1703:1696] = 8'hf1;
		sboxMat[1695:1688] = 8'h71;
		sboxMat[1687:1680] = 8'hd8;
		sboxMat[1679:1672] = 8'h31;
		sboxMat[1671:1664] = 8'h15;
		sboxMat[1663:1656] = 8'h4;
		sboxMat[1655:1648] = 8'hc7;
		sboxMat[1647:1640] = 8'h23;
		sboxMat[1639:1632] = 8'hc3;
		sboxMat[1631:1624] = 8'h18;
		sboxMat[1623:1616] = 8'h96;
		sboxMat[1615:1608] = 8'h5;
		sboxMat[1607:1600] = 8'h9a;
		sboxMat[1599:1592] = 8'h7;
		sboxMat[1591:1584] = 8'h12;
		sboxMat[1583:1576] = 8'h80;
		sboxMat[1575:1568] = 8'he2;
		sboxMat[1567:1560] = 8'heb;
		sboxMat[1559:1552] = 8'h27;
		sboxMat[1551:1544] = 8'hb2;
		sboxMat[1543:1536] = 8'h75;
		sboxMat[1535:1528] = 8'h9;
		sboxMat[1527:1520] = 8'h83;
		sboxMat[1519:1512] = 8'h2c;
		sboxMat[1511:1504] = 8'h1a;
		sboxMat[1503:1496] = 8'h1b;
		sboxMat[1495:1488] = 8'h6e;
		sboxMat[1487:1480] = 8'h5a;
		sboxMat[1479:1472] = 8'ha0;
		sboxMat[1471:1464] = 8'h52;
		sboxMat[1463:1456] = 8'h3b;
		sboxMat[1455:1448] = 8'hd6;
		sboxMat[1447:1440] = 8'hb3;
		sboxMat[1439:1432] = 8'h29;
		sboxMat[1431:1424] = 8'he3;
		sboxMat[1423:1416] = 8'h2f;
		sboxMat[1415:1408] = 8'h84;
		sboxMat[1407:1400] = 8'h53;
		sboxMat[1399:1392] = 8'hd1;
		sboxMat[1391:1384] = 8'h0;
		sboxMat[1383:1376] = 8'hed;
		sboxMat[1375:1368] = 8'h20;
		sboxMat[1367:1360] = 8'hfc;
		sboxMat[1359:1352] = 8'hb1;
		sboxMat[1351:1344] = 8'h5b;
		sboxMat[1343:1336] = 8'h6a;
		sboxMat[1335:1328] = 8'hcb;
		sboxMat[1327:1320] = 8'hbe;
		sboxMat[1319:1312] = 8'h39;
		sboxMat[1311:1304] = 8'h4a;
		sboxMat[1303:1296] = 8'h4c;
		sboxMat[1295:1288] = 8'h58;
		sboxMat[1287:1280] = 8'hcf;
		sboxMat[1279:1272] = 8'hd0;
		sboxMat[1271:1264] = 8'hef;
		sboxMat[1263:1256] = 8'haa;
		sboxMat[1255:1248] = 8'hfb;
		sboxMat[1247:1240] = 8'h43;
		sboxMat[1239:1232] = 8'h4d;
		sboxMat[1231:1224] = 8'h33;
		sboxMat[1223:1216] = 8'h85;
		sboxMat[1215:1208] = 8'h45;
		sboxMat[1207:1200] = 8'hf9;
		sboxMat[1199:1192] = 8'h2;
		sboxMat[1191:1184] = 8'h7f;
		sboxMat[1183:1176] = 8'h50;
		sboxMat[1175:1168] = 8'h3c;
		sboxMat[1167:1160] = 8'h9f;
		sboxMat[1159:1152] = 8'ha8;
		sboxMat[1151:1144] = 8'h51;
		sboxMat[1143:1136] = 8'ha3;
		sboxMat[1135:1128] = 8'h40;
		sboxMat[1127:1120] = 8'h8f;
		sboxMat[1119:1112] = 8'h92;
		sboxMat[1111:1104] = 8'h9d;
		sboxMat[1103:1096] = 8'h38;
		sboxMat[1095:1088] = 8'hf5;
		sboxMat[1087:1080] = 8'hbc;
		sboxMat[1079:1072] = 8'hb6;
		sboxMat[1071:1064] = 8'hda;
		sboxMat[1063:1056] = 8'h21;
		sboxMat[1055:1048] = 8'h10;
		sboxMat[1047:1040] = 8'hff;
		sboxMat[1039:1032] = 8'hf3;
		sboxMat[1031:1024] = 8'hd2;
		sboxMat[1023:1016] = 8'hcd;
		sboxMat[1015:1008] = 8'h0c;
		sboxMat[1007:1000] = 8'h13;
		sboxMat[999:992] = 8'hec;
		sboxMat[991:984] = 8'h5f;
		sboxMat[983:976] = 8'h97;
		sboxMat[975:968] = 8'h44;
		sboxMat[967:960] = 8'h17;
		sboxMat[959:952] = 8'hc4;
		sboxMat[951:944] = 8'ha7;
		sboxMat[943:936] = 8'h7e;
		sboxMat[935:928] = 8'h3d;
		sboxMat[927:920] = 8'h64;
		sboxMat[919:912] = 8'h5d;
		sboxMat[911:904] = 8'h19;
		sboxMat[903:896] = 8'h73;
		sboxMat[895:888] = 8'h60;
		sboxMat[887:880] = 8'h81;
		sboxMat[879:872] = 8'h4f;
		sboxMat[871:864] = 8'hdc;
		sboxMat[863:856] = 8'h22;
		sboxMat[855:848] = 8'h2a;
		sboxMat[847:840] = 8'h90;
		sboxMat[839:832] = 8'h88;
		sboxMat[831:824] = 8'h46;
		sboxMat[823:816] = 8'hee;
		sboxMat[815:808] = 8'hb8;
		sboxMat[807:800] = 8'h14;
		sboxMat[799:792] = 8'hde;
		sboxMat[791:784] = 8'h5e;
		sboxMat[783:776] = 8'h0b;
		sboxMat[775:768] = 8'hdb;
		sboxMat[767:760] = 8'he0;
		sboxMat[759:752] = 8'h32;
		sboxMat[751:744] = 8'h3a;
		sboxMat[743:736] = 8'h0a;
		sboxMat[735:728] = 8'h49;
		sboxMat[727:720] = 8'h6;
		sboxMat[719:712] = 8'h24;
		sboxMat[711:704] = 8'h5c;
		sboxMat[703:696] = 8'hc2;
		sboxMat[695:688] = 8'hd3;
		sboxMat[687:680] = 8'hac;
		sboxMat[679:672] = 8'h62;
		sboxMat[671:664] = 8'h91;
		sboxMat[663:656] = 8'h95;
		sboxMat[655:648] = 8'he4;
		sboxMat[647:640] = 8'h79;
		sboxMat[639:632] = 8'he7;
		sboxMat[631:624] = 8'hc8;
		sboxMat[623:616] = 8'h37;
		sboxMat[615:608] = 8'h6d;
		sboxMat[607:600] = 8'h8d;
		sboxMat[599:592] = 8'hd5;
		sboxMat[591:584] = 8'h4e;
		sboxMat[583:576] = 8'ha9;
		sboxMat[575:568] = 8'h6c;
		sboxMat[567:560] = 8'h56;
		sboxMat[559:552] = 8'hf4;
		sboxMat[551:544] = 8'hea;
		sboxMat[543:536] = 8'h65;
		sboxMat[535:528] = 8'h7a;
		sboxMat[527:520] = 8'hae;
		sboxMat[519:512] = 8'h8;
		sboxMat[511:504] = 8'hba;
		sboxMat[503:496] = 8'h78;
		sboxMat[495:488] = 8'h25;
		sboxMat[487:480] = 8'h2e;
		sboxMat[479:472] = 8'h1c;
		sboxMat[471:464] = 8'ha6;
		sboxMat[463:456] = 8'hb4;
		sboxMat[455:448] = 8'hc6;
		sboxMat[447:440] = 8'he8;
		sboxMat[439:432] = 8'hdd;
		sboxMat[431:424] = 8'h74;
		sboxMat[423:416] = 8'h1f;
		sboxMat[415:408] = 8'h4b;
		sboxMat[407:400] = 8'hbd;
		sboxMat[399:392] = 8'h8b;
		sboxMat[391:384] = 8'h8a;
		sboxMat[383:376] = 8'h70;
		sboxMat[375:368] = 8'h3e;
		sboxMat[367:360] = 8'hb5;
		sboxMat[359:352] = 8'h66;
		sboxMat[351:344] = 8'h48;
		sboxMat[343:336] = 8'h3;
		sboxMat[335:328] = 8'hf6;
		sboxMat[327:320] = 8'h0e;
		sboxMat[319:312] = 8'h61;
		sboxMat[311:304] = 8'h35;
		sboxMat[303:296] = 8'h57;
		sboxMat[295:288] = 8'hb9;
		sboxMat[287:280] = 8'h86;
		sboxMat[279:272] = 8'hc1;
		sboxMat[271:264] = 8'h1d;
		sboxMat[263:256] = 8'h9e;
		sboxMat[255:248] = 8'he1;
		sboxMat[247:240] = 8'hf8;
		sboxMat[239:232] = 8'h98;
		sboxMat[231:224] = 8'h11;
		sboxMat[223:216] = 8'h69;
		sboxMat[215:208] = 8'hd9;
		sboxMat[207:200] = 8'h8e;
		sboxMat[199:192] = 8'h94;
		sboxMat[191:184] = 8'h9b;
		sboxMat[183:176] = 8'h1e;
		sboxMat[175:168] = 8'h87;
		sboxMat[167:160] = 8'he9;
		sboxMat[159:152] = 8'hce;
		sboxMat[151:144] = 8'h55;
		sboxMat[143:136] = 8'h28;
		sboxMat[135:128] = 8'hdf;
		sboxMat[127:120] = 8'h8c;
		sboxMat[119:112] = 8'ha1;
		sboxMat[111:104] = 8'h89;
		sboxMat[103:96] = 8'h0d;
		sboxMat[95:88] = 8'hbf;
		sboxMat[87:80] = 8'he6;
		sboxMat[79:72] = 8'h42;
		sboxMat[71:64] = 8'h68;
		sboxMat[63:56] = 8'h41;
		sboxMat[55:48] = 8'h99;
		sboxMat[47:40] = 8'h2d;
		sboxMat[39:32] = 8'h0f;
		sboxMat[31:24] = 8'hb0;
		sboxMat[23:16] = 8'h54;
		sboxMat[15:8] = 8'hbb;
		sboxMat[7:0] = 8'h16;

		columnMat[127:120] = 8'h1b;
		columnMat[119:112] = 8'h01;
		columnMat[111:104] = 8'h01;
		columnMat[103:096] = 8'h1b; //3
		columnMat[095:088] = 8'h1b; //3
		columnMat[087:080] = 8'h1b;
		columnMat[079:072] = 8'h01;
		columnMat[071:064] = 8'h01;
		columnMat[063:056] = 8'h01;
		columnMat[055:048] = 8'h1b; //3
		columnMat[047:040] = 8'h1b;
		columnMat[039:032] = 8'h01;
		columnMat[031:024] = 8'h01;
		columnMat[023:016] = 8'h01;
		columnMat[015:008] = 8'h1b; //3
		columnMat[007:000] = 8'h1b;
		
		rConMatrix[319:312] = 8'h01;
		rConMatrix[311:304] = 8'h00;
		rConMatrix[303:294] = 8'h00;
		rConMatrix[295:288] = 8'h00;
		rConMatrix[287:280] = 8'h02;
		rConMatrix[279:272] = 8'h00;
		rConMatrix[271:264] = 8'h00;
		rConMatrix[263:256] = 8'h00;
		rConMatrix[255:248] = 8'h04;
		rConMatrix[247:240] = 8'h00;
		rConMatrix[239:232] = 8'h00;
		rConMatrix[231:224] = 8'h00;
		rConMatrix[223:216] = 8'h08;
		rConMatrix[215:208] = 8'h00;
		rConMatrix[207:200] = 8'h00;
		rConMatrix[199:192] = 8'h00;
		rConMatrix[191:184] = 8'h10;
		rConMatrix[183:176] = 8'h00;
		rConMatrix[175:168] = 8'h00;
		rConMatrix[167:160] = 8'h00;
		rConMatrix[159:152] = 8'h20;
		rConMatrix[151:144] = 8'h00;
		rConMatrix[143:136] = 8'h00;
		rConMatrix[135:128] = 8'h00;
		rConMatrix[127:120] = 8'h40;
		rConMatrix[119:112] = 8'h00;
		rConMatrix[111:104] = 8'h00;
		rConMatrix[103:96] = 8'h00;
		rConMatrix[95:88] = 8'h80;
		rConMatrix[87:80] = 8'h00;
		rConMatrix[79:72] = 8'h00;
		rConMatrix[71:64] = 8'h00;
		rConMatrix[63:56] = 8'h1b;
		rConMatrix[55:48] = 8'h00;
		rConMatrix[47:40] = 8'h00;
		rConMatrix[39:32] = 8'h00;
		rConMatrix[31:24] = 8'h36;
		rConMatrix[23:16] = 8'h00;
		rConMatrix[15:8] = 8'h00;
		rConMatrix[7:0] = 8'h00;

	end

	
	function [31: 0] rotWord(input [31:0] data);
		reg [31: 0] newWord;
		begin
			newWord[31 : 24] = data[23 : 16];
			newWord[23 : 16] = data[15 : 08];
			newWord[15 : 08] = data[07 : 00];
			newWord[07 : 00] = data[31 : 24];

			rotWord = newWord;
		end
	endfunction

	function [31 : 0] subBytesKey(input [31:0] data);
		reg [31 : 0] newMat;
		
		begin
			idx1 = col1[31 : 24]*8 - 1;
			idx2 = col1[23 : 16]*8 - 1;
			idx3 = col1[15 : 08]*8 - 1;
			idx4 = col1[07 : 00]*8 - 1;
			
			idx1 = 2047 - idx1 - 1;
			idx2 = 2047 - idx2 - 1;
			idx3 = 2047 - idx3 - 1;
			idx4 = 2047 - idx4 - 1;
			

			newMat[31 : 24] = sboxMat[idx1 -: 8];
			newMat[23 : 16] = sboxMat[idx2 -: 8];
			newMat[15 : 08] = sboxMat[idx3 -: 8];
			newMat[07 : 00] = sboxMat[idx4 -: 8];
			
			subBytesKey = newMat;
			
		end
	endfunction

	function [31 : 0] rconXor(input [31:0] data1, input [31:0] data2, input [31:0] rCol);
		begin
			rconXor = data1 ^ data2 ^ rCol;
		end
	endfunction
	
	function [31 : 0] addWords(input [31:0] data1, input [31:0] data2);
		reg [31 : 0] newMat;
		begin
			newMat = data1 ^ data2;
			addWords = newMat;
		end
	endfunction
	
	function [127 : 0] addRoundKey(input[127 : 0] mat, input [127 : 0] roundKey);
		begin
			addRoundKey = mat ^ roundKey;
		end
	endfunction 
	
	function [127 : 0] subBytes(input[127 : 0] mat);
		begin
			idx1 = mat[127 : 120]*8 - 1;
			idx2 = mat[119 : 112]*8 - 1;
			idx3 = mat[111 : 104]*8 - 1;
			idx4 = mat[103 : 096]*8 - 1;
			idx5 = mat[95 : 088]*8 - 1;
			idx6 = mat[87 : 080]*8 - 1;
			idx7 = mat[79 : 072]*8 - 1;
			idx8 = mat[71 : 064]*8 - 1;
			idx9 = mat[63 : 056]*8 - 1;
			idxa = mat[55 : 048]*8 - 1;
			idxb = mat[47 : 040]*8 - 1;
			idxc = mat[039 : 032]*8 - 1;
			idxd = mat[31 : 24]*8 - 1;
			idxe = mat[23 : 16]*8 - 1;
			idxf = mat[15 : 08]*8 - 1;
			idx10 = mat[07 : 00]*8 - 1;

			
			idx1 = 2047 - idx1 - 1;
			idx2 = 2047 - idx2 - 1;
			idx3 = 2047 - idx3 - 1;
			idx4 = 2047 - idx4 - 1;
			idx5 = 2047 - idx5 - 1;
			idx6 = 2047 - idx6 - 1;
			idx7 = 2047 - idx7 - 1;
			idx8 = 2047 - idx8 - 1;
			idx9 = 2047 - idx9 - 1;
			idxa = 2047 - idxa - 1;
			idxb = 2047 - idxb - 1;
			idxc = 2047 - idxc - 1;
			idxd = 2047 - idxd - 1;
			idxe = 2047 - idxe - 1;
			idxf = 2047 - idxf - 1;
			idx10 = 2047 - idx10 - 1;
		
			tempSubBytesMat[127 : 120] = sboxMat[idx1 -: 8];
			tempSubBytesMat[119 : 112] = sboxMat[idx2 -: 8];
			tempSubBytesMat[111 : 104] = sboxMat[idx3 -: 8];
			tempSubBytesMat[103 : 096] = sboxMat[idx4 -: 8];
			tempSubBytesMat[095 : 088] = sboxMat[idx5 -: 8];
			tempSubBytesMat[087 : 080] = sboxMat[idx6 -: 8];
			tempSubBytesMat[079 : 072] = sboxMat[idx7 -: 8];
			tempSubBytesMat[071 : 064] = sboxMat[idx8 -: 8];
			tempSubBytesMat[063 : 056] = sboxMat[idx9 -: 8];
			tempSubBytesMat[055 : 048] = sboxMat[idxa -: 8];
			tempSubBytesMat[047 : 040] = sboxMat[idxb -: 8];
			tempSubBytesMat[039 : 032] = sboxMat[idxc -: 8];
			tempSubBytesMat[031 : 024] = sboxMat[idxd -: 8];
			tempSubBytesMat[023 : 016] = sboxMat[idxe -: 8];
			tempSubBytesMat[015 : 008] = sboxMat[idxf -: 8];
			tempSubBytesMat[007 : 000] = sboxMat[idx10 -: 8];
			
			subBytes = tempSubBytesMat;
		end
		
	endfunction

	function [127 : 0] shiftRows(input [127 : 0] data);
		reg [31 : 0] col1, col2, col3, col4;
		reg [31 : 0] newRow1, newRow2, newRow3, newRow4;
		
		begin
			col1 = data[127 : 096];
			col2 = data[095 : 064];
			col3 = data[063 : 032];
			col4 = data[031 : 000];

			newRow1 = {col1[31 : 24], col2[23 : 16], col3[15 : 08], col4[07 : 00]}; 
			newRow2 = {col2[31 : 24], col3[23 : 16], col4[15 : 08], col1[07 : 00]}; //shifts each byte over cyclically where required
			newRow3 = {col3[31 : 24], col4[23 : 16], col1[15 : 08], col2[07 : 00]};
			newRow4 = {col4[31 : 24], col1[23 : 16], col2[15 : 08], col3[07 : 00]};
			
			shiftRows = {newRow1, newRow2, newRow3, newRow4};
		end
	endfunction
	
	function [7 : 0] mult2GF(input [7 : 0] data);
    begin
      mult2GF = {data[6 : 0], 1'b0} ^ (8'h1b & {8{data[7]}}); //left shifts data, multiplies it by hex 1b with overflow bit (if applicable) to perform multiply by 2 in GF
    end
  endfunction

  function [7 : 0] mult3GF(input [7 : 0] data);
    begin
      mult3GF = mult2GF(data) ^ data; //GF multiply by three requires a *2 in GF XORed with original data
    end
  endfunction 

  function [31 : 0] multGF(input [31 : 0] col);
    reg [7 : 0] i1, i2, i3, i4, o1, o2, o3, o4;
    begin
      i1 = col[31 : 24];
      i2 = col[23 : 16];
      i3 = col[15 : 08];
      i4 = col[07 : 00];

      o1 = mult2GF(i1) ^ mult3GF(i2) ^ i3 ^ i4;
      o2 = i1 ^ mult2GF(i2) ^ mult3GF(i3) ^ i4;
      o3 = i1 ^ i2 ^ mult2GF(i3) ^ mult3GF(i4);
      o4 = mult3GF(i1) ^ i2 ^ i3 ^ mult2GF(i4);

      multGF = {o1, o2, o3, o4};
    end
  endfunction

  function [127 : 0] mixColumns(input [127 : 0] data);
    reg [31 : 0] col1, col2, col3, col4, newCol1, newCol2, newCol3, newCol4;
    begin
      col1 = data[127 : 096];
      col2 = data[095 : 064];
      col3 = data[063 : 032];
      col4 = data[031 : 000];

      newCol1 = multGF(col1);
      newCol2 = multGF(col2);
      newCol3 = multGF(col3);
      newCol4 = multGF(col4);

      mixColumns = {newCol1, newCol2, newCol3, newCol4};
    end
  endfunction

	
	//key schedule
	always @(posedge Clk) begin
		if(keyDone);
		else if (readin && keyDone == 0) begin
		
			//round 1		
			col1 = rotWord(key[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(key[colIdx1 -: 32], subCol1, rConMatrix[rconRow0 -: 32]);
			col2 = addWords(key[colIdx2 -: 32], col1);
			col3 = addWords(key[colIdx3 -: 32], col2);
			col4 = addWords(key[colIdx4 -: 32], col3);
			key1 = {col1, col2, col3, col4};
			prevKey = key1;

			
			//round 2
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow1 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key2 = {col1, col2, col3, col4};
			prevKey = key2;
			
			//round 3
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow2 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key3 = {col1, col2, col3, col4};
			prevKey = key3;
			
			
			//round 4
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow3 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key4 = {col1, col2, col3, col4};
			prevKey = key4;
			
			//round 5
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow4 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key5 = {col1, col2, col3, col4};
			prevKey = key5;
			
			//round 6
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow5 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key6 = {col1, col2, col3, col4};
			prevKey = key6;
			
			//round 7
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow6 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key7 = {col1, col2, col3, col4};
			prevKey = key7;
			
			//round 8
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow7 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key8 = {col1, col2, col3, col4};
			prevKey = key8;
			
			//round 9
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow8 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key9 = {col1, col2, col3, col4};
			prevKey = key9;
			
			col1 = rotWord(prevKey[31:00]);
			subCol1 = subBytesKey(col1);
			col1 = rconXor(prevKey[colIdx1 -: 32], subCol1, rConMatrix[rconRow9 -: 32]);
			col2 = addWords(prevKey[colIdx2 -: 32], col1);
			col3 = addWords(prevKey[colIdx3 -: 32], col2);
			col4 = addWords(prevKey[colIdx4 -: 32], col3);
			key10 = {col1, col2, col3, col4};
			prevKey = key10;
			
			$display("final key: %h", key10);
			keyDone = 1;
		end
	end
	
	always @(posedge Clk) begin
		if(encryptFinished);
		else if (readin && keyDone) begin
		
		
		firstMat = inputWord;

		roundKeyMat = addRoundKey(inputWord, key);
		for(i = 0; i < 10; i = i + 1) begin
			if(i == 0) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key1);
			end else if(i == 1) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key2);
			end else if (i == 2) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key3);
			end else if (i == 3) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key4);
			end else if (i == 4) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key5);
			end else if (i == 5) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key6);
			end else if (i == 6) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key7);
			end else if (i == 7) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key8);
			end else if (i == 8) begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				colMat = mixColumns(rowMat);
				roundKeyMat = addRoundKey(colMat, key9);
			end else begin
				subMat = subBytes(roundKeyMat);
				rowMat = shiftRows(subMat);
				roundKeyMat = addRoundKey(rowMat, key10);
			end
			newMat = roundKeyMat;
			
			
		end
		encryptFinished = 1;
		end
	end


	always @(posedge Clk)	begin
		if(writeFlag) begin
		
			//write each data chunk to output buffer
			if(writeCount == 0) begin
				outBuf = newMat[127:96];
			end
			else if(writeCount == 1) begin
				outBuf = newMat[95:64];
			end
			else if(writeCount == 2) begin
				outBuf = newMat[63:32];
			end
			else if(writeCount == 3) begin
				outBuf = newMat[31:00];
			end
			if(writeCount <= 3) begin
				writeCount = writeCount + 1; //increment chunk counter
			end
		end
	end
	







endmodule
