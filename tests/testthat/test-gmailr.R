context("Quoted Printable")

test_that("plain ascii should not be encoded",
          expect_match("quoted_printable",
                       quoted_printable_encode("quoted_printable"))
          )
test_that("trailing space should be encoded", {
          expect_equal("=20=20",
                       quoted_printable_encode("  "))
          expect_equal("\tt=09",
                       quoted_printable_encode("\tt\t"))
          expect_equal("test=20=20\ntest\n=09=20=09=20\n",
                       quoted_printable_encode("test  \ntest\n\t \t \n"))
})
test_that("\"=\" is special an should be decoded", {
          expect_equal( "=3D30\n",
                       quoted_printable_encode("=30\n"))
})
test_that("trailing whitespace", {
          expect_equal( "foo=20=09=20",
                       quoted_printable_encode("foo \t "))
          expect_equal( "foo=09=20\n=20=09",
                       quoted_printable_encode("foo\t \n \t"))
})
