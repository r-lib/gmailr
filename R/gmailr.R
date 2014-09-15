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
#' to(mime_message(), 'someone@@somewhere.com')
#' # you can write
#' mime_message() %>% to('someone@@somewhere.com')
NULL

gmailr_env = new.env(parent = emptyenv())

get_token = function() {
  if(!exists('token', gmailr_env)){
    stop("Please register a gmail authentication token (https://cloud.google.com/console#/project) and run gmail_auth")
  }
  gmailr_env$token
}

#' Setup oauth authentication for your gmail
#' @param secret_file the secret json file downloaded from \url{https://cloud.google.com/console#/project}
#' @param scope the authentication scope to use
#' @export
#' @examples
#' \dontrun{
#' gmail_auth("file", "compose")
#' }
gmail_auth = function(secret_file, scope=c("read_only", "modify", "compose", "full")){

  info = jsonlite::fromJSON(readChar(secret_file, nchars=1e5))
  myapp = oauth_app("google", info$installed$client_id, info$installed$client_secret)

  scope = switch(match.arg(scope),
                 read_only = 'https://www.googleapis.com/auth/gmail.readonly',
                 modify = 'https://www.googleapis.com/auth/gmail.modify',
                 compose = 'https://www.googleapis.com/auth/gmail.compose',
                 full = 'https://mail.google.com/'
                 )

  gmailr_env$token = oauth2.0_token(oauth_endpoints("google"), myapp, scope = scope)
}
#' Get the body text of a message or draft
#' @param x the object from which to retrieve the body
#' @param ... other parameters passed to methods
#' @param collapse if `FALSE` will return each formatted body in list, if
#'   `TRUE` will collapse them together
#' @export
#' @examples
#' \dontrun{
#' body(my_message)
#' body(my_draft)
#' }
body = function(x, ...) UseMethod("body")

#' @rdname body
#' @export
body.gmail_message = function(x, collapse = FALSE, ...){
  res = lapply(x$payload$parts,
         function(x){
           base64url_decode_to_char(x$body$data)
         })
  if(collapse){
    paste0(collapse='\n', res)
  }
  else {
    res
  }
}

#' @export
#' @rdname body
body.gmail_draft = function(x, ...){ body.gmail_message(x$message, ...) }

#' Get the id of a gmailr object
#' @param x the object from which to retrieve the id
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' id(my_message)
#' id(my_draft)
#' }
id = function(x, ...) UseMethod("id")

#' @export
#' @rdname id
id.gmail_message = function(x, ...) { x$id }

#' @export
#' @rdname id
id.gmail_draft = id.gmail_message

#' @export
#' @inheritParams id
#' @param what the type of id to return
#' @rdname id
id.gmail_messages = function(x, what=c('message_id', 'thread_id'), ...){
  what = switch(match.arg(what),
    message_id = 'id',
    thread_id = 'threadId'
  )
  unlist(lapply(x, function(page) { vapply(page$messages, '[[', character(1), what) }))
}

#' @export
#' @rdname id
id.gmail_threads = function(x, ...){
  unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'id') }))
}

#' Methods to get values from message or grafts or set values in a mime message
#' @param x the object from which to get or set the field
#' @param ... other parameters passed to methods
#' @param val value to set
#' @param vals values to set, they will be joined by commas
#' @rdname accessors
#' @export
#' @examples
#' \dontrun{
#' to(my_message)
#' to(my_draft)
#' }
to = function(x, ...) UseMethod("to")

#' @export
#' @rdname accessors
to.gmail_message = function(x, ...){ header_value(x, "To") }

#' @export
#' @rdname accessors
to.gmail_draft = function(x, ...){ to.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
from = function(x, ...) UseMethod("from")

#' @rdname accessors
#' @export
from.gmail_message = function(x, ...){ header_value(x, "From") }

#' @rdname accessors
#' @export
from.gmail_draft = function(x, ...){ from.gmail_message(x$message, ...) }

#' @rdname accessors
#' @export
date = function(x, ...) UseMethod("date")

#' @rdname accessors
#' @export
date.gmail_message = function(x, ...){ header_value(x, "Date") }

#' @rdname accessors
#' @export
date.gmail_draft = function(x, ...){ date.gmail_message(x$message, ...) }

#' Get the subject field of a message or draft
#' @param x the object from which to retrieve the field
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' subject(my_message)
#' subject(my_draft)
#' }
subject = function(x, ...) UseMethod("subject")

#' @export
#' @rdname subject
subject.gmail_message = function(x, ...) { header_value(x, "Subject") }

#' @export
#' @rdname subject
subject.gmail_draft = function(x, ...){ subject.gmail_message(x$message, ...) }

header_value = function(x, name){
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
format.gmail_message = function(x, ...){
  to = to(x)
  from = from(x)
  date = date(x)
  subject = subject(x)
  id = id(x)
  cat("Id: ", id, "\n")
  cat("To: ", to, "\n")
  cat("From: ", from, "\n")
  cat("Date: ", date, "\n")
  cat("Subject: ", subject, "\n",
      body(x, collapse=TRUE))
}

#' @export
#' @rdname format
format.gmail_draft = format.gmail_message

#' @export
#' @rdname format
format.gmail_messages = function(x, ...){
  message_ids = id(x, 'message_id')
  thread_ids = id(x, 'thread_id')
  format(data.frame(message_id=message_ids, thread_id=thread_ids))
}

#' @export
#' @rdname format
format.gmail_threads = function(x, ...){
  thread_ids = id(x)
  snippets = unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'snippet') }))
  format(data.frame(thread_id=thread_ids, snippet=snippets))
}

#' @export
print.gmail_message = function(x, ...){
  format(x, ...)
}

#' @export
print.gmail_draft = print.gmail_message
#' @export
print.gmail_messages = print.gmail_message
#' @export
print.gmail_thread = print.gmail_message
#' @export
print.gmail_threads = print.gmail_message
