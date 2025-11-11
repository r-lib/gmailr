# Edit auth configuration

See the article [Set up an OAuth
client](https://gmailr.r-lib.org/dev/articles/oauth-client.html) for
instructions on how to get an OAuth client. Then you can use
`gm_auth_configure()` to register your client for use with gmailr.
`gm_oauth_client()` retrieves the currently configured OAuth client.

## Usage

``` r
gm_auth_configure(
  client = NULL,
  path = gm_default_oauth_client(),
  key = deprecated(),
  secret = deprecated(),
  appname = deprecated(),
  app = deprecated()
)

gm_oauth_client()
```

## Arguments

- client:

  A Google OAuth client, presumably constructed via
  [`gargle::gargle_oauth_client_from_json()`](https://gargle.r-lib.org/reference/gargle_oauth_client_from_json.html).
  Note, however, that it is preferred to specify the client with JSON,
  using the `path` argument.

- path:

  JSON downloaded from [Google Cloud
  Console](https://console.cloud.google.com), containing a client id and
  secret, in one of the forms supported for the `txt` argument of
  [`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html)
  (typically, a file path or JSON string).

- key, secret, appname, app:

  **\[deprecated\]** Use the `path` (strongly recommended) or `client`
  argument instead.

## Value

- `gm_auth_configure()`: An object of R6 class
  [gargle::AuthState](https://gargle.r-lib.org/reference/AuthState-class.html),
  invisibly.

- `gm_oauth_client()`: the current user-configured OAuth client.

## See also

[`gm_default_oauth_client()`](https://gmailr.r-lib.org/dev/reference/gmailr-configuration.md)
to learn how you can make your OAuth client easy for gmailr to discover.

Other auth functions:
[`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md),
[`gm_deauth()`](https://gmailr.r-lib.org/dev/reference/gm_deauth.md),
[`gm_scopes()`](https://gmailr.r-lib.org/dev/reference/gm_scopes.md),
[`gmailr-configuration`](https://gmailr.r-lib.org/dev/reference/gmailr-configuration.md)

## Examples

``` r
if (FALSE) { # rlang::is_interactive()
# if your OAuth client can be auto-discovered (see ?gm_default_oauth_client),
# you don't need to provide anything!
gm_auth_configure()
}
# see and store the current user-configured OAuth client
(original_client <- gm_oauth_client())
#> NULL

# the preferred way to configure your own client is via a JSON file
# downloaded from Google Developers Console
# this example JSON is indicative, but fake
path_to_json <- system.file(
  "extdata", "client_secret_installed.googleusercontent.com.json",
  package = "gargle"
)
gm_auth_configure(path = path_to_json)

# confirm that a (fake) OAuth client is now configured
gm_oauth_client()
#> <gargle_oauth_client>
#> name: a_project_d1c5a8066d2cbe48e8d94514dd286163
#> id: abc.apps.googleusercontent.com
#> secret: <REDACTED>
#> type: installed
#> redirect_uris: http://localhost

# restore original auth config
gm_auth_configure(client = original_client)
```
