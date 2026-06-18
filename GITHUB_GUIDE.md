\# GitHub Upload Guide

\## Smart Home Automation Controller on FPGA



\---



\## Step 1 — Create GitHub Account (if not done)



1\. Go to https://github.com

2\. Click \*\*Sign Up\*\*

3\. Username: `seshu-8` (already done)

4\. Verify email



\---



\## Step 2 — Create New Repository



1\. Go to https://github.com/seshu-8

2\. Click the \*\*+\*\* button (top right) → \*\*New Repository\*\*

3\. Fill in:



```

Repository name:  Smart-Home-Automation-FPGA

Description:      Verilog RTL Smart Home Controller on FPGA — 6-state Moore FSM,

&#x20;                 sensor automation, security alarm, energy saving.

&#x20;                 Simulation verified in Vivado 2024.2. Basys3 ready.

Visibility:       Public

Initialize:       tick "Add a README file" → NO (we have our own)

```



4\. Click \*\*Create Repository\*\*



\---



\## Step 3 — Upload Files (Easiest Way — GitHub Web UI)



\### Upload RTL code



1\. In your new repo page click \*\*Add file → Upload files\*\*

2\. Create folder structure by typing the path:

&#x20;  - Click \*\*create new file\*\*

&#x20;  - Type `rtl/smart\_home\_controller.v`

&#x20;  - Paste the RTL code content

&#x20;  - Click \*\*Commit new file\*\*



Repeat for each file:



| Type path as | File content |

|---|---|

| `rtl/smart\_home\_controller.v` | RTL module code |

| `tb/tb\_smart\_home\_controller.v` | Testbench code |

| `constraints/smart\_home\_basys3.xdc` | XDC constraints |

| `simulation/run\_simulation.sh` | Simulation script |

| `simulation/EDA\_Playground\_Guide.md` | EDA guide |

| `reports/Project\_Report.md` | Project report |

| `docs/Interview\_QA.md` | Interview Q\&A |

| `README.md` | Main README |

| `.gitignore` | Git ignore file |



\---



\### Upload Screenshots



1\. Click \*\*Add file → Upload files\*\*

2\. Drag and drop all 6 screenshots at once

3\. Before committing — type the path `images/` at the top

4\. Commit message: `Add simulation and synthesis screenshots`

5\. Click \*\*Commit changes\*\*



\---



\## Step 4 — Upload via Git (Alternative — using Git on PC)



If you have Git installed on Windows, open \*\*Git Bash\*\* or \*\*Command Prompt\*\*:



```bash

\# Step 1: Clone your empty repo

git clone https://github.com/seshu-8/Smart-Home-Automation-FPGA

cd Smart-Home-Automation-FPGA



\# Step 2: Copy all your project files into this folder

\# (copy rtl/, tb/, constraints/, simulation/, reports/, docs/, images/, README.md)



\# Step 3: Add all files

git add .



\# Step 4: Commit

git commit -m "Initial commit: Complete VLSI Smart Home FPGA project"



\# Step 5: Push to GitHub

git push origin main

```



\---



\## Step 5 — Add Repository Topics (Tags)



1\. Go to your repo page

2\. Click the \*\*gear icon\*\* next to "About" (top right of repo)

3\. Under Topics add these one by one:



```

verilog

fpga

vlsi

fsm

xilinx

vivado

digital-design

rtl

smart-home

basys3

```



4\. Click \*\*Save changes\*\*



\---



\## Step 6 — Pin Repository to Profile



1\. Go to your GitHub profile: https://github.com/seshu-8

2\. Click \*\*Customize your pins\*\*

3\. Select `Smart-Home-Automation-FPGA`

4\. Click \*\*Save pins\*\*



Now it shows on your profile front page.



\---



\## Step 7 — Verify Everything Looks Good



Open your repo and check:



\- \[ ] README.md displays correctly with all sections

\- \[ ] `rtl/` folder has `smart\_home\_controller.v`

\- \[ ] `tb/` folder has `tb\_smart\_home\_controller.v`

\- \[ ] `constraints/` folder has `.xdc` file

\- \[ ] `images/` folder has all 6 screenshots

\- \[ ] `reports/` folder has Project Report

\- \[ ] `docs/` folder has Interview Q\&A

\- \[ ] Repository topics are added

\- \[ ] Repository is pinned to profile



\---



\## Commit Message Guide



Use these commit messages in order:



```

1\. "Initial commit: RTL and testbench files"

2\. "Add FPGA constraints file for Basys3"

3\. "Add simulation scripts and EDA Playground guide"

4\. "Add Vivado 2024.2 simulation screenshots"

5\. "Add synthesis and implementation results"

6\. "Add project report and interview Q\&A"

7\. "Add README with full project documentation"

```



Multiple commits look better than one big commit — shows real development activity.



\---



\## Final Repository Structure



```

Smart-Home-Automation-FPGA/

│

├── rtl/

│   └── smart\_home\_controller.v

│

├── tb/

│   └── tb\_smart\_home\_controller.v

│

├── constraints/

│   └── smart\_home\_basys3.xdc

│

├── simulation/

│   ├── run\_simulation.sh

│   └── EDA\_Playground\_Guide.md

│

├── reports/

│   └── Project\_Report.md

│

├── docs/

│   └── Interview\_QA.md

│

├── images/

│   ├── waveform\_fsm\_states.png

│   ├── waveform\_energy\_save.png

│   ├── synthesized\_device.png

│   ├── schematic\_utilization.png

│   ├── timing\_synthesis.png

│   └── implemented\_timing.png

│

├── README.md

└── .gitignore

```

