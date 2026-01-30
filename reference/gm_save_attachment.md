# Save the attachment to a file

This is a low level function that only works on attachments retrieved
with
[`gm_attachment()`](https://gmailr.r-lib.org/reference/gm_attachment.md).
To save an attachment directly from a message see
[`gm_save_attachments()`](https://gmailr.r-lib.org/reference/gm_save_attachments.md),
which is a higher level interface more suitable for most uses.

## Usage

``` r
gm_save_attachment(x, filename)
```

## Arguments

- x:

  attachment to save

- filename:

  location to save to

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/reference/gm_message.md),
[`gm_messages()`](https://gmailr.r-lib.org/reference/gm_messages.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/reference/gm_modify_message.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_attachment <- gm_attachment("a32e324b", "12345")
# save attachment to a file
gm_save_attachment(my_attachment, "photo.jpg")
} # }
```
