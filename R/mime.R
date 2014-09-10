random_hex = function(width=4) {
  paste(sprintf("%x", sample(16, size=width, replace=TRUE) - 1), collapse="")
}

format_headers = function(x) {
  paste0(paste(sep=": ", collapse="\r\n", names(x), x), '\r\n', '\r\n')
}
#' Create a mime formatted message
#' @export
mime_message = function(from, to, subject, ...){
  boundary = random_hex(32)

  parts = list(...)

  types = vector(length = length(parts), mode='list')
  texts = vapply(parts, inherits, logical(1), "character")
  htmls = vapply(parts, inherits, logical(1), "html")
  types[texts] = format_headers(c("Content-Type" = "text/plain; charset=UTF-8"))
  types[htmls] = format_headers(c("Content-Type" = "text/html; charset=UTF-8"))
  paste0(
    format_headers(c(
                     "MIME-Version" = "1.0",
                     Date = http_date(Sys.time()),
                     From = paste(from, sep=', '),
                     To = paste(to, sep=', '),
                     Subject = paste(subject, sep=', '),
                     "Content-Type" = paste0("multipart/mixed; boundary=", boundary))),
        "--", boundary, "\r\n",
        paste0(types, parts, "\r\n\r\n", collapse=paste0("--", boundary, "\r\n")),
        paste0("--", boundary, "--")
        )
}
