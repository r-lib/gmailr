#' Create a mime formatted message object
#'
#' These functions create a MIME message. They can be created atomically using
#' `mime()` or iteratively using the various accessors.
#' @param body Message body.
#' @param attr attributes to pass to the message
#' @param parts mime parts to pass to the message
#' @family mime
#' @export
#' @examples
#' # using the field functions
#' msg = mime() %>%
#'  from("james.f.hester@@gmail.com") %>%
#'  to("asdf@asdf.com") %>%
#'  text_body("Test Message")
#'
#' # alternatively you can set the fields using mime(), however you have
#' #  to use properly formatted MIME names
#' msg = mime(From="james.f.hester@@gmail.com",
#'                    To="asdf@asdf.com") %>%
#'         html_body("<b>Test<\b> Message")
mime <- function(..., attr = NULL, body = NULL, parts = list()) {
  structure(list(parts = parts,
                 header = with_defaults(c("MIME-Version" = "1.0",
                          Date = http_date(Sys.time())),
                          ...),
                 body = body, attr = attr), class="mime")
}

#' @param x the object whose fields you are setting
#' @param val the value to set
#' @param vals one or more values to use, will be joined by commas
#' @rdname mime
#' @export
to.mime <- function(x, vals, ...){
  if(missing(vals)){ return(x$header$To) }
  x$header$To <- paste0(collapse = ", ", vals)
  x
}

#' @rdname mime
#' @export
from.mime <- function(x, val, ...){
  if(missing(val)){ return(x$header$From) }
  x$header$From <- val
  x
}

#' @rdname mime
#' @export
cc.mime <- function(x, vals, ...){
  if(missing(vals)){ return(x$header$Cc) }
  x$header$Cc <- paste0(collapse = ", ", vals)
  x
}

#' @rdname mime
#' @export
bcc.mime <- function(x, vals, ...){
  if(missing(vals)){ return(x$header$Bcc) }
  x$header$Bcc <- paste0(collapse = ", ", vals)
  x
}

#' @rdname mime
#' @export
subject.mime <- function(x, val, ...){
  if(missing(val)){ return(x$header$Subject) }
  x$header$Subject <- val
  x
}

#' @param mime message.
#' @param ... additional parameters to put in the attr field
#' @rdname mime
#' @export
text_body <- function(mime, body, ...){
  if(missing(body)){ return(mime$parts[[TEXT_PART]]) }
  mime$parts[[TEXT_PART]] <- mime(attr = list(
              content_type = "text/plain",
              charset      = "utf-8",
              encoding     = "quoted-printable",
              format       = "flowed",
              ...),
              body = body)
  mime
}
TEXT_PART <- 1L

#' @rdname mime
#' @export
html_body <- function(mime, body, ...){
  if(missing(body)){ return(mime$parts[[HTML_PART]]) }
  mime$parts[[HTML_PART]] <- mime(attr = list(
                         content_type = "text/html",
                         charset      = "utf-8",
                         encoding     = "base64",
                         ...),
                         body = body)
  mime
}
HTML_PART <- 2L

#' @param part Message part to attach
#' @param filename name of file to attach
#' @param type mime type of the attached file
#' @rdname mime
#' @export
attach_part <- function(mime, part, ...){
  if(missing(part)){ return(mime$parts[[3L:length(mime$parts)]]) }
  part_num <- if(length(mime$parts) < 3L) 3L else length(mime$parts) + 1L
  mime$parts[[part_num]] <- mime(attr = c(encoding = "base64", list(...)),
                                body = part)
  mime
}

#' @rdname mime
#' @export
attach_file <- function(mime, filename, type = NULL, ...){
  if(missing(filename)){ return(mime$parts[[3L:length(mime$parts)]]) }

  if (is.null(type)) {
    type <- mime::guess_type(filename, empty = NULL)
  }

  con <- file(filename, "rb")
  info <- file.info(filename)
  body <- readBin(con, "raw", info$size)
  close(con)

  base_name <- basename(filename)

  attach_part(mime, body,
         content_type = type,
         name = base_name,
         filename = base_name,
         modification_date = http_date(info$mtime),
         ...)
}

#' Convert a mime object to character representation
#'
#' This function converts a mime object into a character vector
#'
#' @param x object to convert
#' @param newline value to use as newline character
#' @param ... futher arguments ignored
#' @export
as.character.mime <- function(x, newline="\r\n", ...) {

  # if we have both the text part and html part, we have to embed them in a multipart/alternative message
  if(x$attr$content_type %!=% "multipart/alternative" && exists_list(x$parts, TEXT_PART) && exists_list(x$parts, HTML_PART)){
    new_msg <- mime(attr = list(content_type = "multipart/alternative"),
                   parts = c(x$parts[TEXT_PART], x$parts[HTML_PART]))
    x$parts[TEXT_PART] <- list(NULL)
    x$parts[HTML_PART] <- list(NULL)
    x$parts[[1]] <- new_msg
  }

  # if a multipart message
  if(length(x$parts) > 0L){

    x$attr$content_type <- x$attr$content_type %||% "multipart/mixed"

    # random hex boundary if multipart, otherwise nothing
    boundary <- x$attr$boundary <- random_hex(32)

    # sep is --boundary newline if multipart, otherwise newline
    sep <- paste0("--", boundary, newline)

    # end is --boundary-- if mulitpart, otherwise nothing
    end <- paste0("--", boundary, "--", newline)

    body_text <- paste0(collapse=sep, Filter(function(x) length(x) > 0L, c(lapply(x$parts, as.character), x$body)))
  }
  else {
    boundary <- NULL
    sep <- newline
    end <- newline

    body_text <- x$body
  }

  x$header$"Content-Type" <- parse_content_type(x$attr)
  x$header$"Content-Transfer-Encoding" <- x$attr$encoding
  x$header$"Content-Disposition" <- parse_content_disposition(x$attr)

  encoding <- x$attr$encoding %||% ""

  encoded_body <- switch(encoding,
    "base64" = encode_base64(body_text, 76L, newline),
    "quoted-printable" = quoted_printable_encode(body_text),
    body_text
  )
  headers <- format_headers(x$header, newline = newline)

  paste0(headers, encoded_body, end)
}

parse_content_type <- function(header) {
  paste0(header$content_type %||% "text/plain",
         header$charset %|||% paste0("; charset=", header$charset),
         header$format %|||% paste0("; format=", header$format),
         header$name %|||% paste0("; name=", header$name),
         header$boundary %|||% paste0("; boundary=", header$boundary)
         )
}

parse_content_disposition <- function(header) {
  paste0(header$disposition %||% "inline",
         header$filename %|||% paste0("; filename=", header$filename),
         header$modification_date %|||% paste0("; modification-date=", header$modification_date))
}

random_hex <- function(width = 4) {
  paste(sprintf("%x", sample(16, size = width, replace = TRUE) - 1L), collapse="")
}

format_headers <- function(headers, newline) {
  empty <- vapply(headers, function(x) { is.null(x) || length(x) %==% 0L }, logical(1L))
  keep_headers <- headers[!empty]
  if(length(keep_headers) %==% 0L){
    return(NULL)
  }
  paste0(paste(sep = ": ", collapse = newline, names(keep_headers), keep_headers), newline, newline)
}

with_defaults <- function(defaults, ...){
  args <- list(...)
  missing <- setdiff(names(defaults), names(args))
  c(defaults[missing], args)
}
