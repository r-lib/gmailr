#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import base64enc
#' @import httr
#' @import rlang
#' @importFrom glue glue
#' @importFrom lifecycle deprecate_soft
#' @importFrom lifecycle deprecate_warn
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

#' Configuring gmailr
#'
#' gmailr can be configured with various environment variables. Since gmailr
#' uses the gargle package to handle auth, gargle's configuration is also
#' relevant, which is mostly accomplished through [options and associated
#' accessor functions][gargle::gargle_options].
#'
#' @name gmailr_configuration
NULL

#' @rdname gmailr_configuration
#' @export
#' @section `gm_default_email()`:

#' `gm_default_email()` returns the environment variable `GMAILR_EMAIL`, if it
#' exists, and [gargle::gargle_oauth_email()], otherwise.
#' @family auth functions
gm_default_email <- function() {
  user <- Sys.getenv("GMAILR_EMAIL")
  if (nzchar(user)) {
    user
  } else {
    gargle::gargle_oauth_email()
  }
}

