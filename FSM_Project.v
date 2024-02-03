`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2024 15:00:18
// Design Name: 
// Module Name: FSM_Project
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FSM_Project(clockf,resetnf,pkt_validf,busyf,parity_done,data_inf,soft_reset_0,soft_reset_1,soft_reset_2,fifo_fullf,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_regf,rst_int_reg,lfd_state);
input clockf,resetnf,pkt_validf,soft_reset_0,soft_reset_1,soft_reset_2,fifo_fullf,parity_done;
input [1:0] data_inf;
input low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
output busyf,detect_add,ld_state,laf_state,full_state,write_enb_regf,rst_int_reg,lfd_state;
// State Declerations
parameter decode_address = 3'b000,
          load_first_data = 3'b001,
          load_data = 3'b010,
          load_parity = 3'b011,
          check_parity_error = 3'b100,
          fifo_full_state = 3'b101,
          load_after_full = 3'b110,
          wait_till_empty = 3'b111;
// Delcaration of present state and next state
reg [2:0] present_state,next_state;
// Internal variable to store the address
reg [1:0] addr;
// Present state logic
always@(posedge clockf)
begin
    if(!resetnf || soft_reset_0 || soft_reset_1 || soft_reset_2)
        present_state <= decode_address;
    else
        present_state <= next_state;
        addr <= data_inf;
end
// Next state combinational logic
always@(*)
begin
    next_state = decode_address;
    case(present_state)
    decode_address : begin
                     if ((pkt_validf & (data_inf[1:0] == 0) & fifo_empty_0) | 
                         (pkt_validf & (data_inf[1:0] == 1) & fifo_empty_1) | 
                         (pkt_validf & (data_inf[1:0] == 2) & fifo_empty_2))
                        next_state = load_first_data;
                     else if ((pkt_validf & (data_inf[1:0] == 0) & !fifo_empty_0) | 
                              (pkt_validf & (data_inf[1:0] == 1) & !fifo_empty_1) | 
                              (pkt_validf & (data_inf[1:0] == 2) & !fifo_empty_2))
                        next_state = wait_till_empty;
                     else 
                        next_state = decode_address;
                     end
    load_first_data : begin next_state = load_data; end
    load_data       : begin
                      if (!fifo_fullf && !pkt_validf)
                          next_state = load_parity;
                      else if (fifo_fullf)
                          next_state = fifo_full_state;
                      else
                          next_state = load_data;
                      end
    load_parity     : begin next_state = check_parity_error; end
    fifo_full_state : begin
                      if (!fifo_fullf)
                          next_state = load_after_full;
                      else
                          next_state = fifo_full_state;
                      end
    check_parity_error : begin
                         if (!fifo_fullf)
                            next_state = decode_address;
                         else next_state = fifo_full_state; end
    load_after_full : begin 
                      if (parity_done)
                          next_state = decode_address;
                      else if (!parity_done && low_pkt_valid)
                          next_state = load_parity;
                      else if (!parity_done && !low_pkt_valid)
                          next_state = load_data;
                      else
                          next_state = load_after_full;
                      end
    wait_till_empty : begin 
                      if ((fifo_empty_0 && (addr == 0)) ||
                          (fifo_empty_1 && (addr == 1)) ||
                          (fifo_empty_0 && (addr == 0)))
                         next_state = load_first_data; 
                      else next_state = wait_till_empty;
                      end
    default: next_state = decode_address;
    endcase
end
// Output assignment
assign detect_add = (present_state == decode_address);
assign ld_state = (present_state == load_data);
assign laf_state = (present_state == load_after_full);
assign full_state = (present_state ==  fifo_full_state);
assign write_enb_regf = ((present_state == load_data) || (present_state == load_parity) || (present_state == load_after_full));
assign rst_int_reg = (present_state == check_parity_error);
assign lfd_state = (present_state == load_first_data);
assign busyf = !((present_state == decode_address) || (present_state == load_data));
endmodule
