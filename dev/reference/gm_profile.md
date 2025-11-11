# Get info on current gmail profile

Reveals information about the profile associated with the current token.

## Usage

``` r
gm_profile(user_id = "me", verbose = TRUE)
```

## Arguments

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

- verbose:

  Logical, indicating whether to print informative messages (default
  `TRUE`).

## Value

A list of class `gmail_profile`.

## See also

Wraps the `getProfile` endpoint:

- <https://developers.google.com/gmail/api/reference/rest/v1/users/getProfile>

## Examples

``` r
if (FALSE) { # \dontrun{
gm_profile()

## more info is returned than is printed
prof <- gm_profile()
prof[["historyId"]]
} # }
```
