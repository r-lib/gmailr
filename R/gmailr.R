#' \pkg{gmailr} makes gmail access easy.
#'
#' `gmailr` provides an interface to the gmail api <https://developers.google.com/gmail/api/>
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
NULL

#' Pipe statements
#'
#' Like dplyr and ggvis gmailr also uses the pipe function, `\%>\%` to turn
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

gmailr_query <- function(fun, location, user_id, class = NULL, ..., upload = FALSE) {
  path_fun <- if (upload) gmail_upload_path else gmail_path
  response <- fun(path_fun(user_id, location), gm_token(), ...)
  result <- content(response, "parsed")

  the$last_response <- response
  if (status_code(response) >= 300) {
    cond <- structure(list(
        call = sys.call(-1),
        content = result,
        response = response,
        message = paste0("Gmail API error: ", status_code(response), "\n  ", result$error$message, "\n")),
        class = c("condition", "error", "gmailr_error"))
    stop(cond)
  }

  if (!is.null(class) && !is.null(result)) {
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

gmailr_GET <- function(location, user_id, class = NULL, ...) {
  gmailr_query(GET, location, user_id, class, ...)
}

gmailr_DELETE <- function(location, user_id, class = NULL, ...) {
  gmailr_query(DELETE, location, user_id, class, ...)
}

gmailr_PATCH <- function(location, user_id, class = NULL, ...) {
  gmailr_query(PATCH, location, user_id, class, ...)
}

gmailr_POST <- function(location, user_id, class = NULL, ...) {
  gmailr_query(POST, location, user_id, class, ...)
}
