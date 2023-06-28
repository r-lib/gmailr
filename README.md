
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gmailr

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/gmailr)](https://CRAN.R-project.org/package=gmailr)
[![R-CMD-check](https://github.com/r-lib/gmailr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/gmailr/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/r-lib/gmailr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/gmailr?branch=main)
<!-- badges: end -->

Exposing the [Gmail API](https://developers.google.com/gmail/api) from
R.

## Installation

Install the released version of gmailr from CRAN:

``` r
install.packages("gmailr")
```

Or install the development version from GitHub with:

``` r
# install.packages("pak")
pak::pak("r-lib/gmailr")
```

## Attach gmailr

``` r
library(gmailr)
```

## Setup and auth

In order to use gmailr, you **must** provide your own OAuth client. This
is documented in the article [Set up an OAuth
client](https://gmailr.r-lib.org/dev/articles/oauth-client.html). The
article goes deeply into how to create an OAuth client and also how to
configure it for gmailr’s use. If you already have an OAuth client or
know how to create one, the help topics for `?gm_auth_configure` and
`?gm_default_oauth_client` are more concise resources for just the
client configuration piece.

Configuring an OAuth client is step 1 of 2 for getting ready to use
gmailr. Step 2 is to complete the so-called “OAuth dance”, which is
triggered automatically upon first need. You are taken to a web browser,
where you must select or login as the Google user you want to use
(authenticate yourself) and give your OAuth client permission to do
Gmail stuff on your behalf (authorize). The OAuth dance does not
(necessarily) need to be repeated in subsequent sessions. See `?gm_auth`
if these defaults aren’t appropriate for your use case and you’d like to
take more control.

You can call `gm_profile()` to confirm that you are using the intended
Google identity.

## Compose and send an email

Create a new email with `gm_mime()` and build it up from parts, using
helper functions like `gm_to()` and `gm_subject()`.

``` r
test_email <-
  gm_mime() |>
  gm_to("PUT_A_VALID_EMAIL_ADDRESS_THAT_YOU_CAN_CHECK_HERE") |>
  gm_from("PUT_THE_GMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_GOOGLE_ACCOUNT_HERE") |>
  gm_subject("this is just a gmailr test") |>
  gm_text_body("Can you hear me now?")
```

When developing the message, you might want to use `gm_create_draft()`,
if you’d like to view a draft and verify that it’s formatted as you
expect. Then you can send the draft with `gm_send_draft()` or send the
original MIME message with `gm_send_message()`.

``` r
# Verify it looks correct, i.e. look at your Gmail drafts in the browser
d <- gm_create_draft(test_email)

# If all is good with your draft, then you can send the existing draft
gm_send_draft(d)
#> Draft Id: 189033f7e08ead50 
#> NULL

# or the existing MIME message
gm_send_message(test_email)
#> Id: 189033f816495611
```

## Read email

You can retrieve all email threads with `gm_threads()` or retrieve a
specific thread with `gm_thread()`. You can then isolate a specific
message and access its parts.

``` r
# view recent threads
my_threads <- gm_threads(num_results = 10)

# retrieve the latest thread by retrieving the first ID
latest_thread <- gm_thread(gm_id(my_threads)[[1]])

# messages in the thread will now be in a list
# retrieve parts of a specific message with the accessors
my_msg <- latest_thread$messages[[1]]

gm_date(my_msg)
#> [1] "Wed, 28 Jun 2023 11:24:00 -0700"
gm_subject(my_msg)
#> [1] "this is just a gmailr test"
gm_body(my_msg)
#> [[1]]
#> [1] "Can you hear me now?\r\n"
```

## Where to learn more

More details are available in the [Get
started](https://gmailr.r-lib.org/articles/gmailr.html) article and in
gmailr’s [other articles](https://gmailr.r-lib.org/articles/index.html).

## Policies

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)
