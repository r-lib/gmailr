skip_unless_authenticated <- function() {
  if (!is.null(tryCatch(gm_oauth_app(), error = function(e) NULL))) {
    return()
  }

  gm_auth_configure()
  gm_auth(cache = TRUE, use_oob = FALSE)

  if (is.null(gm_oauth_app())) {
    skip("not authenticated")
  }
}
