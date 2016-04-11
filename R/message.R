#' Get a single message
#'
#' Function to retrieve a given message by id
#' @param id message id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the message returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages}
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_message = message(12345)
#' }
message <- function(id,
                    user_id = "me",
                    format = c("full", "metadata", "minimal", "raw")) {
  stopifnot(
    is_string(id),
    is_string(user_id))

  format <- match.arg(format)
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
#' @family message
#' @examples
#' \dontrun{
#' #Search for R, return 10 results using label 1 including spam and trash folders
#' my_messages = messages("R", 10, "label_1", TRUE)
#' }
messages <- function(search = NULL,
  num_results = NULL,
  label_ids = NULL,
  include_spam_trash = NULL,
  page_token = NULL,
  user_id = "me") {
  stopifnot(
    nullable(is_string)(search),
    nullable(is_number)(num_results),
    nullable(is_strings)(label_ids),
    nullable(is_boolean)(include_spam_trash),
    nullable(is_string)(page_token),
    is_string(user_id))

  page_and_trim("messages", user_id, num_results, search, page_token, label_ids, include_spam_trash)
}

#' Send a single message to the trash
#'
#' Function to trash a given message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @export
#' @family message
#' @examples
#' \dontrun{
#' trash_message('12345')
#' }
trash_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id))

  gmailr_POST(c("messages", id, "trash"), user_id, class = "gmail_message")
}

#' Remove a single message from the trash
#'
#' Function to trash a given message by id.  This can be undone by \code{\link{untrash_message}}.
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/trash}
#' @family message
#' @export
#' @examples
#' \dontrun{
#' untrash_message('12345')
#' }
untrash_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id))

  gmailr_POST(c("messages", id, "untrash"), user_id, class = "gmail_message")
}

#' Permanently delete a single message
#'
#' Function to delete a given message by id.  This cannot be undone!
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/delete}
#' @family message
#' @export
#' @examples
#' \dontrun{
#' delete_message('12345')
#' }
delete_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id))

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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' modify_message(12345, add_labels='label_1')
#' modify_message(12345, remove_labels='label_1')
#' #add and remove at the same time
#' modify_message(12345, add_labels='label_2', remove_labels='label_1')
#' }
modify_message <- function(id,
                           add_labels = NULL,
                           remove_labels = NULL,
                           user_id = "me") {
  stopifnot(
    is_string(id),
    nullable(is_strings)(add_labels),
    nullable(is_strings)(remove_labels),
    is_string(user_id))

  gmailr_POST(c("messages", id, "modify"), user_id, class = "gmail_message",
    body = rename("add_labels" = I(add_labels), "remove_labels" = I(remove_labels)),
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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_attachment = attachment('a32e324b', '12345')
#' save attachment to a file
#' save_attachment(my_attachment, 'photo.jpg')
#' }
attachment <- function(id,
                       message_id,
                       user_id = "me") {

  stopifnot(
    is_string(id),
    is_string(message_id),
    is_string(user_id))

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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_attachment = attachment('a32e324b', '12345')
#' # save attachment to a file
#' save_attachment(my_attachment, 'photo.jpg')
#' }
save_attachment <- function(x, filename){
  stopifnot(
     has_class(x, "gmail_attachment"),
     is_string(filename))

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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' # save all attachments
#' save_attachments(my_message)
#' # save a specific attachment
#' save_attachments(my_message, 'a32e324b')
#' }
save_attachments <- function(x,
                             attachment_id = NULL,
                             path = ".",
                             user_id = "me") {
  stopifnot(
     has_class(x, "gmail_message"),
     nullable(is_string)(attachment_id),
     valid_path(path),
     is_string(user_id))

  attachments_parts <- if (!is.null(attachment_id)) {
    Find(function(part)
      identical(part$body$attachmentId, attachment_id),
      x$payload$parts)
  } else {
    Filter(function(part)
      !is.null(part$filename) && part$filename != "",
      x$payload$parts)
  }
  invisible(vapply(attachments_parts, function(part) {
                     att <- attachment(part$body$attachmentId, x$id, user_id)
                     save_attachment(att, file.path(path, part$filename))
                   }, character(1L)))
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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' insert_message(mime(From="you@@me.com", To="any@@one.com",
#'                           Subject="hello", "how are you doing?"))
#' }
insert_message <- function(
  mail,
  label_ids,
  type = c("multipart", "media", "resumable"),
  internal_date_source = c("dateHeader", "recievedTime"),
  user_id = "me") {

  mail <- as.character(mail)
  stopifnot(
     nullable(is_strings)(label_ids),
     is_string(user_id))

  type <- match.arg(type)
  internal_date_source <- match.arg(internal_date_source)

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
#' @family message
#' @export
#' @examples
#' \dontrun{
#' import_message(mime(From="you@@me.com", To="any@@one.com",
#'                           Subject="hello", "how are you doing?"))
#' }
import_message <- function(mail,
  label_ids,
  type = c("multipart", "media", "resumable"),
  internal_date_source = c("dateHeader", "recievedTime"),
  user_id = "me") {

  mail <- as.character(mail)
  stopifnot(
     nullable(is_strings)(label_ids),
     is_string(user_id))

  type <- match.arg(type)
  internal_date_source <- match.arg(internal_date_source)

  gmailr_POST(c("messages", "import"), user_id, class = "gmail_message",
    query = list(uploadType = type, interalDateSource = internal_date_source),
    body = jsonlite::toJSON(auto_unbox=TRUE,
      c(not_null(rename(label_ids)),
        raw=base64url_encode(mail))),
    add_headers("Content-Type" = "application/json"))
}

#' Send a message from a mime message
#'
#' @param thread_id the id of the thread to send from.
#' @inheritParams insert_message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/messages/send}
#' @family message
#' @export
#' @examples
#' \dontrun{
#' send_message(mime(from="you@@me.com", to="any@@one.com",
#'                           subject="hello", "how are you doing?"))
#' }
send_message <- function(
  mail,
  type = c("multipart", "media", "resumable"),
  thread_id = NULL,
  user_id = "me") {

  mail <- as.character(mail)
  stopifnot(
     nullable(is_string)(thread_id),
     is_string(user_id))

  type <- match.arg(type)

  gmailr_POST(c("messages", "send"), user_id, class = "gmail_message",
    query = list(uploadType = type),
    body = jsonlite::toJSON(auto_unbox=TRUE, null = "null",
                            c(threadId = thread_id,
                              list(raw = base64url_encode(mail)))),
    add_headers("Content-Type" = "application/json"))
}
