#' @export
base64url_decode = function(x) { rawToChar(base64decode(gsub("_", "/", gsub("-", "+", x)))) }

#' @export
threads <- function(search = NULL, num_results = NULL, user_id = 'me', ...){
  dots = list(search = search, num_results = num_results, ...)
  req = GET(gmail_path(rename(user_id), "threads"),
            query = rename(not_null(dots)), config(token = google_token))
  check(req)
  parse_threads(req)
}

#' @export
parse_threads <- function(req) {
  text = content(req, as = "text")
  data = fromJSON(text)
  if(data$resultSizeEstimate == 0) { message("No results for query") }
  data
}

#' @export
gmail_path = function(user, ...) { paste("https://www.googleapis.com/gmail/v1/users/", user, ..., sep="/") }

#' @export
thread = function(id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  check(req)
  content(req)
}

#' @export
trash_thread = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "threads", id, "trash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

# TODO: warning prompt?
#' @export
delete_thread = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "threads", id),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' @export
modify_thread = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "threads", id, "modify"), body=body,
            config(token = google_token))
  check(req)
  invisible(content(req))
}

# https://developers.google.com/gmail/api/v1/reference/users/messages/attachments/get
# how to handle different types?
#' @export
attachment = function(id, message_id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "messages", message_id, "attachments", id),
            config(token = google_token))
  check(req)
  req
}

#' @export
message = function(id, user_id = 'me') {
  req = GET(gmail_path(rename(user_id), "messages", id),
            config(token = google_token))
  check(req)
  content(req)
}

#' @export
trash_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "trash"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

# TODO: warning prompt?
#' @export
delete_message = function(id, user_id = 'me') {
  req = DELETE(gmail_path(rename(user_id), "messages", id),
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' @export
modify_message = function(id, add_labels = character(0), remove_labels = character(0), user_id = 'me') {
  body = rename(list('add_labels' = add_labels, 'remove_labels' = remove_labels))
  req = POST(gmail_path(rename(user_id), "messages", id, "modify"), body=body,
            config(token = google_token))
  check(req)
  invisible(content(req))
}

#' @export
insert_message = function(id, user_id = 'me') {
  req = POST(gmail_path(rename(user_id), "messages", id, "modify"),
            config(token = google_token))
  check(req)
  invisible(content(req))
}
#' @export
check <- function(req) {
  if (req$status_code < 400) return(invisible())

  message <- content(req)$message
  stop("HTTP failure: ", req$status_code, "\n", message, call. = FALSE)
}

name_map = c(
  "user_id" = "userId",
  "search" = "q",
  "num_results" = "maxResults",
  "add_labels" = "addLabelIds",
  "remove_labels" = "removeLabelIds"
)

#' @export
rename = function(x){ names(x) = names(x)[names(x) %in% names(name_map)] = name_map[names(x)]; x }
#' @export
not_null = function(x){ Filter(Negate(is.null), x) }
