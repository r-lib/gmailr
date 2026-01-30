# Get a list of drafts

Get a list of drafts possibly matching a given query string.

## Usage

``` r
gm_drafts(num_results = NULL, page_token = NULL, user_id = "me")
```

## Arguments

- num_results:

  the number of results to return.

- page_token:

  retrieve a specific page of results

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/list>

## See also

Other draft:
[`gm_delete_draft()`](https://gmailr.r-lib.org/reference/gm_delete_draft.md),
[`gm_draft()`](https://gmailr.r-lib.org/reference/gm_draft.md),
[`gm_send_draft()`](https://gmailr.r-lib.org/reference/gm_send_draft.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_drafts <- gm_drafts()

first_10_drafts <- gm_drafts(10)
} # }
```
