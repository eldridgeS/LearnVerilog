`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Bi-directional Traffic Light FSM implementation with state timer
// Improved from this: https://www.youtube.com/watch?v=77OjVgGVmSs&t=728s
//////////////////////////////////////////////////////////////////////////////////


module traffic_light_controller(
    input clk, reset_n,
    input Sa, Sb,
    output reg Ra, Ya, Ga,
    output reg Rb, Yb, Gb
    );
    
    reg [2:0] current_state, next_state;
    parameter GaRb = 0, YaRb = 1, RaRb = 2,
               RaGb = 3, RaYb = 4, RaRb2 = 5;
               
    reg [5:0] state_timer;
    parameter DURATION_GaRb = 7;
//    parameter DURATION_GaRb2 = 3;
    parameter DURATION_YaRb = 3;
    parameter DURATION_RaRb = 3;
    parameter DURATION_RaGb = 7;
//    parameter DURATION_RaGb2 = 3;
    parameter DURATION_RaYb = 3;
    parameter DURATION_RaRb2 = 3;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= GaRb;
            state_timer <= DURATION_GaRb;
        end else begin
        current_state <= next_state;
            if (current_state != next_state) begin
                case(next_state)
                    GaRb: state_timer <= DURATION_GaRb;
//                    GaRb2: state_timer <= DURATION_GaRb2;
                    YaRb: state_timer <= DURATION_YaRb;
                    RaRb: state_timer <= DURATION_RaRb;
                    RaGb: state_timer <= DURATION_RaGb;
//                    RaGb2: state_timer <= DURATION_RaGb2;
                    RaYb: state_timer <= DURATION_RaYb;
                    RaRb2: state_timer <= DURATION_RaRb2;
                endcase
            end else if (state_timer > 0) begin
                state_timer <= state_timer - 1;
            end
        end
    end
    
    always @(*) begin
        if (!reset_n) begin
            next_state = GaRb;
        end else begin
            next_state = current_state;
            case (current_state)
                YaRb, RaRb, RaYb:
                    if (state_timer == 0) begin
                        next_state = current_state + 1;
                    end 
                GaRb:
                    if (state_timer == 0 && Sb) begin
                        next_state = current_state + 1;
                    end
                RaGb:
                    if (state_timer == 0 && (Sa || ~Sb)) begin
                        next_state = current_state + 1;
                    end
                RaRb2:
                    if (state_timer == 0) begin 
                        next_state = GaRb;
                    end
            endcase
       end
   end     


    // Output logic (combinational or sequential, depending on your needs)
    always @(*) begin
        Ra = 0; Ya = 0; Ga = 0;
        Rb = 0; Yb = 0; Gb = 0;
        case (current_state)
            GaRb: begin Ga = 1; Rb = 1; end
            YaRb: begin Ya = 1; Rb = 1; end
            RaGb: begin Ra = 1; Gb = 1; end
            RaYb: begin Ra = 1; Yb = 1; end
            default: begin Ra = 1; Rb = 1; end
        endcase
    end

endmodule
