# gmailr 2.0.0

## Changes around the OAuth client

* [Set up an OAuth client](https://gmailr.r-lib.org/articles/oauth-client.html)
  is a new non-vignette article with detailed instructions for creating and
  configuring an OAuth client.
* `gm_default_oauth_client()` is a new helper that searches for the JSON file
  representing an OAuth client in a sequence of locations. The (file)path of
  least resistance is to place this file in the directory returned by
  `rappdirs::user_data_dir("gmailr")`. Another alternative is to record its
  filepath in the `GMAILR_OAUTH_CLIENT` environment variable. For backwards
  compatibility, the `GMAILR_APP` environment variable is still consulted, but
  generates a warning (#166).
* `gm_auth()` no longer checks for an OAuth client before calling
  `gargle::token_fetch()`. This allows other auth methods to work, which by and
  large don't need an OAuth client, such as `gargle::credentials_byo_oauth2()`
  (#160, #186).
* If `gm_auth()` fails to get a token and no OAuth client has been configured,
  it silently calls `gm_auth_configure()` to make one attempt at automatic
  client discovery. If an OAuth client is indeed discovered, `gm_auth()` tries
  one more time to get a token.
  
  Since the lack of an OAuth client undoubtedly remains the most common reason
  for `gm_auth()` to fail, its error message includes some specific content if
  no OAuth client has been configured.
  
## Storing and deploying a token

* `gm_token_write()` + `gm_token_read()` is a new matched pair of functions that
  make it much easier to explicitly store a token obtained in an interactive
  session then reuse that token elsewhere, such in CI or in a deployed product
  (#190).
  
* The directory `system.file("deployed-token-demo", package = "gmailr")`
  contains a working demo of how to use `gm_token_write()` +
  `gm_token_read()` in a deployed Shiny app.
  
* `vignette("deploy-a-token")` is a new vignette describing how to capture a
  token interactively, for later use in a non-interactive setting.

## Syncing up with gargle

Versions 1.3.0, 1.4.0, and 1.5.1 of gargle introduced some changes around OAuth and gmailr is syncing up that:

* `gm_oauth_client()` is a new function to replace the now-deprecated
  `gm_oauth_app()`. This is somewhat about a vocabulary change ("client" instead
  of "app"), but it's really connected to a more meaningful shift in gargle,
  which has a new appreciation for different OAuth client types (e.g.,
  "installed" vs. "web").
* `gm_oauth_client()` (and the function it's replacing, `gm_oauth_app()`) no
  longer error if there is no configured OAuth client.
* `gm_auth_configure()` has an updated signature:
  - The first argument is now named `client`, which is morally equivalent to the
    previous `app`, i.e. this is essentially a name change.
  - The `key`, `secret`, `appname`, and `app` arguments are deprecated.
  - Our strong recommendation is to use the `path` argument, either explicitly::
    ``` r
    gm_auth_configure(path = "path/to/my-oauth-client.json")
    ```
    or implicitly:
    ``` r
    gm_auth_configure()
    ```
    which works because of the new default:
    `gm_auth_configure(path = gm_default_oauth_client())`.

## Other changes
  
* `gm_auth(subject =)` is a new argument that can be used with
  `gm_auth(path =)`, i.e. when using a service account. The `path` and
  `subject` arguments are ultimately processed by
  `gargle::credentials_service_account()` and support the use of a service
  account to impersonate a regular user.

* `gm_scopes()` can now take a character vector of scopes, each of which can be
  an actual scope or a short alias, e.g., `"gmail.readonly"`, which identifies a
  scope associated with the Gmail API. When called without arguments,
  `gm_scopes()` still returns a named vector of Gmail API-specific scopes, where
  the names are the associated short aliases.

* The deprecation process for legacy functions that lack the `gm_` prefix has
  been advanced. The functions are still present, but throw an error directing
  the user to switch to the prefixed version.

  The unexported helper
  `gmailr:::gm_convert_file(list.files(pattern = "[.]R$", recursive = TRUE))`
  can be used to convert all R files in the current directory to the new names
  (#95).
  
* Legacy auth functions `clear_token()`, `gmail_auth()`, and `use_secret_file()`
  now throw an error.
  
* gmailr no longer `Imports` magrittr and no longer re-exports the magrittr pipe
  (`%>%`). gmailr is a very pipe-friendly package, so this was originally done
  for user convenience (#42).
  
  Since most users (those using R >= 4.1) now have access to the base pipe
  (`|>`), that is now what is shown in gmailr's documentation. Those using R <
  4.1 can still use gmailr with `magrittr::%>%`, but they will need to do
  `library(magrittr)` for themselves.
  
  Any gmailr examples that use the base pipe will no longer work on R < 4.1. On
  affected R versions, the examples are automatically converted to a regular
  section with a note that they might not work.

# gmailr 1.0.1

* Jenny Bryan is now the maintainer

# gmailr 1.0.0

## Breaking changes

* All functions are now prefixed with `gm_*()` to avoid name conflicts with
  other packages (including the base package), the previous names have been deprecated
  and will be removed in future releases. Use 
  `gmailr:::gm_convert_file(list.files(pattern = "[.]R$", recursive = TRUE))`
  to convert all R files in the current directory to the new names. (#95)

* New `gm_auth_configure()` and `gm_auth()` functions added conforming to the
  conventions in the [gargle](https://cran.r-project.org/package=gargle) package.
  `gmail_auth()`, `clear_token()` and `use_secret_token()` are now deprecated and will be removed
  in a future release.

* The google application bundled in previous gmailr releases has been removed,
  users will now need to create their own applications in order to use gmailr. See
  the [Setup](https://github.com/r-lib/gmailr/blob/main/README.md#setup) section
  in the readme for details. This was necessary to comply with stricter enforcement
  of the API terms of service.

## New features

* New `gm_attachements()` returns a data.frame of attachment information from a
  message or draft (#10, #24).

* New `gm_delete_draft()` added to delete a draft email without sending it to the trash.

* New `gm_profile()` function to return the gmail profile of the currently
  logged in user (#114)

* New `gm_scopes()` function to list the available scopes, and gmailr now
  requests only the full scope by default (#90)

* More detailed examples added to the README and the vignette, including adding
  and referencing attachments in HTML email.

## Minor improvements and fixes

* `gm_body()`, `gm_to()`, `gm_from()`, `gm_cc()`, `gm_bcc()` and `gm_subject()`
  now automatically mark their output as UTF-8 (#47, #86)

* Quoted-printable now works with smart quotes (#77)

* Unicode text can now be used in email headers, including the Subject and
  address fields, like To and Cc (#76, #78)

* `print.gmail_message()` now only prints the parts of the message that are
  defined (#88) and now prints out the filenames of attachments (if any).

# gmailr 0.7.1

* Bundle a application token and secret in gmailr so the average user won't need to create an application.
* Great number of bug fixes
* Reworking the print functions to provide more useful and easy to read output
* Added check for null response to fix bug with DELETE requests (#79) @josibake

# gmailr 0.5.0

### Major Changes

* Added ability to create and send drafts and messages. (#5, #6)
* Added a number of tests for mime message creation derived from the [Email::Stuffer](http://search.cpan.org/~rjbs/Email-Stuffer-0.009/lib/Email/Stuffer.pm) perl module.

### Minor Fixes

* Namespace was not properly updated (#2)
* added extraction functions for gmail_messages (#3)

# gmailr 0.0.1

* Initial release
