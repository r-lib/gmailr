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

