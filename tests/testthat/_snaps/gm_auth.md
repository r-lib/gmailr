# gm_auth() errors if OAuth client is passed to `path`

    Code
      gm_auth(path = system.file("extdata",
        "client_secret_installed.googleusercontent.com.json", package = "gargle"))
    Condition
      Error in `gm_auth()`:
      ! `path` does not represent a service account.
      Did you provide the JSON for an OAuth client instead of for a service account?
      Use `gm_auth_configure()` to configure the OAuth client.

# gm_auth() errors informatively

    Code
      gm_auth()
    Condition
      Error in `gm_auth()`:
      ! Can't get Google credentials.
      x No OAuth client has been configured.
      i To auth with the user flow, you must register an OAuth client with `gm_auth_configure()`.
      i See the article "Set up an OAuth client" for how to get a client:
        <https://gmailr.r-lib.org/dev/articles/oauth-client.html>
      ! gmailr appears to be running in a non-interactive session and it can't auto-discover credentials.
        You may need to call `gm_auth()` directly with all necessary specifics.
      i See gargle's "Non-interactive auth" vignette for more details:
      i <https://gargle.r-lib.org/articles/non-interactive-auth.html>
      i For general auth troubleshooting, set `options(gargle_verbosity = "debug")` to see more detailed debugging information.

# gm_auth_configure() works

    Code
      gm_auth_configure(client = gargle::gargle_client(), path = "PATH")
    Condition
      Error in `gm_auth_configure()`:
      ! Must supply exactly one of `client` and `path`, not both.

---

    Code
      gm_auth_configure()
    Condition
      Error in `gm_auth_configure()`:
      ! Must supply either `client` or `path`.

# gm_auth_configure() errors for key, secret, appname, app

    Code
      gm_auth_configure(key = "KEY", secret = "SECRET")
    Condition
      Error:
      ! The use of `key`, `secret`, `appname`, and `app` with `gm_auth_configure()` was deprecated in gmailr 2.0.0 and is now defunct.
      i Please use the `path` (strongly recommended) or `client` argument instead.

# gm_oauth_app() is deprecated

    Code
      absorb <- gm_oauth_app()
    Condition
      Warning:
      `gm_oauth_app()` was deprecated in gmailr 2.0.0.
      i Please use `gm_oauth_client()` instead.

# gm_scopes() reveals gmail scopes

    Code
      gm_scopes()
    Output
                                                          full 
                                    "https://mail.google.com/" 
                                                 gmail.compose 
               "https://www.googleapis.com/auth/gmail.compose" 
                                                gmail.readonly 
              "https://www.googleapis.com/auth/gmail.readonly" 
                                                  gmail.labels 
                "https://www.googleapis.com/auth/gmail.labels" 
                                                    gmail.send 
                  "https://www.googleapis.com/auth/gmail.send" 
                                                  gmail.insert 
                "https://www.googleapis.com/auth/gmail.insert" 
                                                  gmail.modify 
                "https://www.googleapis.com/auth/gmail.modify" 
                                                gmail.metadata 
              "https://www.googleapis.com/auth/gmail.metadata" 
                                          gmail.settings_basic 
        "https://www.googleapis.com/auth/gmail.settings.basic" 
                                        gmail.settings_sharing 
      "https://www.googleapis.com/auth/gmail.settings.sharing" 

# gm_scopes() substitutes actual scope for legacy super-short form

    The use of extremely short scopes ("readonly") was deprecated in gmailr 2.0.0.
    i Please use the slightly longer form ("gmail.readonly") instead.

---

    The use of extremely short scopes ("readonly", "compose") was deprecated in gmailr 2.0.0.
    i Please use the slightly longer form ("gmail.readonly", "gmail.compose") instead.

