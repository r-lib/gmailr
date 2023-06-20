test_that("the 'with-auth' GHA workflow actually has a token", {
  skip_if_not(
    Sys.getenv("GITHUB_ACTIONS") == "true",
    "Not on GitHub Actions"
  )

  skip_if_not(
    Sys.getenv("WITH_AUTH") == "true",
    "Not the 'with-auth' GHA workflow"
  )

  expect_true(gm_has_token())
})

# gm_auth() ----
test_that("gm_auth() errors if OAuth client is passed to `path`", {
  expect_snapshot(
    error = TRUE,
    gm_auth(
      path = system.file(
        "extdata", "client_secret_installed.googleusercontent.com.json",
        package = "gargle"
      )
    )
  )
})

test_that("gm_auth() errors informatively", {
  credentials_nope <- function(scopes, ...) { NULL }
  gargle::local_cred_funs(funs = list(credentials_nope = credentials_nope))
  local_mocked_bindings(gm_default_oauth_client = function() NULL)
  local_interactive(FALSE)

  expect_snapshot(
    error = TRUE,
    gm_auth()
  )
})

# gm_auth_configure() ----
test_that("gm_auth_configure() works", {
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  withr::local_envvar(GMAILR_APP = NA)
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

  local_mocked_bindings(gm_default_oauth_client = function() NULL)
  expect_snapshot(
    error = TRUE,
    gm_auth_configure()
  )
})

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

# gm_scopes() ----
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

# gm_token_write / gm_token_read() ----

test_that("gm_token_write() / gm_token_read() roundtrip, built-in key", {
  fauxen_in <- gargle::gargle2.0_token(
    email = "a@example.org",
    credentials = list(a = 1)
  )
  tmp <- withr::local_tempfile(pattern = "fauxen-")

  gm_token_write(fauxen_in, tmp)
  fauxen_out <- gm_token_read(tmp)

  expect_error(readRDS(tmp))
  expect_equal(fauxen_in, fauxen_out)
})

test_that("gm_token_write() / gm_token_read() roundtrip, explicit key", {
  fauxen_in <- gargle::gargle2.0_token(
    email = "b@example.org",
    credentials = list(b = 1)
  )
  tmp <- withr::local_tempfile(pattern = "fauxen-")
  withr::local_envvar(GMAILR_ABCXYZ_KEY = gargle::secret_make_key())

  gm_token_write(fauxen_in, tmp, key = "GMAILR_ABCXYZ_KEY")

  expect_error(readRDS(tmp))
  expect_error(gm_token_read(tmp))

  fauxen_out <- gm_token_read(tmp, "GMAILR_ABCXYZ_KEY")
  expect_equal(fauxen_in, fauxen_out)
})
