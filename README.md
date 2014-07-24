# gmailr #
Easily exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

## Features ##
- Retrieve data from your email
  - drafts: `drafts()`
  - history: `history(start_num)`
  - labels: `labels()`
  - messages: `messages("search query")`
  - threads: `threads("search query")`
- manage email labels programmatically: `modify_thread(thread_id, add_labels="label_1")`
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
This package is still in the rough stages, so getting it setup is a bit of a pain. The steps to do so are detailed below.

1. Register an application at https://cloud.google.com/console#/project
   - create a new client ID and download the resulting JSON
   - read your client_id and secret from `file.json`

  ```s
  info = fromJSON(readChar('file.json', nchars=100000))
  myapp = oauth_app("google", info$installed$client_id, info$installed$client_secret)
  ```
2. Get OAuth credentials

  ```s
  google_token = oauth2.0_token(oauth_endpoints("google"), myapp,
    scope = "https://www.googleapis.com/auth/gmail.readonly")
  ```

## Usage ##

Retrieve first 10 email threads matching R

```s
r_threads = threads('R', 10)
```
