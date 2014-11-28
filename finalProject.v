`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:34:45 11/10/2014 
// Design Name: 
// Module Name:    helicopter_game 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module helicopter_game(ClkPort, btnC, btnL, btnR, btnU, vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, vgaRed1, vgaRed2, vgaGreen1, vgaGreen2, vgaBlue2
    );

//inputs

input ClkPort;
input btnC;
input btnL;
input btnR;
input btnU;

//output

output vga_h_sync, vga_v_sync, vga_r, vga_g, vga_b, vgaRed1, vgaRed2, vgaGreen1, vgaGreen2, vgaBlue2;

//localparam

wire ClkPort, reset, vga_clk, inDisplayArea;
wire [9:0] CounterX;
wire [9:0] CounterY;

reg [26:0] div_clk;
reg vga_r, vga_g, vga_b,vgaRed1, vgaRed2,vgaGreen1, vgaGreen2, vgaBlue2;

//state machine variables
reg [9:0] playerScore;
reg [9:0] highScore;
reg [9:0] playerLoc;
reg hsFlag;
reg collision;

assign reset = btnC;
assign startButton = btnU; //ASSIGNS THE START BUTTON TO THE UP BUTTON, HAVE TO CHANGE OTHER FILE
assign leftButton  = btnL;
assign rightButton = btnR;

always @ (posedge ClkPort, posedge reset)
	begin
		if (reset)
			div_clk <= 0;
		else
			div_clk <= div_clk + 1'b1;
	end
assign vga_clk = div_clk[1];

hvsync_generator videoout(
.clk(vga_clk), 
.reset(reset), 
.vga_h_sync(vga_h_sync),
.vga_v_sync(vga_v_sync),
.inDisplayArea(inDisplayArea),
.CounterX(CounterX),
.CounterY(CounterY)
);

always @ (posedge vga_clk)
	begin
		vga_r <= white & inDisplayArea;
		vga_g <= white & inDisplayArea;
		vga_b <= white & inDisplayArea;
		vgaRed1 <= white & inDisplayArea;
		vgaRed2 <= white & inDisplayArea;
		vgaGreen1 <= white & inDisplayArea;
		vgaGreen2 <= white & inDisplayArea;
		vgaBlue2  <= white & inDisplayArea;
	end

//playerIcon is 10 px wide and is NOT centered around the playerLoc but instead that is the leftmost location
wire playerIcon = (CounterY >= 460 && CounterY <= 470) && (CounterX >= playerLoc && CounterX <= (playerLoc + 10));

wire white = playerIcon;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//                             STATE MACHINE

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

reg [2:0] state; //state variable

localparam 	
		INIT   = 3’b000, //initial state
		PLAY   = 3’b001, //playing state
		NEWHS  = 3’b010, //new high score state
		DEAD   = 3’b011, //dead state (possibly unneeded)
		UNK    = 3’bXXX; //unclear state for everything else

always @ (posedge vga_clk, posedge reset) begin: STATE_MACHINE

	if (reset) begin
		//CODE FOR RESETTING GOES HERE, CENTER THE PLAYER, CLEAR SCORE, ETC.
		playerLoc <= 315;
		state <= INIT;
	end

	else begin
		case (state)
			INIT: begin
				//state transitions
				if (startButton) begin
					state <= PLAY;
				end

				//rtl logic
				playerScore <= 0;
				playerLoc <= 315;
			end

			PLAY: begin
				//state transitions

				
				//rtl logic
				if (rightButton) begin
					playerLoc <= playerLoc + 5;
				end
				else if (leftButton) begin
					playerLoc <= playerLoc - 5;
				end
				if (collision == 1 && hsFlag == 1) begin
					state <= NEWHS;
				end
				else if (collision == 1 && hsFlag == 0) begin
					state <= DEAD;
				end
			end

			NEWHS: begin
				//state transitions
				state <= INIT;

				//rtl logic
			end

			DEAD: begin
				//state transitions
				state <= INIT;

				//rtl logic
			end

			default: begin
				state <= UNK;
			end
		endcase
	end
		

endmodule
