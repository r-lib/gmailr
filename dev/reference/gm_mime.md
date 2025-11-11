# Create a mime formatted message object

These functions create a MIME message. They can be created atomically
using `gm_mime()` or iteratively using the various accessors.

## Usage

``` r
gm_mime(..., attr = NULL, body = NULL, parts = list())

# S3 method for class 'mime'
gm_to(x, val, ...)

# S3 method for class 'mime'
gm_from(x, val, ...)

# S3 method for class 'mime'
gm_cc(x, val, ...)

# S3 method for class 'mime'
gm_bcc(x, val, ...)

# S3 method for class 'mime'
gm_subject(x, val, ...)

gm_text_body(
  mime,
  body,
  content_type = "text/plain",
  charset = "utf-8",
  encoding = "quoted-printable",
  format = "flowed",
  ...
)

gm_html_body(
  mime,
  body,
  content_type = "text/html",
  charset = "utf-8",
  encoding = "base64",
  ...
)

gm_attach_part(mime, part, id = NULL, ...)

gm_attach_file(mime, filename, type = NULL, id = NULL, ...)
```

## Arguments

- ...:

  additional parameters to put in the attr field

- attr:

  attributes to pass to the message

- body:

  Message body.

- parts:

  mime parts to pass to the message

- x:

  the object whose fields you are setting

- val:

  the value to set, can be a vector, in which case the values will be
  joined by ", ".

- mime:

  message.

- content_type:

  The content type to use for the body.

- charset:

  The character set to use for the body.

- encoding:

  The transfer encoding to use for the body.

- format:

  The mime format to use for the body.

- part:

  Message part to attach

- id:

  The content ID of the attachment

- filename:

  name of file to attach

- type:

  mime type of the attached file

## Examples

``` r
# using the field functions
msg <- gm_mime() |>
  gm_to("asdf@asdf.com") |>
  gm_text_body("Test Message")

# alternatively you can set the fields using gm_mime(), however you have
#  to use properly formatted MIME names
msg <- gm_mime(
  From = "james.f.hester@gmail.com",
  To = "asdf@asdf.com"
) |>
  gm_html_body("<b>Test<\b> Message")

# send to multiple recipients
msg <- gm_mime() |>
  gm_to(c("alice@example.com", "bob@example.com")) |>
  gm_text_body("hello to multiple people at once!")
```
