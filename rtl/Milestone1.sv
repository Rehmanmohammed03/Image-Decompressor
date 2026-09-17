
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This module monitors the data from UART
// It also assembles and writes the data into the SRAM
module MILESTONE_ONE (
   input  logic		Clock,
   input  logic		Resetn, 

   input  logic		start,
	input logic [15:0] SRAM_read_data,
   
   output logic [17:0]	SRAM_address,
   output logic [15:0]	SRAM_write_data,
   output logic		SRAM_we_n,
	output logic done
);

MILESTONE_ONE_state_type M1_state;

logic [31:0] Y_even;
logic [31:0] Y_odd;
logic [31:0] U_reg [9:0];
logic [31:0] V_reg [9:0];
logic [31:0] U_odd;
logic [31:0] V_odd;
logic [31:0] R_even;
logic [31:0] R_odd;
logic [31:0] G_even;
logic [31:0] G_odd;
logic [31:0] B_even;
logic [31:0] B_odd;
logic [7:0] U_oddbuf;
logic [7:0] V_oddbuf;
logic [15:0] U_EvenOdd;
logic [15:0] V_EvenOdd;

logic [31:0] op1,op2,op3,op4,op5,op6,op7,op8;
logic [63:0] result_long1,result_long2,result_long3,result_long4;
logic [31:0] result1,result2,result3,result4;

logic [17:0] Y_address,U_address,V_address,RGB_address;
logic [7:0] row_counter;

logic new_read;
logic [7:0] CC_counter;
integer i,j;

// Milestone One Data crunching
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		SRAM_we_n <= 1'b1;
		SRAM_write_data <= 16'd0;
		Y_address <= 18'd0;
		U_address <= 18'd0;
		V_address <= 18'd0;
		RGB_address <= 18'd0;
		SRAM_address <= 18'd0;
		Y_even <= 32'd0;
		Y_odd <= 32'd0;
		U_reg <= '{default:32'd0};
		V_reg <= '{default:32'd0};
		U_odd <= 32'd0;
		V_odd <= 32'd0;
		R_even <= 32'd0;
		R_odd <= 32'd0;
		G_even <= 32'd0;
		G_odd <= 32'd0;
		B_even <= 32'd0;
		B_odd <= 32'd0;
		U_oddbuf <= 8'd0;
		V_oddbuf <= 8'd0;
		U_EvenOdd <= 32'd0;
		V_EvenOdd <= 32'd0;
		row_counter <= 8'd0;
		new_read <= 1'b1;
		CC_counter <= 8'd0;
		done <= 1'b0;
		M1_state <= WAIT_IDLE;
		
	end else begin				
		case (M1_state)
		WAIT_IDLE: begin
			if (start == 1'b1) begin	
				M1_state <= LEAD_IN_1;
				Y_address <= 18'd0;
				U_address <= 18'd13824;
				V_address <= 18'd20736;
				RGB_address <= 18'd220672;
				done <= 1'b0;
				SRAM_we_n <= 1'b1;
				row_counter <= 8'd0;
				CC_counter <= 8'd0;
			end
		end
		
		LEAD_IN_1: begin
			U_odd <= 32'd2048;
			V_odd <= 32'd2048;
			SRAM_address <= U_address;
			U_address <= U_address + 18'd1;
			SRAM_we_n <= 1'b1;
			row_counter <= row_counter + 1'b1;
			M1_state <= LEAD_IN_2;
			new_read <= 1'b1;
			CC_counter <= CC_counter + 8'd2;
		end
		
		LEAD_IN_2: begin
			SRAM_address <= U_address;
			U_address <= U_address + 18'd1;
			SRAM_we_n <= 1'b1;
			M1_state <= LEAD_IN_3;
		end
		
		LEAD_IN_3: begin
			SRAM_address <= U_address;
			U_address <= U_address + 18'd1;
			SRAM_we_n <= 1'b1;
			M1_state <= LEAD_IN_4;
		end
		
		LEAD_IN_4: begin
			SRAM_address <= V_address;
			V_address <= V_address + 18'd1;
			SRAM_we_n <= 1'b1;
			U_reg[0] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[1] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[2] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[3] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[4] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[5] <= {24'd0, SRAM_read_data[7:0]};
			M1_state <= LEAD_IN_5;
		end
		
		LEAD_IN_5: begin
			SRAM_address <= V_address;
			V_address <= V_address + 18'd1;
			SRAM_we_n <= 1'b1;
			U_reg[6] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[7] <= {24'd0, SRAM_read_data[7:0]};
			
			U_odd <= U_odd + result1 + (result2) + (result3) + result4;
			M1_state <= LEAD_IN_6;
			
		end
		
		LEAD_IN_6: begin
			SRAM_address <= V_address;
			V_address <= V_address + 18'd1;
			SRAM_we_n <= 1'b1;
			U_reg[8] <= {24'd0, SRAM_read_data[15:8]};
			U_reg[9] <= {24'd0, SRAM_read_data[7:0]};
			
			U_odd <= U_odd + result1 + result2 + result3 + (result4);
			M1_state <= LEAD_IN_7;

		end
		
		LEAD_IN_7: begin
			SRAM_address <= Y_address;
			Y_address <= Y_address + 18'd1;
			SRAM_we_n <= 1'b1;
			V_reg[0] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[1] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[2] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[3] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[4] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[5] <= {24'd0, SRAM_read_data[7:0]};
			
			U_odd <= U_odd + (result1) + result2;
			M1_state <= LEAD_IN_8;
				
		end
		
		LEAD_IN_8: begin
			SRAM_address <= U_address;
			U_address <= U_address + 18'd1;
			SRAM_we_n <= 1'b1;
			V_reg[6] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[7] <= {24'd0, SRAM_read_data[7:0]};
			V_odd <= V_odd + result1 + (result2);	
			M1_state <= LEAD_IN_9;
		end
		
		LEAD_IN_9: begin
			SRAM_address <= V_address;
			V_address <= V_address + 18'd1;
			SRAM_we_n <= 1'b1;
			V_reg[8] <= {24'd0, SRAM_read_data[15:8]};
			V_reg[9] <= {24'd0, SRAM_read_data[7:0]};
			V_odd <= V_odd + (result1) + result2 + result3 + result4;	
			if (U_odd[31] == 1'b1) 
				U_oddbuf <= 8'h00;
			else if (|U_odd[30:20]) 
				U_oddbuf <= 8'hFF;
			else 
				U_oddbuf <= U_odd[19:12];	
			M1_state <= LEAD_IN_10;
				
		end
		
		LEAD_IN_10: begin
			Y_even <= {24'd0, SRAM_read_data[15:8]};
			Y_odd <= {24'd0, SRAM_read_data[7:0]};
			V_odd <= V_odd + result1 + (result2) + (result3) + result4;
			M1_state <= LEAD_IN_11;
		end
		
		LEAD_IN_11: begin
			U_EvenOdd <= SRAM_read_data;
			R_even <= (result1) + (result2) + 32'd16384;
			G_even <= (result1) + (result3) + (result4) + 32'd16384;
			B_even <= (result1) + 32'd16384;
			M1_state <= LEAD_IN_12;
		end
		
		LEAD_IN_12: begin
			R_odd <= (result1) + 32'd16384;
			G_odd <= (result1) + 32'd16384;
			B_odd <= (result1) + 32'd16384;
			B_even <= B_even + (result2);
			V_EvenOdd <= SRAM_read_data;
			
			if (V_odd[31] == 1'b1) 
				V_oddbuf <= 8'h00;
			else if (|V_odd[30:20]) 
				V_oddbuf <= 8'hFF;
			else 
				V_oddbuf <= V_odd[19:12];
			M1_state <= LEAD_IN_13;
		end
		
		LEAD_IN_13: begin
			if (R_even[31] == 1'b1) begin
				if (G_even[31] == 1'b1)
					SRAM_write_data <= 16'h0000;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else
					SRAM_write_data <= {8'h00, G_even[22:15]};
			end else if (|R_even[30:23]) begin
				if (G_even[31] == 1'b1)
					SRAM_write_data <= 16'hFF00;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, G_even[22:15]};
			end else begin
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= {R_even[22:15], 8'h00};
				else if (|G_even[30:23]) 
					SRAM_write_data <= {R_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {R_even[22:15], G_even[22:15]};
			end
			
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			
			U_odd <= 32'd2048;
			V_odd <= 32'd2048;
		
			U_reg[8:0] <= U_reg[9:1];
			U_reg[9] <= {24'd0, U_EvenOdd[15:8]};
			
			V_reg[8:0] <= V_reg[9:1];
			V_reg[9] <= {24'd0, V_EvenOdd[15:8]};
			
			R_odd <= R_odd + (result1);
			G_odd <= G_odd + (result2) + (result3);
			B_odd <= B_odd + (result4);
			M1_state <= LEAD_IN_14;
		end
		
		LEAD_IN_14: begin
			U_odd <= U_odd + result1 + (result2) + (result3) + result4;
			SRAM_we_n <= 1'b1;
			M1_state <= LEAD_IN_15;
			
		end
		
		LEAD_IN_15: begin
			U_odd <= U_odd + result1 + result2 + result3 + (result4);
			M1_state <= LEAD_IN_16;
		end
		
		LEAD_IN_16: begin
			U_odd <= U_odd + (result1) + result2;
			V_odd <= V_odd + result3 + (result4);
			M1_state <= LEAD_IN_17;
			
		end
		
		LEAD_IN_17: begin
			V_odd <= V_odd + (result1) + result2 + result3 + result4;
			M1_state <= LEAD_IN_18;
			
		end
		
		LEAD_IN_18: begin
			V_odd <= V_odd + result1 + (result2) + (result3) + result4;
			
			if (U_odd[31] == 1'b1) 
				U_oddbuf <= 8'h00;
			else if (|U_odd[30:20]) 
				U_oddbuf <= 8'hFF;
			else 
				U_oddbuf <= U_odd[19:12];
			
			
			M1_state <= LEAD_IN_19;
			
		end
		
		LEAD_IN_19: begin
			M1_state <= LEAD_IN_20;
		end
		
		LEAD_IN_20: begin
		
			if (V_odd[31] == 1'b1) 
				V_oddbuf <= 8'h00;
			else if (|V_odd[30:20]) 
				V_oddbuf <= 8'hFF;
			else 
				V_oddbuf <= V_odd[19:12];
			
			
			U_odd <= 32'd2048;
			V_odd <= 32'd2048;
			
			U_reg[8:0] <= U_reg[9:1];
			U_reg[9] <= {24'd0, U_EvenOdd[7:0]};
			
			V_reg[8:0] <= V_reg[9:1];
			V_reg[9] <= {24'd0, V_EvenOdd[7:0]};
			M1_state <= COMMON_CASE_1;
			
		end
		
		COMMON_CASE_1: begin
			
			SRAM_address <= Y_address;
			Y_address <= Y_address + 18'd1;
			SRAM_we_n <= 1'b1;
			U_odd <= U_odd + result1 + (result2) + (result3) + result4;
			
			CC_counter <= CC_counter + 8'd2;
			M1_state <= COMMON_CASE_2;
		end	
		
		COMMON_CASE_2: begin
			
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			U_odd <= U_odd + result1 + result2 + result3 + (result4);
			
			if (B_even[31] == 1'b1) begin
			
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, R_odd[22:15]};
			end else if (|B_even[30:23]) begin
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else
					SRAM_write_data <= {8'hFF, R_odd[22:15]};
			end else begin
				
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= {B_even[22:15], 8'h00};
				else if (|R_odd[30:23]) 
					SRAM_write_data <= {B_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {B_even[22:15], R_odd[22:15]};
			end
			M1_state <= COMMON_CASE_3;
		end
			
		COMMON_CASE_3: begin
			
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			U_odd <= U_odd + (result1) + result2;
			V_odd <= V_odd + result3 + (result4);
			
			
			if (G_odd[31] == 1'b1) begin
				if (B_odd[31] == 1'b1)
					SRAM_write_data <= 16'h0000;
				else if (|B_odd[30:23])
					SRAM_write_data <= 16'h00FF;
				else
					SRAM_write_data <= {8'h00, B_odd[22:15]};
			end else if (|G_odd[30:23]) begin
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|B_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, B_odd[22:15]};
			end else begin
				
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= {G_odd[22:15], 8'h00};
				else if (|B_odd[30:23]) 
					SRAM_write_data <= {G_odd[22:15], 8'hFF};
				else 
					SRAM_write_data <= {G_odd[22:15], B_odd[22:15]};
			end
			
			M1_state <= COMMON_CASE_4;

		end
			
		COMMON_CASE_4: begin
			SRAM_we_n <= 1'b1;
			Y_even <= SRAM_read_data[15:8];
			Y_odd <= SRAM_read_data[7:0];
			V_odd <= V_odd + (result1) + result2 + result3 + result4;
			
			if(new_read && CC_counter < 8'd180) begin
				SRAM_we_n <= 1'b1;
				SRAM_address <= U_address;
				U_address <= U_address + 18'd1;
			end
			M1_state <= COMMON_CASE_5;
			
		end
			
		COMMON_CASE_5: begin
			V_odd <= V_odd + result1 + (result2) + (result3) + result4;
			
			if(new_read && CC_counter < 8'd180) begin
				SRAM_we_n <= 1'b1;
				SRAM_address <= V_address;
				V_address <= V_address + 18'd1;
			end
			M1_state <= COMMON_CASE_6;

		end
		COMMON_CASE_6: begin
			R_even <= (result1) + (result2) + 32'd16384;
			G_even <= (result1) + (result3) + (result4) + 32'd16384;
			B_even <= (result1) + 32'd16384;
			
			M1_state <= COMMON_CASE_7;
		end
			
		COMMON_CASE_7: begin
			R_odd <= (result1) + 32'd16384;
			G_odd <= (result1) + 32'd16384;
			B_odd <= (result1) + 32'd16384;
			
			B_even <= B_even + result2;
			
			if(new_read)
				U_EvenOdd <= SRAM_read_data[15:0]; 			
			
			M1_state <= COMMON_CASE_8;
		end
		
		COMMON_CASE_8: begin
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			U_odd <= 32'd2048;
			V_odd <= 32'd2048;
			
			if(new_read) begin
				V_EvenOdd <= SRAM_read_data[15:0];
				new_read <= ~new_read;
			end else
				new_read <= ~new_read;
			
			
			
			R_odd <= R_odd + (result1);
			G_odd <= G_odd + (result2) + (result3);
			B_odd <= B_odd + (result4);
			
			if (R_even[31] == 1'b1) begin
			
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, G_even[22:15]};
			end else if (|R_even[30:23]) begin
			
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, G_even[22:15]};	
			end else begin
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= {R_even[22:15], 8'h00};
				else if (|G_even[30:23]) 
					SRAM_write_data <= {R_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {R_even[22:15], G_even[22:15]};
			end
			
			
			for (i = 0; i < 9; i = i + 1)
				U_reg[i] <= U_reg[i+1];
			if(CC_counter >= 8'd180)
				U_reg[9] <= U_reg[9];
			else if(new_read)	
				U_reg[9] <= U_EvenOdd[15:8];
			else
				U_reg[9] <= U_EvenOdd[7:0];
				
			for (j = 0; j < 9; j = j + 1)
				V_reg[j] <= V_reg[j+1];
			if(CC_counter >= 8'd180)
				V_reg[9] <= V_reg[9];
			else if(new_read)
				V_reg[9] <= SRAM_read_data[15:8];
			else
				V_reg[9] <= V_EvenOdd[7:0];
			
							
			
			if (U_odd[31] == 1'b1) 
				U_oddbuf <= 8'h00;
			else if (|U_odd[30:20]) 
				U_oddbuf <= 8'hFF;
			else 
				U_oddbuf <= U_odd[19:12];
			
			if (V_odd[31] == 1'b1) 
				V_oddbuf <= 8'h00;
			else if (|V_odd[30:20]) 
				V_oddbuf <= 8'hFF;
			else 
				V_oddbuf <= V_odd[19:12];
			
			
			if(CC_counter == 8'd190)
				M1_state <= LEAD_OUT_1;
			else
				M1_state <= COMMON_CASE_1;
		end
		
		
		LEAD_OUT_1: begin
			SRAM_we_n <= 1'b1;
			SRAM_address <= Y_address;
			Y_address <= Y_address + 18'd1;
			CC_counter <= CC_counter + 8'd2;
			M1_state <= LEAD_OUT_2;
		end
		
		LEAD_OUT_2: begin
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 1'b1;
			SRAM_we_n <= 1'b0;
			
			if (B_even[31] == 1'b1) begin
			
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, R_odd[22:15]};
			end else if (|B_even[30:23]) begin
			
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, R_odd[22:15]};
	
			end else begin
				
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= {B_even[22:15], 8'h00};
				else if (|R_odd[30:23]) 
					SRAM_write_data <= {B_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {B_even[22:15], R_odd[22:15]};
			end
			M1_state <= LEAD_OUT_3;
			
		end
		
		LEAD_OUT_3: begin
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 1'b1;
			SRAM_we_n <= 1'b0;
			
			if (G_odd[31] == 1'b1) begin
			
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|B_odd[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, B_odd[22:15]};

			end else if (|G_odd[30:23]) begin
			
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|B_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, B_odd[22:15]};
			end else begin
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= {G_odd[22:15], 8'h00};
				else if (|B_odd[30:23]) 
					SRAM_write_data <= {G_odd[22:15], 8'hFF};
				else 
					SRAM_write_data <= {G_odd[22:15], B_odd[22:15]};
			end
			
			M1_state <= LEAD_OUT_4;
			
		end
		
		LEAD_OUT_4: begin
			SRAM_we_n <= 1'b1;
			Y_even <= {24'd0, SRAM_read_data[15:8]};
			Y_odd <= {24'd0, SRAM_read_data[7:0]};
		
			M1_state <= LEAD_OUT_5;
		end
		
		LEAD_OUT_5: begin
			R_even <= (result1) + (result2) + 32'd16384;
			G_even <= (result1) + (result3) + (result4) + 32'd16384;
			B_even <= (result1) + 32'd16384;
			M1_state <= LEAD_OUT_6;
		end
		
		LEAD_OUT_6: begin
			R_odd <= (result1) + 32'd16384 + (result2);
			G_odd <= (result1) + 32'd16384;
			B_odd <=(result1) + 32'd16384 + (result4);
			B_even <= B_even + (result3);
			M1_state <= LEAD_OUT_7;
		end
		
		LEAD_OUT_7: begin
			G_odd <= G_odd + (result1) + (result2);
			
			if (R_even[31] == 1'b1) begin
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, G_even[22:15]};
			end else if (|R_even[30:23]) begin
			
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|G_even[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, G_even[22:15]};
				
				
				
			end else begin
				
				if (G_even[31] == 1'b1) 
					SRAM_write_data <= {R_even[22:15], 8'h00};
				else if (|G_even[30:23]) 
					SRAM_write_data <= {R_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {R_even[22:15], G_even[22:15]};
				
			end
			
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			M1_state <= LEAD_OUT_8;
		end
		
		LEAD_OUT_8: begin
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			
			if (B_even[31] == 1'b1) begin
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, R_odd[22:15]};
			end else if (|B_even[30:23]) begin
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|R_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, R_odd[22:15]};
			end else begin
				if (R_odd[31] == 1'b1) 
					SRAM_write_data <= {B_even[22:15], 8'h00};
				else if (|R_odd[30:23]) 
					SRAM_write_data <= {B_even[22:15], 8'hFF};
				else 
					SRAM_write_data <= {B_even[22:15], R_odd[22:15]};
			end
			M1_state <= LEAD_OUT_9;
			
		end
		
		LEAD_OUT_9: begin
			SRAM_we_n <= 1'b0;
			SRAM_address <= RGB_address;
			RGB_address <= RGB_address + 18'd1;
			
			if (G_odd[31] == 1'b1) begin
			
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= 16'h0000;
				else if (|B_odd[30:23]) 
					SRAM_write_data <= 16'h00FF;
				else 
					SRAM_write_data <= {8'h00, B_odd[22:15]};
				
			end else if (|G_odd[30:23]) begin
			
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= 16'hFF00;
				else if (|B_odd[30:23]) 
					SRAM_write_data <= 16'hFFFF;
				else 
					SRAM_write_data <= {8'hFF, B_odd[22:15]};
			end else begin
				
				if (B_odd[31] == 1'b1) 
					SRAM_write_data <= {G_odd[22:15], 8'h00};
				else if (|B_odd[30:23]) 
					SRAM_write_data <= {G_odd[22:15], 8'hFF};
				else 
					SRAM_write_data <= {G_odd[22:15], B_odd[22:15]};
			end
			
			M1_state <= IDLE_WRITE_1;
			
		end
		
		IDLE_WRITE_1: begin
			SRAM_we_n <= 1'b1;
			M1_state <= IDLE_WRITE_2;
			
		end
		
		IDLE_WRITE_2: M1_state <= IDLE_WRITE_3;
		IDLE_WRITE_3: begin
			if (row_counter == 8'd144) begin
				done <= 1'b1;
				M1_state <= IDLE_BUFFER;
			end else begin
				done <= 1'b0;
				M1_state <= LEAD_IN_1;
				CC_counter <= 8'd0;
			end
			
		end
		
		IDLE_BUFFER: M1_state <= WAIT_IDLE;
		
		
		default: M1_state <= WAIT_IDLE;	
		endcase
	end
end



assign result_long1 = op1*op2;
assign result1 = result_long1[31:0];

assign result_long2 = op3*op4;
assign result2 = result_long2[31:0];

assign result_long3 = op5*op6;
assign result3 = result_long3[31:0];

assign result_long4 = op7*op8;
assign result4 = result_long4[31:0];

always_comb begin
	case(M1_state)
		
	LEAD_IN_5: begin
		op1 = 32'd36;
		op2 = U_reg[0];
		op3 = -32'sd98;
		op4 = U_reg[1];
		op5 = -32'sd233;
		op6 = U_reg[2];
		op7 = 32'd528;
		op8 = U_reg[3];
	end
	
	LEAD_IN_6: begin
		op1 = 32'd1815;
		op2 = U_reg[4];
		op3 = 32'd1815;
		op4 = U_reg[5];
		op5 = 32'd528;
		op6 = U_reg[6];
		op7 = -32'sd233;
		op8 = U_reg[7];
	end
	
	LEAD_IN_7: begin
		op1 = -32'sd98;
		op2 = U_reg[8];
		op3 = 32'd36;
		op4 = U_reg[9];
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	
	LEAD_IN_8: begin
		op1 = 32'd36;
		op2 = V_reg[0];
		op3 = -32'sd98;
		op4 = V_reg[1];
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	
	LEAD_IN_9: begin
		op1 = -32'sd233;
		op2 = V_reg[2];
		op3 = 32'd528;
		op4 = V_reg[3];
		op5 = 32'd1815;
		op6 = V_reg[4];
		op7 = 32'd1815;
		op8 = V_reg[5];
	end
	
	LEAD_IN_10: begin
		op1 = 32'd528;
		op2 = V_reg[6];
		op3 = -32'sd233;
		op4 = V_reg[7];
		op5 = -32'sd98;
		op6 = V_reg[8];
		op7 = 32'd36;
		op8 = V_reg[9];
	end
	
	LEAD_IN_11: begin
		op1 = 32'd38142;
		op2 = (Y_even - 32'd16);
		op3 = 32'd52298;
		op4 = (V_reg[0] - 32'd128);
		op5 = -32'sd12845;
		op6 = (U_reg[0] - 32'd128);
		op7 = -32'sd26640;
		op8 = (V_reg[0] - 32'd128);
	end
	
	LEAD_IN_12: begin
		op1 = 32'd38142;
		op2 = (Y_odd - 32'd16);
		op3 = 32'd66093;
		op4 = (U_reg[0] - 32'd128);
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	
	LEAD_IN_13: begin
		op1 = 32'd52298;
		op2 = ({24'd0,V_oddbuf} - 32'd128);
		op3 = -32'sd12845;
		op4 = ({24'd0,U_oddbuf} - 32'd128);
		op5 = -32'sd26640;
		op6 = ({24'd0,V_oddbuf} - 32'd128);
		op7 = 32'd66093;
		op8 = ({24'd0,U_oddbuf} - 32'd128);
	end
	
	LEAD_IN_14: begin
		op1 = 32'd36;
		op2 = U_reg[0];
		op3 = -32'sd98;
		op4 = U_reg[1];
		op5 = -32'sd233;
		op6 = U_reg[2];
		op7 = 32'd528;
		op8 = U_reg[3];
	end
	
	LEAD_IN_15: begin
		op1 = 32'd1815;
		op2 = U_reg[4];
		op3 = 32'd1815;
		op4 = U_reg[5];
		op5 = 32'd528;
		op6 = U_reg[6];
		op7 = -32'sd233;
		op8 = U_reg[7];
	end
	
	LEAD_IN_16: begin
		op1 = -32'sd98;
		op2 = U_reg[8];
		op3 = 32'd36;
		op4 = U_reg[9];
		op5 = 32'd36;
		op6 = V_reg[0];
		op7 = -32'sd98;
		op8 = V_reg[1];
	end
	
	LEAD_IN_17: begin
		op1 = -32'sd233;
		op2 = V_reg[2];
		op3 = 32'd528;
		op4 = V_reg[3];
		op5 = 32'd1815;
		op6 = V_reg[4];
		op7 = 32'd1815;
		op8 = V_reg[5];
	end
	
	LEAD_IN_18: begin
		op1 = 32'd528;
		op2 = V_reg[6];
		op3 = -32'sd233;
		op4 = V_reg[7];
		op5 = -32'sd98;
		op6 = V_reg[8];
		op7 = 32'd36;
		op8 = V_reg[9];
	end
		
	COMMON_CASE_1: begin
		op1 = 32'd36;
		op2 = U_reg[0];
		op3 = -32'sd98;
		op4 = U_reg[1];
		op5 = -32'sd233;
		op6 = U_reg[2];
		op7 = 32'd528;
		op8 = U_reg[3];
	end
	
	COMMON_CASE_2: begin
		op1 = 32'd1815;
		op2 = U_reg[4];
		op3 = 32'd1815;
		op4 = U_reg[5];
		op5 = 32'd528;
		op6 = U_reg[6];
		op7 = -32'sd233;
		op8 = U_reg[7];
	end
	
	COMMON_CASE_3: begin
		op1 = -32'sd98;
		op2 = U_reg[8];
		op3 = 32'd36;
		op4 = U_reg[9];
		op5 = 32'd36;
		op6 = V_reg[0];
		op7 = -32'sd98;
		op8 = V_reg[1];
	end
	
	COMMON_CASE_4: begin
		op1 = -32'sd233;
		op2 = V_reg[2];
		op3 = 32'd528;
		op4 = V_reg[3];
		op5 = 32'd1815;
		op6 = V_reg[4];
		op7 = 32'd1815;
		op8 = V_reg[5];
	end
	
	COMMON_CASE_5: begin
		op1 = 32'd528;
		op2 = V_reg[6];
		op3 = -32'sd233;
		op4 = V_reg[7];
		op5 = -32'sd98;
		op6 = V_reg[8];
		op7 = 32'd36;
		op8 = V_reg[9];
	end
	
	COMMON_CASE_6: begin
		op1 = 32'd38142;
		op2 = (Y_even - 32'd16);
		op3 = 32'd52298;
		op4 = (V_reg[3] - 32'd128);
		op5 = -32'sd12845;
		op6 = (U_reg[3] - 32'd128);
		op7 = -32'sd26640;
		op8 = (V_reg[3] - 32'd128);
	end
	
	COMMON_CASE_7: begin
		op1 = 32'd38142;
		op2 = (Y_odd - 32'd16);
		op3 = 32'd66093;
		op4 = (U_reg[3] - 32'd128);
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	
	COMMON_CASE_8: begin
		op1 = 32'd52298;
		op2 = ({24'd0,V_oddbuf} - 32'd128);
		op3 = -32'sd12845;
		op4 = ({24'd0,U_oddbuf} - 32'd128);
		op5 = -32'sd26640;
		op6 = ({24'd0,V_oddbuf} - 32'd128);
		op7 = 32'd66093;
		op8 = ({24'd0,U_oddbuf} - 32'd128);
	end
	
	LEAD_OUT_5: begin
		op1 = 32'd38142;
		op2 = (Y_even - 32'd16);
		op3 = 32'd52298;
		op4 = (V_reg[3] - 32'd128);
		op5 = -32'sd12845;
		op6 = (U_reg[3] - 32'd128);
		op7 = -32'sd26640;
		op8 = (V_reg[3] - 32'd128);
	end
		
	LEAD_OUT_6: begin
		op1 = 32'd38142;
		op2 = (Y_odd - 32'd16);
		op3 = 32'd52298;
		op4 = ({24'd0,V_oddbuf} - 32'd128);
		op5 = 32'd66093;
		op6 = (U_reg[3] - 32'd128);
		op7 = 32'd66093;
		op8 = ({24'd0,U_oddbuf} - 32'd128); 
	end
	
	LEAD_OUT_7: begin
		op1 = -32'sd12845;
		op2 = ({24'd0,U_oddbuf} - 32'd128);
		op3 = -32'sd26640;
		op4 = ({24'd0,V_oddbuf} - 32'd128);
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	
	default: begin
		op1 = 32'd0;
		op2 = 32'd0;
		op3 = 32'd0;
		op4 = 32'd0;
		op5 = 32'd0;
		op6 = 32'd0;
		op7 = 32'd0;
		op8 = 32'd0;
	end
	endcase
	
end

endmodule
