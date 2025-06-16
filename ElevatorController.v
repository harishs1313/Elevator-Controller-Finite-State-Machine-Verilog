`timescale 1ns / 1ps

module ElevatorController (
    input clk,
    input reset,
    input up_request,
    input down_request,
    input [1:0] current_floor,
    input [1:0] target_floor,
    input emergency_stop,
    output reg move_up,
    output reg move_down,
    output reg door_open,
    output reg stopped,
    output reg [2:0] state  // For debugging
);

// State encoding
localparam IDLE            = 3'b000,
           MOVING_UP       = 3'b001,
           MOVING_DOWN     = 3'b010,
           DOOR_OPEN       = 3'b011,
           EMERGENCY_STOP  = 3'b100;

reg [3:0] door_timer;
reg [2:0] next_state;

// FSM State Transition
always @(posedge clk or posedge reset) begin
    if (reset)
        state <= IDLE;
    else
        state <= next_state;
end

// FSM Next State Logic
always @(*) begin
    case (state)
        IDLE: begin
            if (emergency_stop)
                next_state = EMERGENCY_STOP;
            else if (up_request && current_floor < target_floor)
                next_state = MOVING_UP;
            else if (down_request && current_floor > target_floor)
                next_state = MOVING_DOWN;
            else
                next_state = IDLE;
        end

        MOVING_UP: begin
            if (emergency_stop)
                next_state = EMERGENCY_STOP;
            else if (current_floor == target_floor)
                next_state = DOOR_OPEN;
            else
                next_state = MOVING_UP;
        end

        MOVING_DOWN: begin
            if (emergency_stop)
                next_state = EMERGENCY_STOP;
            else if (current_floor == target_floor)
                next_state = DOOR_OPEN;
            else
                next_state = MOVING_DOWN;
        end

        DOOR_OPEN: begin
            if (emergency_stop)
                next_state = EMERGENCY_STOP;
            else if (door_timer == 0)
                next_state = IDLE;
            else
                next_state = DOOR_OPEN;
        end

        EMERGENCY_STOP: begin
            if (!emergency_stop)
                next_state = IDLE; // Go back to idle after emergency clears
            else
                next_state = EMERGENCY_STOP;
        end

        default: next_state = IDLE;
    endcase
end

// FSM Output Logic and door timer
always @(posedge clk or posedge reset) begin
    if (reset) begin
        move_up    <= 0;
        move_down  <= 0;
        door_open  <= 0;
        stopped    <= 1;
        door_timer <= 0;
    end else begin
        case (state)
            IDLE: begin
                move_up    <= 0;
                move_down  <= 0;
                door_open  <= 0;
                stopped    <= 1;
                door_timer <= 0;
            end

            MOVING_UP: begin
                move_up    <= 1;
                move_down  <= 0;
                door_open  <= 0;
                stopped    <= 0;
            end

            MOVING_DOWN: begin
                move_up    <= 0;
                move_down  <= 1;
                door_open  <= 0;
                stopped    <= 0;
            end

            DOOR_OPEN: begin
                move_up    <= 0;
                move_down  <= 0;
                door_open  <= 1;
                stopped    <= 1;
                if (door_timer == 0)
                    door_timer <= 4;  // Keep door open for 4 cycles
                else
                    door_timer <= door_timer - 1;
            end

            EMERGENCY_STOP: begin
                move_up    <= 0;
                move_down  <= 0;
                door_open  <= 0;
                stopped    <= 1;
                door_timer <= 0;
            end

            default: begin
                move_up    <= 0;
                move_down  <= 0;
                door_open  <= 0;
                stopped    <= 1;
                door_timer <= 0;
            end
        endcase
    end
end

endmodule
