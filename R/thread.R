#' Get a list of threads
#'
#' Get a list of threads possibly matching a given query string.
#' @inheritParams messages
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
            config(token = get_token()))
  stop_for_status(req)
  parsed_req = structure(content(req, "parsed"), class='gmail_thread')

  parsed_req$messages[] = lapply(parsed_req$messages, structure, class='gmail_message')

  parsed_req
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
            config(token = get_token()))
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
            config(token = get_token()))
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
            config(token = get_token()))
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
            config(token = get_token()))
  stop_for_status(req)
  invisible(content(req, "parsed"))
}

