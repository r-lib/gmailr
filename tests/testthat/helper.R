skip_unless_authenticated <- function() {
  maybe_app <- function() {
    tryCatch(gm_oauth_app(), error = function(e) NULL)
  }

  if (!is.null(maybe_app())) {
    return()
  }

  tryCatch(
    expr = {
      gm_auth_configure()
      gm_auth(cache = TRUE, use_oob = FALSE)
    },
    error = function(e) e
  )

  if (is.null(maybe_app())) {
    skip("not authenticated")
  }
}
