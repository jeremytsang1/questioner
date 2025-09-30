(use-modules (srfi srfi-64)
             (util test)
             (src quiz quiz))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)
(test-end TEST-SUITE-NAME)
