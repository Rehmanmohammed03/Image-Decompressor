/*
    Milestone 2
    Group 70
    Mark Le
    Rehman Mohammed
    COMPENG 3DQ5 - Digital System Design
    Fall 2026
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

module milestone2 (
    input  logic          clock,
    input  logic          resetn,
    input  logic          start_signal,
    input  logic [15:0]   SRAM_read_data,

    output logic [17:0]   SRAM_address,
    output logic [15:0]   SRAM_write_data,
    output logic          SRAM_w_en,
    output logic          end_signal
);

// BRAM signals
logic [7:0]  address_a [3:0];
logic [7:0]  address_b [3:0];
logic [15:0] write_data_a [3:0];
logic [15:0] write_data_b [3:0];
logic [15:0] read_data_a [3:0];
logic [15:0] read_data_b [3:0];
logic        write_enable_a [3:0];
logic        write_enable_b [3:0];


// Instantiate BRAMs
dual_port_RAM0 BRAM0 (
    .address_a(address_a[0]),
    .address_b(address_b[0]),
    .clock(clock),
    .data_a(write_data_a[0]),
    .data_b(write_data_b[0]),
    .wren_a(write_enable_a[0]),
    .wren_b(write_enable_b[0]),
    .q_a(read_data_a[0]),
    .q_b(read_data_b[0])
);

dual_port_RAM1 BRAM1 (
    .address_a(address_a[1]),
    .address_b(address_b[1]),
    .clock(clock),
    .data_a(write_data_a[1]),
    .data_b(write_data_b[1]),
    .wren_a(write_enable_a[1]),
    .wren_b(write_enable_b[1]),
    .q_a(read_data_a[1]),
    .q_b(read_data_b[1])
);

dual_port_RAM2 BRAM2 (
    .address_a(address_a[2]),
    .address_b(address_b[2]),
    .clock(clock),
    .data_a(write_data_a[2]),
    .data_b(write_data_b[2]),
    .wren_a(write_enable_a[2]),
    .wren_b(write_enable_b[2]),
    .q_a(read_data_a[2]),
    .q_b(read_data_b[2])
);

dual_port_RAM3 BRAM3 (
    .address_a(address_a[3]),
    .address_b(address_b[3]),
    .clock(clock),
    .data_a(write_data_a[3]),
    .data_b(write_data_b[3]),
    .wren_a(write_enable_a[3]),
    .wren_b(write_enable_b[3]),
    .q_a(read_data_a[3]),
    .q_b(read_data_b[3])
);

M2_state_type M2_state;

// logic declaration:

logic [4:0] block_col_count;
logic [3:0] block_row_count;

logic [3:0] pixel_col_count;
logic [2:0] pixel_row_count;

logic [17:0] y_addr_row_offset; // start at 37632
logic [17:0] u_addr_row_offset; // start at ...
logic [17:0] v_addr_row_offset; // start at ...

//Tracking samples within the block
logic [6:0] sample_count;
logic read_issue;
logic write_issue;

always_comb begin
    SRAM_address = 18'd0;
    SRAM_write_data = 16'd0;
    SRAM_w_en = 1'b1;
    end_signal = 1'b0;

    address_a[0] = 8'd0;
    address_b[0] = 8'd0;
    write_data_a[0] = 16'd0;
    write_data_b[0] = 16'd0;
    read_data_a[0] = 16'd0;
    read_data_b[0] = 16'd0;
    write_enable_a[0] = 1'b0;
    write_enable_b[0] = 1'b0;

    address_a[1] = 8'd0;
    address_b[1] = 8'd0;
    write_data_a[1] = 16'd0;
    write_data_b[1] = 16'd0;
    read_data_a[1] = 16'd0;
    read_data_b[1] = 16'd0;
    write_enable_a[1] = 1'b0;
    write_enable_b[1] = 1'b0;

    address_a[2] = 8'd0;
    address_b[2] = 8'd0;
    write_data_a[2] = 16'd0;
    write_data_b[2] = 16'd0;
    read_data_a[2] = 16'd0;
    read_data_b[2] = 16'd0;
    write_enable_a[2] = 1'b0;
    write_enable_b[2] = 1'b0;

    address_a[3] = 8'd0;
    address_b[3] = 8'd0;
    write_data_a[3] = 16'd0;
    write_data_b[3] = 16'd0;
    read_data_a[3] = 16'd0;
    read_data_b[3] = 16'd0;
    write_enable_a[3] = 1'b0;
    write_enable_b[3] = 1'b0;

    case (M2_state)
        S_M2_FETCH_SP_FIRST: begin
            //SRAM_address = 18'd37632 + 224*sample_count[6:4] + sample_count[3:0]
            // 224 = 128+96+32 = 2^7 + 2^6 + 2^5
            SRAM_address = 18'd37632 + 
            (sample_count[6:4] >> 7) +
            (sample_count[6:4] >> 6) + 
            (sample_count[6:4] >> 5) + 
            sample_count[3:0];

            address_a[0] = {1'b0, bram_write_count} // zero extension
            write_data_a[0] = SRAM_read_data;
            write_enable_a[0] = write_issue;
        end

        S_M2_COMPUTE_T_FIRST: begin

        end

        default: begin
        end
    endcase

end

always_ff @(posedge clock or negedge resetn) begin
    if (~resetn) begin
        M2_state <= S_M2_IDLE;


        //Tracking the samples across the block
        sample_count <= 7'd0;

        // more registers goes here...
    end else begin
        // main logic:
        
        case (M2_state)
            S_M2_IDLE: begin
                sample_count     <= 7'd0;
                bram_write_count <= 7'd0;
                read_issue       <= 1'b1;
                read_issue_d1    <= 1'b0;
                write_issue      <= 1'b0;

                M2_state <= S_M2_FETCH_SP_FIRST;
            end

            S_M2_FETCH_SP_FIRST: begin
                // A read issued in column C enables a BRAM write in column E.
                read_issue_d1 <= read_issue;
                write_issue   <= read_issue_d1;

                if (read_issue) begin
                    if (sample_count == 7'd127)
                        read_issue <= 1'b0; // stop issuing read at 
                    else
                        sample_count <= sample_count + 7'd1;
                end

                if (write_issue) begin
                    if (bram_write_count == 7'd127)
                        M2_state <= S_M2_COMPUTE_FIRST_T;
                    else
                        bram_write_count <= bram_write_count + 7'd1;
                end
            end

            S_M2_COMPUTE_T_FIRST: begin
                
            end


        // Keep your remaining M2 states here.
        endcase
    end
end

endmodule
