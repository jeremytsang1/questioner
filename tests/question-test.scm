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
  (let ((question (qnr-make-question "a" "b" "c" "d")))
    (and (string=? (qnr-query question) "a")
         (string=? (qnr-solutions question) "b")
         (string=? (qnr-expected-response-count question) "c")
         (string=? (qnr-question-number question) "d"))))

(test-equal "validate an object that is not a <question>"
  "passed object is not a <question>"
  (qnr-validate-question '(foo bar baz bop)))

(test-end TEST-SUITE-NAME)
