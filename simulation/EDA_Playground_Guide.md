# EDA Playground Simulation Guide
# Smart Home Automation Controller on FPGA

## What is EDA Playground?
EDA Playground (edaplayground.com) is a FREE browser-based Verilog/SystemVerilog
simulator. No installation required — perfect if you don't have ModelSim or Vivado.

---

## Steps to Simulate on EDA Playground

### 1. Open EDA Playground
   Visit: https://www.edaplayground.com
   Sign up for a free account.

### 2. Set Simulator
   - On the LEFT panel, choose: **Icarus Verilog 0.9.7** (free, no login needed)
   - OR choose **Synopsys VCS** (requires login, industry-grade)

### 3. Paste RTL Code
   In the **Design** tab (left editor), paste the full contents of:
   `rtl/smart_home_controller.v`

### 4. Paste Testbench Code
   In the **Testbench** tab (right editor), paste the full contents of:
   `tb/tb_smart_home_controller.v`

### 5. Enable EPWave (Waveform Viewer)
   - Check the box: **"Open EPWave after run"**
   - This shows a waveform like ModelSim/GTKWave inside your browser!

### 6. Click RUN
   - Click the green **Run** button.
   - The console at the bottom will show simulation log output.
   - EPWave waveform will open automatically.

---

## What to Check in EPWave Waveform

| Signal         | Expected Behavior                         |
|----------------|-------------------------------------------|
| clk            | Regular 10ns toggling clock               |
| rst_n          | Goes HIGH after reset period              |
| fsm_state      | Transitions: 0→1→2→5→4→3→1 etc.          |
| light_ctrl     | HIGH when motion=1 AND light_sensor=1     |
| fan_ctrl       | HIGH when temp_high=1                     |
| ac_ctrl        | HIGH when temp_high=1 AND motion=1        |
| alarm_ctrl     | HIGH when security_mode=1 AND door=1      |
| energy_save    | HIGH after 200+ cycles of no motion       |
| manual_light   | Overrides automation when HIGH            |

---

## Screenshots to Take

1. EDA Playground code window (RTL + Testbench side by side)
2. Simulation console log showing test results
3. EPWave waveform showing:
   - Reset behavior
   - AUTO_CTRL transitions
   - ALARM_STATE trigger
   - ENERGY_SAVE entry and exit
   - MANUAL_OVR priority
4. Save waveform screenshot as `images/waveform_full.png`

---

## Saving Your Work
- EDA Playground allows saving to your account.
- Copy the share URL and paste it in your README for reviewers.
- Example: https://www.edaplayground.com/x/XXXXXX

---

## ModelSim Steps (if installed)

```
# In ModelSim console:
vlib work
vmap work work
vlog rtl/smart_home_controller.v tb/tb_smart_home_controller.v
vsim tb_smart_home_controller
add wave -r /*
run -all
```

---

## Vivado Simulation Steps

1. File → New Project → RTL Project
2. Add Sources → Add rtl/smart_home_controller.v
3. Add Sources → Add tb/tb_smart_home_controller.v (set as Simulation only)
4. Run Simulation → Run Behavioral Simulation
5. In waveform window: add all signals, zoom to fit
6. Screenshot the waveform

---

## Expected Console Output Sample

```
===========================================================
  Smart Home Automation Controller - Testbench Started
===========================================================
--- TEST 1: Reset Condition ---
--- TEST 2: IDLE State (No Motion, No Temp) ---
--- TEST 3: Motion + Low Light → Light ON ---
--- TEST 4: High Temp + Motion → Fan + AC ON ---
...
--- TEST 16: Door Open (No Security) → door_alert only ---
  All Tests Completed Successfully!
===========================================================
```
