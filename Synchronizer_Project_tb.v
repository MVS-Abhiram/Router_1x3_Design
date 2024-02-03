`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2024 15:28:23
// Design Name: 
// Module Name: Synchronizer_Project_tb
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


module Synchronizer_Project_tb();
reg clock,detect_add,write_enb_reg,resetn;
reg read_enb_0,read_enb_1,read_enb_2;
reg [1:0] data_in;
reg empty_0,empty_1,empty_2,full_0,full_1,full_2;
wire valid_out_0,valid_out_1,valid_out_2;
wire soft_reset_0,soft_reset_1,soft_reset_2 , fifo_full;
wire [2:0] write_enb;
// Instantiating the module
Synchronizer_Project uut(detect_add,data_in,write_enb_reg,clock,resetn,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
initial begin
    clock = 1'b0;
    while(1)
    #5 clock =~clock;
end
// Task for initialization
task initialize();
begin
    {detect_add,write_enb_reg,resetn} = 3'b000;
    {read_enb_0,read_enb_1,read_enb_2} = 3'd0;
    {empty_0,empty_1,empty_2,full_0,full_1,full_2} = 6'b111000;
    {data_in} = 2'b00;
end
endtask

task inputs();
begin
    @(negedge clock)
    resetn = 1'b1;
    detect_add = 1'b1;
    data_in = 2'b10;
    #15 write_enb_reg = 1'b1;
    #10 {full_0,full_1,full_2} = 3'b000;
    #10 {empty_0,empty_1,empty_2} = 3'b110;
    {read_enb_0,read_enb_1,read_enb_2} = 3'b110;
    #100 read_enb_2 = 1'b1;
end
endtask
initial begin
    initialize();
    #5;
    inputs();
    #200;
    read_enb_2 = 1'b0;
end
endmodule
