# Smart Home Automation Controller on FPGA
## Project Report

**Student:** Seshuu  
**Course:** VLSI Design  
**Date:** June 2026  

---

## 1. Project Objective

Design and simulate a Smart Home Automation Controller using Verilog RTL on an FPGA platform (Xilinx Basys3). The controller automates home appliances — light, fan, AC — based on sensor inputs (motion, light level, temperature, door status), with security alarm functionality, manual override capability, and energy-saving mode.

---

## 2. Problem Statement

Modern homes waste energy when appliances run unnecessarily. A dedicated hardware controller using an FPGA can react in nanoseconds (vs. milliseconds in software) to sensor events, making it ideal for real-time home automation. This project demonstrates how digital logic and FSM design principles solve the real-world problem of intelligent appliance control.

---

## 3. Smart Home Controller Architecture

```
┌─────────────────────────────────────────────────────────┐
│                INPUT LAYER (Sensors/Switches)            │
│  light_sensor  motion_sensor  temp_high  door_sensor     │
│  security_mode  manual_light  manual_fan  manual_ac      │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│            FPGA CONTROLLER (smart_home_controller.v)     │
│                                                          │
│   ┌──────────────────────────────────────────────────┐  │
│   │           FSM STATE MACHINE                      │  │
│   │                                                  │  │
│   │  IDLE ──→ AUTO_CTRL ──→ ENERGY_SAVE             │  │
│   │    │         │    ↑                              │  │
│   │    │         ▼    └──── motion detected          │  │
│   │    ├──→ SECURITY ──→ ALARM_STATE                 │  │
│   │    │                                             │  │
│   │    └──→ MANUAL_OVR (highest priority)            │  │
│   └──────────────────────────────────────────────────┘  │
│                                                          │
│   No-Motion Counter (8-bit) for energy saving           │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│               OUTPUT LAYER (Appliances/Alerts)           │
│  light_ctrl  fan_ctrl  ac_ctrl  door_alert               │
│  alarm_ctrl  energy_save  fsm_state[2:0]                 │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Input/Output Signal Table

| Signal        | Direction | Width | Description                          |
|---------------|-----------|-------|--------------------------------------|
| clk           | Input     | 1-bit | System clock (100 MHz on Basys3)     |
| rst_n         | Input     | 1-bit | Active-low synchronous reset         |
| light_sensor  | Input     | 1-bit | 1 = Low light / darkness detected   |
| motion_sensor | Input     | 1-bit | 1 = Motion detected in room          |
| temp_high     | Input     | 1-bit | 1 = Temperature above threshold      |
| door_sensor   | Input     | 1-bit | 1 = Door is open                     |
| security_mode | Input     | 1-bit | 1 = Security monitoring enabled      |
| manual_light  | Input     | 1-bit | 1 = Force light ON manually          |
| manual_fan    | Input     | 1-bit | 1 = Force fan ON manually            |
| manual_ac     | Input     | 1-bit | 1 = Force AC ON manually             |
| light_ctrl    | Output    | 1-bit | 1 = Room light activated             |
| fan_ctrl      | Output    | 1-bit | 1 = Fan activated                    |
| ac_ctrl       | Output    | 1-bit | 1 = Air conditioner activated        |
| door_alert    | Output    | 1-bit | 1 = Door open warning                |
| alarm_ctrl    | Output    | 1-bit | 1 = Security alarm triggered         |
| energy_save   | Output    | 1-bit | 1 = Energy-saving mode active        |
| fsm_state     | Output    | 3-bit | Current FSM state (debug)            |

---

## 5. FSM State Description

| State       | Code | Condition to Enter           | Behavior                          |
|-------------|------|------------------------------|-----------------------------------|
| IDLE        | 000  | Default / no activity        | All appliances OFF                |
| AUTO_CTRL   | 001  | motion or temp_high detected | Sensor-driven automation active   |
| SECURITY    | 010  | security_mode=1, door closed | Hallway light ON, monitoring      |
| ENERGY_SAVE | 011  | 200+ cycles without motion   | All appliances OFF, saves power   |
| MANUAL_OVR  | 100  | Any manual switch active     | User manual control (highest pri) |
| ALARM_STATE | 101  | security_mode + door open    | Alarm + all lights ON             |

---

## 6. Control Logic Table

| Condition                              | Output          | State       |
|----------------------------------------|-----------------|-------------|
| motion=1, light_sensor=1               | light_ctrl=1    | AUTO_CTRL   |
| temp_high=1, motion=1                  | fan=1, ac=1     | AUTO_CTRL   |
| temp_high=1, motion=0                  | fan=1           | AUTO_CTRL   |
| security_mode=1, door=0                | light=1         | SECURITY    |
| security_mode=1, door=1                | alarm=1, light=1| ALARM_STATE |
| manual_light=1                         | light=1         | MANUAL_OVR  |
| manual_fan=1                           | fan=1           | MANUAL_OVR  |
| manual_ac=1                            | ac=1            | MANUAL_OVR  |
| no_motion > 200 cycles                 | energy_save=1   | ENERGY_SAVE |
| rst_n=0                                | all outputs=0   | IDLE        |

---

## 7. Priority Table

| Priority | Condition        | Overrides                        |
|----------|------------------|----------------------------------|
| 1 (HIGH) | Manual Override  | All states                       |
| 2        | Alarm State      | Security, Auto, Energy Save      |
| 3        | Security Mode    | Auto, Energy Save, Idle          |
| 4        | Auto Control     | Energy Save, Idle                |
| 5        | Energy Save      | Idle                             |
| 6 (LOW)  | Idle             | None (default state)             |

---

## 8. RTL Module Explanation

The `smart_home_controller` module is implemented using a 3-process FSM style:

1. **State Register** (Sequential): Updates `current_state` on each clock edge. Resets to IDLE on active-low reset.

2. **Next State Logic** (Combinational): Pure combinational block evaluating all input conditions to determine `next_state`. Priority encoding ensures correct behavior.

3. **Output Logic** (Sequential): Registered outputs prevent glitches. Each state drives specific output patterns based on control logic table.

The no-motion counter is an 8-bit register that counts clock cycles without motion detection. When it crosses 200, it triggers ENERGY_SAVE transition. Motion detection immediately resets it to zero.

---

## 9. Testbench Explanation

The testbench (`tb_smart_home_controller.v`) covers 16 test cases:

| Test | Scenario                          | Verification Point              |
|------|-----------------------------------|----------------------------------|
| 1    | Reset                             | All outputs = 0, state = IDLE   |
| 2    | IDLE (no sensors)                 | Stays in IDLE                   |
| 3    | Motion + Low Light                | light_ctrl = 1                  |
| 4    | High Temp + Motion                | fan=1, ac=1                     |
| 5    | All sensors ON                    | light+fan+ac = 1                |
| 6    | Security mode, door closed        | SECURITY state, light=1         |
| 7    | Security + door open              | ALARM_STATE, alarm=1            |
| 8    | Security mode OFF                 | Returns to IDLE                 |
| 9    | Manual light                      | MANUAL_OVR, light=1             |
| 10   | Manual fan + ac                   | MANUAL_OVR, fan=ac=1            |
| 11   | All manual ON                     | MANUAL_OVR, all=1               |
| 12   | Manual cleared                    | Returns to IDLE                 |
| 13   | No motion 210 cycles              | ENERGY_SAVE, energy_save=1      |
| 14   | Motion returns                    | AUTO_CTRL resumed               |
| 15   | Manual vs security priority       | MANUAL_OVR wins                 |
| 16   | Door open, no security            | door_alert=1, alarm=0           |

---

## 10. VLSI Concepts Demonstrated

| Concept          | Implementation                              |
|------------------|---------------------------------------------|
| Sequential Logic | State register (always @posedge clk)        |
| Combinational    | Next state + output logic (always @(*))     |
| FSM Design       | 6-state Moore FSM                           |
| Clock/Reset      | Synchronous reset with active-low polarity  |
| Priority Logic   | Nested conditionals in next-state logic     |
| Registered Outputs| Output FF prevents glitches               |
| Counter Design   | 8-bit no-motion counter for energy saving   |
| Parameterization | `localparam` for state codes and threshold  |
| Synthesis        | Mapped to Xilinx Artix-7 FPGA (Basys3)     |

---

## 11. Waveform Analysis

Expected waveform signal transitions during simulation:

```
clk:         ┐_┌_┐_┌_┐_┌_┐_┌_┐_┌_┐_┌_┐ (100 MHz)
rst_n:       _____┌──────────────────────
fsm_state:   0   0  1   1   5   4   3   
light_ctrl:  0   0  1   1   1   1   0   
fan_ctrl:    0   0  0   1   0   0   0   
alarm_ctrl:  0   0  0   0   1   0   0   
energy_save: 0   0  0   0   0   0   1   
```

Key transitions to verify:
- state goes 0 (IDLE) → 1 (AUTO) on motion
- state goes 1 → 5 (ALARM) when security + door open
- state goes 1 → 4 (MANUAL) when manual switch pressed
- state goes 1 → 3 (ENERGY) after 200 idle cycles

---

## 12. FPGA Implementation Notes

- **Target Board:** Digilent Basys3 (Xilinx Artix-7 XC7A35T)
- **Tool:** Xilinx Vivado 2023.x
- **Clock:** 100 MHz onboard oscillator (W5 pin)
- **Inputs:** 8 PMOD switches mapped to sensors/manual
- **Outputs:** 9 LEDs mapped to appliances + debug state

**Synthesis Results (Estimated):**
- LUTs used: ~25–40 (very minimal — good for student projects)
- FFs used: ~20–30
- Timing: Easily meets 100 MHz (design is very small)

---

## 13. Conclusion

This project successfully demonstrates a hardware-based Smart Home Automation Controller using FSM design in Verilog. It covers real-world automation scenarios including sensor-driven control, security alarm systems, energy saving, and manual override — all implemented as synthesizable RTL code deployable on an FPGA. The design is modular, well-commented, testbench-verified, and ready for GitHub showcase and technical interviews.

---

## 14. Future Improvements

1. Add PWM-based fan speed control (instead of ON/OFF)
2. Integrate temperature threshold as a configurable register
3. Add 7-segment display showing current state
4. Expand to multi-room (parameterized N-room version)
5. Add I2C interface for real sensor integration
6. Implement power consumption monitor using counters
