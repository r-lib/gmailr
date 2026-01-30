# Retrieve change history for the inbox

Retrieves the history results in chronological order

## Usage

``` r
gm_history(
  start_history_id = NULL,
  num_results = NULL,
  label_id = NULL,
  page_token = NULL,
  user_id = "me"
)
```

## Arguments

- start_history_id:

  the point to start the history. The historyId can be obtained from a
  message, thread or previous list response.

- num_results:

  the number of results to return, max per page is 100

- label_id:

  filter history only for this label

- page_token:

  retrieve a specific page of results

- user_id:

  gmail user_id to access, special value of 'me' indicates the
  authenticated user.

## References

<https://developers.google.com/gmail/api/reference/rest/v1/users.history/list>

## Examples

``` r
if (FALSE) { # \dontrun{
my_history <- gm_history("10")
} # }
```
