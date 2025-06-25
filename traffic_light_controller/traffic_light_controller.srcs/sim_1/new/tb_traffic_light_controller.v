`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for the Bi-directional Traffic Light FSM Controller
//////////////////////////////////////////////////////////////////////////////////

module tb_traffic_light_controller;

    //Testbench inputs
    reg clk;       
    reg reset_n;    
    reg Sa;          
    reg Sb;        

    //Testbench outputs
    wire Ra, Ya, Ga;
    wire Rb, Yb, Gb; 
    wire [1:0] light_a, light_b;
    localparam R = 0;
    localparam Y = 1;
    localparam G = 2;
    assign light_a = Ra ? R : Ya ? Y : Ga ? G : light_a;
    assign light_b = Rb ? R : Yb ? Y : Gb ? G : light_b;
    
    // Instantiate DUT
    traffic_light_controller dut (
        .clk(clk),
        .reset_n(reset_n),
        .Sa(Sa),
        .Sb(Sb),
        .Ra(Ra),
        .Ya(Ya),
        .Ga(Ga),
        .Rb(Rb),
        .Yb(Yb),
        .Gb(Gb)
    );

    //Clock
    parameter CLK_PERIOD = 10; // 10ns clock period
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $display("--------------------------------------------------");
        $display("--- Starting Traffic Light Controller Testbench ---");
        $display("--------------------------------------------------");
        $display("Time=%0t | State=%d | Timer=%d | Sa=%b, Sb=%b | A: %b%b%b (RGY) | B: %b%b%b (RGY)",
                 $time, dut.current_state, dut.state_timer, Sa, Sb, Ra, Ya, Ga, Rb, Yb, Gb);

        reset_n = 0; // Assert active-low reset
        Sa = 0;      // No cars initially
        Sb = 0;

        //Ensure proper initialization and reset
        # (CLK_PERIOD * 5); 
        reset_n = 1;
        # (CLK_PERIOD / 2); 
        
        //Reaches GaRb and stays there
        # (dut.DURATION_GaRb * CLK_PERIOD * 2); 
        # (CLK_PERIOD * 10); 

        // A priority
        Sa = 1; // Car appears in A
        # (CLK_PERIOD * 30); 
        
        //Car appears in B
        Sa = 0; // Remove car in A
        Sb = 1; // Car appears in B
        # (CLK_PERIOD * 2); // Allow FSM to react (current state is GaRb, timer=0)

        // GaRb (A Green) -> YaRb (A Yellow) -> RaRb (All Red 1) -> RaGb (B Green)
        # (dut.DURATION_YaRb * CLK_PERIOD); // Wait for Yellow A duration (30ns)
        # (dut.DURATION_RaRb * CLK_PERIOD); // Wait for All Red 1 duration (30ns)
        # (CLK_PERIOD * 2); // Small buffer to ensure state change registers

        //A priority over B
        Sa = 1; // Car appears in A
        Sb = 1; // Keep car in B (B is currently green)
        # (dut.DURATION_RaGb * CLK_PERIOD); // Wait for B's min green (70ns)
        // RaGb (B Green) -> RaYb (B Yellow) -> RaRb2 (All Red 2) -> GaRb (A Green)
        # (dut.DURATION_RaYb * CLK_PERIOD); // Wait for Yellow B duration (30ns)
        # (dut.DURATION_RaRb2 * CLK_PERIOD); // Wait for All Red 2 duration (30ns)
        # (CLK_PERIOD * 2); // Small buffer

        // B has cars but not A
        # (dut.DURATION_GaRb * CLK_PERIOD); // Wait for A's min green (70ns)
        Sa = 0;
        Sb = 1; // Ensure a car is present in B for a while (A will switch to B)
        # (dut.DURATION_YaRb * CLK_PERIOD);
        # (dut.DURATION_RaRb * CLK_PERIOD);
        # (CLK_PERIOD * 10);
        
        // B clears but A still has no car
        Sa = 0; // No car in A
        Sb = 0; // B's lane clears
        // Expected: B should cycle to A
        // Let B go for its minimum duration.
        # (dut.DURATION_RaGb * CLK_PERIOD); // Wait for B's min green (70ns)

        // Expected Sequence: RaGb -> RaYb (because Sb cleared) -> RaRb2 -> GaRb
        # (dut.DURATION_RaYb * CLK_PERIOD); // Wait for Yellow B duration (30ns)
        # (dut.DURATION_RaRb2 * CLK_PERIOD); // Wait for All Red 2 duration (30ns)
        # (CLK_PERIOD * 2); // Small buffer

        // Final observation period
        # (CLK_PERIOD * 100);

        $display("\n--------------------------------------------------");
        $display("--- Simulation Finished ---");
        $display("--------------------------------------------------");
        $finish; // End the simulation
    end

endmodule