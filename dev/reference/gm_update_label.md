# Update a existing label.

Get a specific label by id and user_id. `gm_update_label_patch()` is
identical to `gm_update_label()` but the latter uses [HTTP
PATCH](https://datatracker.ietf.org/doc/html/rfc5789) to allow partial
update.

## Usage

``` r
gm_update_label(id, label, user_id = "me")

gm_update_label_patch(id, label, user_id = "me")
```

## Arguments

- id:

  label id to update

- label:

  the label fields to update

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.labels/update>

<https://developers.google.com/gmail/api/reference/rest/v1/users.labels/patch>

## See also

Other label:
[`gm_create_label()`](https://gmailr.r-lib.org/dev/reference/gm_create_label.md),
[`gm_delete_label()`](https://gmailr.r-lib.org/dev/reference/gm_delete_label.md),
[`gm_label()`](https://gmailr.r-lib.org/dev/reference/gm_label.md),
[`gm_labels()`](https://gmailr.r-lib.org/dev/reference/gm_labels.md)

Other label:
[`gm_create_label()`](https://gmailr.r-lib.org/dev/reference/gm_create_label.md),
[`gm_delete_label()`](https://gmailr.r-lib.org/dev/reference/gm_delete_label.md),
[`gm_label()`](https://gmailr.r-lib.org/dev/reference/gm_label.md),
[`gm_labels()`](https://gmailr.r-lib.org/dev/reference/gm_labels.md)
