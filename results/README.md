# Experiment results

Analysis indexes are stored directly in this directory; detailed summaries remain in their size or allowance folders:
- summary_comp.csv / summary_comp.json: 3,375 records, five methods and 675 instances.
- n120/summary_n120.json through n600/summary_n600.json: 135 instances and 675 records per size.
- summary_sens.csv / summary_sens.json: 2,025 records at allowances 0.05, 0.10 and 0.20.
- s05/summary_sensitivity-05.json, s10/summary_sensitivity10.json, s20/summary_sensitivity20.json: detailed per-level summaries.

Raw comparison/component files remain under n120 through n600; raw sensitivity
files remain under s05, s10 and s20. The alpha=0 sensitivity baseline
is shared with BP-Enh in summary_comp.csv and is not stored a second time.
Density labels are Low, Medium and High. Gaps are fractions; times are seconds.
Method names use canonical identifiers (BP-Enh: bp-enhanced). Original build
metadata is retained, and SHA-256 hashes identify the current source files.
Configured resume_reference indexes allow only exact verified records to be reused.
The layout consolidation does not change objective values, bounds, times or statuses.

The JSON indexes use source_root=".", relative to their own directory, so the
complete bundle can be moved without rewriting raw instance or result files.
The sensitivity metadata reference is also relative to this directory.
