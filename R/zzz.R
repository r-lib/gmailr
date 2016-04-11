is_number <- function(x) {
  is.numeric(x) || tryCatch(as.numeric(x), warning = function(e) FALSE)
}

is_string <- function(x, allow_na = FALSE) {
  is.character(x) && length(x) == 1 && (allow_na || !is.na(x))
}

is_strings <- function(x, allow_na = FALSE) {
  is.character(x) && length(x) > 0 && (allow_na || all(!is.na(x)))
}

is_boolean <- function(x) {
  is.logical(x) && length(x) > 0
}

has_class <- function(x, class) {
  if (isNamespaceLoaded("methods")) {
    methods::is(x, class)
  } else {
    inherits(x, class)
  }
}

nullable <- function(fun) {
  function(x, ...) {
    is.null(x) || fun(x, ...)
  }
}

valid_path <- function(path) {
  is_string(path) && dir.exists(path)
}
