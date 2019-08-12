# This file is the interface between gmailr and the
# auth functionality in gargle.
.auth <- gargle::init_AuthState(
  package     = "gmailr",
  auth_active = TRUE # TODO: what is this?
)

# The roxygen comments for these functions are mostly generated from data
# in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "gmailr",
  YOUR_STUFF  = "your Gmail projects",
  PRODUCT     = "Google Gmail",
  API         = "Gmail API",
  PREFIX      = "gm",
  AUTH_CONFIG_SOURCE = "gmailr" #TODO: what is this?
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
gm_auth <- function(email = NULL,
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

#' Clear current token
#'
#' Clears any currently stored token. The next time gmailr needs a token, the
#' token acquisition process starts over, with a fresh call to [gm_auth()] and,
#' therefore, internally, a call to [gargle::token_fetch()]. Unlike some other
#' packages that use gargle, gmailr is not usable in a de-authorized state.
#' Therefore, calling `gm_deauth()` only clears the token, i.e. it does NOT
#' imply that subsequent requests are made with an API key in lieu of a token.
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
#' @description
#' These functions give the user more control over auth than what is possible
#' with [gm_auth()]. `gm_auth_configure()` gives control of:
#'   * The OAuth app, which is used when obtaining a user token.
#'
#' See the vignette [How to get your own API
#' credentials](https://gargle.r-lib.org/articles/get-api-credentials.html) for
#' more.
#'
#' @param app OAuth app.
#' @inheritParams gargle::oauth_app_from_json
#'
#' @return
#'   * `gm_auth_configure()`: An object of R6 class [gargle::AuthState],
#'     invisibly.
#'   * `gm_oauth_app()`: the current user-configured [httr::oauth_app()].
#'
#' @family auth functions
#' @export
#' @aliases gm_auth_config
#' @examples
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
#' \dontrun{
#' # bring your own app via JSON downloaded from Google Developers Console
#' gm_auth_configure(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
#'
gm_auth_configure <- function(app, path) {
  if (!xor(missing(app), missing(path))) {
    stop("Must supply exactly one of `app` and `path`", call. = FALSE)
  }
  if (!missing(path)) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
  }
  stopifnot(is.null(app) || inherits(app, "oauth_app"))

  .auth$set_app(app)

  invisible(.auth)
}

#' @export
#' @rdname gm_auth_configure
gm_oauth_app <- function() .auth$app