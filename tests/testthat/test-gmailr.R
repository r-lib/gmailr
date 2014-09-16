context("MIME - Basic")

test_that("MIME - Basic functions", {
# Create a new Email::Stuffer object
          msg = mime()
          expect_equal(class(msg), 'mime', label = "msg object has correct class")

          

})
#my $Stuffer = Email::Stuffer->new;
#stuff_ok( $Stuffer );
#my @headers = $Stuffer->headers;
#ok( scalar(@headers), 'Even the default object has headers' );
#
## Set a To name
#my $rv = $Stuffer->to('adam@ali.as');
#stuff_ok( $Stuffer );
#stuff_ok( $rv    );
#is( $Stuffer->as_string, $rv->as_string, '->To returns the same object' );
#is( $Stuffer->email->header('To'), 'adam@ali.as', '->To sets To header' );
#
## Set a From name
#$rv = $Stuffer->from('bob@ali.as');
#stuff_ok( $Stuffer );
#stuff_ok( $rv    );
#is( $Stuffer->as_string, $rv->as_string, '->From returns the same object' );
#is( $Stuffer->email->header('From'), 'bob@ali.as', '->From sets From header' );
#
## To allows multiple recipients
#$rv = $Stuffer->to('adam@ali.as', 'another@ali.as', 'bob@ali.as');
#stuff_ok( $Stuffer );
#stuff_ok( $rv    );
#is( $Stuffer->as_string, $rv->as_string, '->To (multiple) returns the same object' );
#is( $Stuffer->email->header('To'), 'adam@ali.as, another@ali.as, bob@ali.as', '->To (multiple) sets To header' );
#
## Cc allows multiple recipients
#$rv = $Stuffer->cc('adam@ali.as', 'another@ali.as', 'bob@ali.as');
#stuff_ok( $Stuffer );
#stuff_ok( $rv    );
#is( $Stuffer->as_string, $rv->as_string, '->Cc (multiple) returns the same object' );
#is( $Stuffer->email->header('Cc'), 'adam@ali.as, another@ali.as, bob@ali.as', '->Cc (multiple) sets To header' );
#
## Bcc allows multiple recipients
#$rv = $Stuffer->bcc('adam@ali.as', 'another@ali.as', 'bob@ali.as');
#stuff_ok( $Stuffer );
#stuff_ok( $rv    );
#is( $Stuffer->as_string, $rv->as_string, '->Bcc (multiple) returns the same object' );
#is( $Stuffer->email->header('Bcc'), 'adam@ali.as, another@ali.as, bob@ali.as', '->Bcc (multiple) sets To header' );
#
## More complex one
#use Email::Sender::Transport::Test 0.120000 (); # ->delivery_count, etc.
#my $test = Email::Sender::Transport::Test->new;
#my $rv2 = Email::Stuffer->from       ( 'Adam Kennedy<adam@phase-n.com>')
#                        ->to         ( 'adam@phase-n.com'              )
#                        ->subject    ( 'Hello To:!'                    )
#                        ->text_body  ( 'I am an email'                 )
#                        ->attach_file( $TEST_GIF                       )
#                        ->transport  ( $test                           )
#                        ->send;
#ok( $rv2, 'Email sent ok' );
#is( $test->delivery_count, 1, 'Sent one email' );
#my $email = $test->shift_deliveries->{email}->as_string;
#like( $email, qr/Adam Kennedy/,  'Email contains from name' );
#like( $email, qr/phase-n/,       'Email contains to string' );
#like( $email, qr/Hello/,         'Email contains subject string' );
#like( $email, qr/I am an email/, 'Email contains text_body' );
#like( $email, qr/paypal/,        'Email contains file name' );
#
## attach_file content_type
#$rv2 = Email::Stuffer->from       ( 'Adam Kennedy<adam@phase-n.com>'        )
#                     ->to         ( 'adam@phase-n.com'                      )
#                     ->subject    ( 'Hello To:!'                            )
#                     ->text_body  ( 'I am an email'                         )
#                     ->attach_file( 'dist.ini', content_type => 'text/plain')
#                     ->transport  ( $test                                   )
#                     ->send;
#ok( $rv2, 'Email sent ok' );
#is( $test->delivery_count, 1, 'Sent one email' );
#$email = $test->shift_deliveries->{email}->as_string;
#like( $email, qr/Adam Kennedy/,  'Email contains from name' );
#like( $email, qr/phase-n/,       'Email contains to string' );
#like( $email, qr/Hello/,         'Email contains subject string' );
#like( $email, qr/I am an email/, 'Email contains text_body' );
#like( $email, qr{Content-Type: text/plain; name="dist\.ini"}, 'Email contains attachment content-Type' );
#1;

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
