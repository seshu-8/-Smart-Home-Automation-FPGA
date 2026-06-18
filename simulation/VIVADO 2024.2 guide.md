\# Vivado 2024.2 Complete Guide

\## Smart Home Automation Controller on FPGA



\---



\## What is Vivado?



Vivado is Xilinx's (now AMD) official software for:

\- Writing and checking Verilog code

\- Simulating your design (like a test run)

\- Synthesizing (converting Verilog to actual hardware gates)

\- Implementing (placing those gates on the FPGA chip)

\- Programming the physical FPGA board



\---



\## PHASE 1 — Create Project



1\. Open \*\*Vivado 2024.2\*\*

2\. Click \*\*Create Project\*\*

3\. Click \*\*Next\*\*

4\. Project name: `Smart\_Home\_FPGA`

5\. Choose location: `D:/vivado projects/` (or any folder)

6\. Tick \*\*"Create project subdirectory"\*\*

7\. Click \*\*Next\*\*

8\. Select \*\*RTL Project\*\*

9\. Tick \*\*"Do not specify sources at this time"\*\*

10\. Click \*\*Next\*\*

11\. In Default Part search box type: `xc7a35tcpg236-1`

12\. Select it from the list

13\. Click \*\*Next → Finish\*\*



\---



\## PHASE 2 — Add RTL Source File



1\. Flow Navigator (left panel) → \*\*PROJECT MANAGER\*\* → \*\*Add Sources\*\*

2\. Select \*\*"Add or Create Design Sources"\*\*

3\. Click \*\*Next\*\*

4\. Click \*\*"Add Files"\*\*

5\. Browse to `smart\_home\_controller.v` → select it

6\. Tick \*\*"Copy sources into project"\*\*

7\. Click \*\*Finish\*\*

8\. In Sources panel → right-click `smart\_home\_controller` → \*\*Set as Top\*\*



\---



\## PHASE 3 — Add Testbench File



1\. Flow Navigator → \*\*Add Sources\*\* again

2\. This time select \*\*"Add or Create Simulation Sources"\*\*

3\. Click \*\*Next\*\*

4\. Click \*\*"Add Files"\*\*

5\. Browse to `tb\_smart\_home\_controller.v` → select it

6\. Tick \*\*"Copy sources into project"\*\*

7\. Click \*\*Finish\*\*



\---



\## PHASE 4 — Add Constraints File



1\. Flow Navigator → \*\*Add Sources\*\* again

2\. Select \*\*"Add or Create Constraints"\*\*

3\. Click \*\*Next\*\*

4\. Click \*\*"Add Files"\*\*

5\. Browse to `smart\_home\_basys3.xdc` → select it

6\. Tick \*\*"Copy sources into project"\*\*

7\. Click \*\*Finish\*\*



\---



\## PHASE 5 — Run Simulation



\### Step A — Set Testbench as Top

1\. In Sources panel expand \*\*Simulation Sources → sim\_1\*\*

2\. Right-click `tb\_smart\_home\_controller`

3\. Click \*\*"Set as Top"\*\*



\### Step B — Launch Simulation

1\. Flow Navigator → \*\*SIMULATION\*\* → \*\*Run Simulation\*\*

2\. Click \*\*"Run Behavioral Simulation"\*\*

3\. Wait for simulation window to open



\### Step C — Add Signals to Waveform

1\. In \*\*Scope panel\*\* (left) right-click `tb\_smart\_home\_controller`

2\. Click \*\*"Add to Wave Window"\*\*



\### Step D — Run All Tests

1\. In \*\*Tcl Console\*\* (bottom) click the input box

2\. Type: `run -all`

3\. Press \*\*Enter\*\*

4\. Wait for simulation to finish

5\. Tcl console will show: `All Tests Completed Successfully!`



\### Step E — View Waveform

1\. Click on the waveform window (black area)

2\. Press \*\*F\*\* key to zoom fit

3\. Scroll down in signal list to see all signals including `fsm\_state`



\### Step F — Take Screenshots

\- Full waveform showing all signals

\- Zoomed view of `fsm\_state` showing 0→1→2→5→4→3

\- Tcl console showing "All Tests Completed Successfully!"



\---



\## PHASE 6 — Run Synthesis



1\. Flow Navigator → \*\*SYNTHESIS\*\* → \*\*Run Synthesis\*\*

2\. Click \*\*OK\*\* if a dialog appears

3\. Wait 1-2 minutes (small design = fast)

4\. When popup appears → select \*\*"Open Synthesized Design"\*\* → click \*\*OK\*\*



\### Get Schematic

\- Top menu → \*\*Tools → Schematic\*\*

\- Screenshot the full schematic showing 82 Cells, 19 I/O Ports, 93 Nets



\### Get Utilization Report

\- Top menu → \*\*Reports → Report Utilization → OK\*\*

\- Screenshot showing: LUTs = 34, Registers = 17, all < 1%



\### Get Timing Report

\- Top menu → \*\*Reports → Report Timing Summary → OK\*\*

\- Screenshot showing: WNS = 6.025 ns, Failing Endpoints = 0

\- Must see: \*\*"All user specified timing constraints are met"\*\*



\---



\## PHASE 7 — Run Implementation



1\. Flow Navigator → \*\*IMPLEMENTATION\*\* → \*\*Run Implementation\*\*

2\. Click \*\*OK\*\*

3\. Wait 2-3 minutes

4\. When popup appears → \*\*"Open Implemented Design"\*\* → click \*\*OK\*\*



\### Check Implemented Timing

\- Bottom panel → \*\*Timing tab\*\*

\- Should show: WNS = 6.331 ns (better than synthesis)

\- Failing Endpoints = 0



\### Screenshot the Implemented Device View

\- The colorful FPGA chip layout showing your design placed on chip



\---



\## PHASE 8 — Generate Bitstream (Only if you have Basys3 board)



1\. Flow Navigator → \*\*PROGRAM AND DEBUG\*\* → \*\*Generate Bitstream\*\*

2\. Click \*\*OK\*\*

3\. Wait 3-5 minutes

4\. Connect Basys3 board via USB

5\. \*\*Tools → Hardware Manager → Open Target → Auto Connect\*\*

6\. Click \*\*Program Device\*\*

7\. Select the `.bit` file

8\. Click \*\*Program\*\*



Board will now respond to switches:

\- SW0 = light sensor

\- SW1 = motion sensor

\- SW2 = temp high

\- SW3 = door sensor

\- SW4 = security mode

\- SW5 = manual light

\- SW6 = manual fan

\- SW7 = manual AC

\- LD0 = light ctrl

\- LD1 = fan ctrl

\- LD2 = AC ctrl

\- LD4 = alarm

\- LD5 = energy save



\---



\## Common Errors and Fixes



| Error | Fix |

|---|---|

| "No top module" | Right-click RTL file → Set as Top |

| Signals show Z or X | Testbench not set as top — right-click TB → Set as Top |

| Simulation ends immediately | Normal — click Run All or type `run -all` |

| Waveform is empty after run | Scope panel → right-click → Add to Wave Window |

| Synthesis fails | Check Tcl console for error — usually missing file |

| WNS is negative | Timing violation — but our design is too small for this to happen |

| "Cannot find tb file" | Add Sources → Simulation Sources → add TB file again |



\---



\## Key Numbers to Remember



After completing all phases your results should be:



```

Simulation:

&#x20; Tests passed:        16 / 16

&#x20; Simulation time:     2885 ns



Synthesis:

&#x20; Slice LUTs:          34  (out of 20800 = <1%)

&#x20; Slice Registers:     17  (out of 41600 = <1%)

&#x20; Bonded IOB:          19

&#x20; Schematic cells:     82

&#x20; Nets:                93

&#x20; WNS:                 6.025 ns

&#x20; Failing endpoints:   0



Implementation:

&#x20; WNS:                 6.331 ns

&#x20; Failing endpoints:   0

&#x20; All constraints met: YES

```



\---



\## What Each Phase Proves



| Phase | What it proves |

|---|---|

| Simulation | Your logic is functionally correct |

| Synthesis | Your Verilog can be converted to real hardware gates |

| Implementation | Your design fits and meets timing on Artix-7 FPGA |

| Bitstream | Your design works on actual physical hardware |



Even without a board — Simulation + Synthesis + Implementation = complete FPGA design flow proof.

