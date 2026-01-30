# Clear current token

Clears any currently stored token. The next time gmailr needs a token,
the token acquisition process starts over, with a fresh call to
[`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.md) and,
therefore, internally, a call to
[`gargle::token_fetch()`](https://gargle.r-lib.org/reference/token_fetch.html).
Unlike some other packages that use gargle, gmailr is not usable in a
de-authorized state. Therefore, calling `gm_deauth()` only clears the
token, i.e. it does NOT imply that subsequent requests are made with an
API key in lieu of a token.

## Usage

``` r
gm_deauth()
```

## See also

Other auth functions:
[`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.md),
[`gm_auth_configure()`](https://gmailr.r-lib.org/reference/gm_auth_configure.md),
[`gm_scopes()`](https://gmailr.r-lib.org/reference/gm_scopes.md),
[`gmailr-configuration`](https://gmailr.r-lib.org/reference/gmailr-configuration.md)

## Examples

``` r
if (FALSE) { # rlang::is_interactive()
gm_deauth()
}
```
