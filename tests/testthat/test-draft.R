test_that("create_draft, drafts, draft and send_draft", {
  skip_if_no_token()

  my_email <- Sys.getenv("GMAILR_EMAIL")

  mail <- gm_mime(To = my_email, Subject="hello", body = "how are you doing?")

  d1 <- gm_create_draft(mail)
  all_ds <- gm_drafts()

  expect_equal(gm_id(all_ds)[[1]], gm_id(d1))

  d2 <- gm_draft(gm_id(d1))
  expect_equal(gm_id(d2), gm_id(d1))

  expect_equal(gm_to(d2), my_email)
  expect_equal(gm_subject(d2), "hello")
  expect_equal(gm_body(d2), "how are you doing?\r\n")

  m1 <- gm_send_draft(d2)
  msg1 <- gm_message(gm_id(m1))

  expect_true("SENT" %in% msg1$labelIds)
})
