# Get a list of messages

Get a list of messages possibly matching a given query string.

## Usage

``` r
gm_messages(
  search = NULL,
  num_results = NULL,
  label_ids = NULL,
  include_spam_trash = NULL,
  page_token = NULL,
  user_id = "me"
)
```

## Arguments

- search:

  query to use, same format as gmail search box.

- num_results:

  the number of results to return.

- label_ids:

  restrict search to given labels

- include_spam_trash:

  boolean whether to include the spam and trash folders in the search

- page_token:

  retrieve a specific page of results

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list>

## See also

Other message:
[`gm_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_attachment.md),
[`gm_delete_message()`](https://gmailr.r-lib.org/dev/reference/gm_delete_message.md),
[`gm_import_message()`](https://gmailr.r-lib.org/dev/reference/gm_import_message.md),
[`gm_insert_message()`](https://gmailr.r-lib.org/dev/reference/gm_insert_message.md),
[`gm_message()`](https://gmailr.r-lib.org/dev/reference/gm_message.md),
[`gm_modify_message()`](https://gmailr.r-lib.org/dev/reference/gm_modify_message.md),
[`gm_save_attachment()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachment.md),
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md),
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md),
[`gm_trash_message()`](https://gmailr.r-lib.org/dev/reference/gm_trash_message.md),
[`gm_untrash_message()`](https://gmailr.r-lib.org/dev/reference/gm_untrash_message.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Search for R, return 10 results using label 1 including spam and trash folders
my_messages <- gm_messages("R", 10, "label_1", TRUE)
} # }
```
