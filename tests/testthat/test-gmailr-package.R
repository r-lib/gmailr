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
  # unset GMAILR_OAUTH_CLIENT
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  expect_equal(Sys.getenv("GMAILR_OAUTH_CLIENT"), "")

  tmp <- withr::local_tempdir(pattern = "R_USER_DATA_DIR-")
  withr::local_envvar(R_USER_DATA_DIR = tmp)

  user_data_dir <- rappdirs::user_data_dir("gmailr")
  dir.create(user_data_dir, recursive = TRUE)
  file.copy(
    system.file(
      "extdata", "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    user_data_dir
  )
  # a service account key might appear like this, but that shouldn't matter
  file.create(file.path(user_data_dir, "someproject-1234-1a2b3c4d.json"))

  expect_match(
    gm_default_oauth_client(),
    "client_secret_installed.googleusercontent.com.json"
  )
})

test_that("gm_default_oauth_client() errors for >1 matching .json files", {
  # unset GMAILR_OAUTH_CLIENT
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  expect_equal(Sys.getenv("GMAILR_OAUTH_CLIENT"), "")

  tmp <- withr::local_tempdir(pattern = "R_USER_DATA_DIR-")
  withr::local_envvar(R_USER_DATA_DIR = tmp)

  user_data_dir <- rappdirs::user_data_dir("gmailr")
  dir.create(user_data_dir, recursive = TRUE)
  file.copy(
    system.file(
      "extdata", "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    user_data_dir
  )
  file.copy(
    system.file(
      "extdata", "client_secret_web.googleusercontent.com.json",
      package = "gargle"
    ),
    user_data_dir
  )

  scrub_volatile_filepath <- function(x) {
    sub("\'.*/gmailr\'", "{GARGLE_USER_DATA}", x)
  }
  expect_snapshot(
    error = TRUE,
    gm_default_oauth_client(),
    transform = scrub_volatile_filepath
  )
})

test_that("gm_default_oauth_client() still consults GMAILR_APP, but warns", {
  # unset GMAILR_OAUTH_CLIENT
  withr::local_envvar(GMAILR_OAUTH_CLIENT = NA)
  expect_equal(Sys.getenv("GMAILR_OAUTH_CLIENT"), "")

  # make sure nothing is found in the gmailr user data
  tmp <- withr::local_tempdir(pattern = "R_USER_DATA_DIR-")
  withr::local_envvar(R_USER_DATA_DIR = tmp)

  withr::local_options(lifecycle_verbosity = "warning")
  withr::local_envvar(GMAILR_APP = "path/to/my-client.json")

  expect_snapshot_warning(client <- gm_default_oauth_client())
  expect_equal(client, "path/to/my-client.json")
})
