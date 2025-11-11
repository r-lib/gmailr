# Configuring gmailr

gmailr can be configured with various environment variables, which are
accessed through wrapper functions that provide some additional smarts.

## Usage

``` r
gm_default_email()

gm_default_oauth_client()
```

## `gm_default_email()`

`gm_default_email()` returns the environment variable `GMAILR_EMAIL`, if
it exists, and
[`gargle::gargle_oauth_email()`](https://gargle.r-lib.org/reference/gargle_options.html),
otherwise.

## `gm_default_oauth_client()`

`gm_default_oauth_client()` consults a specific set of locations,
looking for the filepath for the JSON file that represents an OAuth
client. This file can be downloaded from the APIs & Services section of
the Google Cloud console <https://console.cloud.google.com>). The search
unfolds like so:

- `GMAILR_OAUTH_CLIENT` environment variable: If defined, it is assumed
  to be the path to the target JSON file.

- A `.json` file found in the directory returned by
  `rappdirs::user_data_dir("gmailr")`, whose filename uniquely matches
  the regular expression `"client_secret.+[.]json$"`.

- `GMAILR_APP` environment variable: This is supported for backwards
  compatibility, but it is preferable to store the JSON below
  `rappdirs::user_data_dir("gmailr")` or to store the path in the
  `GMAILR_OAUTH_CLIENT` environment variable.

Here's an inspirational snippet to move the JSON file you downloaded
into the right place for auto-discovery by
[`gm_auth_configure()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md):

    path_old <- "~/Downloads/client_secret_123-abc.apps.googleusercontent.com.json"
    d <- fs::dir_create(rappdirs::user_data_dir("gmailr"), recurse = TRUE)
    fs::file_move(path_old, d)

## See also

Since gmailr uses the gargle package to handle auth, gargle's
configuration is also relevant, which is mostly accomplished through
[options and associated accessor
functions](https://gargle.r-lib.org/reference/gargle_options.html).

Other auth functions:
[`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md),
[`gm_auth_configure()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md),
[`gm_deauth()`](https://gmailr.r-lib.org/dev/reference/gm_deauth.md),
[`gm_scopes()`](https://gmailr.r-lib.org/dev/reference/gm_scopes.md)

## Examples

``` r
gm_default_email()
#> NULL

withr::with_envvar(
  c(GMAILR_EMAIL = "jenny@example.com"),
  gm_default_email()
)
#> [1] "jenny@example.com"

gm_default_oauth_client()

withr::with_envvar(
  c(GMAILR_OAUTH_CLIENT = "path/to/my-client.json"),
  gm_default_oauth_client()
)
#> [1] "path/to/my-client.json"
```
