# This file is the interface between gmailr and the
# auth functionality in gargle.
.auth <- gargle::init_AuthState(
  package     = "gmailr",
  auth_active = TRUE
)

# The roxygen comments for these functions are mostly generated from data
# in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "gmailr",
  YOUR_STUFF  = "your Gmail projects",
  PRODUCT     = "Google Gmail",
  API         = "Gmail API",
  PREFIX      = "gm"
)

#' Authorize bigrquery
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @family auth functions
#' @export
#'
#' @examples
#' \dontrun{
#' ## load/refresh existing credentials, if available
#' ## otherwise, go to browser for authentication and authorization
#' gm_auth()
#'
#' ## force use of a token associated with a specific email
#' gm_auth(email = "jim@example.com")
#'
#' ## force a menu where you can choose from existing tokens or
#' ## choose to get a new one
#' gm_auth(email = NA)
#'
#' ## use a 'read only' scope, so it's impossible to change data
#' gm_auth(
#'   scopes = "https://www.googleapis.com/auth/gmail.readonly"
#' )
#'
#' ## use a service account token
#' gm_auth(path = "foofy-83ee9e7c9c48.json")
#' }
gm_auth <- function(email = gm_default_email(),
                    path = NULL,
                    scopes = c(
                      "https://www.googleapis.com/auth/gmail.readonly",
                      "https://www.googleapis.com/auth/gmail.modify",
                      "https://www.googleapis.com/auth/gmail.compose",
                      "https://mail.google.com/"
                    ),
                    cache = gargle::gargle_oauth_cache(),
                    use_oob = gargle::gargle_oob_default(),
                    token = NULL) {
  cred <- gargle::token_fetch(
    scopes = scopes,
    app = gm_oauth_app(),
    email = email,
    path = path,
    package = "gmailr",
    cache = cache,
    use_oob = use_oob,
    token = token
  )
  if (!inherits(cred, "Token2.0")) {
    stop(
      "Can't get Google credentials.\n",
      "Are you running gmailr in a non-interactive session? Consider:\n",
      "  * Call `gm_auth()` directly with all necessary specifics.\n",
      call. = FALSE
    )
  }
  .auth$set_cred(cred)
  .auth$set_auth_active(TRUE)

  invisible()
}

gm_default_email <- function() {
  user <- Sys.getenv("GMAILR_EMAIL")
  if (nzchar(user)) {
    return(user)
  }
  NULL
}

#' Clear current token
#'
#' @eval gargle:::PREFIX_deauth_description_no_api_key(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' gm_deauth()
#' }
gm_deauth <- function() {
  .auth$clear_cred()
  invisible()
}

#' Produce configured token
#'
#' @eval gargle:::PREFIX_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_token_return()
#'
#' @family low-level API functions
#' @export
#' @examples
#' \dontrun{
#' gm_token()
#' }
gm_token <- function() {
  if (!gm_has_token()) {
    gm_auth()
  }
  httr::config(token = .auth$cred)
}

#' Is there a token on hand?
#'
#' Reports whether gmailr has stored a token, ready for use in downstream
#' requests.
#'
#' @return Logical.
#' @export
#'
#' @examples
#' gm_has_token()
gm_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

#' Edit auth configuration
#'
#' @eval gargle:::PREFIX_auth_configure_description(gargle_lookup_table, .has_api_key = FALSE)
#' @eval gargle:::PREFIX_auth_configure_params(.has_api_key = FALSE)
#' @eval gargle:::PREFIX_auth_configure_return(gargle_lookup_table, .has_api_key = FALSE)
#'
#' @inheritParams httr::oauth_app
#' @param ... Additional arguments passed to [httr::oauth_app()]
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' # see the current user-configured OAuth app (probaby `NULL`)
#' gm_oauth_app()
#'
#' if (require(httr)) {
#'
#'   # store current state, so we can restore
#'   original_app <- gm_oauth_app()
#'
#'   # bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   gm_auth_configure(app = google_app)
#'
#'   # confirm current app
#'   gm_oauth_app()
#'
#'   # restore original state
#'   gm_auth_configure(app = original_app)
#'   gm_oauth_app()
#' }
#'
#' # bring your own app via JSON downloaded from Google Developers Console
#' gm_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#'
gm_auth_configure <- function(key = Sys.getenv("GMAILR_APP_KEY"), secret = Sys.getenv("GMAILR_APP_SECRET"), path = "", appname = "gmailr", ...) {
  if (!((nzchar(key) && nzchar(secret)) || nzchar(path))) {
    stop("Must supply either `key` and `secret` or `path`", call. = FALSE)
  }
  if (!nzchar(path)) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
  } else {
    app <- httr::oauth_app(appname, key, secret, ...)
  }
  stopifnot(is.null(app) || inherits(app, "oauth_app"))

  .auth$set_app(app)

  invisible(.auth)
}

#' @export
#' @rdname gm_auth_configure
gm_oauth_app <- function() {
  if (!is.null(.auth$app)) {
    return(.auth$app)
  }
  stop("Must create an app and register it with `gm_auth_configure()`", call. = FALSE)
}
