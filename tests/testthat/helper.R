if (gargle:::secret_can_decrypt("gmailr")) {
  # we want to use the oauth token directly, this avoids the need to reproduce the token filename
  token <- unserialize(gzcon(rawConnection(gargle:::secret_read("gmailr", "rpkgtester@gmail.com"))))
  dir.create(token$cache_path, showWarnings = FALSE)
  .auth$set_app(token$app)
  gm_auth(token = token)
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}

expect_error_free <- function(...) {
  expect_error(regexp = NA, ...)
}
