#' \pkg{gmailr} makes gmail access easy.
#'
#' \code{gmailr} provides an interface to the gmail api \url{https://developers.google.com/gmail/api/}
#' @docType package
#' @name gmailr
#' @import httr
NULL

#' Get a list of Threads.
#'
#' Get a list of threads possibly matching a given query string.
#' @param search query to use, same format as gmail search box.
#' @param num_results the number of results to return, max per page is 100
#' @param page_token retrieve a specific page of results
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/list}
#' @export
threads = function(search = NULL, num_results = NULL, label_ids=NULL,
                     include_spam_trash=FALSE, user_id = 'me', page_token = NULL){
  res = threads_itr(search, num_results, label_ids, include_spam_trash, user_id, page_token)
  all_results = list(res)
  while(count_threads(all_results) < num_results && !is.null(res[['nextPageToken']])){
    res = threads_itr(search, num_results, label_ids, include_spam_trash, user_id, page_token)
    all_results[[length(all_results)+1]] = res
  }
  trim_threads(all_results, num_results)
}
threads_itr <- function(search, num_results, label_ids, include_spam_trash, user_id, page_token){
  opts = list(search = search, num_results = num_results,
              page_token = page_token, label_ids = label_ids,
              include_spam_trash = include_spam_trash)

  req = GET(gmail_path(rename(user_id), "threads"),
            query = rename(not_null(opts)), config(token = google_token))
  check(req)
  content(req)
}

#' Get a single Thread.
#'
#' Function to retrieve a given thread by id
#' @param id thread id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/thread}
#' @export
thread = function(id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  check(req)
  content(req)
}

#' Send a single Thread to the trash.
#'
#' Function to trash a given thread by id.  This can be undone by \code{\link{untrash_thread}}.
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/trash}
#' @export
trash_thread = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "threads", id, "trash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Remove a single Thread from the trash.
#'
#' Function to untrash a given Thread by id.  This can reverse the results of a previous \code{\link{trash_thread}}.
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/untrash}
#' @export
untrash_thread = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "threads", id, "untrash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Permanently delete a single Thread.
#'
#' Function to delete a given Thread by id.  This cannot be undone!
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/delete}
#' @export
# TODO: warning prompt?
delete_thread = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Modify the labels on a thread.
#'
#' Function to modify the labels on a given Thread by id.
#' @param add_labels labels to add to the specified thread
#' @param remove_labels labels to remove from the specified thread
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/threads/modify}
#' @export
modify_thread = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "threads", id, "modify"), body=body, encode="json",
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Get a single Message
#'
#' Function to retrieve a given Message by id
#' @param id message id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the message returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages}
#' @export
gmail_message = function(id, user_id = 'me', format=NULL) {
  req = GET(gmail_path(rename(user_id), "messages", id),
            query = not_null(format=format),
            config(token = google_token))
  check(req)
  content(req)
}

#' Get a list of Message.
#'
#' Get a list of messages possibly matching a given query string.
#' @param search query to use, same format as gmail search box.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @inheritParams thread
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/list}
messages = function(search = NULL, num_results = NULL, label_ids=NULL,
                     include_spam_trash=FALSE, user_id = 'me', page_token = NULL){
  res = messages_itr(search, num_results, label_ids, include_spam_trash, user_id, page_token)
  all_results = list(res)
  while(count_messages(all_results) < num_results && !is.null(res[['nextPageToken']])){
    res = messages_itr(search, num_results, label_ids, include_spam_trash, user_id, page_token)
    all_results[[length(all_results)+1]] = res
  }
  trim_messages(all_results, num_results)
}
messages_itr <- function(search, num_results, label_ids, include_spam_trash, user_id, page_token){
  opts = list(search = search, num_results = num_results,
              page_token = page_token, label_ids = label_ids,
              include_spam_trash = include_spam_trash)

  req = GET(gmail_path(rename(user_id), "messages"),
            query = rename(not_null(opts)), config(token = google_token))
  check(req)
  content(req)
}

#' Send a single Message to the trash.
#'
#' Function to trash a given Message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @export
trash_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "trash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Send a single Message to the trash.
#'
#' Function to trash a given Message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @export
untrash_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "trash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Permanently delete a single Message.
#'
#' Function to delete a given message by id.  This cannot be undone!
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/delete}
#' @export
delete_message = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "messages", id),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' Modify the labels on a message.
#'
#' Function to modify the labels on a given message by id.
#' @param add_labels labels to add to the specified message
#' @param remove_labels labels to remove from the specified message
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/modify}
#' @export
modify_message = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "messages", id, "modify"), body=body,
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#TODO: message_send

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
attachment = function(id, message_id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "messages", message_id, 'attachments', id),
            config(token = google_token))
  check(req)
  content(req)
}

#' Save all of the attachments to a message.
#'
#' Function to retrieve and save all of the attachments to a message by id of the message.
#' @param message_id id of the parent message
#' @param path where to save the attachments
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/attachments/get}
#' @export
save_attachments = function(message_id, path='', user_id = 'me'){
  val = message(message_id, user_id)
  for(part in val$payload$parts){
    if('filename' %in% names(part) && part[['filename']] != ''){
      att = attachment(part[['body']][['attachmentId']], message_id, user_id)
      file = paste0(path, part[['filename']])
      data = base64url_decode(att[['data']])
      writeBin(object=data, con=file)
    }
  }
}

#TODO:
##' @export
#insert_message = function(id, user_id = 'me') {
#  req = POST(gmail_path(rename(user_id), "messages", id, "modify"),
#            config(token = google_token))
#  check(req)
#  invisible(content(req))
#}

check <- function(req) {
  if (req$status_code < 400) return(invisible())

  stop("HTTP failure: ", req$status_code, "\n", req, call. = FALSE)
}

name_map = c(
  "user_id" = "userId",
  "search" = "q",
  "num_results" = "maxResults",
  "add_labels" = "addLabelIds",
  "remove_labels" = "removeLabelIds",
  "page_token" = "pageToken",
  "include_spam_trash" = "includeSpamTrash",
  NULL
)

rename = function(x){ names(x) = names(x)[names(x) %in% names(name_map)] = name_map[names(x)]; x }
not_null = function(x){ Filter(Negate(is.null), x) }

gmail_path = function(user, ...) { paste("https://www.googleapis.com/gmail/v1/users", user, ..., sep="/") }
base64url_decode_to_char = function(x) { rawToChar(base64decode(gsub("_", "/", gsub("-", "+", x)))) }
base64url_decode = function(x) { base64decode(gsub("_", "/", gsub("-", "+", x))) }

count_fun = function(type) function(res) { sum(vapply(lapply(res, `[[`, type), length, integer(1))) }
trim_fun = function(type) function(res, amount) {
  num = vapply(lapply(res, `[[`, type), length, integer(1))
  count = 0
  itr = 0
  while(count < amount && itr <= length(num)){
    itr = itr + 1
    count = count + num[itr]
  }
  remain = amount - count
  if(itr > length(res)){
    res
  }
  else {
    res[[itr]][[type]] = res[[itr]][[type]][1:(num[itr] + remain)]
    res[1:itr]
  }
}

count_messages = count_fun("messages")
trim_messages = trim_fun("messages")
count_threads = count_fun("threads")
trim_threads = trim_fun("threads")

debug = function(...){
  args = dplyr:::dots(...)

  message(sprintf(paste0(args, '=%s', collapse=' '), ...))
}

