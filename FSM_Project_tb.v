`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.01.2024 15:01:52
// Design Name: 
// Module Name: FSM_Project_tb
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


module FSM_Project_tb();
reg clock,resetn,pkt_valid,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,parity_done;
reg [1:0] data_in;
reg low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
wire busy,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state;
FSM_Project uut(clock,resetn,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
reg [2:0]a,b;
initial begin
    clock = 1'b0;
    while (1)
    #5 clock = ~clock;
end

// Task for initialization
task initilize();
begin
    {resetn,pkt_valid,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,parity_done} = 7'd0;
    {data_in} = 2'd0;
    {low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2} = 4'b0111;
end
endtask
//Reset task
task reset();
begin
    @(negedge clock)
    resetn = 1'b0;
    @(negedge clock)
    resetn = 1'b1;
end
endtask
// Task 1
// da - lfd - ld - lp - cpe - da
task t1();
begin
    @(negedge clock)
    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;
    @(negedge clock)
    fifo_empty_1 = 1'b0;
    fifo_full = 1'b0;
    pkt_valid = 1'b0;
    @(negedge clock)
    @(negedge clock)
    fifo_full = 1'b0;
end
endtask
// Task 2
// da - lfd - ffs - laf - ld - lp - cpe - da
task t2();
begin
   @(negedge clock)
   pkt_valid = 1'b1;
   data_in = 2'b01;
   fifo_empty_1 = 1'b1; 
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b1;
   @(negedge clock)
   fifo_full = 1'b0;
   @(negedge clock)
   parity_done = 1'b0;
   low_pkt_valid = 1'b1;
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b0;
   // to make it stay in da after completing
   pkt_valid = 1'b0;
   fifo_empty_1 = 1'b0;
end
endtask

// Task 3
// da - lfd - ld - ffs - laf - ld - lp - cpe - da
task t3();
begin
   @(negedge clock)
   pkt_valid = 1'b1;
   data_in = 2'b01;
   fifo_empty_1 = 1'b1; 
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b1;
   @(negedge clock)
   fifo_full = 1'b0;
   @(negedge clock)
   parity_done = 1'b0;
   low_pkt_valid = 1'b0;
   @(negedge clock)
   fifo_full = 1'b0;
   pkt_valid = 1'b0;
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b0;
end
endtask

//Task 4
// da - lfd - ld - lp - cpe - ffs - laf - da
task t4();
begin
   @(negedge clock)
   pkt_valid = 1'b1;
   data_in = 2'b01;
   fifo_empty_1 = 1'b1; 
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b0;
   pkt_valid = 1'b0;
   @(negedge clock)
   @(negedge clock)
   fifo_full = 1'b1;
   @(negedge clock)
   fifo_full = 1'b0;
   @(negedge clock)
   parity_done = 1'b1;
end
endtask

endmodule
