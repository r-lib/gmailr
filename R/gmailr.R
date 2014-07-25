#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
NULL


google_token = NULL
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

  google_token <<- oauth2.0_token(oauth_endpoints("google"), myapp, scope = scope)
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
#' @param x message to retrieve body for
#' @param collapse collapse multipart message into one
#' @param ... other options ignored
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

body.gmail_draft = function(x, ...){ body.gmail_message(x$message, ...) }

#' Get the id of a message or draft
#' @param x the object from which to retrieve the id
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' id(my_message)
#' id(my_draft)
#' }
id = function(x, ...) UseMethod("id")
id.gmail_message = function(x, ...) { x$id }
id.gmail_draft = id.gmail_message

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
to.gmail_message = function(x, ...){ header_value(x, "To") }
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

from.gmail_message = function(x, ...){ header_value(x, "From") }
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

date.gmail_message = function(x, ...){ header_value(x, "Date") }
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

subject.gmail_message = function(x, ...) { header_value(x, "Subject") }
subject.gmail_draft = function(x, ...){ subject.gmail_message(x$message, ...) }

header_value = function(x, name){
  Find(function(header) identical(header$name, name), x$payload$headers)$value
}

#' Print a gmail_message
#' @param x the object to print
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' my_message
#' }
print.gmail_message = function(x, ...){
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
#' Print a gmail_draft
#' @param x the object to print
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' my_message
#' }
print.gmail_draft = print.gmail_message

#' Print a list of gmail_messages
#'
#' Prints each message_id and the corresponding thread_id
#' @param x the object to print
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' my_message
#' }
print.gmail_messages = function(x, ...){
  ids = unlist(lapply(x, function(page) { vapply(page$messages, '[[', character(1), 'id') }))
  threads = unlist(lapply(x, function(page) { vapply(page$messages, '[[', character(1), 'threadId') }))
  print(data.frame(message_id=ids, thread_id=threads))
}

#' Print a list of gmail_threads
#'
#' Prints each thread_id and the corresponding snippet.
#' @param x the object to print
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' my_message
#' }
print.gmail_threads = function(x, ...){
  ids = unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'id') }))
  snip = unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'snippet') }))
  print(data.frame(thread_id=ids, snippet=snip))
}
