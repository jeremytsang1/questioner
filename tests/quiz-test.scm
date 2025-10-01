(use-modules (srfi srfi-64)
             (util test)
             (src quiz quiz))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)

(test-equal "qnr-number-elements: empty list"
  '()
  (qnr-number-elements '()))

(test-end TEST-SUITE-NAME)
