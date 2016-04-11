## Test environments
* local OS X install, R 3.2.4
* ubuntu 12.04 (on travis-ci), R 3.2.4
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

Possibly mis-spelled words in DESCRIPTION:
  API (6:33, 7:48)
  Gmail (6:19, 7:34, 8:5)
  RESTful (6:25, 7:40)

These are all words Google uses to talk about their gmail API so I think are
appropriate spellings.

Found the following (possibly) invalid URLs:
  URL: https://console.cloud.google.com
    From: man/gmail_auth.Rd
    Status: 404
    Message: Not Found

This link is actually valid for GET requests, but HEAD requests (like the check
uses) return a 404.

## Reverse dependencies

There are no reverse dependencies.
