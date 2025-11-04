test_that("MIME - Basic functions", {
  msg <- gm_mime()
  expect_s3_class(msg, "mime")
  expect_true(length(msg$header) > 0)

  rv <- gm_to(msg, "adam@ali.as")
  expect_equal(header_encode(rv$header$To), "adam@ali.as")

  rv <- gm_from(msg, "bob@ali.as")
  expect_equal(header_encode(rv$header$From), "bob@ali.as")

  rv <- gm_to(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode(rv$header$To),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )

  rv <- gm_cc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode(rv$header$Cc),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )

  rv <- gm_bcc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(
    header_encode(rv$header$Bcc),
    "adam@ali.as, another@ali.as, bob@ali.as"
  )
})

test_that("header_encode encodes non-ascii values as base64", {
  expect_equal(header_encode("f\U00F6\U00F6"), "=?utf-8?B?ZsO2w7Y=?=")

  expect_equal(
    header_encode('"f\U00F6\U00F6 b\U00Er1" <baz@qux.com>'),
    "=?utf-8?B?ImbDtsO2IGIOcjEi?= <baz@qux.com>"
  )

  res <- header_encode(
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
