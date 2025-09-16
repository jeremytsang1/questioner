(use-modules (srfi srfi-64)
             (src response))

(define TEST-SUITE-NAME "harness-response")
(define EMPTY-RESPONSE "")
(define EXCLUSIVELY-WHITESPACE "  \n   \t ")
(define SPACES "   ")
(define SINGLE-WORD-RESPONSE "foo")

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

(test-end TEST-SUITE-NAME)
