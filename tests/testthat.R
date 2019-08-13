library(testthat)
library(gmailr)

if (requireNamespace("xml2")) {
  test_check("gmailr", reporter = MultiReporter$new(reporters = list(JunitReporter$new(file = "test-results.xml"), CheckReporter$new())))
} else {
  test_check("gmailr")
}
