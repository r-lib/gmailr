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
            config(token = get_token()))
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
            config(token = get_token()))
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
              config(token = get_token()))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

#' @rdname update_label
#' @export
update_label_patch = function(id, label, user_id = 'me') {
  req = PATCH(gmail_path(user_id, "labels", id),
              body=label, encode='json',
              config(token = get_token()))
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
            config(token = get_token()))
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
            config(token = get_token()))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}
