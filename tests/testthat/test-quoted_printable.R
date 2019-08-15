test_that("quoted_printable_encode works", {
  expect_equal(quoted_printable_encode("foo"), "foo")
  expect_equal(quoted_printable_encode("\u2018"), "=E2=80=98")
})
