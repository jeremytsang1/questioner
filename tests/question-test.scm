;;; (tests question-test) --- Test for module (src question)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (util test)
             (src question))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(test-assert "question fieldname access"
  (let ((question (qnr-make-question "a" "b" "c")))
    (and (string=? (qnr-query question) "a")
         (string=? (qnr-solutions question) "b")
         (string=? (qnr-expected-response-count question) "c"))))

(test-end TEST-SUITE-NAME)
