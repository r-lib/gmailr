test_that("threads and thread work", {
  skip_if_no_token()

  thrds <- gm_threads()
  expect_is(thrds, "gmail_threads")

  ids <- id(thrds)
  expect_true(length(ids) > 0)

  thr <- gm_thread(ids[[1]])

  expect_equal(id(thr), ids[[1]])
})
