#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @import base64enc
#' @import httr
#' @import rlang
#' @importFrom glue glue
#' @importFrom lifecycle deprecate_soft
#' @importFrom lifecycle deprecate_stop
#' @importFrom lifecycle deprecate_warn
#' @importFrom lifecycle deprecated
## usethis namespace: end
NULL

#' Configuring gmailr
#'
#' gmailr can be configured with various environment variables, which are
#' accessed through wrapper functions that provide some additional smarts.
#'
#' @seealso Since gmailr uses the gargle package to handle auth, gargle's
#'   configuration is also relevant, which is mostly accomplished through
#'   [options and associated accessor functions][gargle::gargle_options].
#'
#' @name gmailr-configuration
#' @family auth functions
NULL

#' @rdname gmailr-configuration
#' @export
#' @section `gm_default_email()`:
#' `gm_default_email()` returns the environment variable `GMAILR_EMAIL`, if it
#' exists, and [gargle::gargle_oauth_email()], otherwise.
#' @examples
#' gm_default_email()
#'
#' withr::with_envvar(
#'   c(GMAILR_EMAIL = "jenny@example.com"),
#'   gm_default_email()
#' )
gm_default_email <- function() {
  user <- Sys.getenv("GMAILR_EMAIL")
  if (nzchar(user)) {
    user
  } else {
    gargle::gargle_oauth_email()
  }
}

#' @rdname gmailr-configuration
#' @export
#' @section `gm_default_oauth_client()`:

#' `gm_default_oauth_client()` consults a specific set of locations, looking for
#' the filepath for the JSON file that represents an OAuth client. This file can
#' be downloaded from the APIs & Services section of the Google Cloud console
#' <https://console.cloud.google.com>). The search unfolds like so:

#' * `GMAILR_OAUTH_CLIENT` environment variable: If defined, it is assumed to be
#'   the path to the target JSON file.
#' * A `.json` file found in the directory returned by
#'   `rappdirs::user_data_dir("gmailr")`, whose filename uniquely matches the
#'   regular expression `"client_secret.+[.]json$"`.
#' * `GMAILR_APP` environment variable: This is supported for backwards
#'   compatibility, but it is preferable to store the JSON below
#'   `rappdirs::user_data_dir("gmailr")` or to store the path in the
#'   `GMAILR_OAUTH_CLIENT` environment variable.

#'
#' Here's an inspirational snippet to move the JSON file you downloaded into the
#' right place for auto-discovery by `gm_auth_configure()`:
#' ``` r
#' path_old <- "~/Downloads/client_secret_123-abc.apps.googleusercontent.com.json"
#' d <- fs::dir_create(rappdirs::user_data_dir("gmailr"), recurse = TRUE)
#' fs::file_move(path_old, d)
#' ```

#' @examples
#'
#' gm_default_oauth_client()
#'
#' withr::with_envvar(
#'   c(GMAILR_OAUTH_CLIENT = "path/to/my-client.json"),
#'   gm_default_oauth_client()
#' )
gm_default_oauth_client <- function() {
  path <- Sys.getenv("GMAILR_OAUTH_CLIENT")
  if (nzchar(path)) {
    return(path)
  }

  user_data_dir <- rappdirs::user_data_dir("gmailr")
  # WANT THIS, typical filename of downloaded OAuth client:
  # client_secret_1234-abcd.apps.googleusercontent.com.json
  # EXCLUDE THIS, typical filename of a service account key:
  # gargle-169921-1234abcd.json
  candidates <- list.files(
    user_data_dir,
    pattern = "client_secret.+[.]json$",
    full.names = TRUE
  )
  n <- length(candidates)
  if (n == 1) {
    return(candidates)
  }

  if (n > 1) {
    cli::cli_abort(c(
      "{n} candidate JSON files found in {.path {user_data_dir}}.",
      " " = "OAuth client can't be automatically discovered."
    ))
  }

  path <- Sys.getenv("GMAILR_APP")
  if (nzchar(path)) {
    deprecate_warn(
      when = "2.0.0",
      what = I("The `GMAILR_APP` environment variable"),
      with = I("`GMAILR_OAUTH_CLIENT` or the default storage location"),
      details = "Learn more at `?gm_default_oauth_client`."
    )
    return(path)
  }
}
