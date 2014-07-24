# gmailr #
Easily exposing the [Gmail API](https://developers.google.com/gmail/api/overview) from R.

## Features ##
- retrieve data from your email
  - drafts
  - history
  - labels
  - messages
  - threads
- manage email labels programmatically
- put mail in the gmail trash and remove it
- delete mail without sending to the trash

## Setup ##
This package is still in the rough stages, so getting it setup is a bit of a pain. The steps to do so are detailed below.

1. Setup the oauth endpoint

  ```s
  oauth_endpoints("google")
  ```
2. Register an application at https://cloud.google.com/console#/project
   - create a new client ID and download the resulting JSON
   - read your client_id and secret from `file.json`

  ```s
  info = fromJSON(readChar('file.json', nchars=100000))
  myapp <- oauth_app("google", info$installed$client_id, info$installed$client_secret)
  ```
3. Get OAuth credentials

  ```s
  google_token <- oauth2.0_token(oauth_endpoints("google"), myapp,
    scope = "https://www.googleapis.com/auth/gmail.readonly")
  ```

## Usage ##

Retrieve first 10 email threads matching R

```s
r_threads = threads('R', 10)
```
