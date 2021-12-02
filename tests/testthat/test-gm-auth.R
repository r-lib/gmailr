# https://github.com/r-lib/gmailr/issues/144
test_that("gm_auth_configure() can accept the app via `app`", {
  google_app <- httr::oauth_app(
    "gmailr",
    key = "KEYKEYKEY",
    secret = "SECRETSECRETSECRET"
  )

  expect_error_free(gm_auth_configure(app = google_app))
})
