#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
NULL

#' Pipe statements
#'
#' Like dplyr and ggvis gmailr also uses the pipe function, \code{\%>\%} to turn
#' function composition into a series of imperative statements.
#'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
#' @param lhs,rhs A visualisation and a function to apply to it
#' @examples
#' # Instead of
#' to(mime(), 'someone@@somewhere.com')
#' # you can write
#' mime() %>% to('someone@@somewhere.com')
NULL

the <- new.env(parent = emptyenv())
the$id <- "955034766742-huv7d1b1euegvk5vfmfq7v83u4rpdqb0.apps.googleusercontent.com"
the$secret <- "rpJPeEMnDOh7qNAVjUh_aKlO"

get_token <- function() {
  if(!exists("token", the)){
    gmail_auth()
  }
  the$token
}

#' Clear the current oauth token
#' @export
clear_token <- function() {
  unlink(".httr-oauth")
  the$token <- NULL
}

#' Setup oauth authentication for your gmail
#'
#' @param scope the authentication scope to use
#' @param id the client_id to use for authentication
#' @param secret the client secret to use for authentication
#' @param secret_file the secret json file downloaded from \url{https://console.cloud.google.com}
#' @seealso use_secret_file to set the default id and secret to a different
#'   value than the default.
#' @export
#' @examples
#' \dontrun{
#' gmail_auth("compose")
#' }
gmail_auth <- function(scope=c("read_only", "modify", "compose", "full"),
                      id = the$id,
                      secret = the$secret,
                      secret_file = NULL) {

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
#' @export
use_secret_file <- function(filename) {
  info <- jsonlite::fromJSON(readChar(filename, nchars=1e5))
  the$secret <- info$installed$client_secret
  the$id <- info$installed$client_id
}

#' Get the body text of a message or draft
#' @param x the object from which to retrieve the body
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' body(my_message)
#' body(my_draft)
#' }
body <- function(x, ...) UseMethod("body")

#' @export
body.gmail_message <- function(x, type="text/plain", collapse = FALSE, ...){
  is_multipart <- !is.null(x$payload$parts)

  if (is_multipart) {
    if (is.null(type)){
      good_parts <- TRUE
    } else {
      good_parts <- vapply(x$payload$parts, FUN.VALUE = logical(1),
        function(part) {
          any(
            vapply(part$headers, FUN.VALUE = logical(1),
              function(header) {
                tolower(header$name) %==% "content-type" &&
                  grepl(type, header$value, ignore.case = TRUE)
              })
            )
        })
    }

    res <-
      lapply(x$payload$parts[good_parts],
        function(x){
            base64url_decode_to_char(x$body$data)
        })
  } else { # non_multipart
    res <- base64url_decode_to_char(x$payload$body$data)
  }

  if (collapse){
    res <- paste0(collapse = "\n", res)
  }

  res
}

#' @export
body.gmail_draft <- function(x, ...){ body.gmail_message(x$message, ...) }

#' Get the id of a gmailr object
#' @param x the object from which to retrieve the id
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' id(my_message)
#' id(my_draft)
#' }
id <- function(x, ...) UseMethod("id")

#' @export
id.gmail_message <- function(x, ...) { x$id }

#' @export
id.gmail_thread <- id.gmail_message

#' @export
id.gmail_draft <- id.gmail_message

#' @rdname id
#' @export
#' @inheritParams id
#' @param what the type of id to return
id.gmail_messages <- function(x, what=c("message_id", "thread_id"), ...){
  what <- switch(match.arg(what),
    message_id = "id",
    thread_id = "threadId"
  )
  unlist(lapply(x, function(page) { vapply(page$messages, "[[", character(1), what) }))
}

#' @export
id.gmail_drafts <- function(x, what=c("draft_id", "message_id", "thread_id"), ...){
  what <- switch(match.arg(what),
    draft_id = return(
                      unlist(lapply(x, function(page) { vapply(page$drafts, "[[", character(1), "id")}))
                      ),
    message_id = "id",
    thread_id = "threadId"
  )
  unlist(lapply(x, function(page) { vapply(page$drafts, function(x){ x$message[[what]] }, character(1)) }))
}

#' @export
id.gmail_threads <- function(x, ...){
  unlist(lapply(x, function(page) { vapply(page$threads, "[[", character(1), "id") }))
}

#' Methods to get values from message or drafts
#' @param x the object from which to get or set the field
#' @param ... other parameters passed to methods
#' @rdname accessors
#' @export
to <- function(x, ...) UseMethod("to")

#' @export
to.gmail_message <- function(x, ...){ header_value(x, "To") }

#' @export
to.gmail_draft <- function(x, ...){ to.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
from <- function(x, ...) UseMethod("from")

#' @export
from.gmail_message <- function(x, ...){ header_value(x, "From") }

#' @export
from.gmail_draft <- from.gmail_message

#' @export
from <- function(x, ...) UseMethod("from")

#' @rdname accessors
#' @export
cc <- function(x, ...) UseMethod("cc")

#' @export
cc.gmail_message <- function(x, ...){ header_value(x, "Cc") }

#' @export
cc.gmail_draft <- function(x, ...){ from.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
bcc <- function(x, ...) UseMethod("bcc")

#' @export
bcc.gmail_message <- function(x, ...){ header_value(x, "Bcc") }

#' @export
bcc.gmail_draft <- function(x, ...){ from.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
date <- function(x, ...) UseMethod("date")

#' @export
date.default <- function(x, ...) { base::date() }

#' @export
date.gmail_message <- function(x, ...){ header_value(x, "Date") }

#' @export
date.gmail_draft <- function(x, ...){ date.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
subject <- function(x, ...) UseMethod("subject")

#' @export
subject.gmail_message <- function(x, ...) { header_value(x, "Subject") }

#' @export
subject.gmail_draft <- function(x, ...){ subject.gmail_message(x$message, ...) }

header_value <- function(x, name){
  Find(function(header) identical(header$name, name), x$payload$headers)$value
}

#' @export
print.gmail_message <- function(x, ...){
  to <- to(x)
  from <- from(x)
  date <- date(x)
  subject <- subject(x)
  id <- id(x)
  cat(p(
    crayon::bold("Id: "), id, "\n",
    crayon::bold("To: "), to, "\n",
    crayon::bold("From: "), from, "\n",
    crayon::bold("Date: "), date, "\n",
    crayon::bold("Subject: "), subject, "\n",
      body(x, collapse = TRUE)), "\n")
}

#' @export
print.gmail_thread <- function(x, ...){
  id <- id(x)
  cat(strwrap(p(crayon::bold("Thread Id: "), id, "\n")), "\n")
}

#' @export
print.gmail_draft <- function(x, ...){
  id <- id(x)
  cat(strwrap(p(crayon::bold("Draft Id: "), id, "\n")), "\n")
  print(x$message, ...)
}

#' @export
print.gmail_messages <- function(x, ...){
  message_ids <- id(x, "message_id")
  thread_ids <- id(x, "thread_id")
  print(format(data.frame(message_id=message_ids, thread_id=thread_ids)), ...)
}

#' @export
print.gmail_threads <- function(x, ...){
  thread_ids <- id(x)
  snippets <- unlist(lapply(x, function(page) { vapply(page$threads, "[[", character(1), "snippet") }))
  print(format(data.frame(thread_id=thread_ids, snippet=snippets)), ...)
}

#' @export
print.gmail_drafts <- function(x, ...){
  draft_ids <- id(x, "draft_id")
  message_ids <- id(x, "message_id")
  thread_ids <- id(x, "thread_id")
  print(format(data.frame(draft_ids, message_id=message_ids, thread_id=thread_ids)), ...)
}

the$last_response <- list()

gmailr_query <- function(fun, location, user_id, class = NULL, ...) {
  response <- fun(gmail_path(user_id, location),
             config(token = get_token()),
              ...)
  result <- content(response, "parsed")

  the$last_response <- response
  if (status_code(response) >= 300) {
    cond <- structure(list(
        call = sys.call(-1),
        content = result,
        response = response,
        message = paste0("Gmail API error: ", status_code(response), "\n  ", result$error$message, "\n")),
        class = c("condition", "error", "gmailr_error"))
    stop(cond, call. = FALSE)
  }

  if (!is.null(class)) {
    class(result) <- class
  }
  result
}

#' Response from the last query
#'
#' @export
last_response <- function() {
  the$last_response
}

gmailr_POST <- function(location, user_id, class = NULL, ...) {
  gmailr_query(POST, location, user_id, class, ...)
}

gmailr_GET <- function(location, user_id, class = NULL, ...) {
  gmailr_query(GET, location, user_id, class, ...)
}

gmailr_DELETE <- function(location, user_id, class = NULL, ...) {
  gmailr_query(DELETE, location, user_id, class, ...)
}
