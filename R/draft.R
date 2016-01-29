#' Get a single draft
#'
#' Function to retrieve a given draft by <-
#' @param id draft id to access
#' @param user_id gmail user_id to access, special value of 'me' indicates the authenticated user.
#' @param format format of the draft returned
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/get}
#' @export
#' @examples
#' \dontrun{
#' my_draft = draft('12345')
#' }
draft <- function(id = ? is_string,
                  user_id = "me" ? is_string,
                  format = c("full", "minimal", "raw")) {
  format <- match.arg(format)
  gmailr_GET(c("drafts", id), user_id, query = list(format=format))
}

#' Get a list of drafts
#'
#' Get a list of drafts possibly matching a given query string.
#' @param num_results the number of results to return.
#' @param page_token retrieve a specific page of results
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/list}
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
  gmailr_POST("drafts", user_id, class = "gmail_draft",
              query = list(uploadType=type),
              body = jsonlite::toJSON(auto_unbox=TRUE,
                list(message=list(raw=base64url_encode(mail)))),
              add_headers("Content-Type" = "application/json"))
}

#' Send a draft
#'
#' Send a draft to the recipients in the To, CC, and Bcc headers.
#' @param id the draft id to send
#' @param upload_type type of upload request
#' @inheritParams message
#' @references \url{https://developers.google.com/gmail/api/v1/reference/users/drafts/send}
#' @export
#' @examples
#' \dontrun{
#' send_draft(12345)
#' }
send_draft <- function(id = ? is_string,
                       upload_type = c("media", "multipart", "resumable"),
                       user_id = "me" ? is_string) {
  upload_type <- match.arg(upload_type)
  gmailr_POST("drafts", user_id, class = "gmail_draft",
             query = rename(upload_type),
             body = c("id" = id),
             encode = "json")
}
