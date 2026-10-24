# Branch-and-price experiments for the parallel stack loading problem

This repository contains a prebuilt **Windows x64 experiment bundle** for the
parallel stack loading problem (PSLP). It includes the executable, runtime DLLs,
instance data, experiment launchers, configurations, and the recorded results.
The repository root corresponds to the local `Release` directory; no compilation
is needed to use the supplied executable.

## Quick start

1. Clone this repository or download and extract its ZIP archive.
2. Keep the executable, DLLs, configurations, `instances/`, and `results/`
   together in the extracted directory.
3. In PowerShell, check that the existing results can be reused:

   ```powershell
   .\pslp_bp.exe --check-resume algo_config-120.json
   ```

4. Double-click a batch file, for example `run_pslp_bp-120.bat`, or run:

   ```powershell
   .\pslp_bp.exe --config algo_config-120.json
   ```

The supplied configurations enable resume. A check reporting
`planned=675, skipped=675, missing=0, executed=0` means that all records in that
configuration can be reused. With the files and parameters unchanged, the
ordinary launcher skips those completed runs. Failed, missing, or incompatible
records may be computed when an ordinary experiment is launched.

Use a named configuration or a batch file. Double-clicking `pslp_bp.exe` without
arguments does not select an experiment; no default `algo_config.json` is supplied.
New optimization runs require the solver runtimes and the applicable CPLEX license.
Third-party components remain subject to their respective license terms.

## Directory and file guide

```text
.
|-- README.md
|-- .gitattributes
|-- pslp_bp.exe
|-- pslp_bp.pdb
|-- *.dll
|-- algo_config-*.json
|-- run_pslp_bp-*.bat
|-- instances/
|   |-- instances_120.txt ... instances_600.txt
|   |-- instances_120_tr.txt, instances_240_tr.txt
|   |-- oelschlagel/{arb,at,buckets,po,rt}/
|   `-- random/
|-- results/
|   |-- README.md
|   |-- summary_comp.csv, summary_comp.json
|   |-- summary_sens.csv, summary_sens.json
|   |-- n120/ ... n600/
|   `-- s05/, s10/, s20/
`-- logs/
```

| File or folder | Purpose |
|---|---|
| `pslp_bp.exe` | Command-line solver and experiment runner. |
| `pslp_bp.pdb` | Auxiliary debugging symbols; not needed to run experiments. |
| `*.dll` | Runtime libraries. Keep them next to the executable. They include SCIP/SoPlex, CPLEX, IPOPT/MUMPS, GMP/MPFR, threading and mathematical libraries, Microsoft C++ runtimes, and zlib. |
| `algo_config-*.json` | Select instances, algorithms, output locations, solver parameters, and resume indexes. |
| `run_pslp_bp-*.bat` | Launch the matching configuration and check runtime prerequisites. Each uses its own directory, independent of the caller's working directory. |
| `instances/` | Input JSON instances and size-specific input lists. The supplied experiments use 675 benchmark instances, with 135 at each size. Additional random examples and `_tr` lists are included but are not selected by the eight configurations. |
| `results/` | Raw per-run results, detailed summaries, and flat CSV/JSON analysis exports. |
| `logs/` | Reserved for logs; initially contains only a directory placeholder. Console output is not automatically saved here. |

## Batch files and configurations

The five size experiments each run **135 instances with five methods**, giving
675 runs per configuration.

| Batch file | Configuration | Results directory |
|---|---|---|
| `run_pslp_bp-120.bat` | `algo_config-120.json` | `results/n120/` |
| `run_pslp_bp-240.bat` | `algo_config-240.json` | `results/n240/` |
| `run_pslp_bp-360.bat` | `algo_config-360.json` | `results/n360/` |
| `run_pslp_bp-480.bat` | `algo_config-480.json` | `results/n480/` |
| `run_pslp_bp-600.bat` | `algo_config-600.json` | `results/n600/` |

The three stack-budget sensitivity experiments run BP-Enh on all 675 instances.
The allowance `alpha` increases the permitted stack count relative to its baseline
budget `B`, using `min(n_items, B + ceil(alpha * B))`.

| Batch file | Configuration | Allowance | Results directory |
|---|---|---|---|
| `run_pslp_bp-sensitivity-05.bat` | `algo_config-sensitivity-05.json` | 0.05 | `results/s05/` |
| `run_pslp_bp-sensitivity-10.bat` | `algo_config-sensitivity-10.json` | 0.10 | `results/s10/` |
| `run_pslp_bp-sensitivity-20.bat` | `algo_config-sensitivity-20.json` | 0.20 | `results/s20/` |

Each results directory contains 675 raw `*.result.json` records and one detailed
summary. Size summaries are named `summary_n120.json` through `summary_n600.json`.
Sensitivity summaries are named `summary_sensitivity-05.json`,
`summary_sensitivity10.json`, and `summary_sensitivity20.json` in their respective
directories.

All configurations use a **600-second solver limit**, one solver thread, random
seed 2026, `resume: true`, and `isolate_runs: true`. The reported solver time
excludes common initial-solution construction and is not the total batch time.
Concurrent batches use a global limit of two isolated solver child processes;
additional work waits for a slot.

## Algorithms

| Configuration/CLI name | Result identifier | Label | Main components |
|---|---|---|---|
| `mip` | `mip-flow` | AF-MIP | Arc-flow MIP solved by CPLEX. |
| `standard` | `bp-standard` | BP-Std | Standard branch-and-price with network-flow MIP pricing. |
| `enhanced` | `bp-enhanced` | BP-Enh | Exact stack-labeling pricing and in-search primal recovery and improvement. |
| `without-labeling` | `bp-without-labeling` | NoLabeling | Replaces labeling with exact network-flow MIP pricing and retains primal recovery and improvement. |
| `without-primal-package` | `bp-without-primal-package` | NoPrimal | Retains labeling and disables the in-search primal package. |

All five methods retain common initial-solution construction. The final B&P
configurations do not use early branching. `NoLabeling` is a separate ablation;
it is not an alias for `BP-Enh`.

## Reusing results and checking a run

```powershell
# Show command-line help.
.\pslp_bp.exe --help

# Read-only check: no solving, result deletion, or summary rewriting.
.\pslp_bp.exe --check-resume algo_config-600.json
.\pslp_bp.exe --check-resume algo_config-sensitivity-05.json

# Normal batch execution; matching completed results are skipped.
.\pslp_bp.exe --config algo_config-600.json
```

The size configurations use `results/summary_comp.json` as their verified resume
index; the sensitivity configurations use `results/summary_sens.json`.
Reuse checks the method, instance fingerprint, running parameters, settings,
stack budget, completion status, and relevant components. Indexed records from
the supplied experiment snapshot also require their exact source-file SHA-256.
A time-limited run is a completed result and can be reused. A failed process is
not treated as completed.

Keep the complete bundle together. The indexes use `source_root: "."`, relative
to the index location, and each `source_result` is relative to `results/`.
This permits moving the bundle without changing instance or result files.
The `.gitattributes` file disables text conversion for data files so that Git
checkout preserves the bytes used by fingerprints and SHA-256 checks.

Do not independently edit or rename raw records. Changing a configuration or a
data file can intentionally make an old result incompatible. When all runs are
skipped, an existing detailed summary is preserved.

Batch files pause before closing. To disable this in a command prompt:

```bat
set PSLP_NO_PAUSE=1
run_pslp_bp-120.bat
```

To capture console output, redirect it yourself, for example in PowerShell:

```powershell
.\pslp_bp.exe --config algo_config-120.json *> .\logs\n120.log
```

On failure, each batch file writes a distinct `last_run_error-*.txt` beside the
executable. Inspect that file and the relevant raw result for the failure reason.

## Recorded data

- `results/summary_comp.csv` and `.json` contain the same **3,375 records**:
  675 instances with five comparison/ablation methods.
- `results/summary_sens.csv` and `.json` contain the same **2,025 records**:
  675 instances at three positive stack-budget allowances.
- The zero-allowance sensitivity baseline reuses the 675 BP-Enh records from
  `summary_comp`; it is not duplicated in `summary_sens`.
- JSON exports include column definitions, protocol metadata, null handling,
  and typed `rows`. CSV exports use the same column order; empty cells represent
  missing values rather than zero.
- The objective is the number of blocking items. Time is in seconds, and
  `normalized_gap` is a fraction: `0.20` means 20%. Budget allowances and placement
  densities are also fractions.

See [results/README.md](results/README.md) and the JSON `field_definitions` for
further details. The supplied 5,400 recorded runs should all pass the read-only
resume checks when the bundle remains unchanged.
