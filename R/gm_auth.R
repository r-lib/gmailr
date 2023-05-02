# This file is the interface between gmailr and the
# auth functionality in gargle.

# Initialization happens in .onLoad
.auth <- NULL

# The roxygen comments for these functions are mostly generated from data
# in this list and template text maintained in gargle.
gargle_lookup_table <- list(
  PACKAGE     = "gmailr",
  YOUR_STUFF  = "your Gmail projects",
  PRODUCT     = "Google Gmail",
  API         = "Gmail API",
  PREFIX      = "gm"
)

#' Authorize gmailr
#'
#' @eval gargle:::PREFIX_auth_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_details(gargle_lookup_table)
#' @eval gargle:::PREFIX_auth_params()
#'
#' @family auth functions
#' @param scopes One or more API scopes. Each scope can be specified in full or,
#'   for Gmail API-specific scopes, in an abbreviated form that is recognized by
#'   [gm_scopes()]:
#'   * "full" = "https://mail.google.com/" (the default)
#'   * "gmail.compose" = "https://www.googleapis.com/auth/gmail.compose"
#'   * "gmail.readonly" = "https://www.googleapis.com/auth/gmail.readonly"
#'   * "gmail.labels" = "https://www.googleapis.com/auth/gmail.labels"
#'   * "gmail.send" = "https://www.googleapis.com/auth/gmail.send"
#'   * "gmail.insert" = "https://www.googleapis.com/auth/gmail.insert"
#'   * "gmail.modify" = "https://www.googleapis.com/auth/gmail.modify"
#'   * "gmail.metadata" = "https://www.googleapis.com/auth/gmail.metadata"
#'   * "gmail.settings_basic" = "https://www.googleapis.com/auth/gmail.settings.basic"
#'   * "gmail.settings_sharing" = "https://www.googleapis.com/auth/gmail.settings.sharing"
#'
#' See <https://developers.google.com/gmail/api/auth/scopes> for details on the
#' permissions for each scope.
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
                    scopes = "full",
                    cache = gargle::gargle_oauth_cache(),
                    use_oob = gargle::gargle_oob_default(),
                    token = NULL) {
  scopes <- gm_scopes(scopes)

  app <- gm_oauth_app()

  cred <- gargle::token_fetch(
    scopes = scopes,
    app = app,
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
#' @param secret consumer secret, also sometimes called the client secret.
#' @param ... Additional arguments passed to \code{\link[httr:oauth_app]{httr::oauth_app()}}
#' @family auth functions
#' @export
#' @examples
#' \dontrun{
#' # see the current user-configured OAuth app (errors if not configured)
#' gm_oauth_app()
#'
#' if (require(httr)) {
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
gm_auth_configure <- function(key = "",
                              secret = "",
                              path = Sys.getenv("GMAILR_APP"),
                              appname = "gmailr",
                              ...,
                              # TODO: this is a temporary fix to unblock other
                              # changes and allow re-document(); function needs
                              # more work and thought
                              client,
                              app = httr::oauth_app(appname, key, secret, ...)) {
  have_key_and_secret <- nzchar(key) && nzchar(secret)
  have_path <- nzchar(path)

  if (!(have_key_and_secret || have_path)) {
    have_app <- nzchar(app$key) && nzchar(app$secret)
    if (!have_app) {
      stop("Must supply `key` and `secret`, `path`, or `app`", call. = FALSE)
    }
  }
  if (have_path) {
    stopifnot(is_string(path))
    app <- gargle::oauth_app_from_json(path)
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

#' Get info on current gmail profile
#'
#' Reveals information about the profile associated with the current token.
#'
#' @seealso Wraps the `getProfile` endpoint:
#'   * <https://developers.google.com/gmail/api/reference/rest/v1/users/getProfile>
#'
#' @param verbose Logical, indicating whether to print informative messages
#'   (default `TRUE`).
#' @inheritParams gm_message
#' @return A list of class `gmail_profile`.
#' @export
#' @examples
#' \dontrun{
#' gm_profile()
#'
#' ## more info is returned than is printed
#' prof <- gm_profile()
#' prof[["historyId"]]
#' }
gm_profile <- function(user_id = "me", verbose = TRUE) {
  if (isFALSE(.auth$auth_active)) {
    if (verbose) {
      gm_message("Not logged in as any specific Google user.")
    }
    return(invisible())
  }
  gmailr_GET("profile", user_id, class = "gmail_profile")
}

#' @export
print.gmail_profile <- function(x, ...) {
  cat(
    sprintf(paste0(
      "Logged in as:\n",
      "  * email: %s\n",
      "  * num_messages: %i\n",
      "  * num_threads: %i"
    ), x[["emailAddress"]], x[["messagesTotal"]], x[["threadsTotal"]]),
    sep = "\n"
  )
  invisible(x)
}

#' Produce scopes specific to the Gmail API
#'
#' When called with no arguments, `gm_scopes()` returns a named character vector
#' of scopes associated with the Gmail API. If `gm_scopes(scopes =)` is given,
#' an abbreviated entry such as `"gmail.readonly"` is expanded to a full scope
#' (`"https://www.googleapis.com/auth/gmail.readonly"` in this case).
#' Unrecognized scopes are passed through unchanged.
#'
#' @inheritParams gm_auth
#'
#' @seealso <https://developers.google.com/gmail/api/auth/scopes> for details on
#'   the permissions for each scope.
#' @returns A character vector of scopes.
#' @family auth functions
#' @export
#' @examples
#' gm_scopes("full")
#' gm_scopes("gmail.readonly")
#' gm_scopes()
gm_scopes <- function(scopes = NULL) {
  if (is.null(scopes)) {
    return(gmail_scopes)
  }

  # In hindsight, I think it is better for the short form to be slightly less
  # short. Once you start to think about the full set of APIs and supporting
  # this in gargle, it seems that "gmail.compose" is better than "compose".
  # gmailr will continue to accept the original, very short forms for backwards
  # compatibility, but we catch, warn, and modify them here.
  scopes <- fixup_gmail_scopes(scopes)

  resolve_scopes(user_scopes = scopes, package_scopes = gmail_scopes)
}

gmail_scopes <- c(
  full                   = "https://mail.google.com/",
  gmail.compose          = "https://www.googleapis.com/auth/gmail.compose",
  gmail.readonly         = "https://www.googleapis.com/auth/gmail.readonly",
  gmail.labels           = "https://www.googleapis.com/auth/gmail.labels",
  gmail.send             = "https://www.googleapis.com/auth/gmail.send",
  gmail.insert           = "https://www.googleapis.com/auth/gmail.insert",
  gmail.modify           = "https://www.googleapis.com/auth/gmail.modify",
  gmail.metadata         = "https://www.googleapis.com/auth/gmail.metadata",
  gmail.settings_basic   = "https://www.googleapis.com/auth/gmail.settings.basic",
  gmail.settings_sharing = "https://www.googleapis.com/auth/gmail.settings.sharing"
)

# TODO: put some version of this in gargle
resolve_scopes <- function(user_scopes, package_scopes) {
  m <- match(user_scopes, names(package_scopes))
  ifelse(is.na(m), user_scopes, package_scopes[m])
}

# 'readonly' --> 'gmail.readonly'
# 'whatever' --> 'whatever'
fixup_gmail_scopes <- function(scopes) {
  haystack <- grep(
    "^https://www.googleapis.com/auth/gmail.",
    gmail_scopes,
    value = TRUE
  )
  haystack <- basename(haystack)
  haystack <- set_names(haystack, function(x) sub("^gmail[.]", "", x))

  m <- match(scopes, names(haystack))

  if (any(!is.na(m))) {
    needs_work <- haystack[m]
    needs_work <- needs_work[!is.na(needs_work)]
    what <- glue('
      The use of extremely short scopes \\
      ({glue::glue_collapse(glue::double_quote(names(needs_work)), sep = ", ")})')
    with <- glue('
      the slightly longer form \\
      ({glue::glue_collapse(glue::double_quote(needs_work), sep = ", ")})')
    lifecycle::deprecate_warn(
      when = "2.0.0",
      what = I(what),
      with = I(with)
    )
  }

  ifelse(is.na(m), scopes, haystack[m])
}
