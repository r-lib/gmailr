if (gargle:::secret_can_decrypt("gmailr")) {
  # provide the actual token, so we don't need to get into the oauth client
  token <- unserialize(gzcon(rawConnection(
    gargle:::secret_read("gmailr", "gmailr-dev-token")
  )))
  dir.create(token$cache_path, showWarnings = FALSE)

  # Is this really necessary? I doubt it
  gm_auth_configure(client = token$app)

  gm_auth(token = token)

  # TODO: Think about approaches other than this.
  Sys.setenv(GMAILR_EMAIL = token$email)
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}
