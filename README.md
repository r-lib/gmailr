# gmailr #

[![Build Status](https://travis-ci.org/jimhester/gmailr.svg?branch=master)](https://travis-ci.org/jimhester/gmailr)
[![Coverage Status](https://coveralls.io/repos/jimhester/gmailr/badge.svg)](https://coveralls.io/r/jimhester/gmailr)

Exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

## Installation ##

Get the released version from CRAN:

```R
install.packages("gmailr")
```

Or the development version from github with:

```R
# install.packages("devtools")
devtools::install_github("jimhester/gmailr")
```

## Features ##
- retrieve data from your email
  - drafts: `my_drafts = drafts()`
  - history: `my_history = history(start_num)`
  - labels: `my_labels = labels()`
  - messages: `my_messages = messages("search query")`
  - threads: `my_threads = threads("search query")`
- Create and send emails and drafts: see [sending_messages vignette](https://github.com/jimhester/gmailr/blob/master/vignettes/sending_messages.Rmd)
- manage email labels programmatically: `modify_thread(thread_id, add_labels=c("label_1"), remove_labels=c("label_2"))`
- put things in the gmail trash
  - messages: `trash_message(message_id)`
  - threads: `trash_thread(thread_id)`
- take things out of the gmail trash
  - messages: `untrash_message(message_id)`
  - threads: `untrash_thread(thread_id)`
- delete directly without using the trash
  - messages: `delete_message(message_id)`
  - threads: `delete_thread(thread_id)`

## Setup ##

By default gmailr will use a global project.  However if you are going to be a heavy user and will do a lot of queries _please_ setup your own project with the steps below. This often works best via Google Chrome.

* Pick a project name; referred to as `PROJ-NAME` from now on.
* Register a new project at <https://console.developers.google.com/project>.
* From Overview screen, look at Google Apps APIs and select the Gmail API. Enable it.
* Click "Go to Credentials" or navigate directly to Credentials.
* You want a get a client ID and will need to "Configure consent screen".
  - The email should be pre-filled. Enter `PROJ-NAME` as Product name. Other fields can be left blank.
* Returning to the "client id" process:
  - Application Type: "Other"
  - Enter `PROJ-NAME` again as the name.
  - Click "Create"
* Client id and secret will appear in a pop-up which you can dismiss via "OK". Instead use download icon at far right of your project's listing to download a JSON file with all of this info. Move to an appropriate location and consider renaming as `PROJ-NAME.json`.
* Use the downloaded JSON file as input to `use_secret_file()`, prior to other `gmailr` calls.

```R
use_secret_file('PROJ-NAME.json')
```

## Future Work ##

- More unit tests and better coverage
- More (complicated) examples
- Email statistics
- Programmatic emailing
- Returning data frames in addition to native Gmail API objects which are usually a nested list.
- Support all the formats of [users.messages:get](https://developers.google.com/gmail/api/v1/reference/users/messages/get)

# Examples #
- [Send Email with R](https://github.com/jennybc/send-email-with-r) - Jenny Bryan (@jennybc)
- [Gmail Stats](https://github.com/alkashef/gmailstats) - Ahmad Al-Kashef (@alkashef)
