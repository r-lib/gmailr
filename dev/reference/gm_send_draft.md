# Send a draft

Send a draft to the recipients in the To, CC, and Bcc headers.

## Usage

``` r
gm_send_draft(draft, user_id = "me")
```

## Arguments

- draft:

  the draft to send

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/send>

## See also

Other draft:
[`gm_delete_draft()`](https://gmailr.r-lib.org/dev/reference/gm_delete_draft.md),
[`gm_draft()`](https://gmailr.r-lib.org/dev/reference/gm_draft.md),
[`gm_drafts()`](https://gmailr.r-lib.org/dev/reference/gm_drafts.md)

## Examples

``` r
if (FALSE) { # \dontrun{
draft <- gm_create_draft(gm_mime(
  From = "you@me.com", To = "any@one.com",
  Subject = "hello", "how are you doing?"
))
gm_send_draft(draft)
} # }
```
