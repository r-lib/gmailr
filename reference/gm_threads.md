# Get a list of threads

Get a list of threads possibly matching a given query string.

## Usage

``` r
gm_threads(
  search = NULL,
  num_results = NULL,
  page_token = NULL,
  label_ids = NULL,
  include_spam_trash = NULL,
  user_id = "me"
)
```

## Arguments

- search:

  query to use, same format as gmail search box.

- num_results:

  the number of results to return.

- page_token:

  retrieve a specific page of results

- label_ids:

  restrict search to given labels

- include_spam_trash:

  boolean whether to include the spam and trash folders in the search

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.threads/list>

## See also

Other thread:
[`gm_delete_thread()`](https://gmailr.r-lib.org/reference/gm_delete_thread.md),
[`gm_modify_thread()`](https://gmailr.r-lib.org/reference/gm_modify_thread.md),
[`gm_thread()`](https://gmailr.r-lib.org/reference/gm_thread.md),
[`gm_trash_thread()`](https://gmailr.r-lib.org/reference/gm_trash_thread.md),
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_threads <- gm_threads()

first_10_threads <- gm_threads(10)
} # }
```
