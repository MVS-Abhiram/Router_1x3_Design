`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.01.2024 10:31:03
// Design Name: 
// Module Name: Router_Top_Level_1x3
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


module Router_Top_Level_1x3(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,data_out_0,data_out_1,data_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);
input clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
input [7:0] data_in;
output valid_out_0,valid_out_1,valid_out_2,error,busy;
output [7:0] data_out_0,data_out_1,data_out_2;
// Cnt to count the pkt_valid signal
reg [6:0] cnt = 7'd0;
// Store the adddress bits
reg [1:0] address_bits = 2'd0;
// Capturing the address bit to instantiate the fsm and synchronizer

wire [2:0] soft_reset,write_enable,empty,full_f,valid_out;
wire [7:0] reg_out;
//assign data_in = datain;
assign valid_out_0 = valid_out[0];
assign valid_out_1 = valid_out[1];
assign valid_out_2 = valid_out[2];
// Instantiating Router FIFO - 1
FIFO_Project fifo_0
            (.clk(clock)
            ,.resetnfi(resetn)
            ,.soft_reset(soft_reset[0])
            ,.read_enb(read_enb_0)
            ,.write_enb(write_enable[0])
            ,.data_infi(reg_out)
            ,.lfd_statefi(lfdstate)
            ,.data_out(data_out_0),
            .empty(empty[0])
            ,.full(full_f[0]));
// Instantiating Router FIFO - 1
FIFO_Project fifo_1
            (.clk(clock)
            ,.resetnfi(resetn)
            ,.soft_reset(soft_reset[1])
            ,.read_enb(read_enb_1)
            ,.write_enb(write_enable[1])
            ,.data_infi(reg_out)
            ,.lfd_statefi(lfdstate)
            ,.data_out(data_out_1),
            .empty(empty[1])
            ,.full(full_f[1]));
// Instantiating Router FIFO - 2
FIFO_Project fifo_2
            (.clk(clock)
            ,.resetnfi(resetn)
            ,.soft_reset(soft_reset[2])
            ,.read_enb(read_enb_2)
            ,.write_enb(write_enable[2])
            ,.data_infi(reg_out)
            ,.lfd_statefi(lfdstate)
            ,.data_out(data_out_2),
            .empty(empty[2])
            ,.full(full_f[2]));

// Instantiating Router Synchronizer // ( fifo_full )
Synchronizer_Project sync(.detect_adds(detect_address)
                    ,.data_ins(data_in[1:0])
                    ,.write_enb_reg(write_en_reg)
                    ,.clocks(clock)
                    ,.resetns(resetn)
                    ,.valid_out_0s(valid_out[0])
                    ,.valid_out_1s(valid_out[1])
                    ,.valid_out_2s(valid_out[2])
                    ,.read_enb_0s(read_enb_0)
                    ,.read_enb_1s(read_enb_1)
                    ,.read_enb_2s(read_enb_2)
                    ,.write_enb(write_enable)
                    ,.fifo_full(fifofull)
                    ,.empty_0(empty[0])
                    ,.empty_1(empty[1])
                    ,.empty_2(empty[2])
                    ,.soft_reset_0(soft_reset[0])
                    ,.soft_reset_1(soft_reset[1])
                    ,.soft_reset_2(soft_reset[2])
                    ,.full_0(full_f[0])
                    ,.full_1(full_f[1])
                    ,.full_2(full_f[2]));

// Instantiating Router Controller FSM
FSM_Project fsm0(.clockf(clock)
                ,.resetnf(resetn)
                ,.pkt_validf(pkt_valid)
                ,.busyf(busy)
                ,.parity_done(paritydone)
                ,.data_inf(data_in[1:0])
                ,.soft_reset_0(soft_reset[0])
                ,.soft_reset_1(soft_reset[1])
                ,.soft_reset_2(soft_reset[2])
                ,.fifo_fullf(fifofull)
                ,.low_pkt_valid(lowpktvalid)
                ,.fifo_empty_0(empty[0])
                ,.fifo_empty_1(empty[1])
                ,.fifo_empty_2(empty[2])
                ,.detect_add(detect_address)
                ,.ld_state(ldstate)
                ,.laf_state(lafstate)
                ,.full_state(fullstate)
                ,.write_enb_regf(write_en_reg)
                ,.rst_int_reg(rstintreg)
                ,.lfd_state(lfdstate));

// Instantiating Router Register
Register_Project register(.clockr(clock)
                   ,.resetnr(resetn)
                   ,.pkt_validr(pkt_valid)
                   ,.data_inr(data_in)
                   ,.fifo_fullr(fifofull)
                   ,.rst_int_regr(rstintreg)
                   ,.detect_addr(detect_address)
                   ,.ld_stater(ldstate)
                   ,.laf_stater(lafstate)
                   ,.full_stater(fullstate)
                   ,.lfd_state(lfdstate)
                   ,.parity_doner(paritydone)
                   ,.low_pkt_validr(lowpktvalid)
                   ,.err(error)
                   ,.data_out(reg_out));
endmodule
