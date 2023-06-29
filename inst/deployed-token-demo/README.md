This is an example of how to deploy a gmailr OAuth user token, for use in a Shiny app or similar.

This topic is also covered in the gmailr vignette "Deploy a token" (<https://gmailr.r-lib.org/articles/deploy-a-token.html>).

## Interactive setup

The [`token-setup.R`](token-setup.R) script contains setup code that must be run interactively, in your primary computing environment.

This code should NOT be executed in the deployed data product.
There's no reason for this code to even be part of the deployment.

`token-setup.R` stores the token in the file `.secrets/gmailr-token.rds`.

This approach relies on an encryption key, which you would create with `gargle::secret_make_key()`, and then store as an the environment variable (`"GMAILR_DEPLOY_DEMO_KEY"`, in this example).
Locally, you probably want to define this env var in your user-level `.Renviron` file.
`usethis::edit_r_environ()` is a handy way to access that.
Remember that changes to `.Renviron` don't take effect until you restart R.

`token-setup.R` is code that you run once.
Or, more realistically, you run it "every now and then".
There are various reasons why the cached token might become invalid and, therefore, non-refreshable. 
In that case, you should obtain a new token interactively and re-deploy.

## Deployed product

[`send-email-byo-encrypted-token.Rmd`](send-email-byo-encrypted-token.Rmd) is a Shiny document.
The intent is to show how a deployed Shiny application could use an encrypted user token to send email with gmailr.

This chunk (attempts to) read the stored, encrypted token from file and tells gmailr to use it.

```r
library(gmailr)

try(
  gm_auth(token = gm_token_read(
    ".secrets/gmailr-token.rds",
    key = "GMAILR_DEPLOY_DEMO_KEY"
  ))
)
```

For this to work, the encryption key must be available as a (secure) environment variable named `"GMAILR_DEPLOY_DEMO_KEY"` in the deployed environment.

From that point on, the gmailr usage is completely routine.

When deploying, it is important that all of these files are included:

* `send-email-byo-encrypted-token.Rmd` or, in general, the code that creates the
  Shiny app
* `.secrets/gmailr-token.rds` or, in general, the file that holds the stored,
  encrypted user token
