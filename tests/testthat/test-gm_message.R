test_that("messages and message work", {
  skip_if_no_token()

  msgs <- gm_messages()
  expect_s3_class(msgs, "gmail_messages")

  ids <- gm_id(msgs)
  expect_true(length(ids) > 0)

  msg <- gm_message(ids[[1]])

  expect_equal(gm_id(msg), ids[[1]])

  expect_true(nzchar(gm_to(msg)))
  expect_true(nzchar(gm_from(msg)))
  expect_true(nzchar(gm_date(msg)))
  expect_true(nzchar(gm_subject(msg)))
  expect_true(nzchar(gm_body(msg)))
})

test_that("messages and message work", {
  skip_if_no_token()

  msgs <- gm_messages()
  expect_s3_class(msgs, "gmail_messages")

  ids <- gm_id(msgs)
  expect_true(length(ids) > 0)

  msg <- gm_message(ids[[1]])

  expect_equal(gm_id(msg), ids[[1]])

  expect_true(nzchar(gm_to(msg)))
  expect_true(nzchar(gm_from(msg)))
  expect_true(nzchar(gm_date(msg)))
  expect_true(nzchar(gm_subject(msg)))
  expect_true(nzchar(gm_body(msg)))
})

test_that("gm_import_message() works", {
  skip_if_no_token()

  msg_out <- gm_mime(
    From = "you@me.com",
    To = "any@one.com",
    Subject = "hello from gm_import_message()",
    body = "how are you doing?"
  )
  res <- gm_import_message(msg_out, label_ids = NULL)
  new_id <- gm_id(res)

  # even after successful message import, the "standard email delivery scanning
  # and classification" that comes with `users.messages.import` can take
  # several minutes
  # therefore, the new message can't be addressed immediately
  # that applies to getting it and to deleting it
  # for now, I'm just going to comment out the code we wish we could run

  # on.exit(gm_delete_message(new_id))

  expect_type(new_id, "character")

  # msg <- gm_message(new_id)
  # expect_equal(gm_id(msg), new_id)
  # expect_equal(gm_to(msg), "any@one.com")
  # expect_equal(gm_from(msg), "you@me.com")
  # expect_equal(gm_subject(msg), "hello")
  # expect_equal(gm_body(msg), "how are you doing?\r\n")
})

test_that("insert_message, modify_message, trash_message and untrash_message work", {
  skip_if_no_token()

  new_id <- gm_id(gm_insert_message(
    gm_mime(
      From = "you@me.com",
      To = "any@one.com",
      Subject = "hello",
      body = "how are you doing?"
    ),
    label_ids = NULL
  ))
  msg <- gm_message(new_id)

  expect_equal(gm_id(msg), new_id)
  expect_equal(gm_to(msg), "any@one.com")
  expect_equal(gm_from(msg), "you@me.com")
  expect_equal(gm_subject(msg), "hello")
  expect_equal(gm_body(msg), "how are you doing?\r\n")
  expect_equal(msg$labelIds[[1]], NULL)

  # now modify the labels on the message to put it in the inbox
  gm_modify_message(new_id, add_labels = "INBOX")
  msg2 <- gm_message(new_id)
  expect_equal(msg2$labelIds[[1]], "INBOX")

  # now trash the message
  gm_trash_message(new_id)
  msg3 <- gm_message(new_id)
  expect_equal(msg3$labelIds[[1]], "TRASH")

  # now untrash the message, this does not restore the labels, but removes the trash label
  gm_untrash_message(new_id)
  msg4 <- gm_message(new_id)
  expect_equal(msg4$labelIds[[1]], NULL)

  gm_delete_message(new_id)
  expect_error(gm_message(new_id), "404", class = "gmailr_error")
})

test_that("send_message works", {
  skip_if_no_token()

  msg <- gm_mime(
    From = gm_default_email(),
    To = gm_default_email(),
    Subject = "hello myself",
    body = "how are you doing? I am doing well!"
  )
  sent_id <- gm_id(gm_send_message(msg))
  msg1 <- gm_message(sent_id)

  expect_true("SENT" %in% msg1$labelIds)
})
