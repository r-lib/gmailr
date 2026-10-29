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

test_that("gm_default_oauth_client() transmits GMAILR_OAUTH_CLIENT", {
  withr::local_envvar(GMAILR_OAUTH_CLIENT = "path/to/my-client.json")
  expect_equal(gm_default_oauth_client(), "path/to/my-client.json")
})

test_that("gm_default_oauth_client() latches on to 1 matching .json file", {
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  expect_equal(Sys.getenv("GMAILR_OAUTH_CLIENT"), "")

  tmp <- withr::local_tempdir(pattern = "R_USER_CONFIG_DIR-")
  withr::local_envvar(R_USER_CONFIG_DIR = tmp)

  config_dir <- tools::R_user_dir("gmailr", "config")
  dir.create(config_dir, recursive = TRUE)
  file.copy(
    system.file(
      "extdata",
      "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    config_dir
  )
  # a service account key might appear like this, but that shouldn't matter
  file.create(file.path(config_dir, "someproject-1234-1a2b3c4d.json"))

  expect_match(
    gm_default_oauth_client(),
    "client_secret_installed.googleusercontent.com.json"
  )
})

test_that("gm_default_oauth_client() errors for >1 matching .json files", {
  # unset GMAILR_OAUTH_CLIENT
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  expect_equal(Sys.getenv("GMAILR_OAUTH_CLIENT"), "")

  tmp <- withr::local_tempdir(pattern = "R_USER_CONFIG_DIR-")
  withr::local_envvar(R_USER_CONFIG_DIR = tmp)

  config_dir <- tools::R_user_dir("gmailr", "config")
  dir.create(config_dir, recursive = TRUE)
  file.copy(
    system.file(
      "extdata",
      "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    config_dir
  )
  file.copy(
    system.file(
      "extdata",
      "client_secret_web.googleusercontent.com.json",
      package = "gargle"
    ),
    config_dir
  )

  scrub_volatile_filepath <- function(x) {
    sub("\'.*/gmailr\'", "{GMAILR_CONFIG_DIR}", x)
  }
  expect_snapshot(
    error = TRUE,
    gm_default_oauth_client(),
    transform = scrub_volatile_filepath
  )
})

test_that("gm_default_oauth_client() falls back to legacy location, with warning", {
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  withr::local_options(lifecycle_verbosity = "warning")

  # R_USER_CONFIG_DIR governs the current location, which we leave empty
  # R_USER_DATA_DIR governs the legacy location, which rappdirs also honors
  tmp <- withr::local_tempdir()
  withr::local_envvar(
    R_USER_CONFIG_DIR = file.path(tmp, "config"),
    R_USER_DATA_DIR = file.path(tmp, "data")
  )

  legacy_dir <- rappdirs::user_data_dir("gmailr")
  dir.create(legacy_dir, recursive = TRUE)
  file.copy(
    system.file(
      "extdata",
      "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    legacy_dir
  )

  expect_warning(
    out <- gm_default_oauth_client(),
    class = "lifecycle_warning_deprecated"
  )
  expect_match(out, "client_secret_installed.googleusercontent.com.json")
})
