# gmailr

``` r
library(gmailr)
```

## OAuth client

In order to use gmailr, you **must** provide your own OAuth client. The
article [Set up an OAuth
client](https://gmailr.r-lib.org/dev/articles/oauth-client.html)
explains how to obtain an OAuth client and how to configure it for
gmailr’s use. The help topics for
[`?gm_auth_configure`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md)
and
[`?gm_default_oauth_client`](https://gmailr.r-lib.org/dev/reference/gmailr-configuration.md)
will also be useful.

Unless you have reason to do otherwise, my recommendation is to place
the JSON file for your OAuth client in the default location, so that it
is discovered automatically. The default location is returned by
`rappdirs::user_data_dir("gmailr")`. Alternatively, you can also make
autodiscovery work by exposing the client’s JSON filepath as the
`GMAILR_OAUTH_CLIENT` environment variable. If your client is configured
for auto-discovery, your gmailr code should “just work”, without any
explicit configuration around the client:

``` r
library(gmailr)

# your gmailr code ...
```

Otherwise, your code must always include a call to
[`gm_auth_configure()`](https://gmailr.r-lib.org/dev/reference/gm_auth_configure.md),
probably right after you attach gmailr:

``` r
library(gmailr)
gm_auth_configure("path/to/your/oauth_client.json")

# your gmailr code ...
```

## Auth

Configuring an OAuth client is step 1 of 2 for getting ready to use
gmailr. Step 2 is to complete the so-called “OAuth dance”.

For most folks and especially in early usage, you can just allow the
OAuth dance to be triggered automatically upon first need. You are taken
to a web browser, where you must select or login as the Google user you
want to use (authenticate yourself) and give your OAuth client
permission to do Gmail stuff on your behalf (authorize). The OAuth dance
does not need to be repeated in subsequent sessions, because, by
default, your credentials are cached locally and can be refreshed.

If, however, you want to take more control over auth, you can call
[`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md)
explicitly and proactively. The arguments that are most useful in
practice are:

- `email`: Use this to specify the target user. This can be useful if
  you have a cached token and you want code to run without an attempt to
  get interactive confirmation that it’s OK to use it.
- `scopes`: Following the principle of least privilege, if you have no
  intention of sending email, it could be wise to deliberately use a
  token with a “read only” scope.
- `token`: In a deployed setting, it can be useful to directly provide a
  stored token to gmailr. This use case is documented in
  `vignettes("deploy-a-token")`.

Here’s how a script might begin if the OAuth client can’t be
auto-discovered and the user needs to request non-default behaviour from
[`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md):

``` r
library(gmailr)
gm_auth_configure("path/to/your/oauth_client.json")

gm_auth(
  "target.user@example.com",
  scopes = "gmail.readonly",
  cache = "some/nice/directory/"
)
```

[`gm_profile()`](https://gmailr.r-lib.org/dev/reference/gm_profile.md)
is a handy function to confirm that gmailr is using the intended Google
identity.

``` r
gm_profile()
#> Logged in as:
#>   * email: gargle-testuser@posit.co
#>   * num_messages: 154
#>   * num_threads: 154
```

## Compose and send an email

Create a new email with
[`gm_mime()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md) and
then build it up from parts, using helper functions like
[`gm_to()`](https://gmailr.r-lib.org/dev/reference/accessors.md) and
[`gm_subject()`](https://gmailr.r-lib.org/dev/reference/accessors.md).

``` r
test_email <-
  gm_mime() |>
  gm_to("PUT_A_VALID_EMAIL_ADDRESS_THAT_YOU_CAN_CHECK_HERE") |>
  gm_subject("this is just a gmailr test") |>
  gm_text_body("Can you hear me now?")
```

You can even add a file attachment with
[`gm_attach_file()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md):

``` r
tmp <- tempfile("mtcars-", fileext = ".csv")
write.csv(mtcars, tmp)
test_email <- gm_attach_file(test_email, tmp)
```

When developing a message, it’s a good idea to first create a draft with
[`gm_create_draft()`](https://gmailr.r-lib.org/dev/reference/gm_create_draft.md)
Then you can visit your Gmail drafts in the browser and confirm that the
message content and formatting is as you intend.

``` r
d <- gm_create_draft(test_email)
```

If you’re happy, you can either send that draft from the web UI or with
[`gm_send_draft()`](https://gmailr.r-lib.org/dev/reference/gm_send_draft.md):

``` r
gm_send_draft(d)
#> Draft Id: 19c0fb5bbb89e6f3 
#> NULL
```

Or you can send the original MIME message with
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md):

``` r
gm_send_message(test_email)
```

## Read email

You can retrieve email threads with
[`gm_threads()`](https://gmailr.r-lib.org/dev/reference/gm_threads.md):

``` r
my_threads <- gm_threads(num_results = 10)
```

You can retrieve a specific thread with
[`gm_thread()`](https://gmailr.r-lib.org/dev/reference/gm_thread.md):

``` r
# retrieve the latest thread by retrieving the first ID
latest_thread <- gm_thread(gm_id(my_threads)[[1]])
```

The messages in `latest_thread` are stored as a list. You can then
isolate a specific message and access its parts.

``` r
my_msg <- latest_thread$messages[[1]]

gm_date(my_msg)
#> [1] "Fri, 30 Jan 2026 08:21:34 -0800"
gm_subject(my_msg)
#> [1] "this is just a gmailr test"
gm_body(my_msg)
#> [[1]]
#> [1] "Can you hear me now?\r\n"
```

If a message has attachments, you can download them all locally with
[`gm_save_attachments()`](https://gmailr.r-lib.org/dev/reference/gm_save_attachments.md):

``` r
tmp2 <- tempfile("attachments-")
dir.create(tmp2)
gm_save_attachments(my_msg, path = tmp2)

# let's take a peek
tmp2 |>
  list.files(full.names = TRUE, pattern = "[.]csv$") |>
  read.csv() |>
  head()
#>                   X  mpg cyl disp  hp drat    wt  qsec vs am gear carb
#> 1         Mazda RX4 21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
#> 2     Mazda RX4 Wag 21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
#> 3        Datsun 710 22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
#> 4    Hornet 4 Drive 21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
#> 5 Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
#> 6           Valiant 18.1   6  225 105 2.76 3.460 20.22  1  0    3    1
```

## Quota

The Gmail API is free to use for modest levels of activity. To learn
more about Gmail API quotas see
<https://developers.google.com/gmail/api/reference/quota>.
