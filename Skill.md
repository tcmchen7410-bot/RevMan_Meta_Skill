# RevMan Meta-Analysis Skill

## Purpose

This skill performs conventional pairwise meta-analysis using R and generates
RevMan-style meta-analysis outputs.

The skill supports:

- Binary-outcome meta-analysis
- Continuous-outcome meta-analysis
- Forest plots
- Egger's regression test for funnel-plot asymmetry
- Harbord's test for funnel-plot asymmetry
- Funnel plots

The existing meta-analysis scripts and the small-study-effect tests are
independent modules.

---

## Available scripts

### Binary meta-analysis

Use:

`run_binary_meta.R`

for conventional meta-analysis of binary outcomes.

Typical effect measures include:

- OR: odds ratio
- RR: risk ratio

---

### Continuous meta-analysis

Use:

`run_continuous_meta.R`

for conventional meta-analysis of continuous outcomes.

Typical effect measures include:

- MD: mean difference
- SMD: standardized mean difference

---

## Small-study effects and funnel-plot asymmetry

This skill supports two tests for funnel-plot asymmetry:

1. Egger's regression test
2. Harbord's test

These tests must NOT automatically be performed as part of every
meta-analysis.

Run them when the user explicitly requests:

- Egger test
- Egger's test
- Harbord test
- Harbord's test
- publication bias test
- funnel-plot asymmetry test
- small-study-effect test

If the user specifically names Egger or Harbord, use the requested method.

Do not automatically replace one explicitly requested method with another.

---

## Minimum number of studies

Tests for funnel-plot asymmetry must only be performed when at least
10 studies are included.

This is a mandatory rule for this skill.

### If k >= 10

Perform the requested Egger's or Harbord's test.

### If k < 10

Do NOT calculate Egger's test.

Do NOT calculate Harbord's test.

Do NOT report a test statistic or P value.

Report:

"Fewer than 10 studies were included; therefore, the test for funnel-plot
asymmetry was not performed."

The threshold of 10 studies must not be overridden automatically.

---

## Egger's regression test

### Script

Use:

`run_egger_test.R`

### Trigger

Run this script when the user explicitly requests:

- Egger
- Egger test
- Egger's test
- Egger regression
- Egger regression test
- Egger test for funnel-plot asymmetry
- assessment of small-study effects using Egger's method

### Minimum number of studies

Egger's test is performed only when:

`k >= 10`

If:

`k < 10`

the script must terminate without performing the statistical test.

### Output

When k >= 10, report:

- test name
- number of studies
- test statistic
- degrees of freedom when available
- P value

Generate:

`egger_funnel_plot.png`

### Interpretation

A statistically significant test may indicate funnel-plot asymmetry or
small-study effects.

Do not automatically interpret a significant test as proof of publication
bias because funnel-plot asymmetry can have causes other than publication
bias.

A nonsignificant test must not be interpreted as evidence that publication
bias is absent.

---

## Harbord's test

### Script

Use:

`run_harbord_test.R`

### Outcome type

Harbord's test is used only for binary outcomes.

Do not use `run_harbord_test.R` for continuous outcomes.

### Trigger

Run this script when the user explicitly requests:

- Harbord
- Harbord test
- Harbord's test
- Harbord regression
- Harbord test for funnel-plot asymmetry
- assessment of small-study effects using Harbord's method

### Minimum number of studies

Harbord's test is performed only when:

`k >= 10`

If:

`k < 10`

the script must terminate without performing the statistical test.

### Output

When k >= 10, report:

- test name
- number of studies
- effect measure
- test statistic
- degrees of freedom when available
- P value

Generate:

`harbord_funnel_plot.png`

### Interpretation

A statistically significant test may indicate funnel-plot asymmetry or
small-study effects.

Do not automatically interpret a significant Harbord test as proof of
publication bias.

A nonsignificant Harbord test must not be interpreted as evidence that
publication bias is absent.

---

## Analysis routing

Use the following routing rules.

### Binary meta-analysis

User requests a binary meta-analysis:

→ `run_binary_meta.R`

### Continuous meta-analysis

User requests a continuous meta-analysis:

→ `run_continuous_meta.R`

### Egger's test

User explicitly requests Egger's test:

→ `run_egger_test.R`

### Harbord's test

User explicitly requests Harbord's test:

→ `run_harbord_test.R`

---

## Combined analyses

Multiple scripts can be run for the same dataset.

### Example 1

User:

"Perform a binary meta-analysis using OR."

Run:

`run_binary_meta.R`

Do not automatically run Egger or Harbord.

---

### Example 2

User:

"Perform a binary meta-analysis using OR and conduct Harbord's test."

Run:

`run_binary_meta.R`

and:

`run_harbord_test.R`

---

### Example 3

User:

"Perform a binary meta-analysis and conduct Egger's test."

Run:

`run_binary_meta.R`

and:

`run_egger_test.R`

---

### Example 4

User:

"Perform a continuous meta-analysis using MD and conduct Egger's test."

Run:

`run_continuous_meta.R`

and:

`run_egger_test.R`

---

### Example 5

User:

"Perform Harbord's test."

Run:

`run_harbord_test.R`

Do not run the standard meta-analysis script unless required to construct
the meta-analysis object needed by the test.

---

## Generic requests for publication bias

If the user only says:

"Assess publication bias"

or:

"Assess funnel-plot asymmetry"

or:

"Assess small-study effects"

first determine the outcome type and available data.

Do not automatically claim that funnel-plot asymmetry is equivalent to
publication bias.

For binary outcomes, Harbord's test can be used when appropriate.

For continuous outcomes, Egger's regression test can be used when
appropriate.

Regardless of method:

`k < 10` → do not perform the statistical test.

---

## Reporting requirements

Always distinguish between:

- funnel-plot asymmetry
- small-study effects
- publication bias

These terms must not automatically be treated as equivalent.

Do not report:

"No publication bias"

solely because:

`P > 0.05`

Instead report the statistical result directly, for example:

"Egger's regression test did not detect statistically significant evidence
of funnel-plot asymmetry (P = 0.24)."

Do not claim that publication bias is absent.

---

## Output files

Depending on the requested analysis, the skill can produce:

- RevMan-style forest plot
- `egger_funnel_plot.png`
- `harbord_funnel_plot.png`

Do not overwrite the forest plot when generating funnel plots.
