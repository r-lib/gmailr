# Get a list of all labels

Get a list of all labels for a user.

## Usage

``` r
gm_labels(user_id = "me")
```

## Arguments

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.labels/list>

## See also

Other label:
[`gm_create_label()`](https://gmailr.r-lib.org/reference/gm_create_label.md),
[`gm_delete_label()`](https://gmailr.r-lib.org/reference/gm_delete_label.md),
[`gm_label()`](https://gmailr.r-lib.org/reference/gm_label.md),
[`gm_update_label()`](https://gmailr.r-lib.org/reference/gm_update_label.md)

## Examples

``` r
if (FALSE) { # \dontrun{
my_labels <- gm_labels()
} # }
```
