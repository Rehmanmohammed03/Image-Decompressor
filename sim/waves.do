# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n
add wave -hex UUT/SRAM_read_data

add wave -divider -height 10 {VGA signals}
add wave -bin UUT/VGA_unit/VGA_HSYNC_O
add wave -bin UUT/VGA_unit/VGA_VSYNC_O
add wave -uns UUT/VGA_unit/pixel_X_pos
add wave -uns UUT/VGA_unit/pixel_Y_pos
add wave -hex UUT/VGA_unit/VGA_red
add wave -hex UUT/VGA_unit/VGA_green
add wave -hex UUT/VGA_unit/VGA_blue

add wave -divider -height 10 {Milestone 2}
add wave -uns UUT/M2/M2_Top_State



add wave -divider -height 20 {WRITE S FSM}

# FSM control
add wave UUT/M2/WRITE_S_state
add wave UUT/M2/start_write_s
add wave UUT/M2/done_write_s

# SRAM output interface
add wave UUT/M2/SRAM_we_nWS
add wave UUT/M2/SRAM_addressWS
add wave UUT/M2/SRAM_write_dataWS

add wave UUT/M2/Y_WRITE_ADDRESS
add wave UUT/M2/U_WRITE_ADDRESS
add wave UUT/M2/V_WRITE_ADDRESS


# S RAM read data (input to WS FSM logic)
add wave UUT/M2/S_rdata_a
add wave UUT/M2/S_rdata_b

# S RAM address + write enables from WS FSM
add wave UUT/M2/S_addr_a_WS
add wave UUT/M2/S_addr_b_WS
add wave UUT/M2/S_wren_a_WS
add wave UUT/M2/S_wren_b_WS

# Counter
add wave UUT/M2/S_read_count

# Plane (Y / U / V branch)
add wave UUT/M2/plane

add wave -divider -height 20 {COMPUTE S}



add wave UUT/M2/COMPUTE_S_state
add wave UUT/M2/COMPUTE_S_state

add wave UUT/M2/S_wren_a_CS
add wave UUT/M2/S_wren_b_CS
add wave UUT/M2/S_addr_a_CS 
add wave UUT/M2/S_addr_b_CS
add wave UUT/M2/S_wdata_a_CS
add wave UUT/M2/S_wdata_b_CS
add wave UUT/M2/T_wren_a_CS
add wave UUT/M2/T_addr_a_CS

add wave UUT/M2/C_addr_a_CS 
add wave UUT/M2/C_addr_b_CS
add wave UUT/M2/C_rdata_a
add wave UUT/M2/C_rdata_b

add wave UUT/M2/calc_count
add wave UUT/M2/T_SCOMP_counter
add wave UUT/M2/C_SCOMP_counter
add wave UUT/M2/S_SCOMP_counter
add wave UUT/M2/tricount
add wave UUT/M2/rowcount
add wave UUT/M2/done_cs
add wave UUT/M2/cflag
add wave UUT/M2/S_buff



add wave -divider -height 10 {COMPUTE T}
add wave UUT/M2/start_CT
add wave UUT/M2/done_CT
add wave UUT/M2/plane
add wave UUT/M2/COMPUTE_T_state

# Counters
add wave UUT/M2/C_addr_counter
add wave UUT/M2/SP_addr_counter
add wave UUT/M2/T_counter

# C matrix reads
add wave UUT/M2/C_addr_a_CT
add wave UUT/M2/C_addr_b_CT
add wave UUT/M2/C_rdata_a
add wave UUT/M2/C_rdata_b

# SP matrix reads
add wave UUT/M2/SP_addr_a_CT
add wave UUT/M2/SP_wren_a_CT
add wave UUT/M2/SP_rdata_a

add wave -divider -height 20 {T RAM Signals}


# Addresses going into T RAM
add wave UUT/M2/T_addr_a
add wave UUT/M2/T_addr_b
add wave UUT/M2/T_addr_a_CT
add wave UUT/M2/T_addr_b_CT

# Write data going into T RAM
add wave UUT/M2/T_wdata_a
add wave UUT/M2/T_wdata_b
add wave UUT/M2/T_wdata_a_CT
add wave UUT/M2/T_wdata_b_CT

# Write enables
add wave UUT/M2/T_wren_a
add wave UUT/M2/T_wren_b
add wave UUT/M2/T_wren_a_CT
add wave UUT/M2/T_wren_b_CT


# Counters + intermediate values
add wave UUT/M2/T_counter
add wave -dec UUT/M2/T_value1
add wave -dec UUT/M2/T_value2
add wave -dec UUT/M2/T_value3

add wave -divider -height 20 {operands}

add wave -dec UUT/M2/read_C_flag
add wave -dec UUT/M2/op1
add wave -hex UUT/M2/op2
add wave -dec UUT/M2/op3
add wave -hex UUT/M2/op4
add wave -dec UUT/M2/op5
add wave -hex UUT/M2/op6


add wave -divider -height 20 {FETCH S' FSM}

# FSM state
add wave UUT/M2/FETCH_state

# Start/done control
add wave UUT/M2/start_fetch
add wave UUT/M2/done_fetch
add wave UUT/M2/plane

# SRAM reads for fetch
add wave UUT/M2/SRAM_we_nF
add wave -uns UUT/M2/SRAM_addressF
add wave UUT/M2/SRAM_read_data

# SP Matrix writes
add wave UUT/M2/SP_addr_a_FS
add wave UUT/M2/SP_wdata_a_FS
add wave UUT/M2/SP_wren_a_FS
add wave UUT/M2/SP_write_count



