# Sending Messages With Gmailr

``` r
library(gmailr)
```

## Constructing a MIME message

### Text

First we will construct a simple text only message

``` r
text_msg <- gm_mime() |>
  gm_to("james.f.hester@gmail.com") |>
  gm_from("me@somewhere.com") |>
  gm_text_body("Gmailr is a very handy package!")
```

You can convert the message to a properly formatted MIME message using
[`as.character()`](https://rdrr.io/r/base/character.html).

``` r
strwrap(as.character(text_msg))
#> [1] "MIME-Version: 1.0\r Date: Fri, 30 Jan 2026 16:21:41 GMT\r To:"    
#> [2] "james.f.hester@gmail.com\r From: me@somewhere.com\r Content-Type:"
#> [3] "multipart/mixed; boundary=c6be45eee35844e7ec1d6ada44bc15ee\r"     
#> [4] "--c6be45eee35844e7ec1d6ada44bc15ee\r MIME-Version: 1.0\r Date:"   
#> [5] "Fri, 30 Jan 2026 16:21:41 GMT\r Content-Type: text/plain;"        
#> [6] "charset=utf-8; format=flowed\r Content-Transfer-Encoding:"        
#> [7] "quoted-printable\r Gmailr is a very handy package!\r"             
#> [8] "--c6be45eee35844e7ec1d6ada44bc15ee--\r"
```

### HTML

You can also construct html messages. It is customary to provide a text
only message along with the html message, but with modern email clients
this is not strictly necessary.

``` r
html_msg <- gm_mime() |>
  gm_to("james.f.hester@gmail.com") |>
  gm_from("me@somewhere.com") |>
  gm_html_body("<b>Gmailr</b> is a <i>very</i> handy package!")
```

### Attachments

You can add attachments to your message in two ways.

1.  If the data is in a file, use
    [`gm_attach_file()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md).
    The mime type is automatically guessed by
    [`mime::guess_type`](https://rdrr.io/pkg/mime/man/guess_type.html),
    or you can specify it yourself with the `type` parameter.

``` r
write.csv(file = "iris.csv", iris)

msg <- html_msg |>
  gm_subject("Here are some flowers") |>
  gm_attach_file("iris.csv")
```

2.  If the data are already loaded into R, you can use
    [`gm_attach_part()`](https://gmailr.r-lib.org/dev/reference/gm_mime.md)
    to attach the binary data to your file.

``` r
msg <- html_msg |>
  gm_attach_part(part = charToRaw("attach me!"), name = "please")
```

### Including images

You can also add use attached images in HTML by setting the Content ID
feature of mime emails. This can be done by referencing the image via a
`<img src=cid:xyz>` tag using the `id` argument of `send_file()`. The
tag value can by any unique identifier. E.g. here is an example of
including a ggplot2 image

``` r
# First create a plot to send, and save it to mtcars.png
mtcars$gear <- as.factor(mtcars$gear)

png("mtcars.png", width = 400, height = 400, pointsize = 12)
with(
  mtcars,
  plot(hp,
    mpg,
    col = as.factor(gear),
    pch = 19,
    xlab = "Horsepower",
    ylab = "Miles / gallon"
  )
)
legend("topright",
  title = "# gears",
  pch = 19,
  col = seq_along(levels(mtcars$gear)),
  legend = levels(mtcars$gear)
)
dev.off()
#> agg_png 
#>       2

# Next create an HTML email that references the plot as 'foobar'
email <- gm_mime() |>
  gm_to("someaddress@somewhere.com") |>
  gm_from("someaddress@somewhere.com") |>
  gm_subject("Cars report") |>
  gm_html_body(
    '<h1>A plot of <b>MotorTrend</b> data <i>(1974)</i></h1>
    <br><img src="cid:foobar">'
  ) |>
  gm_attach_file("mtcars.png", id = "foobar")
```

## Uploading

### Create Draft

You can upload any mime message into your gmail drafts using
[`gm_create_draft()`](https://gmailr.r-lib.org/dev/reference/gm_create_draft.md).
Be sure to give yourself at least `compose` permissions first.

``` r
gm_create_draft(file_attachment)
```

### Insert

This inserts the message directly into your mailbox, bypassing gmail’s
default scanning and classification algorithms.

``` r
gm_insert_message(file_attachment)
```

### Import

This imports the email as though it was a normal message, with the same
scanning and classification as normal email.

``` r
gm_import_message(file_attachment)
```

## Sending

### Draft

[`gm_send_draft()`](https://gmailr.r-lib.org/dev/reference/gm_send_draft.md)
sends an email using the `draft_id` of an existing draft (possibly
created with
[`gm_create_draft()`](https://gmailr.r-lib.org/dev/reference/gm_create_draft.md)).

``` r
my_drafts <- gm_drafts()

gm_send_draft(gm_id(my_drafts, "draft_id")[1])
```

### Message

You can also send an email message directly from a `mime` object using
[`gm_send_message()`](https://gmailr.r-lib.org/dev/reference/gm_send_message.md).

``` r
gm_send_message(file_attachment)
```

## Troubleshooting

### Gmail API error 400: Mail service not enabled

It is possible to have a high-functioning Google account that does not
have Gmail enabled. For example, your account might be fully operational
with respect to Google Drive and yet have no mail capabilities. Such an
account cannot be used with the Gmail API and therefore with `gmailr`.
However, you will still be able to complete the `gmailr` authorization
process via
[`gm_auth()`](https://gmailr.r-lib.org/dev/reference/gm_auth.md). The
problem will only reveal itself upon the first attempt to use the API
and it will look something like this:

     Error in gmailr_POST(c("messages", "send"), user_id, class = "gmail_message",  :
      Gmail API error: 400
      Mail service not enabled

You can confirm the account’s lack of mail capability by visiting
`https://mail.google.com/mail/` while logged in. If you don’t already
have Gmail, this link gives you the option of adding mail to your
existing account or creating a new, mail-capable account.
