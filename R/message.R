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
message <- function(id = ? is_string,
                    user_id = "me" ? is_string,
                    format = c("full", "minimal", "raw") ?~ as_enum) {
  gmailr_GET(c("messages", id), user_id, class = "gmail_message",
            query = list(format=format))
}

#' Get a list of messages
#'
#' Get a list of messages possibly matching a given query string.
#' @export
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
messages <- function(search = NULL ? nullable(is_string),
  num_results = NULL ? nullable(is_number),
  label_ids = NULL ? nullable(is_strings),
  include_spam_trash = NULL ? nullable(is_boolean),
  page_token = NULL ? nullable(is_string),
  user_id = "me" ? is_string) {

  page_and_trim("messages", user_id, num_results, search, page_token, label_ids, include_spam_trash)
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
trash_message <- function(id = ? is_string, user_id = "me" ? is_string) {
  gmailr_POST(c("messages", id, "trash"), user_id, class = "gmail_message")
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
untrash_message <- function(id = ? is_string, user_id = "me" ? is_string) {
  gmailr_POST(c("messages", id, "untrash"), user_id, class = "gmail_message")
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
delete_message <- function(id = ? is_string, user_id = "me" ? is_string) {
  gmailr_DELETE(c("messages", id), user_id, class = "gmail_message")
}

#' Modify the labels on a message
#'
#' Function to modify the labels on a given message by id.  Note you need to
#' use the label ID as arguments to this function, not the label name.
#' @param add_labels label IDs to add to the specified message
#' @param remove_labels label IDs to remove from the specified message
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
modify_message <- function(id = ? is_string,
                           add_labels = NULL ? nullable(is_strings),
                           remove_labels = NULL ? nullable(is_strings),
                           user_id = "me" ? is_string) {
  gmailr_POST(c("messages", id, "modify"), user_id, class = "gmail_message",
    body = rename("add_labels" = add_labels, "remove_labels" = remove_labels),
    encode = "json")
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
attachment <- function(id = ? is_string,
                       message_id = ? is_string,
                       user_id = "me" ? is_string) {
  gmailr_GET(c("messages", message_id, "attachments", id),
             user_id,
             class = "gmail_attachment")
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
save_attachment <- function(x = ? has_class("gmail_attachment"),
                            filename = ? is_string){
  data <- base64url_decode(x$data)
  writeBin(object = data, con = filename)
  invisible(filename)
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
save_attachments <- function(x = ? has_class("gmail_message"),
                             attachment_id = NULL ? nullable(is_string),
                             path = "." ? valid_path,
                             user_id = "me" ? is_string) {
  attachments_parts <- if (!is.null(attachment_id)) {
    Find(function(part)
      identical(part$body$attachmentId, attachment_id),
      x$payload$parts)
  } else {
    Filter(function(part)
      !is.null(part$filename) && part$filename != "",
      x$payload$parts)
  }
  for (part in x$payload$parts) {
    att <- attachment(part$body$attachmentId, x$id, user_id)
    save_attachment(att, file.path(path, part$filename))
  }
}

#' Insert a message into the gmail mailbox from a mime message
#'
#' @param mail mime mail message created by mime
#' @param label_ids optional label ids to apply to the message
#' @param type the type of upload to perform
#' @param internal_date_source whether to date the object based on the date of
#'        the message or when it was received by gmail.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/insert}
#' @export
#' @examples
#' \dontrun{
#' insert_message(mime(from="you@@me.com", to="any@@one.com",
#'                           subject='hello", "how are you doing?"))
#' }
insert_message <- function(mail = ?~ as.character,
  label_ids = ? nullable(is_strings),
  type = c("multipart", "media", "resumable") ?~ as_enum,
  internal_date_source = c("dateHeader", "recievedTime") ?~ as_enum,
  user_id = "me" ? is_string) {

  gmailr_POST("messages", user_id, class = "gmail_message",
            query = list(uploadType = type, interalDateSource = internal_date_source),
            body = jsonlite::toJSON(auto_unbox=TRUE,
                          c(not_null(rename(label_ids)),
                            raw=base64url_encode(mail))),
             add_headers("Content-Type" = "application/json"))
}

#' Import a message into the gmail mailbox from a mime message
#'
#' @inheritParams insert_message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/import}
#' @export
#' @examples
#' \dontrun{
#' import_message(mime(from="you@@me.com", to="any@@one.com",
#'                           subject='hello", "how are you doing?"))
#' }
import_message <- function(mail = ?~ as.character,
  label_ids = ? nullable(is_strings),
  type = c("multipart", "media", "resumable") ?~ as_enum,
  internal_date_source = c("dateHeader", "recievedTime") ?~ as_enum,
  user_id = "me" ? is_string) {

  gmailr_POST(c("messages", "import"), user_id, class = "gmail_message",
    query = list(uploadType = type, interalDateSource = internal_date_source),
    body = jsonlite::toJSON(auto_unbox=TRUE,
      c(not_null(rename(label_ids)),
        raw=base64url_encode(mail))),
    add_headers("Content-Type" = "application/json"))
}

#' Send a message from a mime message
#'
#' @inheritParams insert_message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/send}
#' @export
#' @examples
#' \dontrun{
#' send_message(mime(from="you@@me.com", to="any@@one.com",
#'                           subject='hello", "how are you doing?"))
#' }
send_message <- function(
  mail = ?~ as.character,
  type = c("multipart", "media", "resumable") ?~ as_enum,
  thread_id = NULL ? nullable(is_string),
  user_id = "me" ? is_string) {

  gmailr_POST(c("messages", "send"), user_id, class = "gmail_message",
    query = list(uploadType = type),
    body = jsonlite::toJSON(auto_unbox=TRUE,
      c(threadId = thread_id,
        raw = base64url_encode(mail))),
    add_headers("Content-Type" = "application/json"))
}
