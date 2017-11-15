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
#' Whereas \code{\link{gmail_auth}()} gives control over tokens,
#' \code{gmail_auth_config()} gives control of:
#' \itemize{
#' \item The OAuth app. If you want to use your own app, setup a new project
#' in \href{https://console.developers.google.com}{Google Developers Console}.
#' Follow the instructions in \href{https://developers.google.com/identity/protocols/OAuth2InstalledApp}{OAuth 2.0 for Mobile & Desktop Apps}
#' to obtain your own client ID and secret.
#' }
#' Either make an app from your client ID and secret via
#' \code{\link[httr]{oauth_app}()}
#' or provide a path the the JSON file containing same, which you can download
#' from
#' \href{https://console.developers.google.com}{Google Developers Console}.
#'
#' @param app OAuth app. Defaults to a tidyverse app that ships with gmailr.
#' @inheritParams gargle::oauth_app_from_json
#' @export
#' @examples
#' ## this will print current app
#' gmail_auth_config()
#'
#' if (require(httr)) {
#'   ## bring your own app via client id (aka key) and secret
#'   google_app <- httr::oauth_app(
#'     "my-awesome-google-api-wrapping-package",
#'     key = "123456789.apps.googleusercontent.com",
#'     secret = "abcdefghijklmnopqrstuvwxyz"
#'   )
#'   gmail_auth_config(app = google_app)
#' }
#'
#' \dontrun{
#' ## bring your own app via JSON downloaded from Google Developers Console
#' gmail_auth_config(
#'   path = "/path/to/the/JSON/you/downloaded/from/google/dev/console.json"
#' )
#' }
gmail_auth_config <- function(app = NULL,
                              path = NULL) {

  stopifnot(is.null(app) || inherits(app, "oauth_app"))
  stopifnot(is.null(path) || (is.character(path) && length(path) == 1))

  if (!is.null(app)) {
    if (!is.null(path)) {
      stop("Don't provide both 'app' and 'path'. Pick one.\n",
           call. = FALSE)
    }
    the$oauth_app <- app
    return(the$oauth_app)
  }

  if (is.null(path)) return(the$oauth_app)

  the$oauth_app <- gargle::oauth_app_from_json(path)
  the$oauth_app
}
