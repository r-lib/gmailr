# Response from the last query

gmailr now uses
[`gargle::response_process()`](https://gargle.r-lib.org/reference/response_process.html)
to process responses, so
[`gargle::gargle_last_response()`](https://gargle.r-lib.org/reference/gargle_last_response.html)
can and should be used for *post mortem* analysis, instead of
`gm_last_response()`. One benefit of this switch is that auth tokens are
redacted in the stored response.

## Usage

``` r
gm_last_response()
```

## Details

**\[deprecated\]**
