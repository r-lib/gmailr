# gmailr #

[![Build Status](https://travis-ci.org/jimhester/gmailr.png?branch=master)](https://travis-ci.org/jimhester/gmailr)
[![Coverage Status](https://img.shields.io/coveralls/jimhester/gmailr.svg)](https://coveralls.io/r/jimhester/gmailr)

Exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

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

By default gmailr will use a global project.  However if you are going to be
doing a heavy user and will do a lot of queries _please_ setup your own project
with the steps below.

- Register a new project at https://console.cloud.google.com
- Navigate to `APIs`
  - Switch the Gmail API status to `On`, and other API status to `Off`
- Navigate to `APIs & auth->Consent screen`
  - Name your application
  - Select an email address for the application
  - Other fields can be left blank
- Navigate to `APIs & auth->Credentials`
  - Create a new client ID
    - Application Type: Installed Application
    - Installed Application Type: Other
  - Download the Client ID JSON - can be renamed!
- Use the downloaded JSON file as input to `gmail_auth()`

      ```R
      gmail_auth('file.json')
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
