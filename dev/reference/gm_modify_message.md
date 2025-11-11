# Modify the labels on a message

Function to modify the labels on a given message by id. Note you need to
use the label ID as arguments to this function, not the label name.

## Usage

``` r
gm_modify_message(id, add_labels = NULL, remove_labels = NULL, user_id = "me")
```

## Arguments

- id:

  message id to access

- add_labels:

  label IDs to add to the specified message

- remove_labels:

  label IDs to remove from the specified message

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages/modify>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/dev/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/dev/reference/gm_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/dev/reference/gm_messages.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachment.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_modify_message(12345, add_labels = "label_1")
gm_modify_message(12345, remove_labels = "label_1")
# add and remove at the same time
gm_modify_message(12345, add_labels = "label_2", remove_labels = "label_1")
} # }
```
