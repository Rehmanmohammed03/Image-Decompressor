
`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This module monitors the data from UART
// It also assembles and writes the data into the SRAM
module MILESTONE_TWO (
   input  logic		Clock,
   input  logic		Resetn, 

   input  logic		start2,
	input logic [15:0] SRAM_read_data,
   
   output logic [17:0]	SRAM_address,
   output logic [15:0]	SRAM_write_data,
   output logic		SRAM_we_n,
	output logic done2
);



logic[7:0] SP_addr_a, SP_addr_b;
logic[31:0] SP_wdata_a, SP_wdata_b;
logic SP_wren_a, SP_wren_b;
logic[31:0] SP_rdata_a, SP_rdata_b;

logic[7:0] T_addr_a, T_addr_b;
logic[31:0] T_wdata_a, T_wdata_b;
logic T_wren_a, T_wren_b;
logic[31:0] T_rdata_a, T_rdata_b;

logic[7:0] C_addr_a, C_addr_b;
logic[31:0] C_wdata_a, C_wdata_b;
logic C_wren_a, C_wren_b;
logic[31:0] C_rdata_a, C_rdata_b;

logic[7:0] S_addr_a, S_addr_b;
logic[31:0] S_wdata_a, S_wdata_b;
logic S_wren_a, S_wren_b;
logic[31:0] S_rdata_a, S_rdata_b;


dual_port_RAM 
#(
	.MIF_FILE("../rtl/Mif1.mif")
)
C_matrix
(
	.address_a(C_addr_a),
	.address_b(C_addr_b),
	.clock(Clock),
	.data_a(C_wdata_a),
	.data_b(C_wdata_b),
	.wren_a(C_wren_a),
	.wren_b(C_wren_b),
	.q_a(C_rdata_a),
	.q_b(C_rdata_b)
);

dual_port_RAM S_matrix (

	.address_a(S_addr_a),
	.address_b(S_addr_b),
	.clock(Clock),
	.data_a(S_wdata_a),
	.data_b(S_wdata_b),
	.wren_a(S_wren_a),
	.wren_b(S_wren_b),
	.q_a(S_rdata_a),
	.q_b(S_rdata_b)

);

dual_port_RAM SP_matrix (

	.address_a(SP_addr_a),
	.address_b(SP_addr_b),
	.clock(Clock),
	.data_a(SP_wdata_a),
	.data_b(SP_wdata_b),
	.wren_a(SP_wren_a),
	.wren_b(SP_wren_b),
	.q_a(SP_rdata_a),
	.q_b(SP_rdata_b)

);

dual_port_RAM T_matrix (

	.address_a(T_addr_a),
	.address_b(T_addr_b),
	.clock(Clock),
	.data_a(T_wdata_a),
	.data_b(T_wdata_b),
	.wren_a(T_wren_a),
	.wren_b(T_wren_b),
	.q_a(T_rdata_a),
	.q_b(T_rdata_b)

);


logic [31:0] op1,op2,op3,op4,op5,op6;
logic [63:0] result_long1,result_long2,result_long3;
logic [31:0] result1,result2,result3;



logic addr_gen_en_r;
plane_type plane;
logic [7:0] samplecount;
logic [3:0] columnblock;
logic [4:0] rowblock;


//FETCH S' INSTANTIATIONS START
logic SRAM_we_nF;
logic [17:0] SRAM_addressF;
logic done_fetch;

logic[7:0] SP_addr_a_FS;
logic[31:0] SP_wdata_a_FS;
logic SP_wren_a_FS;
logic start_fetch;


FETCH_STATE_TYPE FETCH_state;
logic[7:0] SP_write_count;
//END

// COMPUTE T Instantiations 


COMPUTE_T_STATE_TYPE COMPUTE_T_state;
logic[7:0] C_addr_counter;
logic[7:0] SP_addr_counter;


logic[7:0] T_addr_a_CT, T_addr_b_CT;
logic[31:0] T_wdata_a_CT, T_wdata_b_CT;
logic T_wren_a_CT, T_wren_b_CT;




logic[7:0] C_addr_a_CT, C_addr_b_CT;

logic C_wren_a_CT, C_wren_b_CT;



logic start_CT;
logic done_CT;


logic[31:0] T_value1;
logic[31:0] T_value2;
logic[31:0] T_value3;

logic[7:0] SP_addr_a_CT;
logic SP_wren_a_CT;

logic[7:0] T_counter;

logic buf_flag;

logic read_C_flag;

logic[7:0] SP_addr_buffer;


//WRITE S INSTANTIATIONS START
logic SRAM_we_nWS;
logic [15:0] SRAM_write_dataWS;
logic [17:0] SRAM_addressWS;
logic start_write_s;
logic done_write_s;
WRITE_S_STATE_TYPE WRITE_S_state;
logic[7:0] S_read_count;

logic[7:0] S_addr_a_WS, S_addr_b_WS;
logic S_wren_a_WS, S_wren_b_WS;



//END


//COMPUTE S INSTANTIATIONS START
COMPUTE_S_STATE COMPUTE_S_state;
logic[7:0] T_addr_a_CS;

logic T_wren_a_CS;


logic[7:0] C_addr_a_CS, C_addr_b_CS;

logic C_wren_a_CS, C_wren_b_CS;

logic[7:0] T_SCOMP_counter, C_SCOMP_counter,S_SCOMP_counter;

logic[7:0] S_addr_a_CS, S_addr_b_CS;
logic[31:0] S_wdata_a_CS, S_wdata_b_CS;
logic S_wren_a_CS, S_wren_b_CS;


logic[31:0] S_buff[2:0];
logic cflag;
logic[4:0] calc_count;
logic[2:0] tricount;
logic[4:0] rowcount;
logic start_cs;
logic done_cs;
//END




logic addr_gen_en_w;
logic [7:0] samplecount_w;
logic [3:0] columnblock_w;
logic [4:0] rowblock_w;





logic[7:0] Y_block_counter, UV_block_counter;
logic plane_U_done, plane_V_done, plane_Y_done;


M2_TOP_STATE_TYPE M2_Top_State;
logic [1:0]fetch_armed;

// TOP FSM
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	
	Y_block_counter <= 8'd0;
	UV_block_counter <= 8'd0;
	M2_Top_State <= M2_WAIT;
	plane_U_done <= 1'b0;
	plane_V_done <= 1'b0;
	plane_Y_done <= 1'b0;
	fetch_armed <= 2'd2;
	done2 <= 1'b0;
	start_fetch <= 1'b0;
	start_CT <= 1'b0;
	start_cs <= 1'b0;
	start_write_s <= 1'b0;
	plane <= Y;
	end else begin
		case(M2_Top_State)
		
		M2_WAIT: begin
			Y_block_counter <= 8'd0;
			UV_block_counter <= 8'd0;
		
			if(start2)
				M2_Top_State <= PLANE_SELECT;
			else
				M2_Top_State <= M2_WAIT;
		
		end
		
		PLANE_SELECT: begin
		
			if(plane_V_done) begin
				M2_Top_State <= M2_WAIT;
				done2 <= 1'b1;
				//we're done
			end else if(plane_U_done) begin
				plane <= V;
				M2_Top_State <= M2_LEAD_IN_1;
				// start lead in
			end else if(plane_Y_done) begin
				plane <= U;
				M2_Top_State <= M2_LEAD_IN_1;
				// start lead in
			end else begin
				plane <= Y;
				M2_Top_State <= M2_LEAD_IN_1;
			end
				// start lead in
		end
		
		M2_LEAD_IN_1: begin
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_fetch <= 1'b1;
			
			if (done_fetch && (fetch_armed == 2'd0)) begin
				start_fetch <= 1'b0;
				fetch_armed <= 2'd2;
				M2_Top_State <= M2_LEAD_IN_2;
			end	
			
		end
			
			
		M2_LEAD_IN_2: begin
		
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_CT <= 1'b1;
			
			if(done_CT && (fetch_armed == 2'd0)) begin
				start_CT <= 1'b0;
				fetch_armed <= 2'd2;
				M2_Top_State <= MEGA_STATE_1;
			end
				
			
		end
			
		MEGA_STATE_1: begin
		
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_cs <= 1'b1;
			start_fetch <= 1'b1;
			
			if(done_cs && (fetch_armed == 2'd0))
				start_cs <= 1'b0;
			if(done_fetch && (fetch_armed == 2'd0))
				start_fetch <= 1'b0;
				
			if (done_cs && done_fetch && (fetch_armed == 2'd0))begin
				fetch_armed <= 2'd2;
				M2_Top_State <= MEGA_STATE_2;
			end
		end
			
		MEGA_STATE_2: begin
			
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_write_s <= 1'b1;
			start_CT <= 1'b1;
			
			if(done_write_s && (fetch_armed == 2'd0))
				start_write_s <= 1'b0;
			if(done_CT && (fetch_armed == 2'd0))
				start_CT <= 1'b0;
			if (done_CT && done_write_s && (fetch_armed == 2'd0))
				if(plane == Y) begin
					if(Y_block_counter == 8'd106) begin
						fetch_armed <= 2'd2;
						M2_Top_State <= M2_LEAD_OUT_1;
						plane_Y_done <= 1'b1;
					end else begin
						Y_block_counter <= Y_block_counter + 8'd1;
						fetch_armed <= 2'd2;
						M2_Top_State <= MEGA_STATE_1;
					end
				end else begin
					if(UV_block_counter == 8'd214) begin
						if(plane == U)
							plane_U_done <= 1'b1;
						else if(plane == V)
							plane_V_done <= 1'b1;
						M2_Top_State <= M2_LEAD_OUT_1;
						UV_block_counter <= 8'd0;	
						fetch_armed <= 2'd2;

					end else begin
						UV_block_counter <= UV_block_counter + 8'd1;
						fetch_armed <= 2'd2;
						M2_Top_State <= MEGA_STATE_1;
					end
				end
			
		
		
		end
		M2_LEAD_OUT_1: begin
		
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_cs <= 1'b1;
				
			if(done_cs && (fetch_armed == 2'd0)) begin
				start_cs <= 1'b0;
				fetch_armed <= 2'd2;

				M2_Top_State <= M2_LEAD_OUT_2;
			end
			
		end
		
		M2_LEAD_OUT_2: begin
			
			if (fetch_armed > 2'd0) 
				fetch_armed <= fetch_armed - 2'd1;
				
			start_write_s <= 1'b1;
				
			if(done_write_s && (fetch_armed == 2'd0)) begin
				start_write_s <= 1'b0;
				fetch_armed <= 2'd2;

				M2_Top_State <= PLANE_SELECT;
			end
			
		end 	
		
		default: begin
			M2_Top_State <= M2_WAIT;
		
		end 
		endcase
	end
	
end



assign C_addr_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? C_addr_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? C_addr_a_CT: 8'd0;
assign C_addr_b = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? C_addr_b_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? C_addr_b_CT: 8'd0;
assign C_wren_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? C_wren_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? C_wren_a_CT: 1'd0;
assign C_wren_b = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? C_wren_b_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? C_wren_b_CT: 1'd0;

assign T_addr_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? T_addr_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_addr_a_CT: 8'd0;
assign T_addr_b = (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_addr_b_CT: 8'd0;
assign T_wren_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? T_wren_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_wren_a_CT: 1'd0;
assign T_wren_b = (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_wren_b_CT: 1'd0;


assign T_wdata_a = (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_wdata_a_CT: 32'd0;
assign T_wdata_b = (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? T_wdata_b_CT: 32'd0;


assign S_addr_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_addr_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? S_addr_a_WS: 8'd0;
assign S_addr_b = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_addr_b_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? S_addr_b_WS: 8'd0;
assign S_wren_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_wren_a_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? S_wren_a_WS: 1'd0;
assign S_wren_b = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_wren_b_CS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? S_wren_b_WS: 1'd0;


assign S_wdata_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_wdata_a_CS: 32'd0;
assign S_wdata_b = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_OUT_1) ? S_wdata_b_CS: 32'd0;

assign SRAM_address = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_IN_1) ? SRAM_addressF: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? SRAM_addressWS: 18'd0;
assign SRAM_we_n = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_IN_1) ? SRAM_we_nF: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? SRAM_we_nWS: 1'd1;
assign SRAM_write_data = (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_OUT_2) ? SRAM_write_dataWS: 16'd0;



assign SP_addr_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_IN_1) ? SP_addr_a_FS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? SP_addr_a_CT: 8'd0;
assign SP_wren_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_IN_1) ? SP_wren_a_FS: (M2_Top_State == MEGA_STATE_2 || M2_Top_State == M2_LEAD_IN_2) ? SP_wren_a_CT: 1'd0;

assign SP_wdata_a = (M2_Top_State == MEGA_STATE_1 || M2_Top_State == M2_LEAD_IN_1) ? SP_wdata_a_FS: 32'd0;




//Address Generator for Y,U,V [SHARED]
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	
		samplecount[7:0] <= 8'd0;
		columnblock [3:0] <= 4'd0;
		rowblock[4:0] <= 5'd0;
		
	end else begin				
		case (plane)
		Y: begin
			
			if (addr_gen_en_r) begin
				samplecount <= samplecount + 8'd1;
			end
			
			if ((samplecount == 8'd255) && addr_gen_en_r) begin
				
				if (columnblock == 4'd11) begin
					columnblock <= 4'd0;
				
				end else begin
					columnblock <= columnblock + 4'd1;
				end
			end
			
			if ((samplecount == 8'd255) && addr_gen_en_r && (columnblock == 4'd11)) begin
				
				if (rowblock == 5'd8) begin
					rowblock <= 5'd0;
				
				end else begin
					rowblock <= rowblock + 5'd1;
				end
			end
			
		end
	
		U: begin
			if (addr_gen_en_r) begin
				if (samplecount == 8'd63) begin
					samplecount <= 8'd0;
				end else begin
					samplecount <= samplecount + 8'd1;
				end
			end
			
			if ((samplecount == 8'd63) && addr_gen_en_r) begin
				
				if (columnblock == 4'd11) begin
					columnblock <= 4'd0;
				
				end else begin
					columnblock <= columnblock + 4'd1;
				end
			end
			
			if ((samplecount == 8'd63) && addr_gen_en_r && (columnblock == 4'd11)) begin
				
				if (rowblock == 5'd17) begin
					rowblock <= 5'd0;
				
				end else begin
					rowblock <= rowblock + 5'd1;
				end
			end
			
		end
		
		V: begin
			if (addr_gen_en_r) begin
				if (samplecount == 8'd63) begin
					samplecount <= 8'd0;
				end else begin
					samplecount <= samplecount + 8'd1;
				end
			end
			
			if ((samplecount == 8'd63) && addr_gen_en_r) begin
				
				if (columnblock == 4'd11) begin
					columnblock <= 4'd0;
				
				end else begin
					columnblock <= columnblock + 4'd1;
				end
			end
			
			if ((samplecount == 8'd63) && addr_gen_en_r && (columnblock == 4'd11)) begin
				
				if (rowblock == 5'd17) begin
					rowblock <= 5'd0;
				
				end else begin
					rowblock <= rowblock + 5'd1;
				end
			end
			
		end
			
			
		endcase
		
	end
end

////SRAM Address Generator for WRITING Y,U,V [SHARED]
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
	
		samplecount_w[7:0] <= 8'd0;
		columnblock_w[3:0] <= 4'd0;
		rowblock_w[4:0] <= 5'd0;
		
	end else begin				
		case (plane)
		Y: begin
			
			if (addr_gen_en_w) begin
				if (samplecount_w == 8'd127) begin
					samplecount_w <= 8'd0;
				end else begin
					samplecount_w <= samplecount_w + 8'd1;
				end
			end
			
			if ((samplecount_w == 8'd127) && addr_gen_en_w) begin
				
				if (columnblock_w == 4'd11) begin
					columnblock_w <= 4'd0;
				
				end else begin
					columnblock_w <= columnblock_w + 4'd1;
				end
			end
			
			if ((samplecount_w == 8'd127) && addr_gen_en_w && (columnblock_w == 4'd11)) begin
				
				if (rowblock_w == 5'd8) begin
					rowblock_w <= 5'd0;
				
				end else begin
					rowblock_w <= rowblock_w + 5'd1;
				end
			end
			
		end
	
		U: begin
			if (addr_gen_en_w) begin
				if (samplecount_w == 8'd31) begin
					samplecount_w <= 8'd0;
				end else begin
					samplecount_w <= samplecount_w + 8'd1;
				end
			end
			
			if ((samplecount_w == 8'd31) && addr_gen_en_w) begin
				
				if (columnblock_w == 4'd11) begin
					columnblock_w <= 4'd0;
				
				end else begin
					columnblock_w <= columnblock_w + 4'd1;
				end
			end
			
			if ((samplecount_w == 8'd31) && addr_gen_en_w && (columnblock_w == 4'd11)) begin
				
				if (rowblock_w == 5'd17) begin
					rowblock_w <= 5'd0;
				
				end else begin
					rowblock_w <= rowblock_w + 5'd1;
				end
			end
			
		end
		
		V: begin
			if (addr_gen_en_w) begin
				if (samplecount_w == 8'd31) begin
					samplecount_w <= 8'd0;
				end else begin
					samplecount_w <= samplecount_w + 8'd1;
				end
			end
			
			if ((samplecount_w == 8'd31) && addr_gen_en_w) begin
				
				if (columnblock_w == 4'd11) begin
					columnblock_w <= 4'd0;
				
				end else begin
					columnblock_w <= columnblock_w + 4'd1;
				end
			end
			
			if ((samplecount_w == 8'd31) && addr_gen_en_w && (columnblock_w == 4'd11)) begin
				
				if (rowblock_w == 5'd17) begin
					rowblock_w <= 5'd0;
				
				end else begin
					rowblock_w <= rowblock_w + 5'd1;
				end
			end
			
		end
			
		endcase
		
	end
end


//END




//FETCH S' Y ADDRESSING LOGIC START
logic[17:0] Y_FETCH_ADDRESS;

assign Y_FETCH_ADDRESS = 18'd27648 + {3'd0,rowblock[3:0],samplecount[7:4],7'd0} + {4'd0,rowblock[3:0],samplecount[7:4],6'd0} + {10'd0,columnblock,samplecount[3:0]};

//END

//FETCH S' U ADDRESSING LOGIC START
logic [17:0] U_FETCH_ADDRESS;

assign U_FETCH_ADDRESS = 18'd55296 + {4'd0,rowblock[4:0],samplecount[5:3],6'd0} + {5'd0,rowblock[4:0],samplecount[5:3],5'd0} + {11'd0,columnblock,samplecount[2:0]};
//END

//FETCH S' V ADDRESSING LOGIC START
logic [17:0] V_FETCH_ADDRESS;

assign V_FETCH_ADDRESS = 18'd69120 + {4'd0,rowblock[4:0],samplecount[5:3],6'd0} + {5'd0,rowblock[4:0],samplecount[5:3],5'd0} + {11'd0,columnblock,samplecount[2:0]};
//END


assign addr_gen_en_r = (FETCH_state == DUMMYF_START_1 || FETCH_state == DUMMYF_START_2 || FETCH_state == DUMMYF_START_3 ||FETCH_state == BIG_FETCH) ? 1'b1: 1'b0;
assign addr_gen_en_w = (WRITE_S_state == BIG_WS || WRITE_S_state == DUMMY_WS_END_1 || WRITE_S_state == DUMMY_WS_END_2) ? 1'b1: 1'b0;




//FETCH S' FSM
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		SRAM_we_nF <= 1'b1;
		SRAM_addressF <= 18'd0;
		FETCH_state <= WAIT_FETCH;
		SP_addr_a_FS <= 8'd0;
		SP_wdata_a_FS <= 32'd0;
		SP_wren_a_FS <= 1'b0;
		SP_write_count <= 8'd0;
		done_fetch <= 1'b0;
	end else begin				
		case (FETCH_state)
		
		WAIT_FETCH: begin
			if (start_fetch) begin
				FETCH_state <= DUMMYF_START_1;
				done_fetch <= 1'b0;
				
			end	
		end
		DUMMYF_START_1: begin
			//keep enabled on
			SRAM_we_nF <= 1'b1;
			SRAM_addressF <= (plane == Y) ? Y_FETCH_ADDRESS : (plane == U) ? U_FETCH_ADDRESS : V_FETCH_ADDRESS;
			FETCH_state <= DUMMYF_START_2;
		end
		
		DUMMYF_START_2: begin
			//keep Yaddress counter enable on
			SRAM_we_nF <= 1'b1;
			SRAM_addressF <= (plane == Y) ? Y_FETCH_ADDRESS : (plane == U) ? U_FETCH_ADDRESS : V_FETCH_ADDRESS;
			FETCH_state <= DUMMYF_START_3;
		end
		
		DUMMYF_START_3: begin
			//keep Yaddress counter enable on
			SRAM_we_nF <= 1'b1;
			SRAM_addressF <= (plane == Y) ? Y_FETCH_ADDRESS : (plane == U) ? U_FETCH_ADDRESS : V_FETCH_ADDRESS;
			FETCH_state <= BIG_FETCH;
		end
		
		
		BIG_FETCH: begin
			//keep Yaddress counter enable on
			SRAM_we_nF <= 1'b1;
			SRAM_addressF <= (plane == Y) ? Y_FETCH_ADDRESS : (plane == U) ? U_FETCH_ADDRESS : V_FETCH_ADDRESS;
			SP_addr_a_FS <= SP_write_count;
			SP_write_count <= SP_write_count + 8'd1;
			SP_wdata_a_FS <= {{16{SRAM_read_data[15]}},SRAM_read_data};
			SP_wren_a_FS <= 1'b1;
			if (plane == Y) begin
				if (SP_write_count == 8'd252) 
					FETCH_state <= DUMMYF_END_1;
			end else begin
				if (SP_write_count == 8'd60)
					FETCH_state <= DUMMYF_END_1;
			end
			
		end
		
		DUMMYF_END_1: begin
			//keep Yaddress counter enable OFF
			SP_addr_a_FS <= SP_write_count;
			SP_write_count <= SP_write_count + 8'd1;
			SP_wdata_a_FS <= {{16{SRAM_read_data[15]}},SRAM_read_data};
			SP_wren_a_FS <= 1'b1;
			FETCH_state <= DUMMYF_END_2;
		end
		
		DUMMYF_END_2: begin
			//keep Yaddress counter enable OFF
			SP_addr_a_FS <= SP_write_count;
			SP_write_count <= SP_write_count + 8'd1;
			SP_wdata_a_FS <= {{16{SRAM_read_data[15]}},SRAM_read_data};
			SP_wren_a_FS <= 1'b1;
			FETCH_state <= DUMMYF_END_3;
		end
		
		DUMMYF_END_3: begin
			//keep Yaddress counter enable OFF
			SP_addr_a_FS <= SP_write_count;
			SP_wdata_a_FS <= {{16{SRAM_read_data[15]}},SRAM_read_data};
			SP_wren_a_FS <= 1'b1;
			FETCH_state <= DUMMYF_END_4;
		end
		
		DUMMYF_END_4: begin
			//keep Yaddress counter enable OFF
			SP_wren_a_FS <= 1'b0;
			SP_write_count <= 8'd0;
			FETCH_state <= DUMMYF_END_5;
		end
		
		DUMMYF_END_5: begin
			//keep Yaddress counter enable OFF
			done_fetch <= 1'b1;
			FETCH_state <= FS_BUFFER_STATE;
		end
		
		
		FS_BUFFER_STATE:
			FETCH_state <= WAIT_FETCH;
		
		default:
			FETCH_state <= WAIT_FETCH;
			
			
		endcase
	end
end



// COMPUTE T FM

always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		COMPUTE_T_state <= CT_WAIT;
		T_addr_a_CT <= 8'd0;
		T_addr_b_CT <= 8'd0;
		T_wdata_a_CT <= 32'd0;
		T_wdata_b_CT <= 32'd0;
		T_wren_a_CT <= 1'b0;
		T_wren_b_CT <= 1'b0;
		done_CT <= 1'b0;
		C_addr_counter <= 8'd0;
		SP_addr_counter <= 8'd0;
		T_value1 <= 32'd0;
		T_value2 <= 32'd0;
		T_value3 <= 32'd0;
		T_counter <= 8'd0;
		read_C_flag <= 1'b0;
		C_addr_a_CT <= 8'd0;
		C_addr_b_CT <= 8'd0;
		C_wren_a_CT <= 1'd0;
		C_wren_b_CT <= 1'd0;
		
		SP_addr_a_CT <= 8'd0;
		SP_wren_a_CT <= 1'd0;
		SP_addr_buffer <= 8'd0;

	end else begin
		
		SP_addr_buffer <= SP_addr_buffer;

		case (COMPUTE_T_state)
		
		
		CT_WAIT: begin
		
			if(start_CT)
				COMPUTE_T_state <= CT_DUMMY_IN;
			else
				COMPUTE_T_state <= CT_WAIT;
			
			read_C_flag <= 1'b0;
			C_addr_counter <= 8'd0;
			T_counter <= 8'd0;
			SP_addr_counter <= 8'd0;
			SP_addr_buffer <= 8'd0;
			T_value1 <= 32'd0;
			T_value2 <= 32'd0;
			T_value3 <= 32'd0;
			
		end
		
		CT_DUMMY_IN: begin
		
			if(plane == Y) begin
				C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]}} + {3'b000, {C_addr_counter[7:4]}};
				C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]}} + {3'b000, {C_addr_counter[7:4]}} + 8'd1;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				SP_addr_counter <= SP_addr_counter + 8'd1;
				
				C_addr_counter <= C_addr_counter + 8'd1;
				
				COMPUTE_T_state <= CT_DUMMY_IN_2;
			end else begin
				
				C_addr_a_CT <= {3'b0,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
				C_addr_b_CT <= {3'b0,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				
				SP_addr_counter <= SP_addr_counter + 8'd1;
				
				C_addr_counter <= C_addr_counter + 8'd1;
				
				
				COMPUTE_T_state <= CT_DUMMY_IN_2;
			end

			
			
		end
		
		CT_DUMMY_IN_2: begin
		
			if(plane == Y) begin
				C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]}} + {3'b000, {C_addr_counter[7:4]}};
				C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]}} + {3'b000, {C_addr_counter[7:4]}} + 8'd1;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				SP_addr_counter <= SP_addr_counter + 8'd1;
				
				C_addr_counter <= C_addr_counter + 8'd1;
				
				COMPUTE_T_state <= COMMON_1;
			end else begin
				
				C_addr_a_CT <= {3'b0,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
				C_addr_b_CT <= {3'b0,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				
				SP_addr_counter <= SP_addr_counter + 8'd1;
				
				C_addr_counter <= C_addr_counter + 8'd1;
				
				
				COMPUTE_T_state <= COMMON_1;
			end

			
			
		end
		
		
		COMMON_1: begin		
			
			
			if(plane == Y) begin
				
				
											  
				if(C_addr_counter > 8'b01010000) begin
					T_value1 <= T_value1 + result1;
 					
					if(C_addr_counter == 8'b01100001)begin
					
						C_addr_counter <= 8'd0;
						SP_addr_buffer <= SP_addr_buffer + 8'd16;
						COMPUTE_T_state <= CT_WRITE_LAST;
						
					end else begin
						
						C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
						C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;
						C_wren_a_CT <= 1'b0;
						C_wren_b_CT <= 1'b0;
						
						C_addr_counter <= C_addr_counter + 8'd1;
						SP_addr_counter <= SP_addr_counter + 8'd1;
						
						SP_addr_a_CT <= SP_addr_counter;
						SP_wren_a_CT <= 1'b0;
						
						COMPUTE_T_state <= COMMON_1;
						
					end
											

				end else if(C_addr_counter[3:0] == 4'b0000) begin
										
					
					T_value1 <= T_value1 + result1;
					T_value2 <= T_value2 + result2;
					T_value3 <= T_value3 + result3;
					
										
					COMPUTE_T_state <= CT_WRITE_BUFFER;
					
					
										
				end else begin
					T_value1 <= T_value1 + result1;
					T_value2 <= T_value2 + result2;
					T_value3 <= T_value3 + result3;
					
					C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
					C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;
					C_wren_a_CT <= 1'b0;
					C_wren_b_CT <= 1'b0;
					
					C_addr_counter <= C_addr_counter + 8'd1;
					SP_addr_counter <= SP_addr_counter + 8'd1;
					
					SP_addr_a_CT <= SP_addr_counter;
					SP_wren_a_CT <= 1'b0;
					
					
					COMPUTE_T_state <= COMMON_1;

				end
							
				
					
			end else if(plane == U || plane == V) begin
			
				if(C_addr_counter > 8'b00010000) begin
					T_value1 <= T_value1 + result1;
					T_value2 <= T_value2 + result2;
 					
					if(C_addr_counter == 8'b00011001) begin
					
						C_addr_counter <= 8'd0;
						SP_addr_buffer <= SP_addr_buffer + 8'd8;
						COMPUTE_T_state <= CT_WRITE_LAST;
						
					end else begin
						
						C_addr_a_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
						C_addr_b_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
						C_wren_a_CT <= 1'b0;
						C_wren_b_CT <= 1'b0;
						
						C_addr_counter <= C_addr_counter + 8'd1;
						SP_addr_counter <= SP_addr_counter + 8'd1;
						
						SP_addr_a_CT <= SP_addr_counter;
						SP_wren_a_CT <= 1'b0;
						
						COMPUTE_T_state <= COMMON_1;
						
					end
											

				end else if(C_addr_counter[2:0] == 3'b000) begin
										
					
					T_value1 <= T_value1 + result1;
					T_value2 <= T_value2 + result2;
					T_value3 <= T_value3 + result3;
					
										
					COMPUTE_T_state <= CT_WRITE_BUFFER;
					
					
										
				end else begin
					T_value1 <= T_value1 + result1;
					T_value2 <= T_value2 + result2;
					T_value3 <= T_value3 + result3;
					
					C_addr_a_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
					C_addr_b_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
					C_wren_a_CT <= 1'b0;
					C_wren_b_CT <= 1'b0;
					
					C_addr_counter <= C_addr_counter + 8'd1;
					SP_addr_counter <= SP_addr_counter + 8'd1;
					
					SP_addr_a_CT <= SP_addr_counter;
					SP_wren_a_CT <= 1'b0;
					
					COMPUTE_T_state <= COMMON_1;

					

				end
			end
			
			
				

		end
		
		CT_WRITE_BUFFER: begin
		
		
		
			T_value1 <= T_value1 + result1;
			T_value2 <= T_value2 + result2;
			T_value3 <= T_value3 + result3;
			
			
			COMPUTE_T_state <= CT_WRITE;
		end
		
		
		CT_WRITE: begin
			
			
			T_wren_a_CT <= 1'b1;
			T_wren_b_CT <= 1'b1;
			
			T_addr_a_CT <= T_counter;
			T_addr_b_CT <= T_counter + 8'd1;
			
			T_wdata_a_CT <= {{5{T_value1[31]}}, T_value1[31:5]};
			T_wdata_b_CT <= {{5{T_value2[31]}}, T_value2[31:5]};
			
			
			SP_addr_counter <= SP_addr_buffer + 8'd1;
			SP_addr_a_CT <= SP_addr_buffer;
			SP_wren_a_CT <= 1'b0;
			
			
			C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
			C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;
			C_wren_a_CT <= 1'b0;
			C_wren_b_CT <= 1'b0;
			
			//just added
			C_addr_counter <= C_addr_counter + 8'd1;
			
			
			
			
		
			COMPUTE_T_state <= CT_WRITE_2;
		end
			
		CT_WRITE_2: begin
			
			
			if(plane == Y) begin
				T_wren_a_CT <= 1'b1;
					
				T_counter <= T_counter + 8'd3;

				T_addr_a_CT <= T_counter+ 8'd2;
				
				T_wdata_a_CT <= {{5{T_value3[31]}}, T_value3[31:5]};
				
				
				SP_addr_counter <= SP_addr_counter + 8'd1;
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				
				
				C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
				C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				//just added
				C_addr_counter <= C_addr_counter + 8'd1;
				
				T_value1 <= 32'd0;
				T_value2 <= 32'd0;
				T_value3 <= 32'd0;
				
				read_C_flag <= ~read_C_flag;
				
				COMPUTE_T_state <= COMMON_1;
				
			
			end else begin
				T_wren_a_CT <= 1'b1;
							
				T_counter <= T_counter + 8'd3;

				T_addr_a_CT <= T_counter+ 8'd2;
				
				T_wdata_a_CT <= {{5{T_value3[31]}}, T_value3[31:5]};
				
				
				SP_addr_counter <= SP_addr_counter + 8'd1;
				SP_addr_a_CT <= SP_addr_counter;
				SP_wren_a_CT <= 1'b0;
				
				
				C_addr_a_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
				C_addr_b_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
				C_wren_a_CT <= 1'b0;
				C_wren_b_CT <= 1'b0;
				
				// just added
				C_addr_counter <= C_addr_counter + 8'd1;
				
				T_value1 <= 32'd0;
				T_value2 <= 32'd0;
				T_value3 <= 32'd0;
				
				read_C_flag <= ~read_C_flag;
			
				COMPUTE_T_state <= COMMON_1;
			end

		end
		CT_WRITE_LAST: begin
		
			if(plane == Y) begin
				
				
				
				T_wren_a_CT <= 1'b1;
				
				T_addr_a_CT <= T_counter;
				
				T_wdata_a_CT <= {{5{T_value1[31]}}, T_value1[31:5]};
				T_value1 <= 32'd0;
				T_value2 <= 32'd0;
				T_value3 <= 32'd0;
				
				if(T_counter == 8'd255)
					COMPUTE_T_state <= CT_DUMMY_OUT;
				else begin
					T_counter <= T_counter + 8'd1;
					
					C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
					C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;
					C_wren_a_CT <= 1'b0;
					C_wren_b_CT <= 1'b0;
					
					C_addr_counter <= C_addr_counter + 8'd1;
					
					SP_addr_counter <= SP_addr_buffer + 8'd1;
					SP_addr_a_CT <= SP_addr_buffer;
					SP_wren_a_CT <= 1'b0;
					
					read_C_flag <= ~read_C_flag;
					
					COMPUTE_T_state <= CT_WRITE_LAST_BUFFER;

					
				end
			end else begin
				T_wren_a_CT <= 1'b1;
				
				T_addr_a_CT <= T_counter;
				
				T_wdata_a_CT <= {{5{T_value1[31]}}, T_value1[31:5]};
				
				T_wren_b_CT <= 1'b1;
				
				T_addr_b_CT <= T_counter + 8'd1;
				
				T_wdata_b_CT <= {{5{T_value2[31]}}, T_value2[31:5]};
				
				T_value1 <= 32'd0;
				T_value2 <= 32'd0;
				T_value3 <= 32'd0;
	
				
				if(T_counter == 8'd62)
					COMPUTE_T_state <= CT_DUMMY_OUT;
				else begin
					T_counter <= T_counter + 8'd2;
					
					C_addr_a_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd128;
					C_addr_b_CT <= {3'b000,{C_addr_counter[2:0],C_addr_counter[5:4]}} + {5'b00000, {C_addr_counter[5:3]}} + 8'd1 + 8'd128;
					C_wren_a_CT <= 1'b0;
					C_wren_b_CT <= 1'b0;
					
					C_addr_counter <= C_addr_counter + 8'd1;
					
					
					SP_addr_counter <= SP_addr_buffer + 8'd1;
					SP_addr_a_CT <= SP_addr_buffer;
					SP_wren_a_CT <= 1'b0;
					
					COMPUTE_T_state <= CT_WRITE_LAST_BUFFER;

					
				end
			end
				
		end
		
		CT_WRITE_LAST_BUFFER: begin
			
			C_addr_a_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}};
			C_addr_b_CT <= {1'b0,{C_addr_counter[3:0],C_addr_counter[7:5]} + {3'b000, C_addr_counter[7:4]}} + 8'd1;


			
			
			C_wren_a_CT <= 1'b0;
			C_wren_b_CT <= 1'b0;
			
			C_addr_counter <= C_addr_counter + 8'd1;
			
			SP_addr_counter <= SP_addr_counter + 8'd1;
			SP_addr_a_CT <= SP_addr_counter;
			SP_wren_a_CT <= 1'b0;
			
			COMPUTE_T_state <= COMMON_1;
		
		end
		CT_DUMMY_OUT: begin
					
			
			
			T_counter <= 8'd0;			
						
			done_CT <= 1'b1;
			
			COMPUTE_T_state <= CT_BUFFER_STATE;
			
		end
		
		CT_BUFFER_STATE: 
			
			
			COMPUTE_T_state <= CT_WAIT;
			
		
		default:
			COMPUTE_T_state <= CT_WAIT;
		
			
		endcase
	end
end





//WRITE S Y ADDRESSING LOGIC START
logic[17:0] Y_WRITE_ADDRESS;

assign Y_WRITE_ADDRESS = 18'd0 + {4'd0,rowblock_w[3:0],samplecount_w[6:3],6'd0} + {5'd0,rowblock_w[3:0],samplecount_w[6:3],5'd0} + {11'd0,columnblock_w,samplecount_w[2:0]};

//END

//WRITE S U ADDRESSING LOGIC START
logic[17:0] U_WRITE_ADDRESS;

assign U_WRITE_ADDRESS = 18'd13824 + {5'd0,rowblock_w[4:0],samplecount_w[4:2],5'd0} + {6'd0,rowblock_w[4:0],samplecount_w[4:2],4'd0} + {12'd0,columnblock_w,samplecount_w[1:0]};
//END

//WRITE S V ADDRESSING LOGIC START
logic[17:0] V_WRITE_ADDRESS;

assign V_WRITE_ADDRESS = 18'd20736 + {5'd0,rowblock_w[4:0],samplecount_w[4:2],5'd0} + {6'd0,rowblock_w[4:0],samplecount_w[4:2],4'd0} + {12'd0,columnblock_w,samplecount_w[1:0]};
//END


//WRITE S FSM
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		SRAM_we_nWS <= 1'b1;
		SRAM_write_dataWS <= 16'd0;
		SRAM_addressWS <= 18'd0;
		WRITE_S_state <= WAIT_WRITE_S;
		S_addr_a_WS <= 8'd0;
		S_addr_b_WS <= 8'd0;
		S_wren_a_WS <= 1'b0;
		S_wren_b_WS <= 1'b0;
		S_read_count <= 8'd0;
		done_write_s <= 1'b0;
	end else begin				
		case (WRITE_S_state)
		
		WAIT_WRITE_S: begin
			if (start_write_s) begin
				WRITE_S_state <= DUMMY_WS_START_1;
				done_write_s <= 1'b0;
			end	
		end
		
		DUMMY_WS_START_1: begin
			//keep Yaddress write counter enabled OFF
			S_addr_a_WS <= 8'd0;
			S_addr_b_WS <= 8'd1;
			S_wren_a_WS <= 1'b0;
			S_wren_b_WS <= 1'b0;
			WRITE_S_state <= DUMMY_WS_START_2;
		end
		
		DUMMY_WS_START_2: begin
			//keep Yaddress write counter enabled OFF
			S_wren_a_WS <= 1'b0;
			S_wren_b_WS <= 1'b0;
			S_addr_a_WS <= S_addr_a_WS + 8'd2;
			S_addr_b_WS <= S_addr_b_WS + 8'd2;
			WRITE_S_state <= BIG_WS;
		end
		
		BIG_WS: begin
			//keep Yaddress write counter enable on
			S_read_count <= S_read_count + 8'd1;
			SRAM_we_nWS <= 1'd0;
			SRAM_addressWS <= (plane == Y) ? Y_WRITE_ADDRESS : (plane == U) ? U_WRITE_ADDRESS : V_WRITE_ADDRESS;
			if (S_rdata_a[31] == 1'b1) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'h0000;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'h00FF;
				else
					SRAM_write_dataWS <= {8'h00, S_rdata_b[20:13]};
			end else if (|S_rdata_a[30:21]) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'hFF00;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'hFFFF;
				else 
					SRAM_write_dataWS <= {8'hFF, S_rdata_b[20:13]};
			end else begin
				if (S_rdata_b[31] == 1'b1) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'h00};
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'hFF};
				else 
					SRAM_write_dataWS <= {S_rdata_a[20:13], S_rdata_b[20:13]};
			end
			
			S_wren_a_WS <= 1'b0;
			S_wren_b_WS <= 1'b0;
			S_addr_a_WS <= S_addr_a_WS + 8'd2;
			S_addr_b_WS <= S_addr_b_WS + 8'd2;
			
			if (plane == Y) begin
				if (S_read_count == 8'd125) begin
					WRITE_S_state <= DUMMY_WS_END_1;
				end
			end else begin
				if (S_read_count == 8'd29) begin
					WRITE_S_state <= DUMMY_WS_END_1;
				end
			end					
				
			
		end
		
		DUMMY_WS_END_1: begin
			//keep Yaddress write counter enable ON
			S_addr_a_WS <= 8'd0;
			S_addr_b_WS <= 8'd0;
			SRAM_we_nWS <= 1'd0;
			S_wren_a_WS <= 1'b0;
			S_wren_b_WS <= 1'b0;
			S_read_count <= 8'd0;
			SRAM_we_nWS <= 1'd0;
			SRAM_addressWS <= (plane == Y) ? Y_WRITE_ADDRESS : (plane == U) ? U_WRITE_ADDRESS : V_WRITE_ADDRESS;
			if (S_rdata_a[31] == 1'b1) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'h0000;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'h00FF;
				else
					SRAM_write_dataWS <= {8'h00, S_rdata_b[20:13]};
			end else if (|S_rdata_a[30:21]) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'hFF00;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'hFFFF;
				else 
					SRAM_write_dataWS <= {8'hFF, S_rdata_b[20:13]};
			end else begin
				if (S_rdata_b[31] == 1'b1) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'h00};
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'hFF};
				else 
					SRAM_write_dataWS <= {S_rdata_a[20:13], S_rdata_b[20:13]};
			end
			WRITE_S_state <= DUMMY_WS_END_2;
		end
		
		DUMMY_WS_END_2: begin
			//keep Yaddress write counter enable ON
			S_addr_a_WS <= 8'd0;
			S_addr_b_WS <= 8'd0;
			SRAM_we_nWS <= 1'd0;
			S_wren_a_WS <= 1'b0;
			S_wren_b_WS <= 1'b0;
			S_read_count <= 8'd0;
			SRAM_we_nWS <= 1'd0;
			SRAM_addressWS <= (plane == Y) ? Y_WRITE_ADDRESS : (plane == U) ? U_WRITE_ADDRESS : V_WRITE_ADDRESS;
			if (S_rdata_a[31] == 1'b1) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'h0000;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'h00FF;
				else
					SRAM_write_dataWS <= {8'h00, S_rdata_b[20:13]};
			end else if (|S_rdata_a[30:21]) begin
				if (S_rdata_b[31] == 1'b1)
					SRAM_write_dataWS <= 16'hFF00;
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= 16'hFFFF;
				else 
					SRAM_write_dataWS <= {8'hFF, S_rdata_b[20:13]};
			end else begin
				if (S_rdata_b[31] == 1'b1) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'h00};
				else if (|S_rdata_b[30:21]) 
					SRAM_write_dataWS <= {S_rdata_a[20:13], 8'hFF};
				else 
					SRAM_write_dataWS <= {S_rdata_a[20:13], S_rdata_b[20:13]};
			end
			WRITE_S_state <= WS_BUFFER_STATE;
		end
		
		WS_BUFFER_STATE: 
			WRITE_S_state <= WS_BUFFER_STATE1;
			
		WS_BUFFER_STATE1: 
			WRITE_S_state <= WS_BUFFER_STATE2;
		
		WS_BUFFER_STATE2: begin
			WRITE_S_state <= WS_BUFFER_STATE3;
			done_write_s <= 1'b1;
		end
			
		WS_BUFFER_STATE3: begin
			WRITE_S_state <= WAIT_WRITE_S;
		end
			
		
		default: 
			WRITE_S_state <= WAIT_WRITE_S;
		
			
		endcase
	end
end



//COMPUTE S FSM
always_ff @ (posedge Clock or negedge Resetn) begin
	if (~Resetn) begin
		COMPUTE_S_state <= WAIT_CS;
		S_buff[2] <= 32'd0;
		S_buff[1] <= 32'd0;
		S_buff[0] <= 32'd0;
		calc_count <= 5'd0;
		T_SCOMP_counter <= 8'd0;
		C_SCOMP_counter <= 8'd0;
		S_SCOMP_counter <= 8'd0;
		tricount <= 3'd0;
		rowcount <= 5'd0;
		done_cs <= 1'b0;
		cflag <= 1'd1;
		S_wren_a_CS <= 1'd0;
		S_wren_b_CS <= 1'd0;
		S_addr_a_CS <= 8'd0;
		S_addr_b_CS <= 8'd0;
		S_wdata_a_CS <= 32'd0;
		S_wdata_b_CS <= 32'd0;
		T_wren_a_CS <= 1'd0;
		T_addr_a_CS <= 8'd0;

	end else begin				
		case (plane)
		
		Y: begin
			case (COMPUTE_S_state)
			
			WAIT_CS: begin
				if (start_cs) begin
					done_cs <= 1'b0;
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
				end
			
			end
			DUMMY_S_COMPUTE1: begin
				T_addr_a_CS <= {T_SCOMP_counter[3:0],T_SCOMP_counter[7:4]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})};
				C_addr_b_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				COMPUTE_S_state <= DUMMY_S_COMPUTE2;
			end
			
			DUMMY_S_COMPUTE2: begin
				T_addr_a_CS <= {T_SCOMP_counter[3:0],T_SCOMP_counter[7:4]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})};
				C_addr_b_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				if (tricount == 3'd1 || tricount == 3'd3 || tricount == 3'd5)
					cflag <= 1'd0;
				else
					cflag <= 1'd1;
				if (tricount == 3'd5)
					COMPUTE_S_state <= SPECIAL_CASE;
				else
					COMPUTE_S_state <= THREE_AT_A_TIME;
			end
			
			THREE_AT_A_TIME: begin
				if (calc_count < 5'd14) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[3:0],T_SCOMP_counter[7:4]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})};
					C_addr_b_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})} + 8'd1;
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					C_wren_b_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
					
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1COMMON;
				end
					
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;	
			
			end
			
			COMPLETE_S_BUFFERCALC1COMMON: begin
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;
				COMPUTE_S_state <= COMPLETE_S_SUM_COMMON;
			end 
			
	
			
			SPECIAL_CASE: begin
				if (calc_count < 5'd14) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[3:0],T_SCOMP_counter[7:4]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= {1'd0,({C_SCOMP_counter[3:0],C_SCOMP_counter[7:5]} + {3'd0,C_SCOMP_counter[7:4]})};
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
	
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1SPECIAL;
				end
					
				S_buff[0] <= S_buff[0] + result1;	
			
			end
			
			COMPLETE_S_BUFFERCALC1SPECIAL: begin
				S_buff[0] <= S_buff[0] + result1;
				COMPUTE_S_state <= COMPLETE_S_SUM_SPECIAL;
			end
	
			
			COMPLETE_S_SUM_COMMON: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				S_buff[1] <= S_buff[1] + 32'd4096;
				S_buff[2] <= S_buff[2] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_COMMON;
			end
			
			COMPLETE_S_SUM_SPECIAL: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_SPECIAL;
			end
			
			COMPLETE_S_WRITE1_SPECIAL: begin
				S_addr_a_CS <= {S_SCOMP_counter[3:0], S_SCOMP_counter[7:4]};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER0;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
			
			end
			
			COMPLETE_S_WRITE1_COMMON: begin
				S_addr_a_CS <= {S_SCOMP_counter[3:0], S_SCOMP_counter[7:4]};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE2_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
			end
			
			
			COMPLETE_S_WRITE2_COMMON: begin
				S_addr_a_CS <= {S_SCOMP_counter[3:0], S_SCOMP_counter[7:4]};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE3_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[1];
			end
			
			COMPLETE_S_WRITE3_COMMON: begin
				S_addr_a_CS <= {S_SCOMP_counter[3:0], S_SCOMP_counter[7:4]};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER0;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[2];
			end

			COMPLETE_S_WRITE_BUFFER0: begin 	
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER;
				S_wren_a_CS <= 1'b0;
			end
			
			
			COMPLETE_S_WRITE_BUFFER: begin
				S_wren_a_CS <= 1'b0;
				S_buff[0] <= 32'd0;
				S_buff[1] <= 32'd0;
				S_buff[2] <= 32'd0;
				if (tricount < 3'd5) begin
					tricount <= tricount + 3'd1;
					T_SCOMP_counter[7:4]<= T_SCOMP_counter[7:4] - 4'd1;
				
				end else begin
					tricount <= 3'd0;
					C_SCOMP_counter <= 8'd0;
					rowcount <= rowcount + 5'd1;
				end
				
				if (rowcount == 5'd15) begin
					COMPUTE_S_state <= CS_BUFFER_STATE_Y;
					done_cs <= 1'b1;
					rowcount <= 5'd0;
					S_SCOMP_counter <= 8'd0;
					T_SCOMP_counter <= 8'd0;
					C_SCOMP_counter <= 8'd0;
				end
					
				else
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
			end
			
			
			CS_BUFFER_STATE_Y:
				COMPUTE_S_state <= WAIT_CS;
				
			
			endcase
			
		end
		
		
		U: begin
			case (COMPUTE_S_state)
			
			
			WAIT_CS: begin
				if (start_cs) begin
					done_cs <= 1'b0;
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
				end
			
			end
			DUMMY_S_COMPUTE1: begin
				T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
				C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				COMPUTE_S_state <= DUMMY_S_COMPUTE2;
		
			end
			
			DUMMY_S_COMPUTE2: begin
				T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
				C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				if (tricount == 3'd1)
					cflag <= 1'd0;
				else
					cflag <= 1'd1;
				if (tricount == 3'd2)
					COMPUTE_S_state <= SPECIAL_CASE;
				else
					COMPUTE_S_state <= THREE_AT_A_TIME;
			end
			
			THREE_AT_A_TIME: begin
				if (calc_count < 5'd6) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
					C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					C_wren_b_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
					
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1COMMON;
				end
					
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;	
			
			end
			
			COMPLETE_S_BUFFERCALC1COMMON: begin
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;
				COMPUTE_S_state <= COMPLETE_S_SUM_COMMON;
			end
		
			SPECIAL_CASE: begin
				if (calc_count < 5'd6) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
					C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
	
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1SPECIAL;
				end
					
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
			
			end
			
			COMPLETE_S_BUFFERCALC1SPECIAL: begin
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				COMPUTE_S_state <= COMPLETE_S_SUM_SPECIAL;
			end
			
			COMPLETE_S_SUM_COMMON: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				S_buff[1] <= S_buff[1] + 32'd4096;
				S_buff[2] <= S_buff[2] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_COMMON;
			end
			
			COMPLETE_S_SUM_SPECIAL: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				S_buff[1] <= S_buff[1] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_SPECIAL;
			end
			
			COMPLETE_S_WRITE1_SPECIAL: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_addr_b_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}} + 8'd8;
				S_SCOMP_counter <= S_SCOMP_counter + 8'd2;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER;
				S_wren_a_CS <= 1'b1;
				S_wren_b_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
				S_wdata_b_CS <= S_buff[1];
			
			end
			
			COMPLETE_S_WRITE1_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE2_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
			end
			
			
			COMPLETE_S_WRITE2_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE3_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[1];
			end
			
			COMPLETE_S_WRITE3_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER0;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[2];
			end
			
			COMPLETE_S_WRITE_BUFFER0: begin 	
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER;
				S_wren_a_CS <= 1'b0;
			end
			
			COMPLETE_S_WRITE_BUFFER: begin
				S_wren_a_CS <= 1'b0;
				S_wren_b_CS <= 1'b0;
				S_buff[0] <= 32'd0;
				S_buff[1] <= 32'd0;
				S_buff[2] <= 32'd0;
				if (tricount < 3'd2) begin
					tricount <= tricount + 3'd1;
					T_SCOMP_counter[5:3]<= T_SCOMP_counter[5:3] - 3'd1;
				
				end else begin
					tricount <= 3'd0;
					C_SCOMP_counter <= 8'd0;
					rowcount <= rowcount + 5'd1;
				end
				
				if (rowcount == 5'd7) begin
					COMPUTE_S_state <= CS_BUFFER_STATE_U;
					done_cs <= 1'b1;
					rowcount <= 5'd0;
					S_SCOMP_counter <= 8'd0;
					T_SCOMP_counter <= 8'd0;
					C_SCOMP_counter <= 8'd0;
				end
					
				else
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
			end
			
			CS_BUFFER_STATE_U:
				COMPUTE_S_state <= WAIT_CS;
			
			endcase
			
		end
		
		V: begin
			case (COMPUTE_S_state)
			
			
			WAIT_CS: begin
				if (start_cs) begin
					done_cs <= 1'b0;
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
				end
			
			end
			DUMMY_S_COMPUTE1: begin
				T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
				C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				COMPUTE_S_state <= DUMMY_S_COMPUTE2;
		
			end
			
			DUMMY_S_COMPUTE2: begin
				T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
				T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
				C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
				C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
				C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
				C_wren_a_CS <= 1'd0;
				C_wren_b_CS <= 1'd0;
				T_wren_a_CS <= 1'd0;
				if (tricount == 3'd1)
					cflag <= 1'd0;
				else
					cflag <= 1'd1;
				if (tricount == 3'd2)
					COMPUTE_S_state <= SPECIAL_CASE;
				else
					COMPUTE_S_state <= THREE_AT_A_TIME;
			end
			
			THREE_AT_A_TIME: begin
				if (calc_count < 5'd6) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
					C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					C_wren_b_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
					
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1COMMON;
				end
					
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;	
			
			end
			
			COMPLETE_S_BUFFERCALC1COMMON: begin
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				S_buff[2] <= S_buff[2] + result3;
				COMPUTE_S_state <= COMPLETE_S_SUM_COMMON;
			end
		
			SPECIAL_CASE: begin
				if (calc_count < 5'd6) begin
					calc_count <= calc_count + 5'd1;
					T_addr_a_CS <= {T_SCOMP_counter[2:0],T_SCOMP_counter[5:3]};
					T_SCOMP_counter <= T_SCOMP_counter + 8'd1;
					C_addr_a_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})};
					C_addr_b_CS <= 8'd128 + {3'd0,({C_SCOMP_counter[2:0],C_SCOMP_counter[5:4]} + {2'd0,C_SCOMP_counter[5:3]})} + 8'd1;
					C_SCOMP_counter <= C_SCOMP_counter + 8'd1;
					C_wren_a_CS <= 1'd0;
					T_wren_a_CS <= 1'd0;
	
				end else begin
					calc_count <= 5'd0;
					COMPUTE_S_state <= COMPLETE_S_BUFFERCALC1SPECIAL;
				end
					
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
			
			end
			
			COMPLETE_S_BUFFERCALC1SPECIAL: begin
				S_buff[0] <= S_buff[0] + result1;
				S_buff[1] <= S_buff[1] + result2;
				COMPUTE_S_state <= COMPLETE_S_SUM_SPECIAL;
			end
			
			COMPLETE_S_SUM_COMMON: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				S_buff[1] <= S_buff[1] + 32'd4096;
				S_buff[2] <= S_buff[2] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_COMMON;
			end
			
			COMPLETE_S_SUM_SPECIAL: begin
				S_buff[0] <= S_buff[0] + 32'd4096;
				S_buff[1] <= S_buff[1] + 32'd4096;
				COMPUTE_S_state <= COMPLETE_S_WRITE1_SPECIAL;
			end
			
			COMPLETE_S_WRITE1_SPECIAL: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_addr_b_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}} + 8'd8;
				S_SCOMP_counter <= S_SCOMP_counter + 8'd2;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER;
				S_wren_a_CS <= 1'b1;
				S_wren_b_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
				S_wdata_b_CS <= S_buff[1];
			
			end
			
			COMPLETE_S_WRITE1_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE2_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[0];
			end
			
			
			COMPLETE_S_WRITE2_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE3_COMMON;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[1];
			end
			
			COMPLETE_S_WRITE3_COMMON: begin
				S_addr_a_CS <= {2'd0,{S_SCOMP_counter[2:0], S_SCOMP_counter[5:3]}};
				S_SCOMP_counter <= S_SCOMP_counter + 8'd1;
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER0;
				S_wren_a_CS <= 1'b1;
				S_wdata_a_CS <= S_buff[2];
			end
			
			COMPLETE_S_WRITE_BUFFER0: begin 	
				COMPUTE_S_state <= COMPLETE_S_WRITE_BUFFER;
				S_wren_a_CS <= 1'b0;
			end
			
			COMPLETE_S_WRITE_BUFFER: begin
				S_wren_a_CS <= 1'b0;
				S_wren_b_CS <= 1'b0;
				S_buff[0] <= 32'd0;
				S_buff[1] <= 32'd0;
				S_buff[2] <= 32'd0;
				if (tricount < 3'd2) begin
					tricount <= tricount + 3'd1;
					T_SCOMP_counter[5:3]<= T_SCOMP_counter[5:3] - 3'd1;
				
				end else begin
					tricount <= 3'd0;
					C_SCOMP_counter <= 8'd0;
					rowcount <= rowcount + 5'd1;
				end
				
				if (rowcount == 5'd7) begin
					COMPUTE_S_state <= CS_BUFFER_STATE_V;
					done_cs <= 1'b1;
					rowcount <= 5'd0;
					S_SCOMP_counter <= 8'd0;
					T_SCOMP_counter <= 8'd0;
					C_SCOMP_counter <= 8'd0;
				end
					
				else
					COMPUTE_S_state <= DUMMY_S_COMPUTE1;
			end
			
			CS_BUFFER_STATE_V:
				COMPUTE_S_state <= WAIT_CS;
			endcase
		end
		endcase
	end
end


assign result_long1 = op1*op2;
assign result1 = result_long1[31:0];

assign result_long2 = op3*op4;
assign result2 = result_long2[31:0];

assign result_long3 = op5*op6;
assign result3 = result_long3[31:0];

always_comb begin
	
	if(COMPUTE_T_state == COMMON_1 || COMPUTE_T_state == CT_WRITE_BUFFER) begin
	
		if(read_C_flag == 1'b0) begin// every other 3 columns
	
			op1 = (C_rdata_a[31] == 1'b1)? {16'hffff,C_rdata_a[31:16]}: {16'h0000, C_rdata_a[31:16]};
			op2 = SP_rdata_a;
		
			op3 = (C_rdata_a[15] == 1'b1)? {16'hffff,C_rdata_a[15:0]}: {16'h0000, C_rdata_a[15:0]};
			op4 = SP_rdata_a;
			
			op5 = (C_rdata_b[31] == 1'b1)? {16'hffff,C_rdata_b[31:16]}: {16'h0000, C_rdata_b[31:16]};
			op6 = SP_rdata_a;
		
		end
		
		else begin // every other 3 columns 
		
			op1 = (C_rdata_a[15] == 1'b1)? {16'hffff,C_rdata_a[15:0]}: {16'h0000, C_rdata_a[15:0]};
			op2 = SP_rdata_a;
		
			op3 = (C_rdata_b[31] == 1'b1)? {16'hffff,C_rdata_b[31:16]}: {16'h0000, C_rdata_b[31:16]};
			op4 = SP_rdata_a;
			
			op5 = (C_rdata_b[15] == 1'b1)? {16'hffff,C_rdata_b[15:0]}: {16'h0000, C_rdata_b[15:0]};
			op6 = SP_rdata_a;
			
		end
		
	end
	else if(COMPUTE_S_state == THREE_AT_A_TIME || COMPUTE_S_state == COMPLETE_S_BUFFERCALC1COMMON) begin
	
		if (cflag == 1'b1) begin
			op1 = T_rdata_a;
			op2 = {{16{C_rdata_a[31]}},C_rdata_a[31:16]};
			op3 = T_rdata_a;
			op4 = {{16{C_rdata_a[15]}},C_rdata_a[15:0]};
			op5 = T_rdata_a;
			op6 = {{16{C_rdata_b[31]}},C_rdata_b[31:16]};
	
		end else begin
			op1 = T_rdata_a;
			op2 = {{16{C_rdata_a[15]}},C_rdata_a[15:0]};
			op3 = T_rdata_a;
			op4 = {{16{C_rdata_b[31]}},C_rdata_b[31:16]};
			op5 = T_rdata_a;
			op6 = {{16{C_rdata_b[15]}},C_rdata_b[15:0]};
		
		end
			
	end else if(COMPUTE_S_state == SPECIAL_CASE || COMPUTE_S_state == COMPLETE_S_BUFFERCALC1SPECIAL) begin
	
		if (cflag == 1'b0) begin
			op1 = T_rdata_a;
			op2 = {{16{C_rdata_a[15]}},C_rdata_a[15:0]};
			op3 = 32'd0;
			op4 = 32'd0; 
			op5 = 32'd0;
			op6 = 32'd0;
		end
		
		else begin
			op1 = T_rdata_a;
			op2 = {{16{C_rdata_a[31]}},C_rdata_a[31:16]};
			op3 = T_rdata_a;
			op4 = {{16{C_rdata_a[15]}},C_rdata_a[15:0]}; 
			op5 = 32'd0;
			op6 = 32'd0;
		
		end
	end else begin
		
		op1 = 32'd0;
		op2 = 32'd0;
		op3 = 32'd0;
		op4 = 32'd0;
		op5 = 32'd0;
		op6 = 32'd0;
	end
	
	
end




endmodule