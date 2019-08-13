test_that("threads and thread work", {
  skip_unless_authenticated()

  thrds <- threads()
  expect_is(thrds, "gmail_threads")

  ids <- id(thrds)
  expect_true(length(ids) > 0)

  thr <- thread(ids[[1]])

  expect_equal(id(thr), ids[[1]])
})
