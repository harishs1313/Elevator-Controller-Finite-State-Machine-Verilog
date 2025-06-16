`timescale 1ns / 1ps

module ElevatorController_tb;

    reg clk, reset;
    reg up_request, down_request;
    reg [1:0] current_floor, target_floor;
    reg emergency_stop;

    wire move_up, move_down, door_open, stopped;
    wire [2:0] state;  // For debugging

    // Instantiate the DUT
    ElevatorController dut (
        .clk(clk),
        .reset(reset),
        .up_request(up_request),
        .down_request(down_request),
        .current_floor(current_floor),
        .target_floor(target_floor),
        .emergency_stop(emergency_stop),
        .move_up(move_up),
        .move_down(move_down),
        .door_open(door_open),
        .stopped(stopped),
        .state(state)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Stimulus
    initial begin
        $dumpfile("ElevatorController2.vcd");
        $dumpvars(0, ElevatorController_tb);

        // Initial states
        reset = 1;
        up_request = 0;
        down_request = 0;
        current_floor = 2;
        target_floor = 2;
        emergency_stop = 0;

        #10 reset = 0;

        // Request to go up from floor 2 to 3
        #10 target_floor = 3;
            up_request = 1;

        #20 up_request = 0;
            current_floor = 3; // Simulate arrival

        // Wait for door to open and close
        #50;

        // Request to go down from 3 to 1
        target_floor = 1;
        down_request = 1;

        #20 down_request = 0;
            current_floor = 1;

        #50;

        // Emergency stop while idle
        emergency_stop = 1;
        #20 emergency_stop = 0;

        // Emergency stop during movement
        target_floor = 3;
        up_request = 1;
        #20 up_request = 0;
            current_floor = 2;
        #10 emergency_stop = 1;
        #20 emergency_stop = 0;
        current_floor = 3;

        #100 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | Floor=%d -> %d | UP=%b DOWN=%b DOOR=%b STOP=%b | State=%b | up_req=%b down_req=%b emergency=%b",
                 $time, current_floor, target_floor, move_up, move_down, door_open, stopped, state,
                 up_request, down_request, emergency_stop);
    end

endmodule
