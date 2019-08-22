#' Get a single draft
#'
#' Function to retrieve a given draft by <-
#' @param id draft id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the draft returned
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/drafts/get>
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' my_draft = gm_draft('12345')
#' }
gm_draft <- function(id,
                  user_id = "me",
                  format = c("full", "minimal", "raw")) {
  stopifnot(is_string(id), is_string(user_id))
  format <- match.arg(format)
  res <- gmailr_GET(c("drafts", id), user_id, query = list(format=format), class = "gmail_draft")

  class(res$message) <- c("gmail_message", "list")

  res
}

#' Get a list of drafts
#'
#' Get a list of drafts possibly matching a given query string.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/drafts/list>
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' my_drafts = gm_drafts()
#'
#' first_10_drafts = gm_drafts(10)
#' }
gm_drafts <- function(num_results = NULL, page_token = NULL, user_id = "me") {
  stopifnot(is_string(user_id))
  page_and_trim("drafts", user_id, num_results, page_token)
}

#' Create a draft from a mime message
#'
#' @param mail mime mail message created by mime
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/drafts/create>
#' @export
#' @examples
#' \dontrun{
#' gm_create_draft(gm_mime(From="you@@me.com", To="any@@one.com",
#'                           Subject="hello", "how are you doing?"))
#' }
gm_create_draft <- function(mail,
                         user_id = "me") {
  mail <- as.character(mail)
  stopifnot(is_string(user_id))
  res <- gmailr_POST("drafts", user_id, class = "gmail_draft",
              query = list(uploadType="media"),
              body = mail,
              add_headers("Content-Type" = "message/rfc822"),
              upload=TRUE)

  # This is labeled as a message but is really a thread
  class(res$message) <- c("gmail_thread", "list")
  res
}

#' Send a draft
#'
#' Send a draft to the recipients in the To, CC, and Bcc headers.
#' @param draft the draft to send
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/drafts/send>
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' draft <- gm_create_draft(gm_mime(From="you@@me.com", To="any@@one.com",
#'                       Subject="hello", "how are you doing?"))
#' gm_send_draft(draft)
#' }
gm_send_draft <- function(draft,
                       user_id = "me") {
  stopifnot(has_class(draft, "gmail_draft"), is_string(user_id))
  gmailr_POST(c("drafts", "send"), user_id, class = "gmail_draft",
    body = draft,
    encode = "json")
}

#' Permanently delete a single draft
#'
#' Function to delete a given draft by id.  This cannot be undone!
#' @inheritParams gm_message
#' @references <https://developers.google.com/gmail/api/v1/reference/users/drafts/delete>
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' delete_draft('12345')
#' }
gm_delete_draft <- function(id, user_id = "me") {
  stopifnot(
    is_string(id),
    is_string(user_id))

  gmailr_DELETE(c("drafts", id), user_id, class = "gmail_message")
}
