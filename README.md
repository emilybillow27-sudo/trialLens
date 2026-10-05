# trialLens 0.1.0

An R package for inspecting a single T3 field trial. Interactive HTML reports work offline, with no server or external assets.

```r
install.packages("remotes")
remotes::install_github("emilybillow27-sudo/trialLens")
library(trialLens)
trial <- read_trial(file.choose()) # Choose your T3 phenotype CSV
trial_summary(trial)
trial_report(trial, file = "trialLens-report.html")
```

Reports include a selectable phenotype map, plot metadata, measurements over exported days, genotype means, descriptive check comparisons, missingness, and comparison CSV export. All phenotype columns with ontology-labelled headers are retained separately. Negative values are preserved, not silently corrected.

Check baseline is the equally weighted mean of observed check-variety means. Differences are not adjusted effects, significance tests, or breeding values. Missing metadata or trait protocols must be reviewed before interpreting cross-trial differences. Exported day labels are preserved without assuming days after planting. Genotypes with no observations remain visible.

The first version requires one trial with unique integer row/column coordinates and observation IDs. It does not interpret design codes or fit spatial/mixed models. This avoids making unsupported adjustments for the Colby file's MAD design and unequal check replication.
