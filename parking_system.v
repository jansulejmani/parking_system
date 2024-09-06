// Verilog code for an automated parking system

`timescale 1ns / 1ps // Sets time unit to 1ns and time precision to 1ps

module parking_system(
    input clk, reset_n, // Clock input & active-low reset input
    input sensor_entrance, sensor_exit, // Inputs from sensors detecting the entrance and exit of cars
    input [1:0] password_1, password_2, // 2-bit inputs representing two parts of the password
    output wire GREEN_LED, RED_LED, // Output wires controlling the green and red LEDs
    output reg [6:0] HEX_1, HEX_2 // 7-bit registers for controlling two 7-segment displays
);

// Definition of the states of the system using 3-bit values
parameter IDLE = 3'b000, WAIT_PASSWORD = 3'b001, WRONG_PASSWORD = 3'b010,
RIGHT_PASSWORD = 3'b011, STOP = 3'b100;
reg[2:0] current_state, next_state; // 3-bit registers to hold current and next state
reg[31:0] counter_wait; // 32-bit counter register
reg red_tmp, green_tmp; // Temporary register for controlling the LED states

// Resets to IDLE if reset is active (low) or continues to next state
always @(posedge clk or negedge reset_n)
begin
    if(~reset_n)
    current_state = IDLE;
    else
    current_state = next_state;
end

// Resets counter if reset is active (low) or increments the wait counter
always @(posedge clk or negedge reset_n)
begin
    if(~reset_n)
    counter_wait <= 0;
    else if(current_state==WAIT_PASSWORD)
    counter_wait <= counter_wait + 1;
    else
    counter_wait <= 0;
end

// Updates next_state based on current_state (Implements the state diagram)
always @(*)
begin
    case (current_state)
    IDLE: begin
        if(sensor_entrance == 1)
        next_state = WAIT_PASSWORD;
        else
        next_state = IDLE;
    end
    WAIT_PASSWORD: begin
        if (counter_wait <= 3)
        next_state = WAIT_PASSWORD;
        else
        begin
            if((password_1==2'b01) && (password_2==2'b10))
            next_state = RIGHT_PASSWORD;
            else
            next_state = WRONG_PASSWORD;
        end
    end
    WRONG_PASSWORD: begin
        if((password_1==2'b01) && (password_2==2'b10))
            next_state = RIGHT_PASSWORD;
            else
            next_state = WRONG_PASSWORD;
    end
    RIGHT_PASSWORD: begin
        if(sensor_entrance==1 && sensor_exit == 1)
        next_state = STOP;
        else if(sensor_exit==1)
        next_state = IDLE;
        else
        next_state = RIGHT_PASSWORD;
    end
    STOP: begin
        if((password_1==2'b01) && (password_2==2'b10))
        next_state = RIGHT_PASSWORD;
        else
        next_state = STOP;
    end
    default: next_state = IDLE;
    endcase
end

// LEDs and output
always @(posedge clk) begin
    case (current_state)
    IDLE: begin
        green_tmp = 1'b0;
        red_tmp = 1'b0;
        HEX_1 = 7'b1111111; // Off
        HEX_2 = 7'b1111111; // Off
    end
    WAIT_PASSWORD: begin
        green_tmp = 1'b0;
        red_tmp = 1'b1;
        HEX_1 = 7'b000_0110; 
        HEX_2 = 7'b010_1011; 
    end
    WRONG_PASSWORD: begin
        green_tmp = 1'b0;
        red_tmp = ~red_tmp;
        HEX_1 = 7'b000_0110; 
        HEX_2 = 7'b000_0110; 
    end
    RIGHT_PASSWORD: begin
        green_tmp = ~green_tmp;
        red_tmp = 1'b0;
        HEX_1 = 7'b000_0010; 
        HEX_2 = 7'b100_0000; 
    end
    STOP: begin
        green_tmp = 1'b0;
        red_tmp = ~red_tmp;
        HEX_1 = 7'b001_0010; 
        HEX_2 = 7'b000_1100; 
    end
endcase
end
assign RED_LED = red_tmp;
assign GREEN_LED = green_tmp;
endmodule