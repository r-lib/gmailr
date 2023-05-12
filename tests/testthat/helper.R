if (gargle:::secret_can_decrypt("gmailr")) {
  token <- unserialize(gzcon(rawConnection(
    gargle:::secret_read("gmailr", "gmailr-dev-token")
  )))
  gm_auth(token = token)

  # TODO: Think about approaches other than this.
  Sys.setenv(GMAILR_EMAIL = token$email)
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}
