#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
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
#' body(my_message)
#' body(my_draft)
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
#' @export
#' @examples
#' \dontrun{
#' body(my_message)
#' body(my_draft)
#' }
body = function(x, ...) UseMethod("body")

#' Extract the message body from an email message
#'
#' If a multipart message was returned each part will be a separate list item.
#' @export
#' @param x message to retrieve body for
#' @param collapse collapse multipart message into one
#' @param ... other options ignored
#' @rdname body
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

#' Get the to field of a message or draft
#' @param x the object from which to retrieve the field
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' to(my_message)
#' to(my_draft)
#' }
to = function(x, ...) UseMethod("to")

#' @export
#' @rdname to
to.gmail_message = function(x, ...){ header_value(x, "To") }

#' @export
#' @rdname to
to.gmail_draft = function(x, ...){ to.gmail_message(x$message, ...) }

#' Get the from field of a message or draft
#' @param x the object from which to retrieve the field
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' from(my_message)
#' from(my_draft)
#' }
from = function(x, ...) UseMethod("from")

#' @export
#' @rdname from
from.gmail_message = function(x, ...){ header_value(x, "From") }

#' @export
#' @rdname from
from.gmail_draft = function(x, ...){ from.gmail_message(x$message, ...) }

#' Get the date field of a message or draft
#' @param x the object from which to retrieve the field
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' date(my_message)
#' date(my_draft)
#' }
date = function(x, ...) UseMethod("date")

#' @export
#' @rdname date
date.gmail_message = function(x, ...){ header_value(x, "Date") }

#' @export
#' @rdname date
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
