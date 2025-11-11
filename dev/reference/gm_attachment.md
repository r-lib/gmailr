# Retrieve an attachment to a message

This is a low level function to retrieve an attachment to a message by
id of the attachment and message. Most users are better off using
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md)
to automatically save all the attachments in a given message.

## Usage

``` r
gm_attachment(id, message_id, user_id = "me")
```

## Arguments

- id:

  id of the attachment

- message_id:

  id of the parent message

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages.attachments/get>

## See also

Other message:
[`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/dev/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/dev/reference/gm_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/dev/reference/gm_messages.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/dev/reference/gm_modify_message.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachment.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_attachment <- gm_attachment("a32e324b", "12345")
# save attachment to a file
gm_save_attachment(my_attachment, "photo.jpg")
} # }
```
