#' Deprecated functions
#'
#' @description `r lifecycle::badge("deprecated")`
#'

#' All of these functions have been renamed, by adding a `gm_` prefix. This is
#' to eliminate name conflicts with other packages (including the base package).
#' Starting with gmailr 1.0.0 (released 2019-08-23), the deprecated functions
#' generated a warning. As of gmailr 2.0.0, they generate an error and they will
#' be completely removed in a future release.
#'
#' @name gmailr-deprecated
#' @keywords internal

# nocov start

# unprefixed functions ----

#' @rdname gmailr-deprecated
#' @export
id <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::id()", "gm_id()")
}

#' @rdname gmailr-deprecated
#' @export
to <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::to()", "gm_to()")
}

#' @rdname gmailr-deprecated
#' @export
from <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::from()", "gm_from()")
}

#' @rdname gmailr-deprecated
#' @export
cc <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::cc()", "gm_cc()")
}

#' @rdname gmailr-deprecated
#' @export
bcc <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::bcc()", "gm_bcc()")
}

#' @rdname gmailr-deprecated
#' @export
date <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::date()", "gm_date()")
}

#' @rdname gmailr-deprecated
#' @export
subject <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::subject()", "gm_subject()")
}

#' @rdname gmailr-deprecated
#' @export
body <- function(x, ...) {
  deprecate_stop("2.0.0", "gmailr::body()", "gm_body()")
}

last_response <- function() {
  deprecate_stop("2.0.0", "gmailr:::last_response()", "gm_last_response()")
}

#' @rdname gmailr-deprecated
#' @export
message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::message()", "gm_message()")
}

#' @rdname gmailr-deprecated
#' @export
messages <- function(...) {
  deprecate_stop("2.0.0", "gmailr::messages()", "gm_messages()")
}

#' @rdname gmailr-deprecated
#' @export
trash_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::trash_message()", "gm_trash_message()")
}

#' @rdname gmailr-deprecated
#' @export
untrash_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::trash_message()", "gm_trash_message()")
}

#' @rdname gmailr-deprecated
#' @export
delete_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::delete_message()", "gm_delete_message()")
}

#' @rdname gmailr-deprecated
#' @export
modify_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::modify_message()", "gm_modify_message()")
}

#' @rdname gmailr-deprecated
#' @export
attachment <- function(...) {
  deprecate_stop("2.0.0", "gmailr::attachment()", "gm_attachment()")
}

#' @rdname gmailr-deprecated
#' @export
save_attachment <- function(...) {
  deprecate_stop("2.0.0", "gmailr::save_attachment()", "gm_save_attachment()")
}

#' @rdname gmailr-deprecated
#' @export
save_attachments <- function(...) {
  deprecate_stop("2.0.0", "gmailr::save_attachments()", "gm_save_attachments()")
}

#' @rdname gmailr-deprecated
#' @export
insert_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::insert_message()", "gm_insert_message()")
}

#' @rdname gmailr-deprecated
#' @export
import_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::import_message()", "gm_import_message()")
}

#' @rdname gmailr-deprecated
#' @export
send_message <- function(...) {
  deprecate_stop("2.0.0", "gmailr::send_message()", "gm_send_message()")
}

#' @rdname gmailr-deprecated
#' @export
threads <- function(...) {
  deprecate_stop("2.0.0", "gmailr::threads()", "gm_threads()")
}

#' @rdname gmailr-deprecated
#' @export
thread <- function(...) {
  deprecate_stop("2.0.0", "gmailr::thread()", "gm_thread()")
}

#' @rdname gmailr-deprecated
#' @export
trash_thread <- function(...) {
  deprecate_stop("2.0.0", "gmailr::trash_thread()", "gm_trash_thread()")
}

#' @rdname gmailr-deprecated
#' @export
untrash_thread <- function(...) {
  deprecate_stop("2.0.0", "gmailr::untrash_thread()", "gm_untrash_thread()")
}

#' @rdname gmailr-deprecated
#' @export
delete_thread <- function(...) {
  deprecate_stop("2.0.0", "gmailr::delete_thread()", "gm_delete_thread()")
}

#' @rdname gmailr-deprecated
#' @export
modify_thread <- function(...) {
  deprecate_stop("2.0.0", "gmailr::modify_thread()", "gm_modify_thread()")
}

#' @rdname gmailr-deprecated
#' @export
draft <- function(...) {
  deprecate_stop("2.0.0", "gmailr::draft()", "gm_draft()")
}

#' @rdname gmailr-deprecated
#' @export
drafts <- function(...) {
  deprecate_stop("2.0.0", "gmailr::drafts()", "gm_drafts()")
}

#' @rdname gmailr-deprecated
#' @export
create_draft <- function(...) {
  deprecate_stop("2.0.0", "gmailr::create_draft()", "gm_create_draft()")
}

#' @rdname gmailr-deprecated
#' @export
send_draft <- function(...) {
  deprecate_stop("2.0.0", "gmailr::send_draft()", "gm_send_draft()")
}

#' @rdname gmailr-deprecated
#' @export
labels <- function(...) {
  deprecate_stop("2.0.0", "gmailr::labels()", "gm_labels()")
}

#' @rdname gmailr-deprecated
#' @export
label <- function(...) {
  deprecate_stop("2.0.0", "gmailr::label()", "gm_label()")
}

#' @rdname gmailr-deprecated
#' @export
update_label <- function(...) {
  deprecate_stop("2.0.0", "gmailr::update_label()", "gm_update_label()")
}

#' @rdname gmailr-deprecated
#' @export
update_label_patch <- function(...) {
  deprecate_stop("2.0.0", "gmailr::update_label_patch()", "gm_update_label_patch()")
}

#' @rdname gmailr-deprecated
#' @export
delete_label <- function(...) {
  deprecate_stop("2.0.0", "gmailr::delete_label()", "gm_delete_label()")
}

#' @rdname gmailr-deprecated
#' @export
create_label <- function(...) {
  deprecate_stop("2.0.0", "gmailr::create_label()", "gm_create_label()")
}

#' @rdname gmailr-deprecated
#' @export
history <- function(...) {
  deprecate_stop("2.0.0", "gmailr::history()", "gm_history()")
}

#' @rdname gmailr-deprecated
#' @export
mime <- function(...) {
  deprecate_stop("2.0.0", "gmailr::mime()", "gm_mime()")
}

#' @rdname gmailr-deprecated
#' @export
text_body <- function(...) {
  deprecate_stop("2.0.0", "gmailr::text_body()", "gm_text_body()")
}

#' @rdname gmailr-deprecated
#' @export
html_body <- function(...) {
  deprecate_stop("2.0.0", "gmailr::html_body()", "gm_html_body()")
}

#' @rdname gmailr-deprecated
#' @export
attach_part <- function(...) {
  deprecate_stop("2.0.0", "gmailr::attach_part()", "gm_attach_part()")
}

#' @rdname gmailr-deprecated
#' @export
attach_file <- function(...) {
  deprecate_stop("2.0.0", "gmailr::attach_file()", "gm_attach_file()")
}

# helper to convert deprecated functions to new names
gm_convert_file <- function(file) {
  gm_funs <- get_deprecated_funs()

  lines <- readLines(file)

  for (i in seq_len(NROW(gm_funs))) {
    find <- paste0("(?<![[:alnum:]_:])", gm_funs$old[[i]], "[(]")
    replace <- paste0(gm_funs$new[[i]], "(")
    lines <- gsub(find, replace, lines, perl = TRUE)
  }
  writeLines(lines, file)
}

get_deprecated_funs <- function() {
  file <- system.file(package = "gmailr", "R", "deprecated.R")
  lines <- readLines(file)
  res <- rematch2::re_match(lines, "deprecate_.*gmailr:::?(?<old>[^(]+).*(?<new>gm_[^(]+)")
  res <- stats::na.omit(res)[c("old", "new")]
  # don't retain a spurious match from this function, i.e. the rematch2 line
  valid_fcn <- grepl("^[a-zA-Z\\.]", res$old)
  res[valid_fcn, ]
}

# old auth ----

#' Deprecated auth
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These functions are deprecated and no longer work.
#' @name gmailr-deprecated-auth
#' @keywords internal

#' @rdname gmailr-deprecated-auth
#' @export
clear_token <- function() {
  deprecate_stop("2.0.0", "gmailr::clear_token()", "gm_deauth()")
}

#' @rdname gmailr-deprecated-auth
#' @export
gmail_auth <- function(scope = c("read_only", "modify", "compose", "full"),
                       id = the$id,
                       secret = the$secret,
                       secret_file = NULL) {
  deprecate_stop("2.0.0", "gmailr::gmail_auth()", "gm_auth()")
}

#' @rdname gmailr-deprecated-auth
#' @export
use_secret_file <- function(filename) {
  deprecate_stop("2.0.0", "gmailr::use_secret_file()", "gm_auth_configure()")
}

# nocov end
