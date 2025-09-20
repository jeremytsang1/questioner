;;; (tests answer-test) --- Test for module (src answer).
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64)
             (src answer)
             (util test))

(define TEST-SUITE-NAME
  ;; Note that this must have the same stem as corresponding `.log` file used
  ;; as a target in the makefile. In this case "answer-test" is the stem where
  ;; the target will be "answer-test.log" and the prerequisite is
  ;; "answer-test.scm".
  (qnr-generate-log-file-name))
(define EMPTY-ANSWER "")
(define EXCLUSIVELY-WHITESPACE "  \n   \t ")
(define SPACES "   ")
(define SINGLE-WORD-ANSWER "foo")
(define SECOND-WORD "bar")
(define LOWERCASE-CONVERTED-ANSWER "foo bar baz bop")
(define MIXED-CASE-ANSWER "Foo BAR baz\t\tbOp")

(test-begin TEST-SUITE-NAME)

(test-assert "empty answer"
  (string=?
   QNR-EMPTY-STRING
   (qnr-format-answer EMPTY-ANSWER)))

(test-assert "only whitespace"
  (string=?
   QNR-EMPTY-STRING
   (qnr-format-answer EXCLUSIVELY-WHITESPACE)))

(test-assert "single word answer"
  (string=?
   SINGLE-WORD-ANSWER
   (qnr-format-answer SINGLE-WORD-ANSWER)))

(test-assert "single word with leading spaces"
  (string=?
   SINGLE-WORD-ANSWER
   (qnr-format-answer
    (string-concatenate (list SPACES SINGLE-WORD-ANSWER)))))

(test-assert "single word with trailing spaces"
  (string=?
   SINGLE-WORD-ANSWER
   (qnr-format-answer
    (string-concatenate (list SINGLE-WORD-ANSWER SPACES)))))

(test-assert "two word answer with multiple spaces between"
  (string=?
   (string-concatenate (list SINGLE-WORD-ANSWER QNR-SINGLE-SPACE SECOND-WORD))
   (qnr-format-answer
    (string-concatenate (list SINGLE-WORD-ANSWER SPACES SECOND-WORD)))))

(test-assert "answer with upper case to lower case"
  (string=?
   LOWERCASE-CONVERTED-ANSWER
   (qnr-format-answer MIXED-CASE-ANSWER)))

(test-end TEST-SUITE-NAME)
