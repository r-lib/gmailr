test_that("gm_auth_configure() errors for key, secret, appname, app", {
  expect_snapshot(
    error = TRUE,
    gm_auth_configure(key = "KEY", secret = "SECRET")
  )
  expect_error(gm_auth_configure(appname = "APPNAME"))
  google_app <- httr::oauth_app(
    "gmailr",
    key = "KEYKEYKEY",
    secret = "SECRETSECRETSECRET"
  )
  expect_error(gm_auth_configure(app = google_app))
})

test_that("gm_oauth_app() is deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_snapshot(absorb <- gm_oauth_app())
})

test_that("gm_auth_configure() works", {
  old_client <- gm_oauth_client()
  withr::defer(gm_auth_configure(client = old_client))

  expect_snapshot(
    gm_auth_configure(client = gargle::gargle_client(), path = "PATH"),
    error = TRUE
  )

  gm_auth_configure(client = gargle::gargle_client())
  expect_s3_class(gm_oauth_client(), "gargle_oauth_client")

  gm_auth_configure(
    path = system.file(
      "extdata", "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    )
  )
  expect_s3_class(gm_oauth_client(), "gargle_oauth_client")

  gm_auth_configure(client = NULL)
  expect_null(gm_oauth_client())
})

test_that("gm_scopes() reveals gmail scopes", {
  expect_snapshot(gm_scopes())
})

test_that("gm_scopes() substitutes actual scope for short form", {
  expect_equal(
    gm_scopes(c(
      "full",
      "gmail.readonly",
      "gmail.settings_basic"
    )),
    c(
      "https://mail.google.com/",
      "https://www.googleapis.com/auth/gmail.readonly",
      "https://www.googleapis.com/auth/gmail.settings.basic"
    )
  )
})

test_that("gm_scopes() substitutes actual scope for legacy super-short form", {
  withr::local_options(lifecycle_verbosity = "warning")

  expect_snapshot_warning(
    out <- gm_scopes("readonly")
  )
  expect_equal(out, gm_scopes("gmail.readonly"))

  # multiple legacy scopes, plus another one
  expect_snapshot_warning(
    out <- gm_scopes(c("readonly", "openid", "compose"))
  )
  expect_equal(
    out,
    gm_scopes(c("gmail.readonly", "openid", "gmail.compose"))
  )
})

test_that("gm_scopes() passes unrecognized scopes through", {
  expect_equal(
    gm_scopes(c(
      "email",
      "gmail.compose",
      "https://www.googleapis.com/auth/cloud-platform"
    )),
    c(
      "email",
      "https://www.googleapis.com/auth/gmail.compose",
      "https://www.googleapis.com/auth/cloud-platform"
    )
  )
})
