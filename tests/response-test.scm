(use-modules (srfi srfi-64)
             (src response))

(define TEST-SUITE-NAME "harness-response")
(define EMPTY-STRING "")
(define EMPTY-RESPONSE "")
(define SINGLE-WORD-RESPONSE "foo")

(test-begin TEST-SUITE-NAME)

(test-assert "empty response"
  (string=?
   EMPTY-STRING
   (qnr-format-response EMPTY-RESPONSE)))

(test-assert "Only whitespace"
  (string=?
   EMPTY-STRING
   (qnr-format-response "  \n   \t ")))

(test-assert "single word response"
  (string=?
   SINGLE-WORD-RESPONSE
   (qnr-format-response SINGLE-WORD-RESPONSE)))

(test-end TEST-SUITE-NAME)
