str(Sys.getenv("GMAILR_EMAIL"))
options(gargle_quiet = FALSE)
if (gargle:::secret_can_decrypt("gmailr")) {
  # we want to use the oauth token directly, this avoids the need to reproduce the token filename
  token <- unserialize(gzcon(rawConnection(gargle:::secret_read("gmailr", "rpkgtester@gmail.com"))))
  dir.create(token$cache_path)
  gm_auth_configure()
  gargle::credentials_byo_oauth2(token = token)
  cred <- gargle::credentials_byo_oauth2(token = token)
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)
  #gm_auth(token = token)
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}
