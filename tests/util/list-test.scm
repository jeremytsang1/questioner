(use-modules (srfi srfi-64)
             (src util list)
             (src util test))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)

(test-equal "qnr-number-elements: empty list"
  '()
  (qnr-number-elements '()))

(test-equal "qnr-number-elements: single element list"
  '((a . 1))
  (qnr-number-elements '(a)))

(test-equal "qnr-number-elements: multi element list"
  '((a . 1) (b . 2) (c . 3) (d . 4))
  (qnr-number-elements '(a b c d)))

(test-end TEST-SUITE-NAME)
