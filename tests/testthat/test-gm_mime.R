test_that("MIME - Basic functions", {
  msg <- gm_mime()
  expect_s3_class(msg, "mime")
  expect_true(length(msg$header) > 0)

  rv <- gm_to(msg, "adam@ali.as")
  expect_equal(header_encode_address(rv$header$To), "adam@ali.as")

  rv <- gm_from(msg, "bob@ali.as")
  expect_equal(header_encode_address(rv$header$From), "bob@ali.as")

  rv <- gm_to(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode_address(rv$header$To),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )

  rv <- gm_cc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode_address(rv$header$Cc),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )

  rv <- gm_bcc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode_address(rv$header$Bcc),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )
})

test_that("header_encode_address encodes non-ascii values as base64", {
  expect_equal(header_encode_address("f\U00F6\U00F6"), "=?utf-8?B?ZsO2w7Y=?=")

  expect_equal(
    header_encode_address('"f\U00F6\U00F6 b\U00Er1" <baz@qux.com>'),
    "=?utf-8?B?ImbDtsO2IGIOcjEi?= <baz@qux.com>"
  )

  res <- header_encode_address(
    c(
      '"f\U00F6\U00F6 b\U00E1r" <baz@qux.com>',
      '"foo bar" <foo.bar@baz.com>',
      "qux@baz.com",
      '"q\U00FBx " <qux@foo.com>'
    )
  )

  expect_equal(
    res,
    "=?utf-8?B?ImbDtsO2IGLDoXIi?= <baz@qux.com>, \"foo bar\" <foo.bar@baz.com>, qux@baz.com, =?utf-8?B?InHDu3ggIg==?= <qux@foo.com>"
  )
})

test_that("MIME - More Complex", {
  msg <- gm_mime() |>
    gm_from("Gargle Testuser <gargle-testuser@posit.co>") |>
    gm_to("jenny+gmailr-tests@posit.co") |>
    gm_subject("Hello To:!") |>
    gm_text_body("I am an email")

  # Text body with PNG attachment
  msg1 <- msg |> gm_attach_file(test_path("fixtures", "volcano.png"))
  msg1_chr <- as.character(msg1)
  expect_match(msg1_chr, "Gargle Testuser")
  expect_match(msg1_chr, "posit")
  expect_match(msg1_chr, "Hello")
  expect_match(msg1_chr, "I am an email")
  expect_match(msg1_chr, "volcano")

  # Text body with text attachment
  msg2 <- msg |>
    gm_attach_file(
      test_path("fixtures", "test.ini"),
      content_type = "text/plain"
    )
  msg2_chr <- as.character(msg2)
  expect_match(msg2_chr, "I am an email")
  expect_match(
    msg2_chr,
    "Content-Type: application/octet-stream; name=test\\.ini"
  )

  # Text + HTML body with attachment
  msg3 <- msg |>
    gm_html_body("<p>I am an <strong>html</strong> email</p>") |>
    gm_attach_file(
      test_path("fixtures", "test.ini"),
      content_type = "application/octet-stream"
    )
  msg3_chr <- as.character(msg3)
  expect_match(msg3_chr, "I am an email")
  expect_match(
    msg3_chr,
    base64encode(charToRaw("<p>I am an <strong>html</strong> email</p>")),
    fixed = TRUE
  )
  expect_match(
    msg3_chr,
    "Content-Type: application/octet-stream; name=test\\.ini"
  )

  skip_if_no_token()
  for (email in c(msg1_chr, msg2_chr, msg3_chr)) {
    expect_no_error({
      draft <- gm_create_draft(email)
      gm_delete_draft(gm_id(draft))
    })
  }
})

test_that("MIME - Alternative emails contain correct parts", {
  msg <- gm_mime() |>
    gm_from("test@example.com") |>
    gm_to("user@example.com") |>
    gm_subject("Hello!") |>
    gm_text_body("I am an email") |>
    gm_html_body("<b>I am a html email</b>")

  email_chr <- as.character(msg)

  expect_match(email_chr, "test@example\\.com")
  expect_match(email_chr, "user@example\\.com")
  expect_match(email_chr, "Hello")
  expect_match(email_chr, "Content-Type: multipart/alternative")
  expect_match(email_chr, "Content-Type: text/plain")
  expect_match(email_chr, "Content-Type: text/html")
  expect_match(email_chr, quoted_printable_encode("I am an email"))
  expect_match(
    email_chr,
    base64encode(charToRaw("<b>I am a html email</b>")),
    fixed = TRUE
  )
})

test_that("MIME - Messages with attachments and alternative bodies", {
  # Test 1: text + HTML + attachment should have nested structure
  msg1 <- gm_mime() |>
    gm_from("test@example.com") |>
    gm_to("user@example.com") |>
    gm_subject("Test with attachment") |>
    gm_text_body("Plain text version") |>
    gm_html_body("<b>HTML version</b>") |>
    gm_attach_file(test_path("fixtures", "volcano.png"))

  msg1_chr <- as.character(msg1)

  # Verify outer is multipart/mixed
  expect_match(msg1_chr, "Content-Type: multipart/mixed")
  # Verify nested multipart/alternative exists
  expect_match(msg1_chr, "Content-Type: multipart/alternative")
  # Verify all parts present
  expect_match(msg1_chr, "Plain text version")
  expect_match(
    msg1_chr,
    base64encode(charToRaw("<b>HTML version</b>")),
    fixed = TRUE
  )
  expect_match(msg1_chr, "volcano\\.png")

  # Test 2: text + HTML + text attachment
  # https://github.com/r-lib/gmailr/issues/202
  msg2 <- gm_mime() |>
    gm_from("test@example.com") |>
    gm_to("user@example.com") |>
    gm_subject("Test with text attachment") |>
    gm_text_body("Email body text") |>
    gm_html_body("<p>Email body HTML</p>") |>
    gm_attach_file(test_path("fixtures", "test.ini"))

  msg2_chr <- as.character(msg2)

  expect_match(msg2_chr, "Content-Type: multipart/mixed")
  expect_match(msg2_chr, "Content-Type: multipart/alternative")
  expect_match(msg2_chr, "Email body text")
  expect_match(
    msg2_chr,
    base64encode(charToRaw("<p>Email body HTML</p>")),
    fixed = TRUE
  )
  expect_match(msg2_chr, "test\\.ini")

  # Test 3: text only + attachment (no HTML) should be flat multipart/mixed
  msg3 <- gm_mime() |>
    gm_from("test@example.com") |>
    gm_to("user@example.com") |>
    gm_subject("Text only with attachment") |>
    gm_text_body("Just plain text") |>
    gm_attach_file(test_path("fixtures", "volcano.png"))

  msg3_chr <- as.character(msg3)

  expect_match(msg3_chr, "Content-Type: multipart/mixed")
  # Should NOT have multipart/alternative since there's no HTML
  expect_false(grepl("multipart/alternative", msg3_chr))

  # Test 4: Multiple attachments
  msg4 <- gm_mime() |>
    gm_from("test@example.com") |>
    gm_to("user@example.com") |>
    gm_subject("Multiple attachments") |>
    gm_text_body("Text body") |>
    gm_html_body("<b>HTML body</b>") |>
    gm_attach_file(test_path("fixtures", "test.ini")) |>
    gm_attach_file(test_path("fixtures", "volcano.png"))

  msg4_chr <- as.character(msg4)

  expect_match(msg4_chr, "Content-Type: multipart/mixed")
  expect_match(msg4_chr, "Content-Type: multipart/alternative")
  expect_match(msg4_chr, "test\\.ini")
  expect_match(msg4_chr, "volcano\\.png")
})

test_that("plain ascii should not be encoded", {
  expect_match(
    "quoted_printable",
    quoted_printable_encode("quoted_printable")
  )
})

test_that("trailing space should be encoded", {
  expect_equal(
    "=20=20",
    quoted_printable_encode("  ")
  )
  expect_equal(
    "\tt=09",
    quoted_printable_encode("\tt\t")
  )
  expect_equal(
    "test=20=20\ntest\n=09=20=09=20\n",
    quoted_printable_encode("test  \ntest\n\t \t \n")
  )
})
test_that("\"=\" is special an should be decoded", {
  expect_equal(
    "=3D30\n",
    quoted_printable_encode("=30\n")
  )
})
test_that("trailing whitespace", {
  expect_equal(
    "foo=20=09=20",
    quoted_printable_encode("foo \t ")
  )
  expect_equal(
    "foo=09=20\n=20=09",
    quoted_printable_encode("foo\t \n \t")
  )
})

test_that("header_encode_text() passes ASCII-only text through", {
  ascii_subject <- "This is a plain ASCII subject"
  result <- header_encode_text(ascii_subject)
  expect_equal(result, ascii_subject)

  long_ascii <- strrep("a", 100)
  result <- header_encode_text(long_ascii)
  expect_equal(result, long_ascii)
})

test_that("header_encode_text() encodes short Unicode text", {
  # Short subject with Unicode that fits in single encoded-word
  short_unicode <- "Hello \u00E1\u00E9\u00ED\u00F3\u00FA"
  result <- header_encode_text(short_unicode)

  # Should not contain CRLF (no folding)
  expect_no_match(result, "\r\n", fixed = TRUE)
  # Should be a single encoded-word
  expect_match(result, "^=[?]utf-8[?]B[?][A-Za-z0-9+/=]+[?]=$")
  # Should be within RFC 2047 limit
  expect_lte(nchar(result), 75)
})

# https://github.com/r-lib/gmailr/issues/193
test_that("header_encode_text() folds long non-ASCII text", {
  long_subject <- paste0("\u00E1", strrep("a", 54), "\u00E1")
  result <- header_encode_text(long_subject)

  # Should contain CRLF SPACE (folded into multiple encoded-words)
  expect_match(result, "\r\n ", fixed = TRUE)

  # Each line should be an encoded-word within RFC 2047 limit
  lines <- strsplit(result, "\r\n ", fixed = TRUE)[[1]]
  expect_gt(length(lines), 1)
  for (line in lines) {
    expect_lte(nchar(line), 75)
    expect_match(line, "^=[?]utf-8[?]B[?][A-Za-z0-9+/=]+[?]=$")
  }
})

test_that("header_encode_text() roundtrip: encode then decode", {
  # this is to make sure we break up the encoded-text in chunks of 4 characters
  original <- "\U0001F389\U0001F38A\U0001F388 C\u00E9l\u00E9bration extraordinaire \u00E0 Z\u00FCrich! \U0001F973\U0001F382\U0001F37E Join us for a tr\u00E8s sp\u00E9cial soir\u00E9e! \U0001F942\U0001F377\U0001F95C"
  encoded <- header_encode_text(original)

  encoded_words <- strsplit(encoded, "\r\n ", fixed = TRUE)[[1]]
  encoded_text <- sub("[?]=$", "", sub("^=[?]utf-8[?]B[?]", "", encoded_words))

  # Decode each chunk separately (to verify each is valid base64), then concatenate
  decoded <- rawToChar(unlist(lapply(encoded_text, base64decode)))
  Encoding(decoded) <- "UTF-8"
  expect_equal(decoded, original)
})

test_that("gm_subject() uses proper encoding in full MIME message", {
  # Long subject - should be folded
  long_subject <- paste0("\u00E1", strrep("a", 100), "\u00E1")
  msg_long <- gm_mime() |>
    gm_to("test@example.com") |>
    gm_subject(long_subject) |>
    gm_text_body("Body")

  msg_long_chr <- as.character(msg_long)

  # The subject should span multiple lines with proper folding
  expect_match(
    msg_long_chr,
    "Subject: =[?]utf-8[?]B[?][A-Za-z0-9+/=]+[?]=\r\n =[?]utf-8[?]B[?]"
  )
})
