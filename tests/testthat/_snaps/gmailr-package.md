# gm_default_oauth_client() errors for >1 matching .json files

    Code
      gm_default_oauth_client()
    Condition
      Error in `gm_default_oauth_client()`:
      ! 2 candidate JSON files found in {GARGLE_USER_DATA}.
        OAuth client can't be automatically discovered.

# gm_default_oauth_client() still consults GMAILR_APP, but warns

    The `GMAILR_APP` environment variable was deprecated in gmailr 2.0.0.
    i Please use `GMAILR_OAUTH_CLIENT` or the default storage location instead.
    i Learn more at `?gm_default_oauth_client`.

