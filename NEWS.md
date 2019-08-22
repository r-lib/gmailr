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
  the [Setup](https://github.com/r-lib/gmailr/blob/master/README.md#setup) section
  in the readme for details. This was nessesary to comply with stricter enforement
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
