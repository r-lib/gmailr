# Package index

## Authentication and authorization

These functions are used to auth with the gmail API.
[`gm_auth_configure()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md)
and [`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md) are
the most important for most users.

- [`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md) :
  Authorize gmailr
- [`gm_deauth()`](https://gmailr.r-lib.org/dev/reference/gm_deauth.md) :
  Clear current token
- [`gm_auth_configure()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md)
  [`gm_oauth_client()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md)
  : Edit auth configuration
- [`gm_scopes()`](https://gmailr.r-lib.org/dev/reference/gm_scopes.md) :
  Produce scopes specific to the Gmail API
- [`gm_has_token()`](https://gmailr.r-lib.org/dev/reference/gm_has_token.md)
  : Is there a token on hand?
- [`gm_profile()`](https://gmailr.r-lib.org/dev/reference/gm_profile.md)
  : Get info on current gmail profile
- [`gm_token()`](https://gmailr.r-lib.org/dev/reference/gm_token.md) :
  Produce configured token
- [`gm_default_email()`](https://gmailr.r-lib.org/dev/reference/gmailr-configuration.md)
  [`gm_default_oauth_client()`](https://gmailr.r-lib.org/dev/reference/gmailr-configuration.md)
  : Configuring gmailr
- [`gm_token_write()`](https://gmailr.r-lib.org/dev/reference/gm_token_write.md)
  [`gm_token_read()`](https://gmailr.r-lib.org/dev/reference/gm_token_write.md)
  **\[experimental\]** : Write/read a gmailr user token

## Messages

These functions create, modify, query and delete email messages.

- [`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md)
  : Permanently delete a single message
- [`gm_id()`](https://gmailr.r-lib.org/dev/reference/gm_id.md) : Get the
  id of a gmailr object
- [`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md)
  : Import a message into the gmail mailbox from a mime message
- [`gm_insert_message()`](https://gmailr.r-lib.org/dev/reference/gm_insert_message.md)
  : Insert a message into the gmail mailbox from a mime message
- [`gm_message()`](https://gmailr.r-lib.org/dev/reference/gm_message.md)
  : Get a single message
- [`gm_messages()`](https://gmailr.r-lib.org/dev/reference/gm_messages.md)
  : Get a list of messages
- [`gm_modify_message()`](https://gmailr.r-lib.org/dev/reference/gm_modify_message.md)
  : Modify the labels on a message
- [`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md)
  : Send a message from a mime message
- [`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md)
  : Send a single message to the trash
- [`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)
  : Remove a single message from the trash

## Threads

These functions create, modify, query and delete email threads.

- [`gm_delete_thread()`](https://gmailr.r-lib.org/dev/reference/gm_delete_thread.md)
  : Permanently delete a single thread.
- [`gm_modify_thread()`](https://gmailr.r-lib.org/dev/reference/gm_modify_thread.md)
  : Modify the labels on a thread
- [`gm_thread()`](https://gmailr.r-lib.org/dev/reference/gm_thread.md) :
  Get a single thread
- [`gm_threads()`](https://gmailr.r-lib.org/dev/reference/gm_threads.md)
  : Get a list of threads
- [`gm_trash_thread()`](https://gmailr.r-lib.org/dev/reference/gm_trash_thread.md)
  : Send a single thread to the trash
- [`gm_untrash_thread()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_thread.md)
  : Remove a single thread from the trash.

## Drafts

These functions create, modify, query and delete email drafts.

- [`gm_create_draft()`](https://gmailr.r-lib.org/dev/reference/gm_create_draft.md)
  : Create a draft from a mime message
- [`gm_delete_draft()`](https://gmailr.r-lib.org/dev/reference/gm_delete_draft.md)
  : Permanently delete a single draft
- [`gm_draft()`](https://gmailr.r-lib.org/dev/reference/gm_draft.md) :
  Get a single draft
- [`gm_drafts()`](https://gmailr.r-lib.org/dev/reference/gm_drafts.md) :
  Get a list of drafts
- [`gm_send_draft()`](https://gmailr.r-lib.org/dev/reference/gm_send_draft.md)
  : Send a draft

## Labels

These functions create, modify, query and delete email labels.

- [`gm_create_label()`](https://gmailr.r-lib.org/dev/reference/gm_create_label.md)
  : Create a new label
- [`gm_delete_label()`](https://gmailr.r-lib.org/dev/reference/gm_delete_label.md)
  : Permanently delete a label
- [`gm_label()`](https://gmailr.r-lib.org/dev/reference/gm_label.md) :
  Get a specific label
- [`gm_labels()`](https://gmailr.r-lib.org/dev/reference/gm_labels.md) :
  Get a list of all labels
- [`gm_update_label()`](https://gmailr.r-lib.org/dev/reference/gm_update_label.md)
  [`gm_update_label_patch()`](https://gmailr.r-lib.org/dev/reference/gm_update_label.md)
  : Update a existing label.

## Attachments

These functions work with email attachments. `gm_attchments()` to list
the attachments of a message and
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md)
are generally the most useful for most users.

- [`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md)
  : Save attachments to a message
- [`gm_save_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachment.md)
  : Save the attachment to a file
- [`gm_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_attachments.md)
  : Retrieve information about attachments
- [`gm_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_attachment.md)
  : Retrieve an attachment to a message

## Email creation (MIME)

These functions are used to query or set parts of a Multipurpose
Internet Mail Extensions (MIME) messages. They can be used to generate
new emails from scratch.

- [`gm_to()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  [`gm_from()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  [`gm_cc()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  [`gm_bcc()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  [`gm_date()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  [`gm_subject()`](https://gmailr.r-lib.org/dev/reference/accessors.md)
  : Methods to get values from message or drafts
- [`gm_body()`](https://gmailr.r-lib.org/dev/reference/gm_body.md) : Get
  the body text of a message or draft
- [`gm_mime()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_to(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_from(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_cc(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_bcc(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_subject(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_text_body()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_html_body()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_attach_part()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  [`gm_attach_file()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
  : Create a mime formatted message object
- [`as.character(`*`<mime>`*`)`](https://gmailr.r-lib.org/dev/reference/as.character.mime.md)
  : Convert a mime object to character representation

## Miscellaneous tools

These functions don’t fit neatly into the above categories and are
generally used internally or for debugging.

- [`gm_history()`](https://gmailr.r-lib.org/dev/reference/gm_history.md)
  : Retrieve change history for the inbox
- [`gm_last_response()`](https://gmailr.r-lib.org/dev/reference/gm_last_response.md)
  : Response from the last query
- [`quoted_printable_encode()`](https://gmailr.r-lib.org/dev/reference/quoted_printable_encode.md)
  : Encode text using quoted printable
