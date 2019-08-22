# nocov start

get_token <- function() {
  if(!exists("token", the)){
    gmail_auth()
  }
  the$token
}

#' Clear the current oauth token
#' @keywords internal
#' @export
clear_token <- function() {
  .Deprecated("gm_deauth()", package = "gmailr")
  unlink(".httr-oauth")
  the$token <- NULL
}

#' Setup oauth authentication for your gmail
#'
#' @param scope the authentication scope to use
#' @param id the client_id to use for authentication
#' @param secret the client secret to use for authentication
#' @param secret_file the secret json file downloaded from <https://console.cloud.google.com>
#' @seealso use_secret_file to set the default id and secret to a different
#'   value than the default.
#' @export
#' @keywords internal
#' @examples
#' \dontrun{
#' gmail_auth("compose")
#' }
gmail_auth <- function(scope=c("read_only", "modify", "compose", "full"),
                      id = the$id,
                      secret = the$secret,
                      secret_file = NULL) {
  .Deprecated("gm_auth() or gm_token()", package = "gmailr")

  if(!is.null(secret_file)){
    if (!(missing(id) && missing(secret))) {
      stop("You should set either ", sQuote("secret_file"), " or ",
           sQuote("id"), " and ", sQuote("secret"), ", not both",
           call. = FALSE)
    }
    use_secret_file(secret_file)

    # Use new ID and secret
    id <- the$id
    secret <- the$secret
  }
  myapp <- oauth_app("google", id, secret)

  scope_urls <- c(read_only = "https://www.googleapis.com/auth/gmail.readonly",
                  modify = "https://www.googleapis.com/auth/gmail.modify",
                  compose = "https://www.googleapis.com/auth/gmail.compose",
                  full = "https://mail.google.com/")
  scope <- scope_urls[match.arg(scope, several.ok=TRUE)]

  the$token <- oauth2.0_token(oauth_endpoints("google"), myapp, scope = scope)
}

#' Use information from a secret file
#'
#' This function sets the default secret and client_id to those in the secret
#' file
#' @param filename the filename of the file
#' @keywords internal
#' @export
use_secret_file <- function(filename) {
  .Deprecated(msg = paste0(
      "Use `gm_auth_configure()` to configure your own OAuth app. That will\n",
      "dictate the app used when `gm_auth()` is called implicitly or explicitly to\n",
      "obtain an OAuth2 token."
      )
  )
  info <- jsonlite::fromJSON(readChar(filename, nchars=1e5))
  the$secret <- info$installed$client_secret
  the$id <- info$installed$client_id
}

# nocov end
