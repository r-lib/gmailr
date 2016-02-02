#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
#' @import argufy
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
#' @param secret_file the secret json file downloaded from \url{https://cloud.google.com/console#/project}
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
#' @param collapse if `FALSE` will return each formatted body in list, if
#'   `TRUE` will collapse them together
#' @param type the content type of the body to return (for multipart messages), if NULL returns all types.
#' @export
#' @examples
#' \dontrun{
#' body(my_message)
#' body(my_draft)
#' }
body <- function(x, ...) UseMethod("body")

#' @rdname body
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
    res <- gmailr:::base64url_decode_to_char(x$payload$body$data)
  }

  if (collapse){
    res <- paste0(collapse = "\n", res)
  }

  res
}

#' @export
#' @rdname body
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
#' @rdname id
id.gmail_message <- function(x, ...) { x$id }

id.gmail_thread <- id.gmail_message

#' @export
#' @rdname id
id.gmail_draft <- id.gmail_message

#' @export
#' @inheritParams id
#' @param what the type of id to return
#' @rdname id
id.gmail_messages <- function(x, what=c("message_id", "thread_id"), ...){
  what <- switch(match.arg(what),
    message_id = "id",
    thread_id = "threadId"
  )
  unlist(lapply(x, function(page) { vapply(page$messages, "[[", character(1), what) }))
}

#' @export
#' @rdname id
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
#' @rdname id
id.gmail_threads <- function(x, ...){
  unlist(lapply(x, function(page) { vapply(page$threads, "[[", character(1), "id") }))
}

#' Methods to get values from message or drafts
#' @param x the object from which to get or set the field
#' @param ... other parameters passed to methods
#' @seealso \code{\link{common_fields}}
#' @rdname accessors
#' @export
to <- function(x, ...) UseMethod("to")

#' @export
#' @rdname accessors
to.gmail_message <- function(x, ...){ header_value(x, "To") }

#' @export
#' @rdname accessors
to.gmail_draft <- function(x, ...){ to.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
from <- function(x, ...) UseMethod("from")

#' @rdname accessors
#' @export
from.gmail_message <- function(x, ...){ header_value(x, "From") }

#' @rdname accessors
#' @export
from.gmail_draft <- from.gmail_message

#' @rdname accessors
#' @export
cc.gmail_message <- function(x, ...){ header_value(x, "Cc") }

#' @rdname accessors
#' @export
cc.gmail_draft <- function(x, ...){ from.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
bcc.gmail_message <- function(x, ...){ header_value(x, "Bcc") }

#' @rdname accessors
#' @export
bcc.gmail_draft <- function(x, ...){ from.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
date <- function(x, ...) UseMethod("date")

#' @export
date.default <- function(x, ...) { base::date() }

#' @rdname accessors
#' @export
date.gmail_message <- function(x, ...){ header_value(x, "Date") }

#' @rdname accessors
#' @export
date.gmail_draft <- function(x, ...){ date.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
subject <- function(x, ...) UseMethod("subject")

#' @rdname accessors
#' @export
subject.gmail_message <- function(x, ...) { header_value(x, "Subject") }

#' @rdname accessors
#' @export
subject.gmail_draft <- function(x, ...){ subject.gmail_message(x$message, ...) }

header_value <- function(x, name){
  Find(function(header) identical(header$name, name), x$payload$headers)$value
}

#' Format gmailr objects for pretty printing
#'
#' @param x object to format
#' @param ... additional arguments ignored
#' @name format
#' @rdname format
NULL

#' @export
#' @rdname format
format.gmail_message <- function(x, ...){
  to <- to(x)
  from <- from(x)
  date <- date(x)
  subject <- subject(x)
  id <- id(x)
  p(
    "Id: ", id, "\n",
    "To: ", to, "\n",
    "From: ", from, "\n",
    "Date: ", date, "\n",
    "Subject: ", subject, "\n",
      body(x, collapse=TRUE))
}

#' @export
#' @rdname format
format.gmail_thread <- function(x, ...){
  id <- id(x)
  strwrap(p("Thread_Id: ", id, "\n"))
}

#' @export
#' @rdname format
format.gmail_draft <- format.gmail_message

#' @export
#' @rdname format
format.gmail_messages <- function(x, ...){
  message_ids <- id(x, "message_id")
  thread_ids <- id(x, "thread_id")
  format(data.frame(message_id=message_ids, thread_id=thread_ids))
}

#' @export
#' @rdname format
format.gmail_threads <- function(x, ...){
  thread_ids <- id(x)
  snippets <- unlist(lapply(x, function(page) { vapply(page$threads, "[[", character(1), "snippet") }))
  format(data.frame(thread_id=thread_ids, snippet=snippets))
}

#' @export
#' @rdname format
format.gmail_drafts <- function(x, ...){
  draft_ids <- id(x, "draft_id")
  message_ids <- id(x, "message_id")
  thread_ids <- id(x, "thread_id")
  format(data.frame(draft_ids, message_id=message_ids, thread_id=thread_ids))
}

#' Print gmailr objects
#'
#' @param x object to print
#' @param ... additional arguments ignored
#' @name print
#' @rdname print
NULL

#' @rdname print
#' @export
print.gmail_message <- function(x, ...){
  print(format(x, ...))
}

#' @rdname print
#' @export
print.gmail_draft <- print.gmail_message

#' @rdname print
#' @export
print.gmail_drafts <- print.gmail_message

#' @rdname print
#' @export
print.gmail_messages <- print.gmail_message

#' @rdname print
#' @export
print.gmail_thread <- print.gmail_message

#' @rdname print
#' @export
print.gmail_threads <- print.gmail_message

the$last_response <- list()

gmailr_query <- function(fun, location, user_id, class = NULL, ...) {
  response <- fun(gmail_path(user_id, location),
             config(token = get_token()),
              ...)
  the$last_response <- response
  stop_for_status(response)
  result <- content(response, "parsed")

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
