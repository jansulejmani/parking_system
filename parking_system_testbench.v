// Testbench Verilog code for an automated car parking system
`timescale 1ns / 1ps
module parking_system_testbench;
    // Inputs
    reg clk;
    reg reset_n;
    reg sensor_entrance;
    reg sensor_exit;
    reg [1:0] password_1;
    reg [1:0] password_2;

    // Outputs
    wire GREEN_LED;
    wire RED_LED;
    wire [6:0] HEX_1;
    wire [6:0] HEX_2;

    // Instantiating the parking_system
    parking_system uut (
        .clk(clk),
        .reset_n(reset_n),
        .sensor_entrance(sensor_entrance),
        .sensor_exit(sensor_exit),
        .password_1(password_1),
        .password_2(password_2),
        .GREEN_LED(GREEN_LED),
        .RED_LED(RED_LED),
        .HEX_1(HEX_1),
        .HEX_2(HEX_2)
    );

    // Generating clock signal
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Providing input signals
    initial begin
        // Initializing inputs
        reset_n = 0;
        sensor_entrance = 0;
        sensor_exit = 0;
        password_1 = 0;
        password_2 = 0;

        // Wait 100ns for global reset
        #100;
        reset_n = 1;
        // Activate sensor_entrance after 20ns
        #20;
        sensor_entrance = 1;
        // Set passwords after 1000ns
        #1000;
        sensor_entrance = 0;
        password_1 = 1;
        password_2 = 2;
        // Activate sensor_exit after 2000ns
        #2000;
        sensor_exit = 1;
    end

    initial begin
        $dumpfile("parking_system_testbench.vcd");
        $dumpvars(0, parking_system_testbench);
    end
endmodule