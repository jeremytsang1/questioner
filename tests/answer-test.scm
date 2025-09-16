(use-modules (srfi srfi-64)
             (src answer))

(define TEST-SUITE-NAME "harness-answer")
(define EMPTY-ANSWER "")
(define EXCLUSIVELY-WHITESPACE "  \n   \t ")
(define SPACES "   ")
(define SINGLE-WORD-ANSWER "foo")
(define SECOND-WORD "bar")

(test-begin TEST-SUITE-NAME)

(test-assert "empty answer"
  (string=?
   EMPTY-STRING
   (qnr-format-answer EMPTY-ANSWER)))

(test-assert "only whitespace"
  (string=?
   EMPTY-STRING
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
   (string-concatenate (list SINGLE-WORD-ANSWER SINGLE-SPACE SECOND-WORD))
   (qnr-format-answer
    (string-concatenate (list SINGLE-WORD-ANSWER SPACES SECOND-WORD)))))

(test-assert "answer with upper case to lower case"
  (string=?
   "foo bar baz bop"
   (qnr-format-answer "Foo BAR baz\t\tbOp")))

(test-end TEST-SUITE-NAME)
