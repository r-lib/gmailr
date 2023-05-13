auth_success <- tryCatch(
  gm_auth_testing(),
  gmailr_auth_internal_error = function(e) e
)
if (!isTRUE(auth_success)) {
  cli::cli_inform(c(
    "!" = "Internal auth failed; not logged in with the testing Gmail account.",
    auth_success$body
  ))
}

skip_if_no_token <- function() {
  testthat::skip_if_not(gm_has_token(), "No Gmail token")
}
