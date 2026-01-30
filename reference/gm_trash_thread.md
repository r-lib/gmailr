# Send a single thread to the trash

Function to trash a given thread by id. This can be undone by
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md).

## Usage

``` r
gm_trash_thread(id, user_id = "me")
```

## Arguments

- id:

  thread id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.threads/trash>

## See also

Other thread:
[`gm_delete_thread()`](https://gmailr.r-lib.org/reference/gm_delete_thread.md),
[`gm_modify_thread()`](https://gmailr.r-lib.org/reference/gm_modify_thread.md),
[`gm_thread()`](https://gmailr.r-lib.org/reference/gm_thread.md),
[`gm_threads()`](https://gmailr.r-lib.org/reference/gm_threads.md),
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_trash_thread(12345)
} # }
```
