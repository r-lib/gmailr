#' Get the body text of a message or draft
#' @param x the object from which to retrieve the body
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' gm_body(my_message)
#' gm_body(my_draft)
#' }
gm_body <- function(x, ...) UseMethod("gm_body")

#' @export
gm_body.gmail_message <- function(x, type = "text/plain", collapse = FALSE, ...) {
  is_multipart <- !is.null(x$payload$parts)

  if (is_multipart) {
    if (is.null(type)) {
      good_parts <- TRUE
    } else {
      good_parts <- vapply(x$payload$parts,
        FUN.VALUE = logical(1),
        function(part) {
          any(
            vapply(part$headers,
              FUN.VALUE = logical(1),
              function(header) {
                tolower(header$name) %==% "content-type" &&
                  grepl(type, header$value, ignore.case = TRUE)
              }
            )
          )
        }
      )
    }

    res <-
      lapply(
        x$payload$parts[good_parts],
        function(x) {
          base64url_decode_to_char(x$body$data)
        }
      )
  } else { # non_multipart
    res <- base64url_decode_to_char(x$payload$body$data)
  }

  if (collapse) {
    res <- paste0(collapse = "\n", res)
  }

  res
}

#' @export
gm_body.gmail_draft <- function(x, ...) {
  gm_body.gmail_message(x$message, ...)
}

#' Get the id of a gmailr object
#' @param x the object from which to retrieve the id
#' @param ... other parameters passed to methods
#' @export
#' @examples
#' \dontrun{
#' gm_id(my_message)
#' gm_id(my_draft)
#' }
gm_id <- function(x, ...) UseMethod("gm_id")

#' @export
gm_id.gmail_message <- function(x, ...) {
  x$id
}

#' @export
gm_id.gmail_thread <- gm_id.gmail_message

#' @export
gm_id.gmail_draft <- gm_id.gmail_message

#' @rdname gm_id
#' @export
#' @param what the type of id to return
gm_id.gmail_messages <- function(x, what = c("message_id", "thread_id"), ...) {
  what <- switch(match.arg(what),
    message_id = "id",
    thread_id = "threadId"
  )
  unlist(lapply(x, function(page) {
    vapply(page$messages, "[[", character(1), what)
  }))
}

#' @export
gm_id.gmail_drafts <- function(x, what = c("draft_id", "message_id", "thread_id"), ...) {
  what <- switch(match.arg(what),
    draft_id = return(
      unlist(lapply(x, function(page) {
        vapply(page$drafts, "[[", character(1), "id")
      }))
    ),
    message_id = "id",
    thread_id = "threadId"
  )
  unlist(lapply(x, function(page) {
    vapply(page$drafts, function(x) {
      x$message[[what]]
    }, character(1))
  }))
}

#' @export
gm_id.gmail_threads <- function(x, ...) {
  unlist(lapply(x, function(page) {
    vapply(page$threads, "[[", character(1), "id")
  }))
}

#' Methods to get values from message or drafts
#' @param x the object from which to get or set the field
#' @param ... other parameters passed to methods
#' @rdname accessors
#' @export
gm_to <- function(x, ...) UseMethod("gm_to")

#' @export
gm_to.gmail_message <- function(x, ...) {
  header_value(x, "To")
}

#' @export
gm_to.gmail_draft <- function(x, ...) {
  gm_to.gmail_message(x$message, ...)
}

#' @rdname accessors
#' @export
gm_from <- function(x, ...) UseMethod("gm_from")

#' @export
gm_from.gmail_message <- function(x, ...) {
  header_value(x, "From")
}

#' @export
gm_from.gmail_draft <- gm_from.gmail_message

#' @export
gm_from <- function(x, ...) UseMethod("gm_from")

#' @rdname accessors
#' @export
gm_cc <- function(x, ...) UseMethod("gm_cc")

#' @export
gm_cc.gmail_message <- function(x, ...) {
  header_value(x, "Cc")
}

#' @export
gm_cc.gmail_draft <- function(x, ...) {
  gm_from.gmail_message(x$message, ...)
}

#' @rdname accessors
#' @export
gm_bcc <- function(x, ...) UseMethod("gm_bcc")

#' @export
gm_bcc.gmail_message <- function(x, ...) {
  header_value(x, "Bcc")
}

#' @export
gm_bcc.gmail_draft <- function(x, ...) {
  gm_from.gmail_message(x$message, ...)
}

#' @rdname accessors
#' @export
gm_date <- function(x, ...) UseMethod("gm_date")

#' @export
gm_date.default <- function(x, ...) {
  base::date()
}

#' @export
gm_date.gmail_message <- function(x, ...) {
  header_value(x, "Date")
}

#' @export
gm_date.gmail_draft <- function(x, ...) {
  gm_date.gmail_message(x$message, ...)
}

#' @rdname accessors
#' @export
gm_subject <- function(x, ...) UseMethod("gm_subject")

#' @export
gm_subject.gmail_message <- function(x, ...) {
  header_value(x, "Subject")
}

#' @export
gm_subject.gmail_draft <- function(x, ...) {
  gm_subject.gmail_message(x$message, ...)
}

header_value <- function(x, name) {
  mark_utf8(Find(function(header) identical(header$name, name), x$payload$headers)$value)
}

#' @export
print.gmail_message <- function(x, ...) {
  to <- gm_to(x)
  from <- gm_from(x)
  date <- gm_date(x)
  subject <- gm_subject(x)
  id <- gm_id(x)
  body <- gm_body(x, collapse = TRUE)
  attached_files <- unlist(lapply(x$payload$parts, function(part) {
    if (!is.null(part$filename) && part$filename != "") {
      part$filename
    }
  }))

  cat(p(
    c(
      crayon::bold("Id: "), id, "\n",
      if (!is.null(to)) {
        c(crayon::bold("To: "), to, "\n")
      },
      if (!is.null(from)) c(crayon::bold("From: "), from, "\n"),
      if (!is.null(date)) c(crayon::bold("Date: "), date, "\n"),
      if (!is.null(subject)) c(crayon::bold("Subject: "), subject, "\n"),
      if (!is.null(body)) c(body),
      if (!is.null(attached_files)) c(crayon::bold("Attachments: "), paste0("'", attached_files, "'", collapse = ", "), "\n")
    )
  ))
}

#' @export
print.gmail_thread <- function(x, ...) {
  id <- gm_id(x)
  cat(strwrap(p(crayon::bold("Thread Id: "), id, "\n")), "\n")
}

#' @export
print.gmail_draft <- function(x, ...) {
  id <- gm_id(x)
  cat(strwrap(p(crayon::bold("Draft Id: "), id, "\n")), "\n")
  print(x$message, ...)
}

#' @export
print.gmail_messages <- function(x, ...) {
  message_ids <- gm_id(x, "message_id")
  thread_ids <- gm_id(x, "thread_id")
  print(format(data.frame(message_id = message_ids, thread_id = thread_ids)), ...)
}

#' @export
print.gmail_threads <- function(x, ...) {
  thread_ids <- gm_id(x)
  snippets <- unlist(lapply(x, function(page) {
    vapply(page$threads, "[[", character(1), "snippet")
  }))
  print(format(data.frame(thread_id = thread_ids, snippet = snippets)), ...)
}

#' @export
print.gmail_drafts <- function(x, ...) {
  draft_ids <- gm_id(x, "draft_id")
  message_ids <- gm_id(x, "message_id")
  thread_ids <- gm_id(x, "thread_id")
  print(format(data.frame(draft_ids, message_id = message_ids, thread_id = thread_ids)), ...)
}

the$last_response <- list()

gmailr_query <- function(fun, location, user_id, class = NULL, ..., upload = FALSE) {
  path_fun <- if (upload) gmail_upload_path else gmail_path
  response <- fun(path_fun(user_id, location), gm_token(), ...)
  result <- content(response, "parsed")

  the$last_response <- response
  if (status_code(response) >= 300) {
    cond <- structure(
      list(
        call = sys.call(-1),
        content = result,
        response = response,
        message = paste0("Gmail API error: ", status_code(response), "\n  ", result$error$message, "\n")
      ),
      class = c("condition", "error", "gmailr_error")
    )
    stop(cond)
  }

  if (!is.null(class) && !is.null(result)) {
    class(result) <- class
  }
  result
}

#' Response from the last query
#'
#' @export
gm_last_response <- function() {
  the$last_response
}

gmailr_GET <- function(location, user_id, class = NULL, ...) {
  gmailr_query(GET, location, user_id, class, ...)
}

gmailr_DELETE <- function(location, user_id, class = NULL, ...) {
  gmailr_query(DELETE, location, user_id, class, ...)
}

gmailr_PATCH <- function(location, user_id, class = NULL, ...) {
  gmailr_query(PATCH, location, user_id, class, ...)
}

gmailr_POST <- function(location, user_id, class = NULL, ...) {
  gmailr_query(POST, location, user_id, class, ...)
}

gmailr_PUT <- function(location, user_id, class = NULL, ...) {
  gmailr_query(PUT, location, user_id, class, ...)
}
