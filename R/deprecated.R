#' These functions are deprecated and will be removed in a future release of
#' gmailr
#' #' \Sexpr[results=rd, stage=render]{lifecycle::badge("deprecated")}
#' @name gmailr-deprecated
#' @keywords internal
#' @importFrom lifecycle deprecate_soft

#' @export
id <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::id()", "gm_id()")
  gm_id(x, ...)
}

#' @export
to <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::to()", "gm_to()")
  gm_to(x, ...)
}

#' @export
from <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::from()", "gm_from()")
  gm_from(x, ...)
}

#' @export
cc <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::cc()", "gm_cc()")
  gm_cc(x, ...)
}

#' @export
bcc <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::bcc()", "gm_bcc()")
  gm_bcc(x, ...)
}


#' @export
date <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::date()", "gm_date()")
  gm_date(x, ...)
}


#' @export
subject <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::subject()", "gm_subject()")
  gm_subject(x, ...)
}


#' @export
body <- function(x, ...) {
  deprecate_soft("1.0.0", "gmailr::body()", "gm_body()")
  gm_body(x, ...)
}

last_response <- function() {
  deprecate_soft("1.0.0", "gmailr::last_response()", "gm_last_response()")
  gm_last_response()
}

#' @export
message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::message()", "gm_message()")
  gm_message(...)
}

#' @export
messages <- function(...) {
  deprecate_soft("1.0.0", "gmailr::messages()", "gm_messages()")
  gm_messages(...)
}

#' @export
trash_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::trash_message()", "gm_trash_message()")
  gm_trash_message(...)
}

#' @export
untrash_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::trash_message()", "gm_trash_message()")
  gm_untrash_message(...)
}

#' @export
delete_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::delete_message()", "gm_delete_message()")
  gm_delete_message(...)
}

#' @export
modify_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::modify_message()", "gm_modify_message()")
  gm_modify_message(...)
}

#' @export
attachment <- function(...) {
  deprecate_soft("1.0.0", "gmailr::attachment()", "gm_attachment()")
  gm_attachment(...)
}

#' @export
save_attachment <- function(...) {
  deprecate_soft("1.0.0", "gmailr::save_attachment()", "gm_save_attachment()")
  gm_save_attachment(...)
}

#' @export
save_attachments <- function(...) {
  deprecate_soft("1.0.0", "gmailr::save_attachments()", "gm_save_attachments()")
  gm_save_attachments(...)
}

#' @export
insert_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::insert_message()", "gm_insert_message()")
  gm_insert_message(...)
}

#' @export
import_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::import_message()", "gm_import_message()")
  gm_import_message(...)
}

#' @export
send_message <- function(...) {
  deprecate_soft("1.0.0", "gmailr::send_message()", "gm_send_message()")
  gm_send_message(...)
}

#' @export
threads <- function(...) {
  deprecate_soft("1.0.0", "gmailr::threads()", "gm_threads()")
  gm_threads(...)
}

#' @export
thread <- function(...) {
  deprecate_soft("1.0.0", "gmailr::thread()", "gm_thread()")
  gm_thread(...)
}

#' @export
trash_thread <- function(...) {
  deprecate_soft("1.0.0", "gmailr::trash_thread()", "gm_trash_thread()")
  gm_trash_thread(...)
}

#' @export
untrash_thread <- function(...) {
  deprecate_soft("1.0.0", "gmailr::untrash_thread()", "gm_untrash_thread()")
  gm_untrash_thread(...)
}

#' @export
delete_thread <- function(...) {
  deprecate_soft("1.0.0", "gmailr::delete_thread()", "gm_delete_thread()")
  gm_delete_thread(...)
}

#' @export
modify_thread <- function(...) {
  deprecate_soft("1.0.0", "gmailr::modify_thread()", "gm_modify_thread()")
  gm_modify_thread(...)
}

#' @export
draft <- function(...) {
  deprecate_soft("1.0.0", "gmailr::draft()", "gm_draft()")
  gm_draft(...)
}

#' @export
drafts <- function(...) {
  deprecate_soft("1.0.0", "gmailr::drafts()", "gm_drafts()")
  gm_drafts(...)
}

#' @export
create_draft <- function(...) {
  deprecate_soft("1.0.0", "gmailr::create_draft()", "gm_create_draft()")
  gm_create_draft(...)
}

#' @export
send_draft <- function(...) {
  deprecate_soft("1.0.0", "gmailr::send_draft()", "gm_send_draft()")
  gm_send_draft(...)
}

#' @export
labels <- function(...) {
  deprecate_soft("1.0.0", "gmailr::labels()", "gm_labels()")
  gm_labels(...)
}

#' @export
label <- function(...) {
  deprecate_soft("1.0.0", "gmailr::label()", "gm_label()")
  gm_label(...)
}

#' @export
update_label <- function(...) {
  deprecate_soft("1.0.0", "gmailr::update_label()", "gm_update_label()")
  gm_update_label(...)
}

#' @export
update_label_patch <- function(...) {
  deprecate_soft("1.0.0", "gmailr::update_label_patch()", "gm_update_label_patch()")
  gm_update_label_patch(...)
}

#' @export
delete_label <- function(...) {
  deprecate_soft("1.0.0", "gmailr::delete_label()", "gm_delete_label()")
  gm_delete_label(...)
}

#' @export
create_label <- function(...) {
  deprecate_soft("1.0.0", "gmailr::create_label()", "gm_create_label()")
  gm_create_label(...)
}

#' @export
history <- function(...) {
  deprecate_soft("1.0.0", "gmailr::history()", "gm_history()")
  gm_history(...)
}

#' @export
mime <- function(...) {
  deprecate_soft("1.0.0", "gmailr::mime()", "gm_mime()")
  gm_mime(...)
}

#' @export
text_body <- function(...) {
  deprecate_soft("1.0.0", "gmailr::text_body()", "gm_text_body()")
  gm_text_body(...)
}

#' @export
html_body <- function(...) {
  deprecate_soft("1.0.0", "gmailr::html_body()", "gm_html_body()")
  gm_html_body(...)
}

#' @export
attach_part <- function(...) {
  deprecate_soft("1.0.0", "gmailr::attach_part()", "gm_attach_part()")
  gm_attach_part(...)
}

#' @export
attach_file <- function(...) {
  deprecate_soft("1.0.0", "gmailr::attach_file()", "gm_attach_file()")
  gm_attach_file(...)
}

