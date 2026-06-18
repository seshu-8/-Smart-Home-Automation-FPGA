#!/bin/bash
# ============================================================
# Project     : Smart Home Automation Controller
# File        : run_simulation.sh
# Description : Script to compile and simulate using
#               Icarus Verilog (iverilog) + GTKWave
#               Works on Linux/macOS/Windows(WSL/Git Bash)
# ============================================================

echo "=============================================="
echo "  Smart Home Automation - Simulation Runner"
echo "=============================================="

# Create waveforms output directory if not present
mkdir -p waveforms

# Step 1: Compile RTL + Testbench
echo ""
echo "[1] Compiling RTL and Testbench..."
iverilog -o simulation/smart_home_sim \
    rtl/smart_home_controller.v \
    tb/tb_smart_home_controller.v

if [ $? -eq 0 ]; then
    echo "    Compilation SUCCESSFUL"
else
    echo "    Compilation FAILED - Check Verilog syntax"
    exit 1
fi

# Step 2: Run Simulation
echo ""
echo "[2] Running Simulation..."
cd simulation
vvp smart_home_sim

if [ $? -eq 0 ]; then
    echo ""
    echo "    Simulation COMPLETED"
else
    echo "    Simulation FAILED"
    exit 1
fi
cd ..

# Step 3: Open Waveform (optional)
echo ""
echo "[3] Opening GTKWave for waveform viewing..."
echo "    Waveform saved at: waveforms/smart_home_tb.vcd"
echo ""
echo "    To open GTKWave manually:"
echo "    gtkwave waveforms/smart_home_tb.vcd"
echo ""

# Uncomment below to auto-open GTKWave:
# gtkwave waveforms/smart_home_tb.vcd &

echo "=============================================="
echo "  Simulation Complete! Check waveforms/ folder"
echo "=============================================="
