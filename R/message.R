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

#' Get a list of messages
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
#' and message.  To save the attachment use \code{\link{save_attachment}}.
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
#' this only works on attachments retrieved with \code{\link{attachment}}.
#' To save an attachment directly from a message see \code{\link{save_attachments}}
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
#' @param x message with attachment
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

