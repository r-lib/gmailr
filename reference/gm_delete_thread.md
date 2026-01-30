# Permanently delete a single thread.

Function to delete a given thread by id. This cannot be undone!

## Usage

``` r
gm_delete_thread(id, user_id = "me")
```

## Arguments

- id:

  thread id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.threads/delete>

## See also

Other thread:
[`gm_modify_thread()`](https://gmailr.r-lib.org/reference/gm_modify_thread.md),
[`gm_thread()`](https://gmailr.r-lib.org/reference/gm_thread.md),
[`gm_threads()`](https://gmailr.r-lib.org/reference/gm_threads.md),
[`gm_trash_thread()`](https://gmailr.r-lib.org/reference/gm_trash_thread.md),
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md)

## Examples

``` r
if (FALSE) { # \dontrun{
gm_delete_thread(12345)
} # }
```
