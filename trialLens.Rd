\name{trialLens}
\alias{read_trial}\alias{trial_summary}\alias{compare_checks}\alias{trial_report}
\title{Inspect T3 Field Trials}
\description{Read one T3 trial and generate descriptive field maps and check comparisons.}
\usage{
read_trial(file)
trial_summary(trial)
compare_checks(trial, trait = trial$traits[1])
trial_report(trial, file = "trialLens-report.html", open = interactive())
}
\arguments{
\item{file}{Input CSV or output HTML path.}
\item{trial}{Object returned by read_trial.}
\item{trait}{Exact phenotype column name.}
\item{open}{Whether to open the generated report.}
}
\value{A trial object, summary data frame, descriptive comparison data frame, or invisible report path.}
\details{The check baseline is the equally weighted mean of observed check-variety means. Differences are descriptive, without spatial or design adjustment. Plot coordinates describe the exported grid, not geographic orientation. No confidence intervals or breeding values are inferred.}
