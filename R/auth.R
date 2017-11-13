the <- new.env(parent = emptyenv())

get_token <- function() {
  if(!exists("token", the)){
    gmail_auth()
  }
  the$token
}

#' Clear the current oauth token
#' @export
clear_token <- function() {
  ## TODO(jennybc) if this touches the cache, should be more surgical?
  unlink(".httr-oauth")
  the$token <- NULL
}

#' Get or activate a gmail token
#'
#' @param scope the authentication scope to use
#' @param email Optional; email address associated with the desired Google user.
#' @param path Optional; path to the downloaded JSON file for a service token.
#' @inheritParams httr::oauth2.0_token
#' @export
#' @examples
#' \dontrun{
#' gmail_auth("compose")
#' }
gmail_auth <- function(scope = c("read_only", "modify", "compose", "full"),
                       email = NULL,
                       path = NULL,
                       cache = getOption("httr_oauth_cache"),
                       use_oob = getOption("httr_oob_default")) {

  scope_urls <- c(
    read_only = "https://www.googleapis.com/auth/gmail.readonly",
    modify = "https://www.googleapis.com/auth/gmail.modify",
    compose = "https://www.googleapis.com/auth/gmail.compose",
    full = "https://mail.google.com/"
  )
  scope <- scope_urls[match.arg(scope, several.ok = TRUE)]

  cred <- gargle::token_fetch(
    scopes = scope,
    app = the$oauth_app,
    email = email,
    path = path,
    cache = cache,
    use_oob = use_oob
  )
  #stopifnot(is_legit_token(cred, verbose = TRUE))
  the$token <- cred

  return(invisible(the$token))
}

#' View or set auth config
#'
#' @description This function gives advanced users more control over auth.
#' Whereas [gmail_auth()] gives control over tokens, `gmail_auth_config()`
#' gives control of:
#'   * The OAuth app. If you want to use your own app, setup a new project in
#'   [Google Developers Console](https://console.developers.google.com). Follow
#'   the instructions in
#'   [OAuth 2.0 for Mobile & Desktop Apps](https://developers.google.com/identity/protocols/OAuth2InstalledApp)
#'   to obtain your own client ID and secret. Provide these to
#'   [httr::oauth_app()].
#'
#' @param app OAuth app. Defaults to a tidyverse app that ships with gmailr.
#' @param secret_file Alternative way to bring your own app: the secret json
#'   file downloaded from \url{https://console.cloud.google.com} containing
#'   a client id and secret.
#' @export
#' @examples
#' gmail_auth_config()
gmail_auth_config <- function(app = NULL,
                              secret_file = NULL) {

  stopifnot(is.null(app) || inherits(app, "oauth_app"))
  stopifnot(is.null(secret_file) ||
              is.character(secret_file) ||
              length(secret_file) == 1)

  if (!is.null(app)) {
    if (!is.null(secret_file)) {
      stop("Don't provide both 'app' and 'secret_file'. Pick one.\n",
           call. = FALSE)
    }
    the$oauth_app <- app
    return(the$oauth_app)
  }

  if (is.null(secret_file)) return(the$oauth_app)

  info <- jsonlite::fromJSON(readChar(secret_file, nchars = 1e5))
  the$oauth_app <- oauth_app(
    "google",
    info$installed$client_id,
    info$installed$client_secret
  )
  the$oauth_app
}
