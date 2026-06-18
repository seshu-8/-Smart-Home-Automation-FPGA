# ============================================================
# Project     : Smart Home Automation Controller on FPGA
# File        : smart_home_basys3.xdc
# Board       : Digilent Basys3 (Xilinx Artix-7)
# Description : Pin constraint file mapping FPGA switches to
#               sensor inputs and LEDs to appliance outputs.
#
# SWITCH MAPPING (SW[0..9]):
#   SW0 = light_sensor    (Low light detected)
#   SW1 = motion_sensor   (Motion detected)
#   SW2 = temp_high       (High temperature)
#   SW3 = door_sensor     (Door open)
#   SW4 = security_mode   (Security mode ON)
#   SW5 = manual_light    (Manual light override)
#   SW6 = manual_fan      (Manual fan override)
#   SW7 = manual_ac       (Manual AC override)
#   SW15 = rst_n          (Active-LOW reset via SW15)
#
# LED MAPPING (LD[0..7]):
#   LD0 = light_ctrl      (Room Light ON)
#   LD1 = fan_ctrl        (Fan ON)
#   LD2 = ac_ctrl         (AC ON)
#   LD3 = door_alert      (Door Alert)
#   LD4 = alarm_ctrl      (Security Alarm)
#   LD5 = energy_save     (Energy Saving Mode)
#   LD14,LD15 = fsm_state [1:0] (State debug output)
# ============================================================

# ---- Clock (100 MHz onboard oscillator) ----
set_property PACKAGE_PIN W5   [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# ---- Reset (SW15 used as active-low reset) ----
set_property PACKAGE_PIN R2   [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# ---- Sensor Inputs (Switches) ----
set_property PACKAGE_PIN V17  [get_ports light_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports light_sensor]

set_property PACKAGE_PIN V16  [get_ports motion_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports motion_sensor]

set_property PACKAGE_PIN W16  [get_ports temp_high]
set_property IOSTANDARD LVCMOS33 [get_ports temp_high]

set_property PACKAGE_PIN W17  [get_ports door_sensor]
set_property IOSTANDARD LVCMOS33 [get_ports door_sensor]

set_property PACKAGE_PIN W15  [get_ports security_mode]
set_property IOSTANDARD LVCMOS33 [get_ports security_mode]

# ---- Manual Override Switches ----
set_property PACKAGE_PIN V15  [get_ports manual_light]
set_property IOSTANDARD LVCMOS33 [get_ports manual_light]

set_property PACKAGE_PIN W14  [get_ports manual_fan]
set_property IOSTANDARD LVCMOS33 [get_ports manual_fan]

set_property PACKAGE_PIN W13  [get_ports manual_ac]
set_property IOSTANDARD LVCMOS33 [get_ports manual_ac]

# ---- Appliance Output LEDs ----
set_property PACKAGE_PIN U16  [get_ports light_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports light_ctrl]

set_property PACKAGE_PIN E19  [get_ports fan_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports fan_ctrl]

set_property PACKAGE_PIN U19  [get_ports ac_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports ac_ctrl]

set_property PACKAGE_PIN V19  [get_ports door_alert]
set_property IOSTANDARD LVCMOS33 [get_ports door_alert]

set_property PACKAGE_PIN W18  [get_ports alarm_ctrl]
set_property IOSTANDARD LVCMOS33 [get_ports alarm_ctrl]

set_property PACKAGE_PIN U15  [get_ports energy_save]
set_property IOSTANDARD LVCMOS33 [get_ports energy_save]

# ---- FSM State Debug LEDs ----
set_property PACKAGE_PIN U14  [get_ports {fsm_state[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fsm_state[0]}]

set_property PACKAGE_PIN V14  [get_ports {fsm_state[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fsm_state[1]}]

set_property PACKAGE_PIN V13  [get_ports {fsm_state[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {fsm_state[2]}]
