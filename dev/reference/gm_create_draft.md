# Create a draft from a mime message

Create a draft from a mime message

## Usage

``` r
gm_create_draft(mail, user_id = "me")
```

## Arguments

- mail:

  mime mail message created by mime

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/create>

## Examples

``` r
if (FALSE) { # \dontrun{
gm_create_draft(gm_mime(
  From = "you@me.com", To = "any@one.com",
  Subject = "hello", "how are you doing?"
))
} # }
```
