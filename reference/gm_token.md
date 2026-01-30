# Produce configured token

For internal use or for those programming around the Gmail API. Returns
a token pre-processed with
[`httr::config()`](https://httr.r-lib.org/reference/config.html). Most
users do not need to handle tokens "by hand" or, even if they need some
control, [`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.md) is
what they need. If there is no current token,
[`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.md) is called
to either load from cache or initiate OAuth2.0 flow. If auth has been
deactivated via
[`gm_deauth()`](https://gmailr.r-lib.org/reference/gm_deauth.md),
`gm_token()` returns `NULL`.

## Usage

``` r
gm_token()
```

## Value

A `request` object (an S3 class provided by
[httr](https://httr.r-lib.org/reference/httr-package.html)).

## See also

Other low-level API functions:
[`gm_has_token()`](https://gmailr.r-lib.org/reference/gm_has_token.md)

## Examples

``` r
if (FALSE) { # gm_has_token()
gm_token()
}
```
