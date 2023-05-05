test_that("MIME - Basic functions", {
  # Create a new Email::Stuffer object
  msg <- gm_mime()
  expect_equal(class(msg), "mime", label = "msg object has correct class")

  expect_true(length(msg$header) > 0, label = "Even the default object has headers")

  rv <- gm_to(msg, "adam@ali.as")
  expect_equal(header_encode(rv$header$To), "adam@ali.as", label = "to sets To Header")

  rv <- gm_from(msg, "bob@ali.as")
  expect_equal(header_encode(rv$header$From), "bob@ali.as", label = "from sets From Header")

  rv <- gm_to(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(header_encode(rv$header$To), "adam@ali.as, another@ali.as, bob@ali.as", label = "to (multiple) sets To header")

  rv <- gm_cc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(header_encode(rv$header$Cc), "adam@ali.as, another@ali.as, bob@ali.as", label = "cc (multiple) sets To header")

  rv <- gm_bcc(msg, c("adam@ali.as", "another@ali.as", "bob@ali.as"))
  expect_equal(header_encode(rv$header$Bcc), "adam@ali.as, another@ali.as, bob@ali.as", label = "bcc (multiple) sets To header")
})

test_that("header_encode encodes non-ascii values as base64", {
  expect_equal(header_encode("f\U00F6\U00F6"), "=?utf-8?B?ZsO2w7Y=?=")

  expect_equal(header_encode('"f\U00F6\U00F6 b\U00Er1" <baz@qux.com>'), "=?utf-8?B?ImbDtsO2IGIOcjEi?= <baz@qux.com>")

  res <- header_encode(
    c(
      '"f\U00F6\U00F6 b\U00E1r" <baz@qux.com>',
      '"foo bar" <foo.bar@baz.com>',
      "qux@baz.com",
      '"q\U00FBx " <qux@foo.com>'
    )
  )

  expect_equal(res, "=?utf-8?B?ImbDtsO2IGLDoXIi?= <baz@qux.com>, \"foo bar\" <foo.bar@baz.com>, qux@baz.com, =?utf-8?B?InHDu3ggIg==?= <qux@foo.com>")
})

test_that("MIME - More Complex", {
  msg <- gm_mime()
  msg <- gm_from(msg, "Jim Hester<james.f.hester@gmail.com>")
  msg <- gm_to(msg, "james.f.hester@gmail.com")
  msg <- gm_subject(msg, "Hello To:!")
  msg <- gm_text_body(msg, "I am an email")

  msg1 <- gm_attach_file(msg, test_path("fixtures", "volcano.png"))

  msg1_chr <- as.character(msg1)

  expect_match(msg1_chr, "Jim Hester", label = "Email contains from name")
  expect_match(msg1_chr, "gmail", label = "Email contains to string")
  expect_match(msg1_chr, "Hello", label = "Email contains subject string")
  expect_match(msg1_chr, "I am an email", label = "Email contains text_body")
  expect_match(msg1_chr, "volcano", label = "Email contains file name")

  msg2 <- gm_attach_file(
    msg,
    test_path("fixtures", "test.ini"),
    content_type = "text/plain"
  )

  msg2_chr <- as.character(msg2)

  expect_match(msg2_chr, "Jim Hester", label = "Email contains from name")
  expect_match(msg2_chr, "gmail", label = "Email contains to string")
  expect_match(msg2_chr, "Hello", label = "Email contains subject string")
  expect_match(msg2_chr, "I am an email", label = "Email contains text_body")
  expect_match(msg2_chr, "Content-Type: application/octet-stream; name=test\\.ini", label = "Email contains attachment Content-Type")

  msg3 <- gm_html_body(msg, "I am an html email<br>")
  msg3 <- gm_attach_file(
    msg3,
    test_path("fixtures", "test.ini"),
    content_type = "application/octet-stream"
  )

  msg3_chr <- as.character(msg3)

  expect_match(msg3_chr, "Jim Hester", label = "Email contains from name")
  expect_match(msg3_chr, "gmail", label = "Email contains to string")
  expect_match(msg3_chr, "Hello", label = "Email contains subject string")
  expect_match(msg3_chr, "I am an email", label = "Email contains text_body")
  expect_match(msg3_chr, base64url_encode("I am an html email<br>"), label = "Email contains html_body")
  expect_match(msg3_chr, "Content-Type: application/octet-stream; name=test\\.ini", label = "Email contains attachment Content-Type")

  skip_if_no_token()
  for (email in c(msg1_chr, msg2_chr, msg3_chr)) {
    expect_no_error({
      draft <- gm_create_draft(email)
      gm_delete_draft(gm_id(draft))
    })
  }
})

test_that("MIME - Alternative emails contain correct parts", {
  msg <- gm_mime()
  msg <- gm_from(msg, "Jim Hester<james.f.hester@gmail.com>")
  msg <- gm_to(msg, "james.f.hester@gmail.com")
  msg <- gm_subject(msg, "Hello To:!")
  msg <- gm_text_body(msg, "I am an email")
  msg <- gm_html_body(msg, "<b>I am a html email</b>")

  email_chr <- as.character(msg)

  expect_match(email_chr, "Jim Hester", label = "Email contains from name")
  expect_match(email_chr, "james.f.hester", label = "Email contains to string")
  expect_match(email_chr, "Hello", label = "Email contains subject string")
  expect_match(email_chr, "Content-Type: multipart/alternative", label = "Email content type")
  expect_match(email_chr, "Content-Type: text/plain", label = "Email content type")
  expect_match(email_chr, "Content-Type: text/html", label = "Email content type")

  expect_match(email_chr, quoted_printable_encode("I am an email"), label = "Email contains text body")
  expect_match(email_chr, base64encode(charToRaw("<b>I am a html email</b>")), fixed = TRUE, label = "Email contains html body")
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
