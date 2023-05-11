if (gargle:::secret_can_decrypt("gmailr")) {
  # provide the actual token, so we don't need to get into the oauth client
  token <- unserialize(gzcon(rawConnection(
    gargle:::secret_read("gmailr", "gmailr-dev-token")
  )))
  dir.create(token$cache_path, showWarnings = FALSE)

  # https://github.com/r-lib/gmailr/issues/160
  fake_client <- gargle::gargle_oauth_client(
    id = "PLACEHOLDER",
    secret = "PLACEHOLDER"
  )
  gm_auth_configure(fake_client)
  # Alternatively, I could do this:
  # gm_auth_configure(client = token$app)
  # But that is somewhat misleading, i.e. it suggests the client needs to match
  # that of the token, which it does not.

  gm_auth(token = token)

  # TODO: Think about approaches other than this.
  Sys.setenv(GMAILR_EMAIL = token$email)
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}
