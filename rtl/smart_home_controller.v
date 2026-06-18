// ============================================================
// Project     : Smart Home Automation Controller on FPGA
// File        : smart_home_controller.v
// Author      : Seshuu
// Description : Top-level RTL module for Smart Home Automation
//               Implements FSM-based appliance control logic
//               with sensor inputs, manual override, security
//               alarm, and energy-saving mode.
// ============================================================

module smart_home_controller (
    // ---- Clock and Reset ----
    input  wire        clk,           // System clock
    input  wire        rst_n,         // Active-low synchronous reset

    // ---- Sensor Inputs ----
    input  wire        light_sensor,  // 1 = Low light detected
    input  wire        motion_sensor, // 1 = Motion detected
    input  wire        temp_high,     // 1 = Temperature above threshold
    input  wire        door_sensor,   // 1 = Door is OPEN
    input  wire        security_mode, // 1 = Security mode enabled

    // ---- Manual Override Inputs ----
    input  wire        manual_light,  // Manual: force light ON
    input  wire        manual_fan,    // Manual: force fan ON
    input  wire        manual_ac,     // Manual: force AC ON

    // ---- Appliance Outputs ----
    output reg         light_ctrl,    // 1 = Room light ON
    output reg         fan_ctrl,      // 1 = Fan ON
    output reg         ac_ctrl,       // 1 = AC ON
    output reg         door_alert,    // 1 = Door alert active
    output reg         alarm_ctrl,    // 1 = Security alarm ON
    output reg         energy_save,   // 1 = Energy-saving mode active

    // ---- Status Output ----
    output reg [2:0]   fsm_state      // Current FSM state (for debug/display)
);

    // ============================================================
    // FSM State Encoding
    // ============================================================
    localparam IDLE         = 3'd0;  // System idle, all OFF
    localparam AUTO_CTRL    = 3'd1;  // Automated sensor-based control
    localparam SECURITY     = 3'd2;  // Security mode: alarm check
    localparam ENERGY_SAVE  = 3'd3;  // Energy-saving mode
    localparam MANUAL_OVR   = 3'd4;  // Manual override active
    localparam ALARM_STATE  = 3'd5;  // Alarm triggered

    // ============================================================
    // Internal Registers
    // ============================================================
    reg [2:0] current_state, next_state;

    // No-motion counter for energy-saving (8-bit = max 255 clock cycles)
    // In real design, scale to minutes using a clock divider
    reg [7:0] no_motion_counter;
    localparam NO_MOTION_THRESHOLD = 8'd200; // threshold for energy save trigger

    // ============================================================
    // STATE REGISTER (Sequential - clock edge)
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // ============================================================
    // NO-MOTION COUNTER (Sequential)
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            no_motion_counter <= 8'd0;
        else if (motion_sensor)
            no_motion_counter <= 8'd0;       // Reset counter on motion
        else if (no_motion_counter < NO_MOTION_THRESHOLD)
            no_motion_counter <= no_motion_counter + 1;
    end

    // ============================================================
    // NEXT STATE LOGIC (Combinational)
    // Priority: Manual > Alarm > Security > Auto > Energy Save > Idle
    // ============================================================
    always @(*) begin
        // Default: stay in current state
        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (manual_light || manual_fan || manual_ac)
                    next_state = MANUAL_OVR;
                else if (security_mode && door_sensor)
                    next_state = ALARM_STATE;
                else if (security_mode)
                    next_state = SECURITY;
                else if (motion_sensor || temp_high)
                    next_state = AUTO_CTRL;
                else
                    next_state = IDLE;
            end

            AUTO_CTRL: begin
                if (manual_light || manual_fan || manual_ac)
                    next_state = MANUAL_OVR;
                else if (security_mode && door_sensor)
                    next_state = ALARM_STATE;
                else if (security_mode)
                    next_state = SECURITY;
                else if (no_motion_counter >= NO_MOTION_THRESHOLD)
                    next_state = ENERGY_SAVE;
                else if (!motion_sensor && !temp_high)
                    next_state = IDLE;
                else
                    next_state = AUTO_CTRL;
            end

            SECURITY: begin
                if (door_sensor)
                    next_state = ALARM_STATE;
                else if (manual_light || manual_fan || manual_ac)
                    next_state = MANUAL_OVR;
                else if (!security_mode)
                    next_state = IDLE;
                else
                    next_state = SECURITY;
            end

            ALARM_STATE: begin
                // Alarm stays until security mode is turned OFF
                if (!security_mode)
                    next_state = IDLE;
                else
                    next_state = ALARM_STATE;
            end

            ENERGY_SAVE: begin
                if (manual_light || manual_fan || manual_ac)
                    next_state = MANUAL_OVR;
                else if (security_mode && door_sensor)
                    next_state = ALARM_STATE;
                else if (motion_sensor)
                    next_state = AUTO_CTRL;
                else
                    next_state = ENERGY_SAVE;
            end

            MANUAL_OVR: begin
                // Leave manual mode only when all manual switches are OFF
                if (!manual_light && !manual_fan && !manual_ac) begin
                    if (security_mode && door_sensor)
                        next_state = ALARM_STATE;
                    else if (motion_sensor || temp_high)
                        next_state = AUTO_CTRL;
                    else
                        next_state = IDLE;
                end
                else
                    next_state = MANUAL_OVR;
            end

            default: next_state = IDLE;
        endcase
    end

    // ============================================================
    // OUTPUT LOGIC (Sequential - registered outputs for stability)
    // ============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            light_ctrl  <= 1'b0;
            fan_ctrl    <= 1'b0;
            ac_ctrl     <= 1'b0;
            door_alert  <= 1'b0;
            alarm_ctrl  <= 1'b0;
            energy_save <= 1'b0;
            fsm_state   <= IDLE;
        end
        else begin
            // Default: all OFF
            light_ctrl  <= 1'b0;
            fan_ctrl    <= 1'b0;
            ac_ctrl     <= 1'b0;
            door_alert  <= 1'b0;
            alarm_ctrl  <= 1'b0;
            energy_save <= 1'b0;
            fsm_state   <= next_state;

            case (next_state)

                IDLE: begin
                    // All outputs OFF; only door alert if door open
                    door_alert  <= door_sensor;
                end

                AUTO_CTRL: begin
                    // Light: turn ON if motion detected AND it's dark
                    light_ctrl  <= motion_sensor & light_sensor;
                    // Fan: turn ON if temperature is high
                    fan_ctrl    <= temp_high;
                    // AC: turn ON if temperature is very high (temp_high sustained)
                    ac_ctrl     <= temp_high & motion_sensor;
                    door_alert  <= door_sensor;
                end

                SECURITY: begin
                    // Security mode: monitor door, light stays dim
                    door_alert  <= door_sensor;
                    light_ctrl  <= 1'b1; // Keep hallway light ON in security mode
                end

                ALARM_STATE: begin
                    alarm_ctrl  <= 1'b1; // Alarm ON
                    light_ctrl  <= 1'b1; // All lights ON
                    door_alert  <= 1'b1; // Door alert ON
                end

                ENERGY_SAVE: begin
                    energy_save <= 1'b1; // Indicate energy save mode
                    // All appliances OFF to save power
                    // Only door alert remains if door is open
                    door_alert  <= door_sensor;
                end

                MANUAL_OVR: begin
                    // Manual switches directly drive outputs
                    light_ctrl  <= manual_light;
                    fan_ctrl    <= manual_fan;
                    ac_ctrl     <= manual_ac;
                    door_alert  <= door_sensor;
                end

                default: begin
                    // Safe default: all OFF
                end
            endcase
        end
    end

endmodule
