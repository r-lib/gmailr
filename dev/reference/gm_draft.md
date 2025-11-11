# Get a single draft

Function to retrieve a given draft by \<-

## Usage

``` r
gm_draft(id, user_id = "me", format = c("full", "minimal", "raw"))
```

## Arguments

- id:

  draft id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

- format:

  format of the draft returned

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/get>

## See also

Other draft:
[`gm_delete_draft()`](https://gmailr.r-lib.org/dev/reference/gm_delete_draft.md),
[`gm_drafts()`](https://gmailr.r-lib.org/dev/reference/gm_drafts.md),
[`gm_send_draft()`](https://gmailr.r-lib.org/dev/reference/gm_send_draft.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_draft <- gm_draft("12345")
} # }
```
