`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.01.2024 11:26:53
// Design Name: 
// Module Name: Register_Project
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


/* module Register_Project(clockr,resetnr,pkt_validr,data_inr,fifo_fullr,rst_int_regr,detect_addr,ld_stater,laf_stater,full_stater,lfd_state,parity_doner,low_pkt_validr,err,data_out);
input clockr,resetnr,pkt_validr,fifo_fullr,rst_int_regr,detect_addr,ld_stater,laf_stater,full_stater,lfd_state;
input [7:0] data_inr;
output reg parity_doner,err;
output reg [7:0] data_out;
output low_pkt_validr;
// Internal registers for header byte and fifo full state
reg [7:0] header_byte,ffs;
// Internal Parity and packet parity
reg [7:0] internal_parity , packet_parity ;
integer i = 0;
reg [5:0] x ;
assign low_pkt_validr = ~pkt_validr;
always@(posedge clockr)
begin
     // Reset Condition
     if (!resetnr)
     begin
        data_out <= 8'd0;
        {header_byte,parity_doner,err} <= 3'd0;
     end
     //Storing the header byte data internally
     else if (detect_addr == 1'b1)
     begin
        header_byte <= data_inr;
        parity_doner <= 1'b0;
        internal_parity <= 8'd0;
     end
     // Displaying the header byte
     else if (lfd_state && pkt_validr && data_inr[1:0]!= 2'b11)
     begin
         data_out <= header_byte;
         x <= header_byte[7:2] + 1'b1;
         if (full_stater == 1'b0 && pkt_validr == 1'b1)
            internal_parity <= internal_parity ^ header_byte;
     end    
end

always@(posedge clockr)
begin
    // Loading data into memory
     if (ld_stater == 1'b1 && !fifo_fullr)
     begin
        data_out <= data_inr;
        x <= x - 1'b1;
        if (full_stater == 1'b0 && pkt_validr == 1'b1)
            internal_parity <= internal_parity ^ data_inr;
     end
     // Preserving data when full is high
     else if (ld_stater && fifo_fullr == 1'b1)
     begin
        ffs <= data_inr;
        x <= x - 1'b1;
        if (full_stater == 1'b0 && pkt_validr == 1'b1)
            internal_parity <= internal_parity ^ ffs;
        else if (laf_stater == 1'b1) begin
           data_out <=  ffs;
           end
     end  
end

always@(posedge clockr)
begin
    // Defining the Error Signal
     if (x == 1) 
        packet_parity <= data_inr;
     else if (rst_int_regr)
        {internal_parity,packet_parity} <= 14'd0;
     if (pkt_validr == 1'b0)
         if (internal_parity != packet_parity)
            err <= 1'b1;
     else
        err <= 1'b0;
     if ((ld_stater && !fifo_fullr && !pkt_validr) || (laf_stater && low_pkt_validr &&!parity_doner))
        parity_doner <= 1'b1;
     else if (laf_stater && low_pkt_validr && !parity_doner)
        parity_doner <= 1'b0;
end
endmodule */



// Outside codeeeee
module Register_Project(input clockr,resetnr,pkt_validr,
input [7:0] data_inr,
input fifo_fullr,detect_addr,ld_stater,laf_stater,full_stater,lfd_state,rst_int_regr,
output reg err,parity_doner,low_pkt_validr,
output reg [7:0] data_out);
reg [7:0] hold_header_byte,fifo_full_state_byte,internal_parity,packet_parity_byte;
//parity done
always@(posedge clockr)
begin
	if(!resetnr)
	begin
		parity_doner<=1'b0;
	end
	else
	begin
		if(ld_stater && !fifo_fullr && !pkt_validr)
			parity_doner<=1'b1;
		else if(laf_stater && low_pkt_validr && !parity_doner)
			parity_doner<=1'b1;
		else
		begin
			if(detect_addr)
				parity_doner<=1'b0;
		end
	end
end
//low_packet valid
always@(posedge clockr)
begin
	if(!resetnr)
		low_pkt_validr<=1'b0;
	else
	begin
		if(rst_int_regr)
			low_pkt_validr<=1'b0;
		if(ld_stater==1'b1 && pkt_validr==1'b0)
			low_pkt_validr<=1'b1;
	end
end
//dout
always@(posedge clockr)
begin
	if(!resetnr)
		data_out<=8'b0;
	else
	begin
		if(detect_addr && pkt_validr)
			hold_header_byte<=data_inr;
		else if(lfd_state)
			data_out<=hold_header_byte;
		else if(ld_stater && !fifo_fullr)
			data_out<=data_inr;
		else if(ld_stater && fifo_fullr)
			fifo_full_state_byte<=data_inr;
		else
		begin
		if(laf_stater)
			data_out<=fifo_full_state_byte;
		end
	end
end
// internal parity
always@(posedge clockr)
	begin
		if(!resetnr)
			internal_parity<=8'b0;
		else if(lfd_state)
			internal_parity<=internal_parity ^ hold_header_byte;
		else if(ld_stater && pkt_validr && !full_stater)
			internal_parity<=internal_parity ^ data_inr;
		else
		begin
			if (detect_addr)
				internal_parity<=8'b0;
		end
end
//error and packet_
always@(posedge clockr)
begin
	if(!resetnr)
		packet_parity_byte<=8'b0;
	else
	begin
		if(!pkt_validr && ld_stater)
			packet_parity_byte<=data_inr;
	end
end
//error
always@(posedge clockr)
begin
	if(!resetnr)
		err<=1'b0;
	else
	begin
		if(parity_doner)
		begin
			if(internal_parity!=packet_parity_byte)
				err<=1'b1;
			else
				err<=1'b0;
		end
	end
end
endmodule
