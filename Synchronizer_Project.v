`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.01.2024 08:32:39
// Design Name: 
// Module Name: Synchronizer_Project
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


module Synchronizer_Project(detect_adds,data_ins,write_enb_reg,clocks,resetns,valid_out_0s,valid_out_1s,valid_out_2s,read_enb_0s,read_enb_1s,read_enb_2s,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
// Input & Output port declaration
input detect_adds,write_enb_reg,clocks,resetns;
input read_enb_0s,read_enb_1s,read_enb_2s;
input [1:0] data_ins;
input empty_0,empty_1,empty_2,full_0,full_1,full_2;
output valid_out_0s,valid_out_1s,valid_out_2s;
output reg soft_reset_0,soft_reset_1,soft_reset_2 , fifo_full;
output reg [2:0] write_enb;
// Declaring a 2bit temp memory for storing data_in
reg [1:0]din;
// Declaring 3 internal variables for counting 30 clock cycles
reg [4:0] cnt0, cnt1,cnt2;
// Assigning valid out signal
assign valid_out_0s = !empty_0;
assign valid_out_1s = !empty_1;
assign valid_out_2s = !empty_2;

always@(posedge clocks)
begin
    if (~resetns)
        din <= 2'b0;
    // Capturing the adderess 
    else if (detect_adds)
        din <= data_ins;
end

// Defining write enable and fifo full
always@(*)
begin
    case(din)
    2'b00: begin
           fifo_full <= full_0;
           if (write_enb_reg)
               write_enb <=3'b001;
           else
               write_enb <= 0;
           end
    2'b01: begin
           fifo_full<=full_1;
           if(write_enb_reg)
               write_enb<=3'b010;
           else
               write_enb<=0;
           end
    2'b10: begin
           fifo_full<=full_2;
           if(write_enb_reg)
               write_enb<=3'b100;
           else
               write_enb<=0;
           end
    default: begin
            fifo_full<=0;
            write_enb<=0;
            end
    endcase 
end
// Defining Valid out 0
always@(posedge clocks)
begin
	if(~resetns)
	begin
		cnt0<=0;
		soft_reset_0<=0;
	end
	else if(valid_out_0s)
	begin
		if(~read_enb_0s)
		begin
			if(cnt0==29)
			begin
				soft_reset_0<=1'b1;
				cnt0<=0;
			end
			else
			begin
				soft_reset_0<=1'b0;
				cnt0<=cnt0+1'b1;
			end
		end
		else
			cnt0<=0;
	end
end

// Defining Valid out 1
always@(posedge clocks)
begin
	if(~resetns)
	begin
		cnt1<=0;
		soft_reset_1<=0;
	end
	else if(valid_out_1s)
	begin
		if(~read_enb_1s)
		begin
			if(cnt1==29)
			begin
				soft_reset_1<=1'b1;
				cnt1<=0;
			end
			else
			begin
				soft_reset_1<=1'b0;
				cnt1<=cnt1+1'b1;
			end
		end
		else
			cnt1<=0;
	end
end

// Defining Valid out 2
always@(posedge clocks)
begin
	if(~resetns)
	begin
		cnt2<=0;
		soft_reset_2<=0;
	end
	else if(valid_out_2s)
	begin
		if(~read_enb_2s)
		begin
			if(cnt2==29)
			begin
				soft_reset_2<=1'b1;
				cnt2<=0;
			end
			else
			begin
				soft_reset_2<=1'b0;
				cnt2<=cnt2+1'b1;
			end
		end
		else
			cnt2<=0;
	end
end
           

 /* always@(posedge clocks)
begin
    // Defining reset condition
    if(!resetns)
    begin
        din <= 2'b0;
        {cnt_0, cnt_1,cnt_2} = 15'd0;
        {soft_reset_0,soft_reset_1,soft_reset_2} <= 3'd0;
        write_enb = 3'd0;  
    end
    // Capturing the address
    else if (detect_adds == 1'b1)
    begin
        din <= data_ins;
    end
        // Defining Write Enable outputs
    if (write_enb_reg == 1'b1)
    begin
    // One Hot encoding
        if (din == 2'b00)
            write_enb = 3'b001;
        else if (din == 2'b01)
            write_enb = 3'b010;
        else if (din == 2'b10)
            write_enb = 3'b100;
    end
    else write_enb = 3'b000;
        // Defining the fifo full signal
        if (din == 2'b00)
            fifo_full = full_0;
        else if (din == 2'b01)
            fifo_full = full_1;
        else if (din == 2'b10)
            fifo_full = full_2;
        // Defining the soft reset 0
        if ( valid_out_0s == 1'b1)
        begin
            if(read_enb_0s == 1'b0)
            begin
                cnt_0 = (cnt_0 == 29) ? 0 : cnt_0 + 1;
                if (cnt_0 == 29) begin
                    soft_reset_0 <= 1;
                    end
            end
            else begin
                cnt_0 = 0;
                soft_reset_0 <= 0;
                end    
        end
        // Defining the soft reset 1
        if ( valid_out_1s == 1'b1)
        begin
            if(read_enb_1s == 1'b0)
            begin
                cnt_1 = (cnt_1 == 29) ? 0 : cnt_1 + 1;
                if (cnt_1 == 29) begin
                    soft_reset_1 <= 1;
                    end
            end
            else begin
                cnt_1 = 0;
                soft_reset_1 <= 0;
                end    
        end
        // Defining the soft reset 2
        if (valid_out_2s == 1'b1)
        begin
            if(read_enb_2s == 1'b0)
            begin
                cnt_2 = (cnt_2 == 29) ? 0 : cnt_2 + 1;
                if (cnt_2 == 29) begin
                    soft_reset_2 <= 1;
                    end
            end
            else begin
                cnt_2 = 0;
                soft_reset_2 <= 0;
                end    
        end
end*/
endmodule

