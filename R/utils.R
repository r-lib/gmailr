label_value_map = c("hide" = "labelHide",
                    "show" = "labelShow",
                    "show_unread" = "labelSHowIfUnread",
                    NULL
                    )

name_map = c(
  "user_id" = "userId",
  "search" = "q",
  "num_results" = "maxResults",
  "add_labels" = "addLabelIds",
  "remove_labels" = "removeLabelIds",
  "page_token" = "pageToken",
  "include_spam_trash" = "includeSpamTrash",
  "start_history_id" = "startHistoryId",
  "label_list_visibility" = "labelListVisibility",
  "message_list_visibility" = "messageListVisibility",
  "upload_type" = "uploadType",
  NULL
)

rename = function(...) {
  args = as.character(dots(...))
  to_rename = args %in% names(name_map)
  args[to_rename] = name_map[args[to_rename]]

  vals = list(...)
  names(vals) = args
  vals
}
not_null = function(x){ Filter(Negate(is.null), x) }

gmail_path = function(user, ...) { paste("https://www.googleapis.com/gmail/v1/users", user, ..., sep="/") }
base64url_decode_to_char = function(x) { rawToChar(base64decode(gsub("_", "/", gsub("-", "+", x)))) }
base64url_decode = function(x) { base64decode(gsub("_", "/", gsub("-", "+", x))) }

debug = function(...){
  args = dots(...)

  message(sprintf(paste0(args, '=%s', collapse=' '), ...))
}

dots = function (...) { eval(substitute(alist(...))) }

page_and_trim = function(type, user_id, num_results, ...){
  itr = function(...){
    req = GET(gmail_path(user_id, type),
             query = not_null(rename(...)), config(token = google_token))
    stop_for_status(req)
    content(req, "parsed")
  }
  counts = function(res) { vapply(lapply(res, `[[`, type), length, integer(1)) }
  trim = function(res, amount) {
    if(is.null(amount)){
      return(res)
    }
    num = counts(res)
    count = 0
    itr = 0
    while(count < amount && itr <= length(num)){
      itr = itr + 1
      count = count + num[itr]
    }
    remain = amount - count
    if(itr > length(res)){
      res
    }
    else {
      res[[itr]][[type]] = res[[itr]][[type]][1:(num[itr] + remain)]
      res[1:itr]
    }
  }
  res = itr(...)
  all_results = list(res)
  while(sum(counts(all_results)) < num_results && !is.null(res[['nextPageToken']])){
    res = itr(...)
    all_results[[length(all_results)+1]] = res
  }
  structure(trim(all_results, num_results), class=paste0('gmail_', type))
}
