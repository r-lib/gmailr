# Get the id of a gmailr object

Get the id of a gmailr object

## Usage

``` r
gm_id(x, ...)

# S3 method for class 'gmail_messages'
gm_id(x, what = c("message_id", "thread_id"), ...)
```

## Arguments

- x:

  the object from which to retrieve the id

- ...:

  other parameters passed to methods

- what:

  the type of id to return

## Examples

``` r
if (FALSE) { # \dontrun{
gm_id(my_message)
gm_id(my_draft)
} # }
```
