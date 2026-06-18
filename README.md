# 🏠 Smart Home Automation Controller on FPGA

> A hardware-level Smart Home Automation System implemented in Verilog RTL, targeting Xilinx Artix-7 FPGA (Basys3). Features FSM-based appliance control, security alarm, manual override, and energy-saving mode — fully simulation-verified.

---

## 📌 Problem Statement

Modern homes waste energy when appliances run without checking occupancy or environment. A dedicated **hardware controller** using an FPGA reacts in **nanoseconds** to sensor events — far faster and more deterministic than software on a microcontroller. This project demonstrates how FSM-based digital logic solves real-world home automation challenges in silicon.

---

## 🧠 VLSI Concepts Used

| Concept | Implementation |
|---|---|
| Finite State Machine (FSM) | 6-state Moore FSM for control logic |
| Sequential Logic | State register and output FFs on clock edge |
| Combinational Logic | Next-state and output decode (`always @(*)`) |
| Clock / Reset | 100 MHz clock, active-low synchronous reset |
| Priority Encoding | Nested if-else in next-state logic |
| Counter Design | 8-bit no-motion counter for energy saving |
| Registered Outputs | Glitch-free output FFs |
| RTL Synthesis | Mapped to Xilinx Artix-7 via Vivado |
| Testbench | 16-scenario self-checking simulation |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│         INPUT LAYER (Sensors / Switches)      │
│  light_sensor  motion_sensor  temp_high       │
│  door_sensor   security_mode                  │
│  manual_light  manual_fan    manual_ac        │
└────────────────────┬─────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────┐
│         FPGA CONTROLLER (Verilog RTL)         │
│                                              │
│   ┌──────────────────────────────────────┐  │
│   │         6-STATE MOORE FSM            │  │
│   │                                      │  │
│   │  IDLE ──→ AUTO_CTRL ──→ ENERGY_SAVE │  │
│   │    │         │    ↑                  │  │
│   │    ├──→ SECURITY ──→ ALARM_STATE    │  │
│   │    └──→ MANUAL_OVR  (top priority)  │  │
│   └──────────────────────────────────────┘  │
│                                              │
│   No-Motion Counter → Energy Save trigger   │
└────────────────────┬─────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────┐
│         OUTPUT LAYER (Appliances / Alerts)    │
│  light_ctrl  fan_ctrl  ac_ctrl                │
│  door_alert  alarm_ctrl  energy_save          │
│  fsm_state[2:0]  (debug)                     │
└──────────────────────────────────────────────┘
```

---

## 🔁 FSM State Diagram

```
         rst_n=0
            │
            ▼
        ┌───────┐
        │ IDLE  │◄──────────────────────────────┐
        └───┬───┘                               │
            │ motion / temp_high                │ all manual OFF + no sensors
            ▼                                   │
       ┌──────────┐   no_motion > 200    ┌──────────────┐
       │ AUTO_CTRL│──────────────────────►│ ENERGY_SAVE  │
       └────┬─────┘                      └──────────────┘
            │ security_mode=1                   ▲ motion detected
            ▼                                   │
       ┌──────────┐   door_sensor=1    ┌────────────────┐
       │ SECURITY │───────────────────►│  ALARM_STATE   │
       └──────────┘                    └────────────────┘
            
       ┌─────────────┐ ← ANY manual switch ON (overrides all states)
       │ MANUAL_OVR  │
       └─────────────┘
```

---

## 🎛️ Control Logic Table

| Condition | light | fan | ac | alarm | energy_save | State |
|---|---|---|---|---|---|---|
| Reset | 0 | 0 | 0 | 0 | 0 | IDLE |
| motion=1, light_sensor=1 | ✅ | 0 | 0 | 0 | 0 | AUTO_CTRL |
| temp_high=1, motion=1 | 0 | ✅ | ✅ | 0 | 0 | AUTO_CTRL |
| security=1, door=0 | ✅ | 0 | 0 | 0 | 0 | SECURITY |
| security=1, door=1 | ✅ | 0 | 0 | ✅ | 0 | ALARM_STATE |
| manual_light=1 | ✅ | 0 | 0 | 0 | 0 | MANUAL_OVR |
| no_motion > threshold | 0 | 0 | 0 | 0 | ✅ | ENERGY_SAVE |

### Priority (Highest → Lowest)
```
1. Manual Override  (user always wins)
2. Alarm State      (security emergency)
3. Security Mode    (monitoring active)
4. Auto Control     (sensor-based)
5. Energy Save      (power optimization)
6. Idle             (safe default)
```

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| Icarus Verilog (`iverilog`) | Compilation + simulation |
| GTKWave | Waveform viewing |
| EDA Playground | Browser-based simulation (no install) |
| Xilinx Vivado | Synthesis + FPGA implementation |
| Digilent Basys3 | Target FPGA board (Artix-7) |

---

## 📁 Folder Structure

```
Smart-Home-Automation-FPGA/
│
├── rtl/
│   └── smart_home_controller.v      ← Main RTL module
│
├── tb/
│   └── tb_smart_home_controller.v   ← 16-scenario testbench
│
├── constraints/
│   └── smart_home_basys3.xdc        ← FPGA pin assignments
│
├── simulation/
│   ├── run_simulation.sh            ← One-click sim script
│   └── EDA_Playground_Guide.md      ← Browser sim instructions
    |__VIVADO 2024.2 guide.md       
│
├── waveforms/
│   └── smart_home_tb.vcd            ← Generated after simulation
│
├── reports/
│   └── Project_Report.md            ← Full project report
│
├── docs/
│   └── Interview_QA.md              ← 10 Q&A for interviews
│
├── images/                          ← Screenshots go here
│
├── README.md
└── .gitignore
```

---

## ▶️ How to Simulate

### Option A — EDA Playground (No Installation Needed)
1. Go to [edaplayground.com](https://www.edaplayground.com)
2. Paste `rtl/smart_home_controller.v` in the Design tab
3. Paste `tb/tb_smart_home_controller.v` in the Testbench tab
4. Select **Icarus Verilog**, check **"Open EPWave after run"**
5. Click **Run** → waveform opens in browser

### Option B — Icarus Verilog + GTKWave (Local)
```bash
# Install (Ubuntu/WSL)
sudo apt install iverilog gtkwave

# Clone repo
git clone https://github.com/seshu-8/Smart-Home-Automation-FPGA
cd Smart-Home-Automation-FPGA

# Run simulation
chmod +x simulation/run_simulation.sh
./simulation/run_simulation.sh

# View waveform
gtkwave waveforms/smart_home_tb.vcd
```

### Option C — Xilinx Vivado
1. New Project → RTL Project → Add `rtl/` sources
2. Add `tb/` as simulation-only source
3. Add `constraints/smart_home_basys3.xdc`
4. Run Simulation → Behavioral Simulation
5. Add all signals to waveform, Run All

---

## 📊 Waveform Verification Checklist

After simulation, verify these transitions in waveform:

- [ ] `rst_n` LOW → all outputs = 0, `fsm_state` = 0 (IDLE)
- [ ] `motion=1, light_sensor=1` → `light_ctrl` goes HIGH, state = AUTO_CTRL
- [ ] `temp_high=1` → `fan_ctrl` and `ac_ctrl` go HIGH
- [ ] `security_mode=1, door=1` → `alarm_ctrl` HIGH, state = ALARM_STATE
- [ ] `manual_light=1` → overrides all, state = MANUAL_OVR
- [ ] No motion for 200+ cycles → `energy_save` HIGH, state = ENERGY_SAVE
- [ ] Motion after energy save → returns to AUTO_CTRL

---

## 📸 Screenshots Checklist

For GitHub proof of work, capture and upload to `images/`:

- [ ] `rtl_code.png` — RTL module in editor
- [ ] `testbench_code.png` — Testbench in editor
- [ ] `simulation_run.png` — Console output showing tests
- [ ] `waveform_full.png` — Full waveform in GTKWave/EPWave
- [ ] `waveform_alarm.png` — Zoomed waveform: alarm trigger
- [ ] `waveform_energy.png` — Zoomed waveform: energy save
- [ ] `waveform_manual.png` — Zoomed waveform: manual override
- [ ] `vivado_synthesis.png` — Synthesis completed (if Vivado used)
- [ ] `utilization_report.png` — FPGA resource utilization
- [ ] `github_repo.png` — Repository preview

---

## 🚀 Future Improvements

1. PWM-based variable fan speed control
2. Configurable temperature threshold via register interface
3. 7-segment display showing current FSM state
4. Multi-room parameterized architecture (`N` rooms)
5. I2C/SPI interface for real sensor integration
6. AXI-Lite slave register for SoC integration
7. Power consumption counter with threshold alert

---

## 🎓 Learning Outcomes

- Designed and implemented a synthesizable Moore FSM in Verilog
- Applied priority-encoded control logic in hardware
- Built a comprehensive self-checking testbench with 16 scenarios
- Generated and analyzed VCD waveforms using GTKWave
- Created FPGA pin constraints for Basys3 board
- Understood the full RTL-to-FPGA flow (Design → Simulate → Synthesize → Implement)

---

## 👤 Author

**K.V.Seshu Babu**  
GitHub: [@GIT PROFILE](https://github.com/seshu-8) 
Linkedin:[@Linkedin profile](https://www.linkedin.com/in/seshu-babu-konijeti-74968b2b9?utm_source=share_via&utm_content=profile&utm_medium=member_android) 
Project: VLSI Course — Smart Home Automation Controller on FPGA
