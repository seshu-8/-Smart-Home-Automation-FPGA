# Smart Home Automation Controller — Interview Preparation
## 10 Questions + Strong Answers

---

### Q1. Explain your project.

**Answer:**

I built a Smart Home Automation Controller using Verilog RTL targeting a Xilinx Artix-7 FPGA. The project automates home appliances — lights, fan, and AC — based on real-time sensor inputs including a motion sensor, light sensor, temperature sensor, and a door sensor.

The core of the design is a 6-state Moore Finite State Machine with states for IDLE, AUTO_CTRL, SECURITY, ENERGY_SAVE, MANUAL_OVR, and ALARM_STATE. The controller follows a priority hierarchy where manual override takes highest priority, followed by alarm, security mode, auto control, energy saving, and idle.

I used a 3-process FSM style — a state register, combinational next-state logic, and registered output logic — to ensure clean, glitch-free outputs. I also implemented a no-motion counter that triggers energy-saving mode when no activity is detected for a configurable threshold.

The design is fully simulation-verified using a 16-scenario testbench and synthesized with pin constraints targeting the Digilent Basys3 board, where FPGA switches represent sensors and LEDs represent appliances.

---

### Q2. What is an FSM and why did you use it here?

**Answer:**

An FSM — Finite State Machine — is a digital design construct that models a system as a finite number of states, with transitions between them driven by inputs, and outputs determined by the current state (Moore) or state + inputs (Mealy).

I used a Moore FSM because in a home automation controller, the outputs (appliance states) should be stable and depend only on the current system state — not on instantaneous input glitches. For example, the alarm output should only activate when the system is in ALARM_STATE, regardless of input transitions during other states.

FSMs are the standard approach for control-dominated digital designs, which is exactly what automation logic is.

---

### Q3. What is the difference between combinational and sequential logic? Where did you use each?

**Answer:**

Combinational logic produces outputs that depend only on current inputs — no memory, no clock. Sequential logic has memory elements (flip-flops) and output depends on both current inputs and past state.

In my design:
- **Sequential logic:** The state register (`always @(posedge clk)`) stores the current FSM state. The output logic (`always @(posedge clk)`) drives registered outputs.
- **Combinational logic:** The next-state logic (`always @(*)`) determines what state to go to next based on all current inputs — this is purely combinational, no clock edge.

Using registered outputs instead of purely combinational outputs is a best practice — it prevents glitches caused by short-duration input transitions.

---

### Q4. What is the role of the clock and reset in your design?

**Answer:**

The **clock** synchronizes all sequential elements. Every state transition and output update happens on the positive edge of `clk`. This ensures all parts of the design update in a coordinated, predictable manner — critical for FPGA timing closure.

The **reset** (`rst_n`, active-low) forces the entire system to a known initial state — IDLE — with all outputs OFF. I used a synchronous reset (evaluated on the clock edge) to avoid metastability issues common with asynchronous resets in synchronous designs.

On hardware (Basys3), the clock runs at 100 MHz, meaning the controller evaluates and updates state every 10 nanoseconds — far faster than any real home sensor event.

---

### Q5. Why FPGA instead of a microcontroller (like Arduino) for home automation?

**Answer:**

Both work, but FPGAs have specific advantages:

| Property         | FPGA                            | Microcontroller             |
|------------------|---------------------------------|-----------------------------|
| Execution        | True parallel hardware          | Sequential software         |
| Latency          | Nanoseconds (clock-cycle level) | Microseconds to milliseconds|
| Customization    | Any digital logic possible      | Limited to instruction set  |
| Determinism      | Guaranteed timing               | Interrupts can vary         |
| Reliability      | No OS overhead                  | Software bugs possible      |

For safety-critical use cases — like a security alarm that must respond in deterministic time — FPGA hardware logic is more reliable. This project demonstrates understanding of hardware-level design, which is what VLSI coursework targets.

---

### Q6. What is a testbench and why is it important?

**Answer:**

A testbench is a non-synthesizable Verilog module that drives inputs to the DUT (Design Under Test) and monitors outputs to verify correct behavior. It is the hardware equivalent of a unit test in software.

In my project, the testbench covers 16 test scenarios — reset, all sensor combinations, security alarm trigger, manual override priority, and energy-saving mode. Each test applies specific input patterns and lets the simulation run for enough clock cycles to observe state transitions.

Without a testbench, I have no way to verify my RTL logic is correct before synthesis. Bugs found in simulation are free to fix; bugs found after silicon fabrication can cost millions. This is why verification (including testbench writing) is a dedicated job role in the semiconductor industry.

---

### Q7. How does the energy-saving mode work in your design?

**Answer:**

I implemented an 8-bit counter (`no_motion_counter`) that increments on every clock cycle when `motion_sensor` is LOW (no motion). When motion is detected, the counter immediately resets to zero.

When the counter reaches the threshold (200 cycles in simulation — scaled to minutes in real deployment using a clock divider), the FSM transitions from AUTO_CTRL to ENERGY_SAVE state. In this state, all appliances — light, fan, AC — are turned OFF to save power.

As soon as motion is detected again, the FSM returns to AUTO_CTRL and resumes normal automation. This directly mimics real-world commercial building systems that use occupancy sensors to cut HVAC and lighting when rooms are empty.

---

### Q8. What is an XDC file and what does it do in FPGA design?

**Answer:**

An XDC (Xilinx Design Constraints) file is the constraints file used in Vivado that maps RTL signal names to physical FPGA pins and specifies timing requirements.

In my project, the `smart_home_basys3.xdc` file:
- Maps `light_sensor` → SW0 switch pin on Basys3
- Maps `motion_sensor` → SW1 switch pin
- Maps `light_ctrl` → LD0 LED pin
- Maps `alarm_ctrl` → LD4 LED pin
- Creates a 100 MHz clock constraint on pin W5

Without the XDC file, Vivado cannot generate a bitstream because it doesn't know which physical pins to route signals to. The tool also uses timing constraints to perform static timing analysis and verify the design meets setup/hold requirements.

---

### Q9. What does "synthesizable Verilog" mean and what constructs did you avoid?

**Answer:**

Synthesizable Verilog is a subset of the Verilog language that synthesis tools (like Vivado or Synopsys Design Compiler) can convert to actual hardware gates. Not all valid Verilog simulates AND synthesizes.

**Constructs I used (synthesizable):**
- `always @(posedge clk)` — maps to flip-flops
- `always @(*)` — maps to combinational gates (MUX/AND/OR)
- `if/else`, `case` statements
- `reg`, `wire`, `assign`
- `localparam` for constants

**Constructs I avoided (simulation-only, NOT synthesizable):**
- `#10` (delay statements) — only in testbench
- `$display`, `$dumpfile` — only in testbench
- `initial` blocks — only in testbench
- `fork/join` constructs

This discipline ensures my RTL module can be directly synthesized to gate-level and deployed on an FPGA.

---

### Q10. How did you handle priority logic in your design?

**Answer:**

Priority logic determines which condition takes precedence when multiple inputs are simultaneously asserted. In a home controller, this is critical — for example, if both motion detection and a manual switch are active, which one should control the lights?

My priority hierarchy (highest to lowest):
1. **Manual Override** — user always has control
2. **Alarm State** — security emergency overrides everything
3. **Security Mode** — monitoring takes priority over comfort automation
4. **Auto Control** — sensor-driven appliance management
5. **Energy Save** — power optimization when no activity
6. **Idle** — default safe state

I implemented this using nested `if-else` statements in the next-state combinational logic. The first condition checked is Manual Override — if any manual switch is active, it immediately transitions to MANUAL_OVR regardless of sensor state. Only if manual is not active does the logic evaluate security, then auto, etc.

This is exactly how real SCADA and building management systems implement control priority hierarchies in hardware.

---

## Bonus: Quick Technical Facts

- **FSM type:** Moore FSM (outputs depend only on state)
- **States:** 6 (IDLE, AUTO, SECURITY, ENERGY_SAVE, MANUAL_OVR, ALARM)
- **State encoding:** 3-bit binary
- **Clock domain:** Single clock domain (100 MHz)
- **Reset polarity:** Active-low (`rst_n`)
- **Target FPGA:** Xilinx Artix-7 (Basys3 board)
- **Tool:** Xilinx Vivado / Icarus Verilog + GTKWave
- **Estimated LUT utilization:** ~30–50 LUTs (very efficient)
