# https://github.com/r-lib/gmailr/issues/144
test_that("gm_auth_configure() can accept the app via `app`", {
  google_app <- httr::oauth_app(
    "gmailr",
    key = "KEYKEYKEY",
    secret = "SECRETSECRETSECRET"
  )

  expect_error_free(gm_auth_configure(app = google_app))
})

test_that("gm_scopes() reveals gmail scopes", {
  local_edition(3)
  expect_snapshot(gm_scopes())
})

test_that("gm_scopes() substitutes full scope for short form", {
  expect_equal(gm_scopes("full"), "https://mail.google.com/")
  expect_equal(
    gm_scopes(c("readonly", "settings_basic")),
    c(
      "https://www.googleapis.com/auth/gmail.readonly",
      "https://www.googleapis.com/auth/gmail.settings.basic"
    )
  )
})

test_that("gm_scopes() passes unrecognized scopes through", {
  expect_equal(
    gm_scopes(c(
      "email",
      "readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )),
    c(
      "email",
      "https://www.googleapis.com/auth/gmail.readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )
  )
})
