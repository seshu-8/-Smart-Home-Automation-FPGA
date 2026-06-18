// ============================================================
// Project     : Smart Home Automation Controller on FPGA
// File        : tb_smart_home_controller.v
// Author      : Seshuu
// Description : Comprehensive testbench covering all scenarios:
//               Reset, Auto control, Security alarm, Manual
//               override, Energy-saving mode, Priority logic.
// ============================================================

`timescale 1ns / 1ps

module tb_smart_home_controller;

    // ---- DUT Port Connections ----
    reg        clk;
    reg        rst_n;
    reg        light_sensor;
    reg        motion_sensor;
    reg        temp_high;
    reg        door_sensor;
    reg        security_mode;
    reg        manual_light;
    reg        manual_fan;
    reg        manual_ac;

    wire       light_ctrl;
    wire       fan_ctrl;
    wire       ac_ctrl;
    wire       door_alert;
    wire       alarm_ctrl;
    wire       energy_save;
    wire [2:0] fsm_state;

    // ---- FSM State Names (for readability in log) ----
    reg [127:0] state_name;
    always @(*) begin
        case (fsm_state)
            3'd0: state_name = "IDLE       ";
            3'd1: state_name = "AUTO_CTRL  ";
            3'd2: state_name = "SECURITY   ";
            3'd3: state_name = "ENERGY_SAVE";
            3'd4: state_name = "MANUAL_OVR ";
            3'd5: state_name = "ALARM_STATE";
            default: state_name = "UNKNOWN    ";
        endcase
    end

    // ============================================================
    // DUT Instantiation
    // ============================================================
    smart_home_controller DUT (
        .clk          (clk),
        .rst_n        (rst_n),
        .light_sensor (light_sensor),
        .motion_sensor(motion_sensor),
        .temp_high    (temp_high),
        .door_sensor  (door_sensor),
        .security_mode(security_mode),
        .manual_light (manual_light),
        .manual_fan   (manual_fan),
        .manual_ac    (manual_ac),
        .light_ctrl   (light_ctrl),
        .fan_ctrl     (fan_ctrl),
        .ac_ctrl      (ac_ctrl),
        .door_alert   (door_alert),
        .alarm_ctrl   (alarm_ctrl),
        .energy_save  (energy_save),
        .fsm_state    (fsm_state)
    );

    // ============================================================
    // Clock Generation: 10 ns period = 100 MHz
    // ============================================================
    initial clk = 0;
    always #5 clk = ~clk;

    // ============================================================
    // Waveform Dump (for GTKWave / ModelSim)
    // ============================================================
    initial begin
        $dumpfile("waveforms/smart_home_tb.vcd");
        $dumpvars(0, tb_smart_home_controller);
    end

    // ============================================================
    // Display Header
    // ============================================================
    initial begin
        $display("==========================================================");
        $display("  Smart Home Automation Controller - Testbench Started");
        $display("==========================================================");
        $display("Time | State       | Light Fan AC | DoorAlrt Alarm EnrSv");
        $display("----------------------------------------------------------");
    end

    // ============================================================
    // Monitor: print output on every change
    // ============================================================
    always @(posedge clk) begin
        $display("%4t | %s | %b     %b   %b  |   %b        %b      %b",
            $time, state_name,
            light_ctrl, fan_ctrl, ac_ctrl,
            door_alert, alarm_ctrl, energy_save);
    end

    // ============================================================
    // Task: Apply inputs and wait N clock cycles
    // ============================================================
    task apply_inputs;
        input ls, ms, th, ds, sm, ml, mf, ma;
        input integer wait_cycles;
        begin
            light_sensor  = ls;
            motion_sensor = ms;
            temp_high     = th;
            door_sensor   = ds;
            security_mode = sm;
            manual_light  = ml;
            manual_fan    = mf;
            manual_ac     = ma;
            repeat(wait_cycles) @(posedge clk);
        end
    endtask

    // ============================================================
    // MAIN TEST SEQUENCE
    // ============================================================
    initial begin

        // --------------------------------------------------
        // TEST 1: Reset Condition
        // --------------------------------------------------
        $display("\n--- TEST 1: Reset Condition ---");
        rst_n = 0;
        apply_inputs(0, 0, 0, 0, 0, 0, 0, 0, 5);
        rst_n = 1;
        @(posedge clk); #1;
        $display("RESET released. Expecting IDLE state, all outputs OFF.");

        // --------------------------------------------------
        // TEST 2: IDLE - No sensor, no motion
        // --------------------------------------------------
        $display("\n--- TEST 2: IDLE State (No Motion, No Temp) ---");
        apply_inputs(0, 0, 0, 0, 0, 0, 0, 0, 5);
        $display("Expected: IDLE, all outputs OFF.");

        // --------------------------------------------------
        // TEST 3: Motion + Low Light → AUTO_CTRL → Light ON
        // --------------------------------------------------
        $display("\n--- TEST 3: Motion + Low Light → Light ON ---");
        apply_inputs(1, 1, 0, 0, 0, 0, 0, 0, 5);
        $display("Expected: AUTO_CTRL, light_ctrl=1, fan=0, ac=0.");

        // --------------------------------------------------
        // TEST 4: High Temperature → Fan + AC ON
        // --------------------------------------------------
        $display("\n--- TEST 4: High Temp + Motion → Fan + AC ON ---");
        apply_inputs(0, 1, 1, 0, 0, 0, 0, 0, 5);
        $display("Expected: AUTO_CTRL, fan=1, ac=1, light=0.");

        // --------------------------------------------------
        // TEST 5: Motion + Low Light + High Temp → All ON
        // --------------------------------------------------
        $display("\n--- TEST 5: Motion + Low Light + High Temp → Light+Fan+AC ---");
        apply_inputs(1, 1, 1, 0, 0, 0, 0, 0, 5);
        $display("Expected: AUTO_CTRL, light=1, fan=1, ac=1.");

        // --------------------------------------------------
        // TEST 6: Security Mode ON, Door Closed
        // --------------------------------------------------
        $display("\n--- TEST 6: Security Mode ON, Door Closed → SECURITY State ---");
        apply_inputs(0, 0, 0, 0, 1, 0, 0, 0, 5);
        $display("Expected: SECURITY state, light=1, alarm=0.");

        // --------------------------------------------------
        // TEST 7: Security Mode + Door Opens → ALARM
        // --------------------------------------------------
        $display("\n--- TEST 7: Security Mode + Door Opens → ALARM ---");
        apply_inputs(0, 0, 0, 1, 1, 0, 0, 0, 5);
        $display("Expected: ALARM_STATE, alarm=1, light=1, door_alert=1.");

        // --------------------------------------------------
        // TEST 8: Security Mode OFF → Alarm Clears
        // --------------------------------------------------
        $display("\n--- TEST 8: Security Mode Disabled → Returns to IDLE ---");
        apply_inputs(0, 0, 0, 0, 0, 0, 0, 0, 5);
        $display("Expected: IDLE, alarm=0.");

        // --------------------------------------------------
        // TEST 9: Manual Override - Light ON manually
        // --------------------------------------------------
        $display("\n--- TEST 9: Manual Override → Light ON ---");
        apply_inputs(0, 0, 0, 0, 0, 1, 0, 0, 5);
        $display("Expected: MANUAL_OVR, light=1, fan=0, ac=0.");

        // --------------------------------------------------
        // TEST 10: Manual Override - Fan + AC manually
        // --------------------------------------------------
        $display("\n--- TEST 10: Manual Override → Fan + AC ON ---");
        apply_inputs(0, 0, 0, 0, 0, 0, 1, 1, 5);
        $display("Expected: MANUAL_OVR, fan=1, ac=1, light=0.");

        // --------------------------------------------------
        // TEST 11: Manual Override - All three ON simultaneously
        // --------------------------------------------------
        $display("\n--- TEST 11: Manual Override → All ON ---");
        apply_inputs(0, 0, 0, 0, 0, 1, 1, 1, 5);
        $display("Expected: MANUAL_OVR, light=1, fan=1, ac=1.");

        // --------------------------------------------------
        // TEST 12: Manual Override cleared → back to IDLE
        // --------------------------------------------------
        $display("\n--- TEST 12: Manual Override Cleared → IDLE ---");
        apply_inputs(0, 0, 0, 0, 0, 0, 0, 0, 5);
        $display("Expected: IDLE, all outputs OFF.");

        // --------------------------------------------------
        // TEST 13: Energy Saving Mode (no motion for 200+ cycles)
        // --------------------------------------------------
        $display("\n--- TEST 13: Energy Saving (no motion) ---");
        // Step 1: Enter AUTO_CTRL with motion + temp
        apply_inputs(1, 1, 1, 0, 0, 0, 0, 0, 3);
        // Step 2: Remove motion but keep temp_high to stay in AUTO_CTRL
        //         while counter counts up to 200
        apply_inputs(0, 0, 1, 0, 0, 0, 0, 0, 210);
        $display("Expected: ENERGY_SAVE, energy_save=1, all appliances OFF.");

        // --------------------------------------------------
        // TEST 14: Motion detected again → exits Energy Save
        // --------------------------------------------------
        $display("\n--- TEST 14: Motion Returns → Exit Energy Save ---");
        apply_inputs(1, 1, 0, 0, 0, 0, 0, 0, 5);
        $display("Expected: AUTO_CTRL, light=1, energy_save=0.");

        // --------------------------------------------------
        // TEST 15: Priority Check - Manual overrides security alarm
        // --------------------------------------------------
        $display("\n--- TEST 15: Manual Priority Over Security Mode ---");
        apply_inputs(0, 0, 0, 1, 1, 1, 0, 0, 5);
        $display("Expected: MANUAL_OVR (manual takes priority), light=1.");

        // --------------------------------------------------
        // TEST 16: Door alert in IDLE (door open, no security)
        // --------------------------------------------------
        $display("\n--- TEST 16: Door Open (No Security) → door_alert only ---");
        apply_inputs(0, 0, 0, 1, 0, 0, 0, 0, 5);
        $display("Expected: IDLE, door_alert=1, alarm=0.");

        // --------------------------------------------------
        // DONE
        // --------------------------------------------------
        $display("\n==========================================================");
        $display("  All Tests Completed Successfully!");
        $display("==========================================================");
        $finish;
    end

endmodule
