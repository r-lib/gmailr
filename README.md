# gmailr #

[![Build Status](https://travis-ci.org/jimhester/gmailr.png?branch=master)](https://travis-ci.org/jimhester/gmailr)

Easily exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

## Features ##
- retrieve data from your email
  - drafts: `my_drafts = drafts()`
  - history: `my_history = history(start_num)`
  - labels: `my_labels = labels()`
  - messages: `my_messages = messages("search query")`
  - threads: `my_threads = threads("search query")`
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

- Register a new project at https://cloud.google.com/console#/project
- Navigate to `APIs`
  - Switch the Gmail API status to `On`
- Navigate to `APIs & auth->Credentials`
  - Create a new client ID
  - Download the Client ID JSON
- Use the downloaded JSON as input to `gmail_auth()`

      ```R
      gmail_auth('file.json')
      ```
