test_that("threads and thread work", {
  skip_if_no_token()

  thrds <- gm_threads()
  expect_s3_class(thrds, "gmail_threads")

  ids <- gm_id(thrds)
  expect_true(length(ids) > 0)

  thr <- gm_thread(ids[[1]])

  expect_equal(gm_id(thr), ids[[1]])
})
