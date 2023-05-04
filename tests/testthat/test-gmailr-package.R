test_that("gm_default_email() transmits GMAILR_EMAIL", {
  withr::local_envvar(GMAILR_EMAIL = "jenny@example.com")
  expect_equal(gm_default_email(), "jenny@example.com")
})

test_that("gm_default_email() falls back to gargle::gargle_oauth_email()", {
  # unset GMAILR_EMAIL
  withr::local_envvar(GMAILR_EMAIL = NA)
  expect_equal(Sys.getenv("GMAILR_EMAIL"), "")

  withr::local_options(gargle_oauth_email = NULL)
  expect_null(gm_default_email())

  withr::local_options(gargle_oauth_email = "*@example.com")
  expect_equal(gm_default_email(), "*@example.com")

  withr::local_options(gargle_oauth_email = TRUE)
  expect_true(gm_default_email())
})
