(use-modules (srfi srfi-64)
             (src response))

(define TEST-SUITE-NAME "harness-response")
(define EMPTY-STRING "")
(define EMPTY-RESPONSE "")
(define SINGLE-WORD-RESPONSE "foo")

(test-begin TEST-SUITE-NAME)

(test-assert "Empty Response"
  (string=?
   EMPTY-STRING
   (qnr-format-response EMPTY-RESPONSE)))

(test-assert "Single word response"
  (string=?
   SINGLE-WORD-RESPONSE
   (qnr-format-response SINGLE-WORD-RESPONSE)))

(test-end TEST-SUITE-NAME)
