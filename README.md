# gmailr #
<!-- badges: start -->
[![Azure pipelines build status](https://img.shields.io/azure-devops/build/r-lib/gmailr/5)](https://dev.azure.com/r-lib/gmailr/_build/latest?definitionId=5&branchName=master)
[![Azure pipelines test status](https://img.shields.io/azure-devops/tests/r-lib/gmailr/5?color=brightgreen&compact_message)](https://dev.azure.com/r-lib/gmailr/_build/latest?definitionId=5&branchName=master)
[![Azure pipelines coverage status](https://img.shields.io/azure-devops/coverage/r-lib/gmailr/5)](https://dev.azure.com/r-lib/gmailr/_build/latest?definitionId=5&branchName=master)
[![Build Status](https://travis-ci.org/r-lib/gmailr.svg?branch=master)](https://travis-ci.org/r-lib/gmailr)
<!-- badges: end -->

Exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

## Installation ##

Get the released version from CRAN:

```R
install.packages("gmailr")
```

Or the development version from github with:

```R
# install.packages("devtools")
devtools::install_github("r-lib/gmailr")
```

## Writing new emails ##

Create a new email with `gm_mime()` and the helper functions. When testing it
is recommended to use `gm_create_draft()` to verify your email is formatted as you
expect before automating it (if desired) with `gm_send_message()`.

```r
test_email <-
  gm_mime() %>%
  gm_to("PUT_A_VALID_EMAIL_ADDRESS_THAT_YOU_CAN_CHECK_HERE") %>%
  gm_from("PUT_THE_GMAIL_ADDRESS_ASSOCIATED_WITH_YOUR_GOOGLE_ACCOUNT_HERE") %>%
  gm_subject("this is just a gmailr test") %>%
  gm_text_body("Can you hear me now?")

# Verify it looks correct
gm_create_draft(test_email)

# If all is good with your draft, then you can send it
gm_send_message(test_email)
```

You can add a file attachment to your message with `gm_attach_file()`.

```r
write.csv("mtcars.csv", mtcars)
test_email <- gm_attach_file("mtcars.csv")

# Verify it looks correct
gm_create_draft(test_email)

# If so, send it
gm_send_message(test_email)
```

## Reading emails ##

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

## Features ##
- retrieve data from your email
  - drafts: `my_drafts = gm_drafts()`
  - history: `my_history = history(start_num)`
  - labels: `my_labels = gm_labels()`
  - messages: `my_messages = gm_messages("search query")`
  - threads: `my_threads = gm_threads("search query")`
- Create and send emails and drafts: see [sending_messages vignette](https://github.com/r-lib/gmailr/blob/master/vignettes/sending_messages.Rmd)
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

## Setup ##

In order to use gmailr you will need to create a google project for it. The
easiest way to do this is via the [Python
Quickstart](https://developers.google.com/gmail/api/quickstart/python).

* Click the `Enable the Gmail API` button.
* In the resulting dialog click the `DOWNLOAD CLIENT CONFIGURATION` on your computer.
* Tell gmailr where the JSON lives, by doing one of the two things
  1. Call `gm_auth_configure(path = "path/to/downloaded/json")
  2. Set the `GMAILR_APP` environment variable to the location of the JSON
     file, it is convienent to do this in your `.Renviron` file with
     `usethis::edit_r_environ()`. Then calling `gm_auth_configure()` with no arguments.
* Call `gm_auth()` to start the OAuth flow to verify to google that you would
  like your gmailr project to have access to your email. You will get a scary
  warning about an untrusted application, this is because the application is
  the one you just created, click advanced and `Go to gmailr` to proceed to do
  the oauth flow.
* If you want to authenticate with fewer scopes than the default use the
  `scopes` parameter to `gm_auth()`. You can see a full list of available
  scopes from `gm_scopes()`.
  
Only very heavy usage of the Gmail API requires payment, so use of the API for most
people should be free.

## Using gmailr in deployed applications ##

If you are using gmailr in a deployed application you will need to copy two pieces to your deployed location.

1. The application JSON file, that you setup in the local setup.
2. The oauth token cache, by default this is `~/.R/gargle/gargle-oauth`

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

## Policies ##

[Privacy policy](https://www.tidyverse.org/google_privacy_policy)

# Community Examples #
- [Send Email with R](https://github.com/jennybc/send-email-with-r) - Jenny Bryan (@jennybc)
