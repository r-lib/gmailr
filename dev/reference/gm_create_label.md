# Create a new label

Function to create a label.

## Usage

``` r
gm_create_label(
  name,
  label_list_visibility = c("show", "hide", "show_unread"),
  message_list_visibility = c("show", "hide"),
  user_id = "me"
)
```

## Arguments

- name:

  name to give to the new label

- label_list_visibility:

  The visibility of the label in the label list in the Gmail web
  interface.

- message_list_visibility:

  The visibility of messages with this label in the message list in the
  Gmail web interface.

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.labels/create>

## See also

Other label:
[`gm_delete_label()`](https://gmailr.r-lib.org/dev/reference/gm_delete_label.md),
[`gm_label()`](https://gmailr.r-lib.org/dev/reference/gm_label.md),
[`gm_labels()`](https://gmailr.r-lib.org/dev/reference/gm_labels.md),
[`gm_update_label()`](https://gmailr.r-lib.org/dev/reference/gm_update_label.md)
