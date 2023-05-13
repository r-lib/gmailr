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
#'
#' @family auth functions
#' @export
#'
#' @examplesIf rlang::is_interactive()
#' # load/refresh existing credentials, if available
#' # otherwise, go to browser for authentication and authorization
#' gm_auth()
#'
#' # indicate the specific identity you want to auth as
#' gm_auth(email = "jim@example.com")
#'
#' # force a new browser dance, i.e. don't even try to use existing user
#' # credentials
#' gm_auth(email = NA)
#'
#' # use a 'read only' scope, so it's impossible to, e.g., send or delete email
#' gm_auth(scopes = "gmail.readonly")
gm_auth <- function(email = gm_default_email(),
                    path = NULL,
                    scopes = "full",
                    cache = gargle::gargle_oauth_cache(),
                    use_oob = gargle::gargle_oob_default(),
                    token = NULL) {
  gargle::check_is_service_account(path, hint = "gm_auth_configure")
  scopes <- gm_scopes(scopes)

  client <- gm_oauth_client()
  cred <- gargle::token_fetch(
    scopes = scopes,
    app = client,
    email = email,
    path = path,
    package = "gmailr",
    cache = cache,
    use_oob = use_oob,
    token = token
  )

  if (inherits(cred, "Token2.0")) {
    .auth$set_cred(cred)
    .auth$set_auth_active(TRUE)
    return(invisible())
  }

  no_client <- is.null(client)
  no_client_msg <- c(
    "x" = "No OAuth client has been configured.",
    "i" = "To auth with the user flow, you must register an OAuth client with \\
           {.fun gm_auth_configure}.",
    "i" = "See the article \"Set up an OAuth client\" for how to get a client:",
    " " = "{.url https://gmailr.r-lib.org/dev/articles/oauth-client.html}"
  )

  non_interactive_msg <- c(
    "!" = "{.pkg gmailr} appears to be running in a non-interactive session \\
             and it can't auto-discover credentials.",
    " " = "You may need to call {.fun gm_auth} directly with all necessary \\
             specifics.",
    "i" = "See gargle's \"Non-interactive auth\" vignette for more details:",
    "i" = "{.url https://gargle.r-lib.org/articles/non-interactive-auth.html}"
  )

  cli::cli_abort(c(
    "Can't get Google credentials.",
    if (no_client) no_client_msg,
    if (!is_interactive()) non_interactive_msg,
    "i" = "For general auth troubleshooting, set \\
           {.code options(gargle_verbosity = \"debug\")} to see more detailed
           debugging information."
  ))
}

#' Clear current token
#'
#' @eval gargle:::PREFIX_deauth_description_no_api_key(gargle_lookup_table)
#'
#' @family auth functions
#' @export
#' @examplesIf rlang::is_interactive()
#' gm_deauth()
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
#' @examplesIf gm_has_token()
#' gm_token()
gm_token <- function() {
  if (!gm_has_token()) {
    gm_auth()
  }
  httr::config(token = .auth$cred)
}

#' Is there a token on hand?
#'
#' @eval gargle:::PREFIX_has_token_description(gargle_lookup_table)
#' @eval gargle:::PREFIX_has_token_return()
#'
#' @family low-level API functions
#' @export
#'
#' @examples
#' gm_has_token()
gm_has_token <- function() {
  inherits(.auth$cred, "Token2.0")
}

# gm_auth_configure() started out with a signature that is quite different from
# other packages, because gmailr adopted gargle later in its life. Therefore I
# had to document the arguments "by hand". That situation will improve with
# time, i.e. once I can truly remove deprecated arguments.

#' Edit auth configuration
#'
#' @description

#' See the article [Set up an OAuth
#' client](https://gmailr.r-lib.org/dev/articles/oauth-client.html) for
#' instructions on how to get an OAuth client. Then you can use
#' `gm_auth_configure()` to register your client for use with gmailr.
#' `gm_oauth_client()` retrieves the currently configured OAuth client.
#'
#' @param client A Google OAuth client, presumably constructed via
#'   [gargle::gargle_oauth_client_from_json()]. Note, however, that it is
#'   preferred to specify the client with JSON, using the `path` argument.
#' @inheritParams gargle::gargle_oauth_client_from_json
#' @param key,secret,appname,app `r lifecycle::badge('deprecated')` Use the
#'   `path` (strongly recommended) or `client` argument instead.
#'
#' @eval gargle:::PREFIX_auth_configure_return(gargle_lookup_table, .has_api_key
#'   = FALSE)
#'
#' @seealso [gm_default_oauth_client()] to learn how you can make your OAuth
#'   client easy for gmailr to discover.
#' @family auth functions
#' @export

#' @examplesIf rlang::is_interactive()
#' # if your OAuth client can be auto-discovered (see ?gm_default_oauth_client),
#' # you don't need to provide anything!
#' gm_auth_configure()

#' @examples
#' # see and store the current user-configured OAuth client
#' (original_client <- gm_oauth_client())
#'
#' # the preferred way to configure your own client is via a JSON file
#' # downloaded from Google Developers Console
#' # this example JSON is indicative, but fake
#' path_to_json <- system.file(
#'   "extdata", "client_secret_installed.googleusercontent.com.json",
#'   package = "gargle"
#' )
#' gm_auth_configure(path = path_to_json)
#'
#' # confirm that a (fake) OAuth client is now configured
#' gm_oauth_client()
#'
#' # restore original auth config
#' gm_auth_configure(client = original_client)
gm_auth_configure <- function(client = NULL,
                              path = gm_default_oauth_client(),
                              key = deprecated(),
                              secret = deprecated(),
                              appname = deprecated(),
                              app = deprecated()) {
  if (lifecycle::is_present(app) ||
      lifecycle::is_present(key) ||
      lifecycle::is_present(secret) ||
      lifecycle::is_present(appname)) {
    what <- glue("
      The use of `key`, `secret`, `appname`, and `app` with `gm_auth_configure()`")
    with <- glue("
      the `path` (strongly recommended) or `client` argument")
    deprecate_stop(
      when = "2.0.0",
      what = I(what),
      with = I(with)
    )
  }

  if (!missing(client) && !missing(path)) {
    cli::cli_abort(
      "Must supply exactly one of {.arg client} and {.arg path}, not both."
    )
  }

  if (missing(client)) {
    if (is.null(path)) {
      cli::cli_abort(
        "Must supply either {.arg client} or {.arg path}."
      )
    }
    check_string(path)
    client <- gargle::gargle_oauth_client_from_json(path)
  }
  stopifnot(is.null(client) || inherits(client, "gargle_oauth_client"))

  .auth$set_app(client)
  invisible(.auth)
}

#' @export
#' @rdname gm_auth_configure
gm_oauth_client <- function() {
  .auth$app
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
    deprecate_warn(
      when = "2.0.0",
      what = I(what),
      with = I(with)
    )
  }

  ifelse(is.na(m), scopes, haystack[m])
}

# unexported helpers that are nice for internal use ----
gm_auth_testing <- function() {
  can_decrypt <- gargle:::secret_can_decrypt("gmailr")
  online <- !is.null(curl::nslookup("gmail.googleapis.com", error = FALSE))
  if (!can_decrypt || !online) {
    cli::cli_abort(c(
      "Auth unsuccessful:",
      if (!can_decrypt) {
        c("x" = "Can't decrypt the token.")
      },
      if (!online) {
        c("x" = "We don't appear to be online. Or maybe the Gmail API is down?")
      }
    ),
    class = "gmailr_auth_internal_error",
    can_decrypt = can_decrypt, online = online
    )
  }

  token <- unserialize(gzcon(rawConnection(
    gargle:::secret_read("gmailr", "gmailr-dev-token")
  )))
  gm_auth(token = token)

  # TODO: Think about approaches other than this.
  Sys.setenv(GMAILR_EMAIL = token$email)

  print(gm_profile())
  invisible(TRUE)
}

# deprecated functions ----

#' Get currently configured OAuth app (deprecated)
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' In light of the new [gargle::gargle_oauth_client()] constructor and class of
#' the same name, `gm_oauth_app()` is being replaced by [gm_oauth_client()].
#' @keywords internal
#' @export
gm_oauth_app <- function() {
  deprecate_warn(
    "2.0.0", "gm_oauth_app()", "gm_oauth_client()"
  )
  gm_oauth_client()
}
