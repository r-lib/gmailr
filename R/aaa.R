the <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {

  .auth <<- gargle::init_AuthState(
    package     = "gmailr",
    auth_active = TRUE
  )
}
