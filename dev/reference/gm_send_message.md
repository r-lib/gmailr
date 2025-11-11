# Send a message from a mime message

Send a message from a mime message

## Usage

``` r
gm_send_message(
  mail,
  type = c("multipart", "media", "resumable"),
  thread_id = NULL,
  user_id = "me"
)
```

## Arguments

- mail:

  mime mail message created by mime

- type:

  the type of upload to perform

- thread_id:

  the id of the thread to send from.

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages/send>

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
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_send_message(gm_mime(
  from = "you@me.com", to = "any@one.com",
  subject = "hello", "how are you doing?"
))
} # }
```
