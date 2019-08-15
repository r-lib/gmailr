#' Encode text using quoted printable
#'
#' Does no do any line wrapping of the output to 76 characters
#' Implementation derived from the perl MIME::QuotedPrint
#' @param data data to encode
#' @references <http://search.cpan.org/~gaas/MIME-Base64-3.14/QuotedPrint.pm>
#' @export
quoted_printable_encode <- function(data){
  # All printable ASCII characters (decimal values between 33 and 126) may be represented by themselves, except "=" (decimal 61).
  res <- substitute_regex(data,
                   "([^ \t\n!\"#$%&'()*+,\\-./0123456789:;<>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz\\{|\\}~])",
                   function(x) sprintf("=%02X", ord(x)),
                   perl = TRUE
                   )
  res <- substitute_regex(res,
                         "([ \t]+)(?=\n|$)",
                   function(x) paste0(sprintf("=%02X", ord(x)), collapse=""),
                   perl = TRUE
                   )
  res
}

