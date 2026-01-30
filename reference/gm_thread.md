# Get a single thread

Function to retrieve a given thread by id

## Usage

``` r
gm_thread(id, user_id = "me")
```

## Arguments

- id:

  thread id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.threads>

## See also

Other thread:
[`gm_delete_thread()`](https://gmailr.r-lib.org/reference/gm_delete_thread.md),
[`gm_modify_thread()`](https://gmailr.r-lib.org/reference/gm_modify_thread.md),
[`gm_threads()`](https://gmailr.r-lib.org/reference/gm_threads.md),
[`gm_trash_thread()`](https://gmailr.r-lib.org/reference/gm_trash_thread.md),
[`gm_untrash_thread()`](https://gmailr.r-lib.org/reference/gm_untrash_thread.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_thread <- gm_thread(12345)
} # }
```
