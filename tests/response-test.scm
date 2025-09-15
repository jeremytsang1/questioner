(use-modules (srfi srfi-64)
             (src response))

(test-begin "harness-response")

(test-assert "Empty Response"
  (string=?
   ""
   (qnr-format-response "")))

(test-end "harness-response")
