#' Retrieve change history for the inbox
#'
#' Retrieves the history results in chronological order
#' @param start_history_id the point to start the history.  The historyId can be obtained from a message, thread or previous list response.
#' @param num_results the number of results to return, max per page is 100
#' @param label_id filter history only for this label
#' @param page_token retrieve a specific page of results
#' @inheritParams gm_thread
#' @references <https://developers.google.com/gmail/api/reference/rest/v1/users.history/list>
#' @export
#' @examples
#' \dontrun{
#' my_history = history("10")
#' }
gm_history <- function(start_history_id = NULL, num_results = NULL, label_id = NULL, page_token = NULL,  user_id = "me"){
  page_and_trim("history", user_id, num_results, label_id, start_history_id, page_token)
}
