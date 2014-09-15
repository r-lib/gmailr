#' Create a mime formatted message object
#'
#' @param ... You can set header values initially, or use
#' \code{\link{common_fields}} set functions to set them after object creation.
#' @export
#' @seealso \code{\link{common_fields}}, \code{\link{body}}
#' @examples
#' # using the field functions
#' msg = mime_message() %>%
#'  from("james.f.hester@@gmail.com") %>%
#'  to("CRAN@@R-project.org") %>%
#'  text_body("Please don't reject my package")
#'
#' # alternatively you can set the fields using mime_message, however you hav()e
#' #  to use properly formatted MIME names
#' msg = mime_message(From="james.f.hester@@gmail.com",
#'                    To="CRAN@@R-project.org") %>%
#'         html_body("<b>Please<\b> don't reject my package")
mime_message = function(...) {
  structure(list(parts = list(),
                 header=with_defaults(c("MIME-Version" = "1.0",
                          Date = http_date(Sys.time())),
                          ...)), class='mime_message')
}

#' Accessor functions for mime messages
#' @param x the object whose fields you are setting
#' @param val the value to set
#' @param vals one or more values to use, will be joined by commas
#' @param ... other arguments ignored
#' @rdname common_fields
#' @export
to.mime_message = function(x, vals, ...){
  if(missing(vals)){ return(x$header$To) }
  x$header$To = paste0(collapse=", ", vals)
  x
}

#' @name common_fields
#' @rdname common_fields
#' @export
from.mime_message = function(x, val, ...){
  if(missing(val)){ return(x$header$From) }
  x$header$From = val
  x
}
#' @rdname common_fields
#' @export
cc = function(x, vals, ...){
  if(missing(vals)){ return(x$header$Cc) }
  x$header$Cc = paste0(collapse=", ", vals)
  x
}

#' @rdname common_fields
#' @export
bcc = function(x, vals, ...){
  if(missing(vals)){ return(x$header$Bcc) }
  x$header$Bcc = paste0(collapse=", ", vals)
  x
}

#' @rdname common_fields
#' @export
subject.mime_message = function(x, val, ...){
  if(missing(val)){ return(x$header$Subject) }
  x$header$Subject = val
  x
}

#' Add a text or html body to a mime message
#'
#' if called without a body returns the current body
#' @param mime message to add the body to
#' @param body the body to add to the message
#' @param ... additional parameters to put in the attr field
#' @rdname mime_body
#' @export
text_body = function(mime, body, ...){
  if(missing(body)){ return(mime$parts[[1]]) }
  attr = with_defaults(c(
              content_type = 'text/plain',
              charset      = 'utf-8',
              encoding     = 'quoted-printable',
              format       = 'flowed'
              ), ...)
  mime$parts[[1]] =
    structure(list(
                   body   = body,
                   attr = attr,
                   header = list()
                  ),
              class = 'mime_part')
  mime
}

#' @rdname mime_body
#' @export
html_body = function(mime, body, ...){
  if(missing(body)){ return(mime$parts[[2]]) }
  attr = with_defaults(c(
              content_type = 'text/html',
              charset      = 'utf-8',
              encoding     = 'base64'
              ), ...)
  mime$parts[[2]] =
    structure(list(
                   body   = body,
                   attr = attr,
                   header = list()
                  ),
              class = 'mime_part')
  mime
}

#' Attach an object to a mime message
#' @rdname attach
#' @param mime object to attach to
#' @param body data to attach
#' @param filename name of file to attach
#' @param type mime type of the attached file
#' @param ... additional arguments put into the attr field of the object
#' @export
attach_part = function(mime, body, ...){
  if(missing(body)){ return(mime$parts[[3:length(mime$parts)]]) }
  attr = with_defaults(c(
              encoding = 'base64',
              NULL
              ), ...)
  part_num = if(length(mime$parts) < 3) 3 else length(mime$parts) + 1
  mime$parts[[part_num]] =
    structure(list(
                   body   = body,
                   attr = attr
                  ),
              class = 'mime_part')
  mime
}

#' @rdname attach
#' @export
attach_file = function(mime, filename, type = guess_media(filename), ...){
  if(missing(filename)){ return(mime$parts[[3:length(mime$parts)]]) }
  con = file(filename, "rb")
  info = file.info(filename)
  body = readBin(con, "raw", info$size)
  close(con)

  base_name = basename(filename)

  attach_part(mime, body,
         content_type = type,
         name = base_name,
         filename = base_name,
         modification_date = http_date(info$mtime),
         ...)
}

#' Convert a mime object to character representation
#'
#' These functions convert a mime object into the final mime character
#' representation.
#' @param x object to convert
#' @param ... additional arguments ignored
#' @rdname as.character.mime
#' @export
as.character.mime_message = function(x, ...) {
  if(length(x$parts) > 1){
    boundary = random_hex(32)
    x$attr$boundary = boundary
    sep = paste0('--', boundary, '\r\n')
    end = paste0('--', boundary, '--')
    if(length(x$parts) == 2){
      x$attr$content_type = x$attr$content_type %||% "multipart/alternative"
    }
    else {
      x$attr$content_type = x$attr$content_type %||% "multipart/mixed"
    }
    x$header$"Content-Type" = parse_content_type(x$attr)
  }
  else {
    x$parts[[1]]$header = do.call(with_defaults, list(c(defaults=x$parts[[1]]$header, x$header)))
    return(as.character(x$parts[[1]]))
  }
  body = paste0(collapse=sep, Filter(function(x) length(x) > 0L, lapply(x$parts, as.character )))
  paste0(paste(names(x$header), x$header, sep=': ', collapse='\r\n'), '\r\n\r\n', sep, body, end)
}

#' @rdname as.character.mime
#' @export
as.character.mime_part = function(x,...) {
  x$header$"Content-Type" = parse_content_type(x$attr)
  x$header$"Content-Transfer-Encoding" = x$attr$encoding
  x$header$"Content-Disposition" = parse_content_disposition(x$attr)
  encoding = x$attr$encoding %||% ''
  body = switch(encoding,
    'base64' = if(is.raw(x$body)) base64encode(x$body, 76L, '\r\n') else base64encode(charToRaw(x$body), 76L, '\r\n'),
    'quoted-printable' = quoted_printable_encode(x$body),
    x$body
    )
  paste0(paste(sep=': ', names(x$header), x$header, collapse='\r\n'), '\r\n\r\n', body, '\r\n')
}

parse_content_type = function(header) {
  paste0(header$content_type %||% 'text/plain',
         header$charset %|||% paste0('; charset=', header$charset),
         header$format %|||% paste0('; format=', header$format),
         header$name %|||% paste0('; name=', header$name),
         header$boundary %|||% paste0('; boundary=', header$boundary)
         )
}

parse_content_disposition = function(header) {
  paste0(header$disposition %||% 'inline',
         header$filename %|||% paste0('; filename=', header$filename),
         header$modification_date %|||% paste0('; modification-date=', header$modification_date))
}

random_hex = function(width=4) {
  paste(sprintf("%x", sample(16, size=width, replace=TRUE) - 1), collapse="")
}

format_headers = function(...) {
  headers = list(...)
  empty = vapply(headers, function(x) { is.null(x) || length(x) == 0 }, logical(1))
  keep_headers = headers[!empty]
  if(length(keep_headers) == 0){
    return(NULL)
  }
  paste0(paste(sep=": ", collapse="\r\n", names(keep_headers), keep_headers), '\r\n')
}

with_defaults = function(defaults, ...){
  args = list(...)
  missing = setdiff(names(defaults), names(args))
  c(defaults[missing], args)
}

