# Produce scopes specific to the Gmail API

When called with no arguments, `gm_scopes()` returns a named character
vector of scopes associated with the Gmail API. If `gm_scopes(scopes =)`
is given, an abbreviated entry such as `"gmail.readonly"` is expanded to
a full scope (`"https://www.googleapis.com/auth/gmail.readonly"` in this
case). Unrecognized scopes are passed through unchanged.

## Usage

``` r
gm_scopes(scopes = NULL)
```

## Arguments

- scopes:

  One or more API scopes. Each scope can be specified in full or, for
  Gmail API-specific scopes, in an abbreviated form that is recognized
  by `gm_scopes()`:

  - "full" = "https://mail.google.com/" (the default)

  - "gmail.compose" = "https://www.googleapis.com/auth/gmail.compose"

  - "gmail.readonly" = "https://www.googleapis.com/auth/gmail.readonly"

  - "gmail.labels" = "https://www.googleapis.com/auth/gmail.labels"

  - "gmail.send" = "https://www.googleapis.com/auth/gmail.send"

  - "gmail.insert" = "https://www.googleapis.com/auth/gmail.insert"

  - "gmail.modify" = "https://www.googleapis.com/auth/gmail.modify"

  - "gmail.metadata" = "https://www.googleapis.com/auth/gmail.metadata"

  - "gmail.settings_basic" =
    "https://www.googleapis.com/auth/gmail.settings.basic"

  - "gmail.settings_sharing" =
    "https://www.googleapis.com/auth/gmail.settings.sharing"

  See <https://developers.google.com/gmail/api/auth/scopes> for details
  on the permissions for each scope.

## Value

A character vector of scopes.

## See also

<https://developers.google.com/gmail/api/auth/scopes> for details on the
permissions for each scope.

Other auth functions:
[`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.md),
[`gm_auth_configure()`](https://gmailr.r-lib.org/reference/gm_auth_configure.md),
[`gm_deauth()`](https://gmailr.r-lib.org/reference/gm_deauth.md),
[`gmailr-configuration`](https://gmailr.r-lib.org/reference/gmailr-configuration.md)

## Examples

``` r
gm_scopes("full")
#> [1] "https://mail.google.com/"
gm_scopes("gmail.readonly")
#> [1] "https://www.googleapis.com/auth/gmail.readonly"
gm_scopes()
#>                                                     full 
#>                               "https://mail.google.com/" 
#>                                            gmail.compose 
#>          "https://www.googleapis.com/auth/gmail.compose" 
#>                                           gmail.readonly 
#>         "https://www.googleapis.com/auth/gmail.readonly" 
#>                                             gmail.labels 
#>           "https://www.googleapis.com/auth/gmail.labels" 
#>                                               gmail.send 
#>             "https://www.googleapis.com/auth/gmail.send" 
#>                                             gmail.insert 
#>           "https://www.googleapis.com/auth/gmail.insert" 
#>                                             gmail.modify 
#>           "https://www.googleapis.com/auth/gmail.modify" 
#>                                           gmail.metadata 
#>         "https://www.googleapis.com/auth/gmail.metadata" 
#>                                     gmail.settings_basic 
#>   "https://www.googleapis.com/auth/gmail.settings.basic" 
#>                                   gmail.settings_sharing 
#> "https://www.googleapis.com/auth/gmail.settings.sharing" 
```
