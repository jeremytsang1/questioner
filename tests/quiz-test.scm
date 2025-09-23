;;; (tests question-test)
;; Description
;; Usage: guile -L . tests/quiz-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (ice-9 q)
             (util test)
             (src question))

(test-begin "quiz-test")

(test-assert "Questions is a queue"
  (q? (qnr-questions (qnr-make-quiz))))

(test-end "quiz-test")
