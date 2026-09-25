---
name: revman-meta-analysis
description: Perform RevMan 5-style conventional pairwise meta-analysis in R for binary (OR/RR) and continuous (MD/SMD) outcomes, generate forest or funnel plots, and run Egger or Harbord funnel-asymmetry tests when explicitly requested. Use for CSV-based meta-analysis, RevMan-compatible calculations, publication-bias or small-study-effect assessment, and batch outcome processing.
---

# RevMan Meta-Analysis

Use the bundled R scripts. Resolve script paths relative to this `SKILL.md`.

## Mandatory RevMan 5 preset

Every script that creates a `meta` object must run this before `metabin()` or `metacont()`:

```r
settings.meta("RevMan5")
```

This is mandatory and case-sensitive. `forest(..., layout = "RevMan5")` changes presentation and does not replace the preset.

Verify the active preset before analysis:

```r
cfg <- settings.meta()
stopifnot(
  cfg$method.tau == "DL",
  cfg$method.random.ci == "classic",
  isTRUE(cfg$RR.Cochrane),
  cfg$method.smd == "Hedges",
  identical(cfg$exact.smd, FALSE),
  cfg$layout == "RevMan5"
)
```

Do not silently substitute package defaults such as REML. Record `packageVersion("meta")` when reproducibility or cross-run comparison matters.

## Route by data type

- Binary data require `event.e`, `n.e`, `event.c`, `n.c`, `Author`, and `Year`.
- Continuous data require `m_e`, `sd_e`, `n_e`, `m_c`, `n_c`, and either `sd_c` or `s_c`, plus `Author` and `Year`.

Use:

- `run_binary_meta.R <csv> <OR|RR> <fixed|random>` for binary meta-analysis and a RevMan-style forest plot.
- `run_continuous_meta.R <csv> <MD|SMD> <fixed|random>` for continuous meta-analysis and a RevMan-style forest plot.
- `run_egger_test.R <csv> <effect measure>` only when Egger's test or a generic continuous-outcome asymmetry assessment is explicitly requested.
- `run_harbord_test.R <csv> <OR|RR>` only for binary outcomes when Harbord's test or a generic binary-outcome asymmetry assessment is explicitly requested.

Default to OR and fixed effect for binary data, and MD and fixed effect for continuous data, only when the user does not specify them.

## Forest plots

Use the model and effect measure requested by the user or encoded in the source filename. Preserve the RevMan 5 preset for both calculations and layout. Report the pooled effect, 95% CI, number of studies, total participants, heterogeneity, and overall-effect test when available.

For batch work, verify every expected image exists and is non-empty. Inspect at least one binary, one continuous, and one random-effects plot before delivery.

## Funnel-asymmetry tests

Meta-analysis, funnel plots, Egger's test, and Harbord's test are independent modules. Do not run an asymmetry test automatically with every meta-analysis.

Run a test only when the user explicitly requests Egger, Harbord, publication-bias assessment, funnel-plot asymmetry, or small-study effects.

### Minimum study count

Require at least 10 included studies.

- If `k >= 10`, run the requested test.
- If `k < 10`, do not calculate a statistic or P value. Report: `Fewer than 10 studies were included; therefore, the test for funnel-plot asymmetry was not performed.`

Never override this threshold automatically.

### Egger's test

Use `run_egger_test.R`. Report the test name, study count, statistic, degrees of freedom when available, and P value. Generate `egger_funnel_plot.png`.

### Harbord's test

Use `run_harbord_test.R` only for binary data. Report the test name, study count, effect measure, statistic, degrees of freedom when available, and P value. Generate `harbord_funnel_plot.png`.

## Interpretation

Distinguish funnel-plot asymmetry, small-study effects, and publication bias.

- A significant result may indicate funnel-plot asymmetry or small-study effects; it is not proof of publication bias.
- A nonsignificant result is not evidence that publication bias is absent.
- Prefer wording such as: `Egger's regression test did not detect statistically significant evidence of funnel-plot asymmetry (P = 0.24).`

Do not overwrite a forest plot when generating funnel plots.
