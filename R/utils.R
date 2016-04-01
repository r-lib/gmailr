label_value_map <- c("hide" = "labelHide",
                    "show" = "labelShow",
                    "show_unread" = "labelSHowIfUnread",
                    NULL
                    )

name_map <- c(
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
  "label_ids" = "labelIds",
  NULL
)

rename <- function(...) {
  args <- dots(...)
  arg_names <- names(args)
  missing <-
    if (is.null(arg_names)) {
      rep(TRUE, length(args))
    } else {
      !nzchar(arg_names)
    }
  arg_names[missing] <- vapply(args[missing], deparse, character(1))

  to_rename <- arg_names %in% names(name_map)
  arg_names[to_rename] <- name_map[arg_names[to_rename]]

  vals <- list(...)
  names(vals) <- arg_names
  vals
}

not_null <- function(x){ Filter(Negate(is.null), x) }

gmail_path <- function(user, ...) { paste("https://www.googleapis.com/gmail/v1/users", user, paste0(unlist(list(...)), collapse = "/"), sep = "/") }
gmail_upload_path <- function(user, ...) { paste("https://www.googleapis.com/upload/gmail/v1/users", user, paste0(list(...), collapse = "/"), sep = "/") }
base64url_decode_to_char <- function(x) { rawToChar(base64decode(gsub("_", "/", gsub("-", "+", x)))) }
base64url_decode <- function(x) { base64decode(gsub("_", "/", gsub("-", "+", x))) }
base64url_encode <- function(x) { gsub("/", "_", gsub("\\+", "-", base64encode(charToRaw(as.character(x))))) }

debug <- function(...){
  args <- dots(...)

  base::message(sprintf(paste0(args, "=%s", collapse=" "), ...))
}

dots <- function (...) { eval(substitute(alist(...))) }

page_and_trim <- function(type, user_id, num_results, ...){

  num_results <- num_results %||% 100
  itr <- function(...){
    req <- GET(gmail_path(user_id, type),
             query = not_null(rename(...)), config(token = get_token()))
    stop_for_status(req)
    content(req, "parsed")
  }
  counts <- function(res) { vapply(lapply(res, `[[`, type), length, integer(1)) }
  trim <- function(res, amount) {
    if(is.null(amount)){
      return(res)
    }
    num <- counts(res)
    count <- 0
    itr <- 0
    while(count < amount && itr <= length(num)){
      itr <- itr + 1
      count <- count + num[itr]
    }
    remain <- amount - count
    if(itr > length(res)){
      res
    }
    else {
      res[[itr]][[type]] <- res[[itr]][[type]][1:(num[itr] + remain)]
      res[1:itr]
    }
  }
  res <- itr(...)
  all_results <- list(res)
  page_token <- res[["nextPageToken"]]
  while(sum(counts(all_results)) < num_results && !is.null(page_token)){
    res <- itr(..., page_token = page_token)
    page_token <- res[["nextPageToken"]]

    all_results[[length(all_results) + 1]] <- res
  }
  structure(trim(all_results, num_results), class=paste0("gmail_", type))
}

ord <- function(x) { strtoi(charToRaw(x), 16L) }

chr <- function(x) { rawToChar(as.raw(x)) }

substitute_regex <- function(data, pattern, fun, ...) {
  match <- gregexpr(pattern, ..., data)
  regmatches(data, match) <- lapply(regmatches(data, match),
                                   function(x) { if(length(x) > 0) { vapply(x, function(xx) fun(xx), character(1)) } else { x } })
  data
}

# return RHS if LHS is null, else LHS
"%||%" <- function(x, y){ if(is.null(x)){ y } else { x } }

# return LHS if LHS is null, else RHS, usually RHS should also include The LHS
# value, otherwise this function makes little sense
"%|||%" <- function(x, y){ if(is.null(x)){ x } else { y } }

#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

encode_base64 <- function(x, line_length = 76L, newline = "\r\n") {
  if(is.raw(x)) {
    base64encode(x, 76L, newline)
  } else {
    base64encode(charToRaw(x), 76L, "\r\n")
  }
}

exists_list <- function(data, x){
  if(is.character(x)){
    return(exists(x, data))
  }
  return(length(data) >= x && !is.null(data[[x]]))
}

"%==%" <- function(x, y) { identical(x, y) }
"%!=%" <- function(x, y) { !identical(x, y) }

p <- function(...) paste(sep="", collapse="", ...)
