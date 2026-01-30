# Get a single message

Function to retrieve a given message by id

## Usage

``` r
gm_message(
  id,
  user_id = "me",
  format = c("full", "metadata", "minimal", "raw")
)
```

## Arguments

- id:

  message id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

- format:

  format of the message returned

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/reference/gm_insert_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/reference/gm_messages.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/reference/gm_modify_message.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/reference/gm_save_attachment.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_message <- gm_message(12345)
} # }
```
