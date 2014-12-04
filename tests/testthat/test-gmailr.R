context("MIME - Basic")

test_that("MIME - Basic functions", {
          # Create a new Email::Stuffer object
          msg = mime()
          expect_equal(class(msg), 'mime', label = "msg object has correct class")

          expect_true(length(msg$header) > 0, label = "Even the default object has headers")

          rv = msg %>% to('adam@ali.as')
          expect_equal(rv$header$To, 'adam@ali.as', label = 'to sets To Header')

          rv = msg %>% from('bob@ali.as')
          expect_equal(rv$header$From, 'bob@ali.as', label = 'from sets From Header')

          rv = msg %>% to(c('adam@ali.as', 'another@ali.as', 'bob@ali.as'))
          expect_equal(rv$header$To, 'adam@ali.as, another@ali.as, bob@ali.as', label = 'to (multiple) sets To header' )

          rv = msg %>% cc(c('adam@ali.as', 'another@ali.as', 'bob@ali.as'))
          expect_equal(rv$header$Cc, 'adam@ali.as, another@ali.as, bob@ali.as', label = 'cc (multiple) sets To header' )

          rv = msg %>% bcc(c('adam@ali.as', 'another@ali.as', 'bob@ali.as'))
          expect_equal(rv$header$Bcc, 'adam@ali.as, another@ali.as, bob@ali.as', label = 'bcc (multiple) sets To header' )
})

context("MIME - More Complex")
test_that("MIME - More Complex", {
          # create test files
          library(graphics)
          TEST_PNG = 'volcano.png'
          png(file=TEST_PNG, width=200, height=200)
          filled.contour(volcano, color.palette = terrain.colors, asp=1)
          dev.off()

          TEST_INI='test.ini'
          cat(file=TEST_INI, 'testing')

          on.exit({
            unlink(TEST_PNG)
            unlink(TEST_INI)
          })

          rv2 = mime() %>% from('Jim Hester<james.f.hester@gmail.com>') %>%
                           to         ( 'james.f.hester@gmail.com'    ) %>%
                           subject    ( 'Hello To:!'                  ) %>%
                           text_body  ( 'I am an email'               ) %>%
                           attach_file( TEST_PNG                      )

          rv2_chr = as.character(rv2)

          expect_match(rv2_chr, 'Jim Hester',    label = 'Email contains from name' )
          expect_match(rv2_chr, 'gmail',         label = 'Email contains to string' )
          expect_match(rv2_chr, 'Hello',         label = 'Email contains subject string' )
          expect_match(rv2_chr, 'I am an email', label = 'Email contains text_body' )
          expect_match(rv2_chr, 'volcano',       label = 'Email contains file name' )

          rv2 = mime() %>% from('Jim Hester<james.f.hester@gmail.com>') %>%
                           to         ( 'james.f.hester@gmail.com'    ) %>%
                           subject    ( 'Hello To:!'                  ) %>%
                           text_body  ( 'I am an email'               ) %>%
                           attach_file( TEST_INI, content_type = 'text/plain')

          rv2_chr = as.character(rv2)

          expect_match(rv2_chr, 'Jim Hester',    label = 'Email contains from name' )
          expect_match(rv2_chr, 'gmail',         label = 'Email contains to string' )
          expect_match(rv2_chr, 'Hello',         label = 'Email contains subject string' )
          expect_match(rv2_chr, 'I am an email', label = 'Email contains text_body' )
          expect_match(rv2_chr, "Content-Type: application/octet-stream; name=test\\.ini", label = 'Email contains attachment Content-Type' )

          rv2 = mime() %>% from('Jim Hester<james.f.hester@gmail.com>') %>%
                           to         ( 'james.f.hester@gmail.com'    ) %>%
                           subject    ( 'Hello To:!'                  ) %>%
                           text_body  ( 'I am an email'               ) %>%
                           html_body  ( 'I am an html email<br>'               ) %>%
                           attach_file( TEST_INI, content_type = 'application/octet-stream')

          expect_match(rv2_chr, 'Jim Hester',    label = 'Email contains from name' )
          expect_match(rv2_chr, 'gmail',         label = 'Email contains to string' )
          expect_match(rv2_chr, 'Hello',         label = 'Email contains subject string' )
          expect_match(rv2_chr, 'I am an email', label = 'Email contains text_body' )
          expect_match(rv2_chr, "Content-Type: application/octet-stream; name=test\\.ini", label = 'Email contains attachment Content-Type' )
})

context("MIME - Alternative")

test_that("MIME - Alternative emails contain correct parts", {
          email = mime() %>%
            from('Jim Hester<james.f.hester@gmail.com>') %>%
            to('james.f.hester@gmail.com') %>%
            subject('Hello To:!') %>%
            text_body('I am an email') %>%
            html_body('<b>I am a html email</b>')

          email_chr = as.character(email)

          expect_match(email_chr, 'Jim Hester', label = 'Email contains from name')
          expect_match(email_chr, 'james.f.hester', label = 'Email contains to string')
          expect_match(email_chr, 'Hello', label = 'Email contains subject string')
          expect_match(email_chr, 'Content-Type: multipart/alternative', label = 'Email content type')
          expect_match(email_chr, 'Content-Type: text/plain', label = 'Email content type')
          expect_match(email_chr, 'Content-Type: text/html', label = 'Email content type')

          expect_match(email_chr, quoted_printable_encode('I am an email'), label = 'Email contains text body')
          expect_match(email_chr, base64encode(charToRaw('<b>I am a html email</b>')), fixed = TRUE, label = 'Email contains html body')
})


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
