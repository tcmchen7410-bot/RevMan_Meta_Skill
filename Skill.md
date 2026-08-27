---
name: revman-meta-analysis
description: Perform RevMan 5-style meta-analysis on CSV files (local or uploaded) using R's meta package. Supports binary data (OR/RR) and continuous data (MD/SMD) with option to set fixed or random effects models, and generates forest plots.
---

# RevMan Meta Analysis Skill

When a user requests a Meta-Analysis or provides a CSV file for Meta-Analysis, execute the following workflow:

## 1. File & Data Identification
Inspect the CSV column names to determine the data type:
- **Binary Data**: Contains `event.e`, `n.e`, `event.c`, `n.c` (along with `Author` and `Year`).
- **Continuous Data**: Contains `m_e`, `sd_e`, `n_e`, `m_c`, `s_c` (or `sd_c`), `n_c` (along with `Author` and `Year`).

## 2. Parameter Extraction
Extract parameters from the user request or use default values:
- **Binary Data Parameters**:
  - Effect Measure (`sm`): `"OR"` or `"RR"` (Default: `"OR"`)
  - Model Type (`model`): `"fixed"` (common=TRUE, random=FALSE) or `"random"` (common=FALSE, random=TRUE) (Default: `"fixed"`)
- **Continuous Data Parameters**:
  - Effect Measure (`sm`): `"MD"` or `"SMD"` (Default: `"MD"`)
  - Model Type (`model`): `"fixed"` or `"random"` (Default: `"fixed"`)

## 3. Script Execution
Execute the corresponding R script based on data type:
- **Binary Data**:
  ```bash
  Rscript run_binary_meta.R <file_path> <sm> <model>
