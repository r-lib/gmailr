# Permanently delete a label

Function to delete a label by id. This cannot be undone!

## Usage

``` r
gm_delete_label(id, user_id = "me")
```

## Arguments

- id:

  label id to retrieve

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.labels/delete>

## See also

Other label:
[`gm_create_label()`](https://gmailr.r-lib.org/reference/gm_create_label.md),
[`gm_label()`](https://gmailr.r-lib.org/reference/gm_label.md),
[`gm_labels()`](https://gmailr.r-lib.org/reference/gm_labels.md),
[`gm_update_label()`](https://gmailr.r-lib.org/reference/gm_update_label.md)
