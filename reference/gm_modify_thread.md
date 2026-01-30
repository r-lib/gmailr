# Modify the labels on a thread

Function to modify the labels on a given thread by id.

## Usage

``` r
gm_modify_thread(
  id,
  add_labels = character(0),
  remove_labels = character(0),
  user_id = "me"
)
```

## Arguments

- id:

  thread id to access

- add_labels:

  labels to add to the specified thread

- remove_labels:

  labels to remove from the specified thread

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.threads/modify>

## See also

Other thread:
[`gm_delete_thread()`](https://gmailr.r-lib.org/reference/gm_delete_thread.md),
[`gm_thread()`](https://gmailr.r-lib.org/reference/gm_thread.md),
[`gm_threads()`](https://gmailr.r-lib.org/reference/gm_threads.md),
[`gm_trash_thread()`](https://gmailr.r-lib.org/reference/gm_trash_thread.md),
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_modify_thread(12345, add_labels = "label_1")
gm_modify_thread(12345, remove_labels = "label_1")
# add and remove at the same time
gm_modify_thread(12345, add_labels = "label_2", remove_labels = "label_1")
} # }
```
