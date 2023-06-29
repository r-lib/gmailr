# This is setup that you run interactively once (or occasionally), to obtain a
# token.
# This code should not run in the deployed setting.
# This code does not need to be deployed at all.

library(gmailr)

# create a folder for the auth-related files
dir.create(".secrets")

# configure the oauth client, if the desired client is not rigged for
# auto-discovery
gm_auth_configure(path = "path/to/your/oauth-client.json")

# confirm the above worked, if you wish to
gm_oauth_client()

# do interactive auth as the target user; do not cache the token
# if you want non-default scopes, do that here via gm_auth(scopes =)
gm_auth("user@example.com", cache = FALSE)

# confirm you are logged in with the intended identity
gm_profile()

# encrypt the token and write to file
# for `key`, substitute the name of YOUR environment variable
gm_token_write(
  path = ".secrets/gmailr-token.rds",
  key = "GMAILR_DEPLOY_DEMO_KEY"
)

# the token file should be in the cache now
list.files(".secrets/")

# check that the `.rds` file can't be read by normal means
# this should be an error
readRDS(".secrets/gmailr-token.rds")

# THE TOKEN SETUP IS DONE!
