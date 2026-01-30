# Permanently delete a single draft

Function to delete a given draft by id. This cannot be undone!

## Usage

``` r
gm_delete_draft(id, user_id = "me")
```

## Arguments

- id:

  message id to access

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/delete>

## See also

Other draft:
[`gm_draft()`](https://gmailr.r-lib.org/reference/gm_draft.md),
[`gm_drafts()`](https://gmailr.r-lib.org/reference/gm_drafts.md),
[`gm_send_draft()`](https://gmailr.r-lib.org/reference/gm_send_draft.md)

## Examples

``` r
if (FALSE) { # \dontrun{
delete_draft("12345")
} # }
```
