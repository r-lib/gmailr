# gmailr
<!-- badges: start -->
[![R-CMD-check](https://github.com/r-lib/gmailr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/r-lib/gmailr/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/r-lib/gmailr/branch/main/graph/badge.svg)](https://app.codecov.io/gh/r-lib/gmailr?branch=main)
<!-- badges: end -->

Exposing the [Gmail API](https://developers.google.com/gmail/api) from R.

## Installation

Install the released version of gmailr from CRAN:

```r
install.packages("gmailr")
```

Or install the development version from GitHub with:

```r
# install.packages("pak")
pak::pak("r-lib/gmailr")
```

## Setup

In order to use gmailr, you will need to create your own OAuth client.
This is documented in the article LINK GOES HERE.

After successful setup, a typical gmailr-using script should start like this:

```r
library(gmailr)
gm_auth_configure()

# your gmailr code ...
```

The `gm_auth_configure()` function will discover and configure the OAuth client.
Alternatively, it can also accept an explicit path to the client JSON.

## Writing new emails

Create a new email with `gm_mime()` and the helper functions (`gm_from()`, `gm_to()`, etc.).
When developing the message, you might want to use `gm_create_draft()` to verify your email is formatted as you expect.
Then you can send the draft with `gm_send_draft()` or send the original MIME message with `gm_send_message()`.

```r
test_email <-
  gm_mime() |>
  gm_to("PUT_A_VALID_EMAIL_ADDRESS_THAT_YOU_CAN_CHECK_HERE") |>
  gm_from("PUT_THE_GMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_GOOGLE_ACCOUNT_HERE") |>
  gm_subject("this is just a gmailr test") |>
  gm_text_body("Can you hear me now?")

# Verify it looks correct, i.e. look at your Gmail drafts in the browser
d <- gm_create_draft(test_email)

# If all is good with your draft, then you can send the existing draft
gm_send_draft(d)

# or the existing MIME message
gm_send_message(test_email)
```

You can add a file attachment to your message with `gm_attach_file()`.

```r
write.csv(mtcars,"mtcars.csv")
test_email <- test_email |> gm_attach_file("mtcars.csv")

# Verify it looks correct
d <- gm_create_draft(test_email)

# If so, send it
gm_send_draft(d)
```

## Reading emails

gmail shows you threads of messages in the web UI, you can retrieve all threads
with `gm_threads()`, and retrieve a specific thread with `gm_thread()`

```r
# view the latest thread
my_threads <- gm_threads(num_results = 10)

# retrieve the latest thread by retrieving the first ID

latest_thread <- gm_thread(gm_id(my_threads)[[1]])

# The messages in the thread will now be in a list
latest_thread$messages

# Retrieve parts of a specific message with the accessors
my_msg <- latest_thread$messages[[1]]

gm_to(my_msg)
gm_from(my_msg)
gm_date(my_msg)
gm_subject(my_msg)
gm_body(my_msg)

# If a message has attachments, download them all locally with `gm_save_attachments()`.
gm_save_attachments(my_msg)
```

## Features
- retrieve data from your email
  - drafts: `my_drafts = gm_drafts()`
  - history: `my_history = history(start_num)`
  - labels: `my_labels = gm_labels()`
  - messages: `my_messages = gm_messages("search query")`
  - threads: `my_threads = gm_threads("search query")`
- Create and send emails and drafts: see [sending_messages vignette](https://gmailr.r-lib.org/articles/sending_messages.html)
- manage email labels programmatically: `modify_thread(thread_id, add_labels=c("label_1"), remove_labels=c("label_2"))`
- put things in the gmail trash
  - messages: `gm_trash_message(message_id)`
  - threads: `trash_thread(thread_id)`
- take things out of the gmail trash
  - messages: `gm_untrash_message(message_id)`
  - threads: `untrash_thread(thread_id)`
- delete directly without using the trash
  - messages: `gm_delete_message(message_id)`
  - threads: `delete_thread(thread_id)`

## Using gmailr in deployed applications

If you are using gmailr in a deployed application you will need to copy two pieces to your deployed location.

1. The JSON for your OAuth client.
2. The OAuth token cache, by default this is the return value of
   `rappdirs::user_cache_dir("gargle")`.

The easiest thing to do to ensure you are copying only the gmailr oauth token
is to set this explicitly locally, e.g. do the following.

### Run locally
```r
# Configure your app
gm_auth_configure(path = "credentials.json")

# Authenticate with the new cache, store tokens in .secret
gm_auth(cache = ".secret")
# Go through the oauth flow
```

Then copy `credentials.json` _and_ the `.secret` directory to your remote location.

### Run remotely
```
# Configure your app
gm_auth_configure(path = "credentials.json")

# Authenticate with the tokens in the copied cache
gm_auth(email = TRUE, cache = ".secret")
```

There are additional details on dealing with [non-interactive
auth](https://gargle.r-lib.org/articles/non-interactive-auth.html#provide-an-oauth-token-directly)
in the gargle documentation.

## Policies

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)

# Community Examples
- [Send Email with R](https://github.com/jennybc/send-email-with-r) - Jenny Bryan (@jennybc)
