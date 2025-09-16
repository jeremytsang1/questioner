(use-modules (srfi srfi-64)
             (src response))

(define TEST-SUITE-NAME "harness-response")
(define EMPTY-RESPONSE "")
(define SINGLE-SPACE " ")
(define EXCLUSIVELY-WHITESPACE "  \n   \t ")
(define SPACES "   ")
(define SINGLE-WORD-RESPONSE "foo")
(define SECOND-WORD "bar")

(test-begin TEST-SUITE-NAME)

(test-assert "empty response"
  (string=?
   EMPTY-STRING
   (qnr-format-response EMPTY-RESPONSE)))

(test-assert "only whitespace"
  (string=?
   EMPTY-STRING
   (qnr-format-response EXCLUSIVELY-WHITESPACE)))

(test-assert "single word response"
  (string=?
   SINGLE-WORD-RESPONSE
   (qnr-format-response SINGLE-WORD-RESPONSE)))

(test-assert "single word with leading spaces"
  (string=?
   SINGLE-WORD-RESPONSE
   (qnr-format-response
    (string-concatenate (list SPACES SINGLE-WORD-RESPONSE)))))

(test-assert "single word with trailing spaces"
  (string=?
   SINGLE-WORD-RESPONSE
   (qnr-format-response
    (string-concatenate (list SINGLE-WORD-RESPONSE SPACES)))))

(test-assert "two word response with multiple spaces between"
  (string=?
   (string-concatenate (list SINGLE-WORD-RESPONSE SINGLE-SPACE SECOND-WORD))
   (qnr-format-response
    (string-concatenate (list SINGLE-WORD-RESPONSE SPACES SECOND-WORD)))))

(test-end TEST-SUITE-NAME)
