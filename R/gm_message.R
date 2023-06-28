#' Get a single message
#'
#' Function to retrieve a given message by id
#' @param id message id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the message returned
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_message <- gm_message(12345)
#' }
gm_message <- function(id,
                       user_id = "me",
                       format = c("full", "metadata", "minimal", "raw")) {
  stopifnot(
    is_string(id),
    is_string(user_id)
  )

  format <- match.arg(format)
  gmailr_GET(c("messages", id), user_id,
    class = "gmail_message",
    query = list(format = format)
  )
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
#' @inheritParams gm_thread
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list>
#' @family message
#' @examples
#' \dontrun{
#' # Search for R, return 10 results using label 1 including spam and trash folders
#' my_messages <- gm_messages("R", 10, "label_1", TRUE)
#' }
gm_messages <- function(search = NULL,
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
    is_string(user_id)
  )

  page_and_trim("messages", user_id, num_results, search, page_token, label_ids, include_spam_trash)
}

#' Send a single message to the trash
#'
#' Function to trash a given message by id.  This can be undone by [gm_untrash_message()].
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/trash>
#' @export
#' @family message
#' @examples
#' \dontrun{
#' gm_trash_message("12345")
#' }
gm_trash_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id)
  )

  gmailr_POST(c("messages", id, "trash"), user_id, class = "gmail_message")
}

#' Remove a single message from the trash
#'
#' Function to trash a given message by id.  This can be undone by [gm_untrash_message()].
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/trash>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_untrash_message("12345")
#' }
gm_untrash_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id)
  )

  gmailr_POST(c("messages", id, "untrash"), user_id, class = "gmail_message")
}

#' Permanently delete a single message
#'
#' Function to delete a given message by id.  This cannot be undone!
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/delete>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_delete_message("12345")
#' }
gm_delete_message <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id)
  )

  gmailr_DELETE(c("messages", id), user_id, class = "gmail_message")
}

#' Modify the labels on a message
#'
#' Function to modify the labels on a given message by id.  Note you need to
#' use the label ID as arguments to this function, not the label name.
#' @param add_labels label IDs to add to the specified message
#' @param remove_labels label IDs to remove from the specified message
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/modify>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_modify_message(12345, add_labels = "label_1")
#' gm_modify_message(12345, remove_labels = "label_1")
#' # add and remove at the same time
#' gm_modify_message(12345, add_labels = "label_2", remove_labels = "label_1")
#' }
gm_modify_message <- function(id,
                              add_labels = NULL,
                              remove_labels = NULL,
                              user_id = "me") {
  stopifnot(
    is_string(id),
    nullable(is_strings)(add_labels),
    nullable(is_strings)(remove_labels),
    is_string(user_id)
  )

  gmailr_POST(c("messages", id, "modify"), user_id,
    class = "gmail_message",
    body = rename("add_labels" = as.list(add_labels), "remove_labels" = as.list(remove_labels)),
    encode = "json"
  )
}

#' Retrieve an attachment to a message
#'
#' This is a low level function to retrieve an attachment to a message by id of the attachment
#' and message. Most users are better off using [gm_save_attachments()] to
#' automatically save all the attachments in a given message.
#' @param id id of the attachment
#' @param message_id id of the parent message
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages.attachments/get>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_attachment <- gm_attachment("a32e324b", "12345")
#' # save attachment to a file
#' gm_save_attachment(my_attachment, "photo.jpg")
#' }
gm_attachment <- function(id,
                          message_id,
                          user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(message_id),
    is_string(user_id)
  )

  gmailr_GET(c("messages", message_id, "attachments", id),
    user_id,
    class = "gmail_attachment"
  )
}

#' Save the attachment to a file
#'
#' This is a low level function that only works on attachments retrieved with [gm_attachment()].
#' To save an attachment directly from a message see [gm_save_attachments()],
#' which is a higher level interface more suitable for most uses.
#' @param x attachment to save
#' @param filename location to save to
#' @family message
#' @export
#' @examples
#' \dontrun{
#' my_attachment <- gm_attachment("a32e324b", "12345")
#' # save attachment to a file
#' gm_save_attachment(my_attachment, "photo.jpg")
#' }
gm_save_attachment <- function(x, filename) {
  stopifnot(
    has_class(x, "gmail_attachment"),
    is_string(filename)
  )

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
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages.attachments/get>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' # save all attachments
#' gm_save_attachments(my_message)
#' # save a specific attachment
#' gm_save_attachments(my_message, "a32e324b")
#' }
gm_save_attachments <- function(x,
                                attachment_id = NULL,
                                path = ".",
                                user_id = "me") {
  stopifnot(
    has_class(x, "gmail_message"),
    nullable(is_string)(attachment_id),
    valid_path(path),
    is_string(user_id)
  )

  attachments_parts <- if (!is.null(attachment_id)) {
    Find(
      function(part) {
        identical(part$body$attachmentId, attachment_id)
      },
      x$payload$parts
    )
  } else {
    Filter(
      function(part) {
        !is.null(part$filename) && part$filename != ""
      },
      x$payload$parts
    )
  }
  invisible(vapply(attachments_parts, function(part) {
    att <- gm_attachment(part$body$attachmentId, x$id, user_id)
    gm_save_attachment(att, file.path(path, part$filename))
  }, character(1L)))
}


#' Retrieve information about attachments
#'
#' @inheritParams gm_body
#' @param x An object from which to retrieve the attachment information.
#' @return A data.frame with the `filename`, `type`, `size` and `id` of each
#' attachment in the message.
#' @export
gm_attachments <- function(x, ...) {
  UseMethod("gm_attachments")
}

#' @export
gm_attachments.gmail_message <- function(x, ...) {
  has_attachments <- vlapply(x$payload$parts, function(part) {
    !is.null(part$filename) && part$filename != ""
  })

  filename <- vcapply(x$payload$parts[has_attachments], function(part) part$filename)
  type <- vcapply(x$payload$parts[has_attachments], function(part) part$mimeType)
  size <- vnapply(x$payload$parts[has_attachments], function(part) as.numeric(part$body$size))
  id <- vcapply(x$payload$parts[has_attachments], function(part) part$body$attachmentId)

  return(data.frame(filename = filename, type = type, size = size, id = id))
}

#' @export
gm_attachments.gmail_draft <- function(x, ...) {
  gm_attachments.gmail_message(x$message)
}


#' Insert a message into the gmail mailbox from a mime message
#'
#' @param mail mime mail message created by mime
#' @param label_ids optional label ids to apply to the message
#' @param type the type of upload to perform
#' @param internal_date_source whether to date the object based on the date of
#'        the message or when it was received by gmail.
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/insert>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_insert_message(gm_mime(
#'   From = "you@@me.com", To = "any@@one.com",
#'   Subject = "hello", "how are you doing?"
#' ))
#' }
gm_insert_message <- function(mail,
                              label_ids,
                              type = c("multipart", "media", "resumable"),
                              internal_date_source = c("dateHeader", "recievedTime"),
                              user_id = "me") {
  mail <- as.character(mail)
  stopifnot(
    nullable(is_strings)(label_ids),
    is_string(user_id)
  )

  type <- match.arg(type)
  internal_date_source <- match.arg(internal_date_source)

  gmailr_POST("messages", user_id,
    class = "gmail_message",
    query = list(uploadType = type, interalDateSource = internal_date_source),
    body = jsonlite::toJSON(
      auto_unbox = TRUE,
      c(not_null(rename(label_ids)),
        raw = base64url_encode(mail)
      )
    ),
    add_headers("Content-Type" = "application/json")
  )
}

#' Import a message into the gmail mailbox from a mime message
#'
#' @inheritParams gm_insert_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/import>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_import_message(gm_mime(
#'   From = "you@@me.com", To = "any@@one.com",
#'   Subject = "hello", "how are you doing?"
#' ))
#' }
gm_import_message <- function(mail,
                              label_ids,
                              type = c("multipart", "media", "resumable"),
                              internal_date_source = c("dateHeader", "recievedTime"),
                              user_id = "me") {
  mail <- as.character(mail)
  stopifnot(
    nullable(is_strings)(label_ids),
    is_string(user_id)
  )

  type <- match.arg(type)
  internal_date_source <- match.arg(internal_date_source)

  gmailr_POST(c("messages", "import"), user_id,
    class = "gmail_message",
    query = list(uploadType = type, interalDateSource = internal_date_source),
    body = jsonlite::toJSON(
      auto_unbox = TRUE,
      c(not_null(rename(label_ids)),
        raw = base64url_encode(mail)
      )
    ),
    add_headers("Content-Type" = "application/json")
  )
}

#' Send a message from a mime message
#'
#' @param thread_id the id of the thread to send from.
#' @inheritParams gm_insert_message
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.messages/send>
#' @family message
#' @export
#' @examples
#' \dontrun{
#' gm_send_message(gm_mime(
#'   from = "you@@me.com", to = "any@@one.com",
#'   subject = "hello", "how are you doing?"
#' ))
#' }
gm_send_message <- function(mail,
                            type = c("multipart", "media", "resumable"),
                            thread_id = NULL,
                            user_id = "me") {
  mail <- as.character(mail)
  stopifnot(
    nullable(is_string)(thread_id),
    is_string(user_id)
  )

  type <- match.arg(type)

  gmailr_POST(c("messages", "send"), user_id,
    class = "gmail_message",
    query = list(uploadType = type),
    body = jsonlite::toJSON(
      auto_unbox = TRUE, null = "null",
      c(
        threadId = thread_id,
        list(raw = base64url_encode(mail))
      )
    ),
    add_headers("Content-Type" = "application/json")
  )
}
