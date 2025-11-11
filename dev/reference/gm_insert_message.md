# Insert a message into the gmail mailbox from a mime message

Insert a message into the gmail mailbox from a mime message

## Usage

``` r
gm_insert_message(
  mail,
  label_ids,
  type = c("multipart", "media", "resumable"),
  internal_date_source = c("dateHeader", "recievedTime"),
  user_id = "me"
)
```

## Arguments

- mail:

  mime mail message created by mime

- label_ids:

  optional label ids to apply to the message

- type:

  the type of upload to perform

- internal_date_source:

  whether to date the object based on the date of the message or when it
  was received by gmail.

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages/insert>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md),
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
gm_insert_message(gm_mime(
  From = "you@me.com", To = "any@one.com",
  Subject = "hello", "how are you doing?"
))
} # }
```
