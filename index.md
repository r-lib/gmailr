# gmailr

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
know how to create one, the help topics for
[`?gm_auth_configure`](https://gmailr.r-lib.org/reference/gm_auth_configure.md)
and
[`?gm_default_oauth_client`](https://gmailr.r-lib.org/reference/gmailr-configuration.md)
are more concise resources for just the client configuration piece.

Configuring an OAuth client is step 1 of 2 for getting ready to use
gmailr. Step 2 is to complete the so-called “OAuth dance”, which is
triggered automatically upon first need. You are taken to a web browser,
where you must select or login as the Google user you want to use
(authenticate yourself) and give your OAuth client permission to do
Gmail stuff on your behalf (authorize). The OAuth dance does not
(necessarily) need to be repeated in subsequent sessions. See
[`?gm_auth`](https://gmailr.r-lib.org/reference/gm_auth.md) if these
defaults aren’t appropriate for your use case and you’d like to take
more control.

You can call
[`gm_profile()`](https://gmailr.r-lib.org/reference/gm_profile.md) to
confirm that you are using the intended Google identity.

## Compose and send an email

Create a new email with
[`gm_mime()`](https://gmailr.r-lib.org/reference/gm_mime.md) and build
it up from parts, using helper functions like
[`gm_to()`](https://gmailr.r-lib.org/reference/accessors.md) and
[`gm_subject()`](https://gmailr.r-lib.org/reference/accessors.md).

``` r
test_email <-
  gm_mime() |>
  gm_to("PUT_A_VALID_EMAIL_ADDRESS_THAT_YOU_CAN_CHECK_HERE") |>
  gm_from("PUT_THE_GMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_GOOGLE_ACCOUNT_HERE") |>
  gm_subject("this is just a gmailr test") |>
  gm_text_body("Can you hear me now?")
```

When developing the message, you might want to use
[`gm_create_draft()`](https://gmailr.r-lib.org/reference/gm_create_draft.md),
if you’d like to view a draft and verify that it’s formatted as you
expect. Then you can send the draft with
[`gm_send_draft()`](https://gmailr.r-lib.org/reference/gm_send_draft.md)
or send the original MIME message with
[`gm_send_message()`](https://gmailr.r-lib.org/reference/gm_send_message.md).

``` r
# Verify it looks correct, i.e. look at your Gmail drafts in the browser
d <- gm_create_draft(test_email)

# If all is good with your draft, then you can send the existing draft
gm_send_draft(d)
#> Draft Id: 19c01d17602c97f8 
#> NULL

# or the existing MIME message
gm_send_message(test_email)
#> Id: 19c01d1785c5f52f
```

## Read email

You can retrieve all email threads with
[`gm_threads()`](https://gmailr.r-lib.org/reference/gm_threads.md) or
retrieve a specific thread with
[`gm_thread()`](https://gmailr.r-lib.org/reference/gm_thread.md). You
can then isolate a specific message and access its parts.

``` r
# view recent threads
my_threads <- gm_threads(num_results = 10)

# retrieve the latest thread by retrieving the first ID
latest_thread <- gm_thread(gm_id(my_threads)[[1]])

# messages in the thread will now be in a list
# retrieve parts of a specific message with the accessors
my_msg <- latest_thread$messages[[1]]

gm_date(my_msg)
#> [1] "Tue, 27 Jan 2026 15:37:11 -0800"
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

[Privacy policy](https://tidyverse.org/google_privacy_policy/)
