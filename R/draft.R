#' Get a single draft
#'
#' Function to retrieve a given draft by <-
#' @param id draft id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the draft returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/get}
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' my_draft = draft('12345')
#' }
draft <- function(id = ? is_string,
                  user_id = "me" ? is_string,
                  format = c("full", "minimal", "raw")) {
  format <- match.arg(format)
  res <- gmailr_GET(c("drafts", id), user_id, query = list(format=format), class = "gmail_draft")

  class(res$message) <- "gmail_message"

  res
}

#' Get a list of drafts
#'
#' Get a list of drafts possibly matching a given query string.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/list}
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' my_drafts = drafts()
#'
#' first_10_drafts = drafts(10)
#' }
drafts <- function(num_results = NULL, page_token = NULL, user_id = "me" ? is_string) {
  page_and_trim("drafts", user_id, num_results, page_token)
}

#' Create a draft from a mime message
#'
#' @param mail mime mail message created by mime
#' @param type the type of upload to perform
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/create}
#' @export
#' @examples
#' \dontrun{
#' create_draft(mime(From="you@@me.com", To="any@@one.com",
#'                           Subject="hello", "how are you doing?"))
#' }
create_draft <- function(mail = ?~ as.character,
                         user_id = "me" ? is_string,
                         type = c("multipart",
                                "media",
                                "resumable")) {
  type <- match.arg(type)
  res <- gmailr_POST("drafts", user_id, class = "gmail_draft",
              query = list(uploadType=type),
              body = jsonlite::toJSON(auto_unbox=TRUE,
                list(message=list(raw=base64url_encode(mail)))),
              add_headers("Content-Type" = "application/json"))

  # This is labeled as a message but is really a thread
  class(res$message) <- "gmail_thread"
  res
}

#' Send a draft
#'
#' Send a draft to the recipients in the To, CC, and Bcc headers.
#' @param draft the draft to send
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/send}
#' @family draft
#' @export
#' @examples
#' \dontrun{
#' draft <- create_draft(mime(From="you@@me.com", To="any@@one.com",
#'                       Subject="hello", "how are you doing?"))
#' send_draft(draft)
#' }
send_draft <- function(draft = ? has_class(draft, "gmail_draft"),
                       user_id = "me" ? is_string) {
    gmailr_POST(c("drafts", "send"), user_id, class = "gmail_draft",
                body = draft,
                encode = "json")
}
