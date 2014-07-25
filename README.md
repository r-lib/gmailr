# gmailr #
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

Register an application at https://cloud.google.com/console#/project
  - create a new client ID and download the resulting JSON
  - authorize the application using `gmail_auth()`

      ```R
      gmail_auth('file.json')
      ```
