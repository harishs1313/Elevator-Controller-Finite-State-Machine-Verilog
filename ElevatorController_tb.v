`timescale 1ns / 1ps

module ElevatorController_tb;

reg clk, reset;
reg up_request, down_request;
reg [1:0] current_floor, target_floor;
reg emergency_stop;

wire move_up, move_down, door_open, stopped;
wire [2:0] state;

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
always #5 clk = ~clk; // 10ns clock cycle

initial begin
    $dumpfile("ElevatorController.vcd");
    $dumpvars(0, ElevatorController_tb);

    // Initialize
    reset = 1;
    up_request = 0;
    down_request = 0;
    current_floor = 2'b00;
    target_floor = 2'b00;
    emergency_stop = 0;

    #10 reset = 0;

    // Test up request from floor 0 to 3
    current_floor = 2'b00; target_floor = 2'b11;
    up_request = 1; #10;
    up_request = 0;

    // Simulate arrival at target floor
    #50 current_floor = 2'b01;
    #50 current_floor = 2'b10;
    #50 current_floor = 2'b11;

    // Door opens at target floor
    #50;

    // Emergency during door open
    emergency_stop = 1; #20;
    emergency_stop = 0;

    // Test down request from floor 3 to 1
    current_floor = 2'b11; target_floor = 2'b01;
    down_request = 1; #10;
    down_request = 0;

    #50 current_floor = 2'b10;
    #50 current_floor = 2'b01;

    // Let door open and close
    #100;

    $finish;
end

initial begin
    $monitor("Time: %3t | Floor: %b | Target: %b | Up: %b | Down: %b | MoveUp: %b | MoveDown: %b | Door: %b | Emergency: %b | State: %b",
             $time, current_floor, target_floor, up_request, down_request,
             move_up, move_down, door_open, emergency_stop, state);
end

endmodule
