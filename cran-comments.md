## revdepcheck results

We checked 4 reverse dependencies, comparing R CMD check results across CRAN and dev versions of this package.

 * We saw 1 new problems
 * We failed to check 0 packages

Issues with CRAN packages are summarised below.

### New problems
(This reports the first line of each new failure)

* shiny.reglog
  checking dependencies in R code ... WARNING
  This package still has 1 reference to a now-removed function: send_message().
  This function has been hard-deprecated since gmailr v2.0.0 (2023-06-30) and
  soft-deprecated since gmailr v1.0.0 (2019-08-30).
  I have opened a pull request to fix the package:
  https://github.com/StatisMike/shiny.reglog/pull/59
