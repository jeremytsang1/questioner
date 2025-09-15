(use-modules (srfi srfi-64)
             (src response))

(test-begin "harness-response")

(test-assert "Empty Response"
  (string=?
   ""
   (qnr-format-response "")))

(test-assert "Single word response"
  (string=?
   "foo"
   (qnr-format-response "foo")))

(test-end "harness-response")
