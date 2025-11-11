# Save attachments to a message

Function to retrieve and save all of the attachments to a message by id
of the message.

## Usage

``` r
gm_save_attachments(x, attachment_id = NULL, path = ".", user_id = "me")
```

## Arguments

- x:

  message with attachment

- attachment_id:

  id of the attachment to save, if none specified saves all attachments

- path:

  where to save the attachments

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages.attachments/get>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/dev/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/dev/reference/gm_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/dev/reference/gm_messages.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/dev/reference/gm_modify_message.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachment.md),
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# save all attachments
gm_save_attachments(my_message)
# save a specific attachment
gm_save_attachments(my_message, "a32e324b")
} # }
```
