#' Create a mime formatted message object
#'
#' These functions create a MIME message. They can be created atomically using
#' `gm_mime()` or iteratively using the various accessors.
#' @param body Message body.
#' @param attr attributes to pass to the message
#' @param parts mime parts to pass to the message
#' @family mime
#' @export
#' @examples
#' # using the field functions
#' msg <- gm_mime() |>
#'   gm_from("james.f.hester@gmail.com") |>
#'   gm_to("asdf@asdf.com") |>
#'   gm_text_body("Test Message")
#'
#' # alternatively you can set the fields using gm_mime(), however you have
#' #  to use properly formatted MIME names
#' msg <- gm_mime(
#'   From = "james.f.hester@gmail.com",
#'   To = "asdf@asdf.com"
#' ) |>
#'   gm_html_body("<b>Test<\b> Message")
gm_mime <- function(..., attr = NULL, body = NULL, parts = list()) {
  structure(list(
    parts = parts,
    header = with_defaults(
      c("MIME-Version" = "1.0"),
      Date = http_date(Sys.time()),
      ...
    ),
    body = body, attr = attr
  ), class = "mime")
}

#' @param x the object whose fields you are setting
#' @param val the value to set, can be a vector, in which case the values will be joined by ", ".
#' @rdname gm_mime
#' @export
gm_to.mime <- function(x, val, ...) {
  if (missing(val)) {
    return(x$header$To)
  }
  x$header$To <- val
  x
}

#' @rdname gm_mime
#' @export
gm_from.mime <- function(x, val, ...) {
  if (missing(val)) {
    return(x$header$From)
  }
  x$header$From <- val
  x
}

#' @rdname gm_mime
#' @export
gm_cc.mime <- function(x, val, ...) {
  if (missing(val)) {
    return(x$header$Cc)
  }
  x$header$Cc <- val
  x
}

#' @rdname gm_mime
#' @export
gm_bcc.mime <- function(x, val, ...) {
  if (missing(val)) {
    return(x$header$Bcc)
  }
  x$header$Bcc <- val
  x
}

#' @rdname gm_mime
#' @export
gm_subject.mime <- function(x, val, ...) {
  if (missing(val)) {
    return(x$header$Subject)
  }
  x$header$Subject <- val
  x
}

#' @param mime message.
#' @param content_type The content type to use for the body.
#' @param charset The character set to use for the body.
#' @param encoding The transfer encoding to use for the body.
#' @param format The mime format to use for the body.
#' @param ... additional parameters to put in the attr field
#' @rdname gm_mime
#' @export
gm_text_body <- function(mime,
                         body,
                         content_type = "text/plain",
                         charset = "utf-8",
                         encoding = "quoted-printable",
                         format = "flowed",
                         ...) {
  if (missing(body)) {
    return(mime$parts[[TEXT_PART]])
  }
  mime$parts[[TEXT_PART]] <- gm_mime(
    attr = list(
      content_type = content_type,
      charset = charset,
      encoding = encoding,
      format = format,
      ...
    ),
    body = body
  )
  mime
}

TEXT_PART <- 1L

#' @rdname gm_mime
#' @export
gm_html_body <- function(mime,
                         body,
                         content_type = "text/html",
                         charset = "utf-8",
                         encoding = "base64",
                         ...) {
  if (missing(body)) {
    return(mime$parts[[HTML_PART]])
  }
  mime$parts[[HTML_PART]] <- gm_mime(
    attr = list(
      content_type = content_type,
      charset = charset,
      encoding = encoding,
      ...
    ),
    body = body
  )
  mime
}

HTML_PART <- 2L

#' @param part Message part to attach
#' @param filename name of file to attach
#' @param type mime type of the attached file
#' @param id The content ID of the attachment
#' @rdname gm_mime
#' @export
gm_attach_part <- function(mime, part, id = NULL, ...) {
  if (missing(part)) {
    return(mime$parts[[3L:length(mime$parts)]])
  }
  part_num <- if (length(mime$parts) < 3L) 3L else length(mime$parts) + 1L
  part <- gm_mime(attr = c(encoding = "base64", list(...)), body = part)
  if (!is.null(id)) {
    part$header[["Content-Id"]] <- sprintf("<%s>", id)
  }
  mime$parts[[part_num]] <- part
  mime
}

#' @rdname gm_mime
#' @export
gm_attach_file <- function(mime, filename, type = NULL, id = NULL, ...) {
  if (missing(filename)) {
    return(mime$parts[[3L:length(mime$parts)]])
  }

  if (is.null(type)) {
    type <- mime::guess_type(filename, empty = NULL)
  }

  con <- file(filename, "rb")
  info <- file.info(filename)
  body <- readBin(con, "raw", info$size)
  close(con)

  base_name <- basename(filename)

  gm_attach_part(mime, body,
    content_type = type,
    name = base_name,
    filename = base_name,
    disposition = "attachment",
    # modification_date = http_date(info$mtime),
    id = id,
    ...
  )
}

header_encode <- function(x) {
  x <- enc2utf8(unlist(strsplit(as.character(x), ", ?")))

  # this won't deal with <> used in quotes, but I think it is rare enough that
  # is ok
  m <- rematch2::re_match(x, "^(?<phrase>[^<]*?)(?: *<(?<addr_spec>[^>]+)>)?$")
  res <- character(length(x))

  # simple addresses contain no <>, so we don't need to do anything further
  simple <- !nzchar(m$addr_spec)
  res[simple] <- m$phrase[simple]

  # complex addresses may need to be base64-encoded
  needs_encoding <- Encoding(m$phrase) != "unknown"
  res[needs_encoding] <- sprintf("=?utf-8?B?%s?=", vcapply(m$phrase[needs_encoding], encode_base64))
  res[!needs_encoding] <- m$phrase[!needs_encoding]

  # Add the addr_spec onto non-simple examples
  res[!simple] <- sprintf("%s <%s>", res[!simple], m$addr_spec[!simple])

  paste0(res, collapse = ", ")
}

#' Convert a mime object to character representation
#'
#' This function converts a mime object into a character vector
#'
#' @param x object to convert
#' @param newline value to use as newline character
#' @param ... further arguments ignored
#' @export
as.character.mime <- function(x, newline = "\r\n", ...) {
  # encode headers
  x$header <- lapply(x$header, header_encode)

  # if we have both the text part and html part, we have to embed them in a multipart/alternative message
  if (x$attr$content_type %!=% "multipart/alternative" && exists_list(x$parts, TEXT_PART) && exists_list(x$parts, HTML_PART)) {
    x$attr$content_type <- "multipart/alternative"
  }

  # if a multipart message
  if (length(x$parts) > 0L) {
    x$attr$content_type <- x$attr$content_type %||% "multipart/mixed"

    # random hex boundary if multipart, otherwise nothing
    boundary <- x$attr$boundary <- random_hex(32)

    # sep is --boundary newline if multipart, otherwise newline
    sep <- paste0(newline, "--", boundary, newline)

    # end is --boundary-- if mulitpart, otherwise nothing
    end <- paste0(newline, "--", boundary, "--", newline)

    body_text <- paste0(collapse = sep, Filter(function(x) length(x) > 0L, c(lapply(x$parts, as.character), x$body)))
  } else {
    boundary <- NULL
    sep <- newline
    end <- newline

    body_text <- x$body
  }

  x$header$"Content-Type" <- parse_content_type(x$attr)
  x$header$"Content-Transfer-Encoding" <- x$attr$encoding
  x$header$"Content-Disposition" <- generate_content_disposition(x$attr)

  encoding <- x$attr$encoding %||% ""

  encoded_body <- switch(encoding,
    "base64" = encode_base64(body_text, 76L, newline),
    "quoted-printable" = quoted_printable_encode(body_text),
    body_text
  )
  headers <- format_headers(x$header, newline = newline)

  paste0(headers, sep, encoded_body, end)
}

parse_content_type <- function(header) {
  paste0(
    header$content_type %||% "text/plain",
    header$charset %|||% paste0("; charset=", header$charset),
    header$format %|||% paste0("; format=", header$format),
    header$name %|||% paste0("; name=", header$name),
    header$boundary %|||% paste0("; boundary=", header$boundary)
  )
}

generate_content_disposition <- function(header) {
  if (is.null(header$disposition)) {
    return(NULL)
  }

  paste0(
    header$disposition,
    header$filename %|||% paste0("; filename=", header$filename)
    # header$modification_date %|||% paste0("; modification-date=", header$modification_date)
  )
}

random_hex <- function(width = 4) {
  paste(sprintf("%x", sample(16, size = width, replace = TRUE) - 1L), collapse = "")
}

format_headers <- function(headers, newline) {
  empty <- vapply(headers, function(x) {
    is.null(x) || length(x) %==% 0L
  }, logical(1L))
  keep_headers <- headers[!empty]
  if (length(keep_headers) %==% 0L) {
    return(NULL)
  }
  paste0(paste(sep = ": ", collapse = newline, names(keep_headers), keep_headers), newline)
}

with_defaults <- function(defaults, ...) {
  args <- list(...)
  missing <- setdiff(names(defaults), names(args))
  c(defaults[missing], args)
}
