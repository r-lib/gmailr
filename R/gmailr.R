#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
#' @import base64enc
NULL

#' Get a single draft
#'
#' Function to retrieve a given draft by id
#' @param id draft id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the draft returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/get}
#' @export
#' @examples
#' \dontrun{
#' my_draft = draft('12345')
#' }
draft = function(id, user_id = 'me', format=c("full", "minimal", "raw")) {
  format = match.arg(format)
  req = GET(gmail_path(user_id, "drafts", id),
            query = format,
            config(token = google_token))
  stop_for_status(req)
  structure(content(req, "parsed"), class='gmail_draft')
}

#' Get a list of drafts
#'
#' Get a list of drafts possibly matching a given query string.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/list}
#' @examples
#' \dontrun{
#' my_drafts = drafts()
#'
#' first_10_drafts = drafts(10)
#' }
drafts = function(num_results = NULL, page_token = NULL, user_id = 'me'){
  page_and_trim('drafts', user_id, num_results, page_token)
}

#' Send a draft
#'
#' Send a draft to the recipients in the To, CC, and Bcc headers.
#' @param id the draft id to send
#' @param upload_type type of upload request
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/send}
#' @examples
#' \dontrun{
#' send_draft(12345)
#' }
send_draft = function(id, upload_type = c("media", "multipart", "resumable"), user_id = 'me') {
  upload_type = match.arg(upload_type)
  req = POST(gmail_path(user_id, "drafts"),
             query=rename(upload_type),
             body=c("id"=id), encode="json",
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Get a list of threads
#'
#' Get a list of threads possibly matching a given query string.
#' @param search query to use, same format as gmail search box.
#' @param num_results the number of results to return, max per page is 100
#' @param page_token retrieve a specific page of results
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/list}
#' @export
#' @examples
#' \dontrun{
#' my_threads = threads()
#'
#' first_10_threads = threads(10)
#' }
threads = function(search = NULL, num_results = NULL, page_token = NULL, label_ids = NULL, include_spam_trash = NULL, user_id = 'me'){
  page_and_trim('threads', user_id, num_results, search, page_token, label_ids, include_spam_trash)
}

#' Get a single thread
#'
#' Function to retrieve a given thread by id
#' @param id thread id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/thread}
#' @export
#' @examples
#' \dontrun{
#' my_thread = thread(12345)
#' }
thread = function(id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  stop_for_status(req)
  content(req, "parsed")
}

#' Send a single thread to the trash
#'
#' Function to trash a given thread by id.  This can be undone by \code{\link{untrash_thread}}.
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/trash}
#' @export
#' @examples
#' \dontrun{
#' trash_thread(12345)
#' }
trash_thread = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "threads", id, "trash"),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Remove a single thread from the trash.
#'
#' Function to untrash a given thread by id.  This can reverse the results of a previous \code{\link{trash_thread}}.
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/untrash}
#' @export
#' @examples
#' \dontrun{
#' untrash_thread(12345)
#' }
untrash_thread = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "threads", id, "untrash"),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Permanently delete a single thread.
#'
#' Function to delete a given thread by id.  This cannot be undone!
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/delete}
#' @export
#' @examples
#' \dontrun{
#' delete_thread(12345)
#' }
delete_thread = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Modify the labels on a thread
#'
#' Function to modify the labels on a given thread by id.
#' @param add_labels labels to add to the specified thread
#' @param remove_labels labels to remove from the specified thread
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/modify}
#' @export
#' @examples
#' \dontrun{
#' modify_thread(12345, add_labels='label_1')
#' modify_thread(12345, remove_labels='label_1')
#' #add and remove at the same time
#' modify_thread(12345, add_labels='label_2', remove_labels='label_1')
#' }
modify_thread = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "threads", id, "modify"), body=body, encode="json",
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Get a single message
#'
#' Function to retrieve a given message by id
#' @param id message id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the message returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages}
#' @export
#' @examples
#' \dontrun{
#' my_message = message(12345)
#' }
message = function(id, user_id = 'me', format=c("full", "minimal", "raw")) {
  format = match.arg(format)
  req = GET(gmail_path(user_id, "messages", id),
            query = format,
            config(token = google_token))
  stop_for_status(req)
  structure(content(req, "parsed"), class='gmail_message')
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

body.default = base::body

#' Extract the message body from an email message
#'
#' If a multipart message was returned each part will be a separate list item.
#' @param x message to retrieve body for
#' @param collapse collapse multipart message into one
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
#' @examples
#' \dontrun{
#' my_message
#' }
print.gmail_threads = function(x, ...){
  ids = unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'id') }))
  snip = unlist(lapply(x, function(page) { vapply(page$threads, '[[', character(1), 'snippet') }))
  print(data.frame(thread_id=ids, snippet=snip))
}

#' Get a list of message
#'
#' Get a list of messages possibly matching a given query string.
#' @param search query to use, same format as gmail search box.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @param label_ids restrict search to given labels
#' @param include_spam_trash boolean whether to include the spam and trash folders in the search
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/list}
#' @examples
#' \dontrun{
#' #Search for R, return 10 results using label 1 including spam and trash folders
#' my_messages = messages("R", 10, "label_1", TRUE)
#' }
messages = function(search = NULL, num_results = NULL, label_ids = NULL, include_spam_trash = NULL, user_id = 'me', page_token = NULL){
  page_and_trim('messages', user_id, num_results, search, page_token, label_ids, include_spam_trash)
}

#' Send a single message to the trash
#'
#' Function to trash a given message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @export
#' @examples
#' \dontrun{
#' trash_message('12345')
#' }
trash_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "trash"),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Remove a single message from the trash
#'
#' Function to trash a given message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @export
#' @examples
#' \dontrun{
#' untrash_message('12345')
#' }
untrash_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "trash"),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Permanently delete a single message
#'
#' Function to delete a given message by id.  This cannot be undone!
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/delete}
#' @export
#' @examples
#' \dontrun{
#' delete_message('12345')
#' }
delete_message = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "messages", id),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Modify the labels on a message
#'
#' Function to modify the labels on a given message by id.
#' @param add_labels labels to add to the specified message
#' @param remove_labels labels to remove from the specified message
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/modify}
#' @export
#' @examples
#' \dontrun{
#' modify_message(12345, add_labels='label_1')
#' modify_message(12345, remove_labels='label_1')
#' #add and remove at the same time
#' modify_message(12345, add_labels='label_2', remove_labels='label_1')
#' }
modify_message = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "messages", id, "modify"), body=body,
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Retrieve an attachment to a message
#'
#' Function to retrieve an attachment to a message by id of the attachment
#' and message.  This returns the base64 url encoded data, use
#' \link{\code{base64url_decode}} to get the raw bytes.
#' @param id id of the attachment
#' @param message_id id of the parent message
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/attachments/get}
#' @export
#' @examples
#' \dontrun{
#' my_attachment = attachment('a32e324b', '12345')
#' save attachment to a file
#' save_attachment(my_attachment, 'photo.jpg')
#' }
attachment = function(id, message_id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "messages", message_id, 'attachments', id),
            config(token = google_token))
  stop_for_status(req)
  structure(content(req, "parsed"), class="gmail_attachment")
}

#' save the attachment to a file
#'
#' this only works on attachments retrieved with \link{\code{attachment}}.
#' To save an attachment directly from a message see \link{\code{save_attachments}}
#' @param x attachment to save
#' @param filename location to save to
#' @export
#' @examples
#' \dontrun{
#' my_attachment = attachment('a32e324b', '12345')
#' save attachment to a file
#' save_attachment(my_attachment, 'photo.jpg')
#' }
save_attachment = function(x, filename){
  data = base64url_decode(x$data)
  writeBin(object=data, con=filename)
  invisible()
}

#' Save attachments to a message
#'
#' Function to retrieve and save all of the attachments to a message by id of the message.
#' @param message_id id of the parent message
#' @param attachment_id id of the attachment to save, if none specified saves all attachments
#' @param path where to save the attachments
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/attachments/get}
#' @export
#' @examples
#' \dontrun{
#' save all attachments
#' save_attachments(my_message)
#' save a specific attachment
#' save_attachments(my_message, 'a32e324b')
#' }
save_attachments = function(x, attachment_id = NULL, path='', user_id = 'me'){
  attachments_parts = if(!is.null(attachment_id)){
    Find(function(part){ identical(part$body$attachmentId, attachment_id)}, x$payload$parts)
  }
  else {
    Filter(function(part){ "filename" %in% names(part) && !identical(part$filename, '') }, x$payload$parts)
  }
  for(part in x$payload$parts){
    if('filename' %in% names(part) && part[['filename']] != ''){
      att = attachment(part[['body']][['attachmentId']], x$id, user_id)
      save_attachment(att, paste0(path, part[['filename']]))
    }
  }
}

#' Retrieve change history for the inbox
#'
#' Retrieves the history results in chronological order
#' @param start_history_id the point to start the history.  The historyId can be obtained from a message, thread or previous list response.
#' @param num_results the number of results to return, max per page is 100
#' @param label_id filter history only for this label
#' @param page_token retrieve a specific page of results
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/history/list}
#' @export
#' @examples
#' \dontrun{
#' my_history = history("10")
#' }
history = function(start_history_id = NULL, num_results = NULL, label_id = NULL, page_token = NULL,  user_id = 'me'){
  page_and_trim('history', user_id, num_results, label_id, start_history_id, page_token)
}

#' Get a list of all labels
#'
#' Get a list of all labels for a user.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/list}
#' @export
#' @examples
#' \dontrun{
#' my_labels = labels()
#' }
labels = function(user_id = 'me'){
  req = GET(gmail_path(user_id, "labels"),
            config(token = google_token))
  stop_for_status(req)
  content(req, "parsed")
}


#' Get a specific label
#'
#' Get a specific label by id and user_id.
#' @param id label id to retrieve
#' @inheritParams labels
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/get}
#' @export
label = function(id, user_id = 'me') {
  req = GET(gmail_path(user_id, "labels", id),
            config(token = google_token))
  stop_for_status(req)
  content(req, "parsed")
}

#' Update a existing label.
#'
#' Get a specific label by id and user_id.  \code{update_label_patch} is identical to \code{update_label} but the latter uses \href{http://tools.ietf.org/html/rfc5789}{HTTP PATCH} to allow partial update.
#' @param id label id to update
#' @param label the label fields to update
#' @inheritParams labels
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/update}
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/patch}
#' @export
update_label = function(id, label, user_id = 'me') {
  req = POST(gmail_path(user_id, "labels", id),
              body=label, encode='json',
              config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' @rdname update_label
#' @export
update_label_patch = function(id, label, user_id = 'me') {
  req = PATCH(gmail_path(user_id, "labels", id),
              body=label, encode='json',
              config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Permanently delete a label
#'
#' Function to delete a label by id.  This cannot be undone!
#' @inheritParams label
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/delete}
#' @export
delete_label = function(id, user_id = 'me') {
  req = DELETE(gmail_path(user_id, "labels", id),
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' Create a new label
#'
#' Function to create a label.
#' @param name name to give to the new label
#' @param label_list_visibility The visibility of the label in the label list in the Gmail web interface.
#' @param message_list_visibility The visibility of messages with this label in the message list in the Gmail web interface.
#' @inheritParams labels
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/labels/create}
#' @export
create_label = function(name, label_list_visibility=c("hide", "show", "show_unread"), message_list_visibility=c("hide", "show"), user_id = 'me') {
  label_list_visibility = label_value_map[match.arg(label_list_visibility)]
  message_list_visibility = match.arg(message_list_visibility)
  req = POST(gmail_path(user_id, "labels"),
               body=c(rename(name, label_list_visibility, message_list_visibility)), encode="json",
            config(token = google_token))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}
