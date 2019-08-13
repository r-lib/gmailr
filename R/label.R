#' Get a list of all labels
#'
#' Get a list of all labels for a user.
#' @inheritParams message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/list>
#' @family label
#' @export
#' @examples
#' \dontrun{
#' my_labels = labels()
#' }
labels <- function(user_id = "me"){
  gmailr_GET("labels", user_id)
}


#' Get a specific label
#'
#' Get a specific label by id and user_id.
#' @param id label id to retrieve
#' @inheritParams labels
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/get>
#' @family label
#' @export
label <- function(id, user_id = "me") {
  gmailr_GET(c("labels", id), user_id)
}

#' Update a existing label.
#'
#' Get a specific label by id and user_id.  `update_label_patch` is identical to `update_label` but the latter uses [HTTP PATCH](http://tools.ietf.org/html/rfc5789) to allow partial update.
#' @param id label id to update
#' @param label the label fields to update
#' @inheritParams labels
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/update>
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/patch>
#' @family label
#' @export
update_label <- function(id, label, user_id = "me") {
  gmailr_PUT(c("labels", id), user_id, body = label, encode = "json")
}

#' @rdname update_label
#' @family label
#' @export
update_label_patch <- function(id, label, user_id = "me") {
  gmailr_PATCH(c("labels", id), user_id, body = label, encode = "json")
}

#' Permanently delete a label
#'
#' Function to delete a label by id.  This cannot be undone!
#' @inheritParams label
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/delete>
#' @family label
#' @export
delete_label <- function(id, user_id = "me") {
  gmailr_DELETE(c("labels", id), user_id)
}

#' Create a new label
#'
#' Function to create a label.
#' @param name name to give to the new label
#' @param label_list_visibility The visibility of the label in the label list in the Gmail web interface.
#' @param message_list_visibility The visibility of messages with this label in the message list in the Gmail web interface.
#' @inheritParams labels
#' @references <https://developers.google.com/gmail/api/v1/reference/users/labels/create>
#' @family label
#' @export
create_label <- function(name,
                         label_list_visibility=c("show", "hide", "show_unread"),
                         message_list_visibility=c("show", "hide"),
                         user_id = "me") {
  label_list_visibility <- label_value_map[match.arg(label_list_visibility)]
  message_list_visibility <- match.arg(message_list_visibility)

  gmailr_POST("labels", user_id,
              body = c(rename(name,
                              label_list_visibility,
                              message_list_visibility)),
              encode = "json")
}
