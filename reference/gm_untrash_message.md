# Remove a single message from the trash

Function to trash a given message by id. This can be undone by
`gm_untrash_message()`.

## Usage

``` r
gm_untrash_message(id, user_id = "me")
```

## Arguments

- id:

  message id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages/trash>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/reference/gm_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/reference/gm_messages.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/reference/gm_modify_message.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/reference/gm_save_attachment.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/reference/gm_trash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_untrash_message("12345")
} # }
```
