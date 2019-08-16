test_that("labels work", {
  skip_if_no_token()

  my_labels <- labels()
  label_names <- vapply(my_labels$labels, `[[`, character(1), "name")
  expect_true("SENT" %in% label_names)
  expect_true("TRASH" %in% label_names)
  expect_true("INBOX" %in% label_names)
  expect_true("SPAM" %in% label_names)
  expect_true("DRAFT" %in% label_names)
})

test_that("label works", {
  skip_if_no_token()

  my_label <- label("SENT")

  expect_equal(my_label$id, "SENT")
  expect_equal(my_label$type, "system")
  expect_gt(my_label$messagesTotal, 1)
})

test_that("create_label, update_label, update_label_patch and delete_label work", {
  skip_if_no_token()

  label_name1 <- basename(tempfile(pattern = "foo"))
  new_label <- create_label(label_name1)
  expect_equal(new_label$name, label_name1)

  label_name2 <- basename(tempfile(pattern = "bar"))
  new_label$name <- label_name2

  new_label2 <- update_label(new_label$id, new_label)
  expect_equal(new_label2$name, label_name2)

  label_name3 <- basename(tempfile(pattern = "baz"))
  new_label2$name <- label_name3
  new_label3 <- update_label_patch(new_label2$id, new_label2)
  expect_equal(new_label3$name, label_name3)

  delete_label(new_label3$id)

  expect_error(label(new_label3$id))
})
