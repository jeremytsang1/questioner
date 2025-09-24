(use-modules (srfi srfi-64)
             (util test)
             (src quiz-loader))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define PROJECT-ROOT ".")
(define DIR-TEST "tests")
(define DIR-INPUT-FILES "input-files")
(define PREFIX
  (string-concatenate (list
                       PROJECT-ROOT
                       file-name-separator-string
                       DIR-TEST
                       file-name-separator-string
                       DIR-INPUT-FILES
                       file-name-separator-string)))
(define FILENAME-NON-EXISTENT-FILE "does-not-exist.txt")
(define FILENAME-EMPTY-FILE "empty-quiz.json")
(define FILENAME-LOREM-IPSUM "invalid-json-lorem-ipsum.json")
(define FILENAME-MISSING-CLOSING-BRACKET
  "invalid-json-missing-closing-bracket.json")

(test-begin TEST-SUITE-NAME)

(qnr-test-error "open invalid file: non-existent file"
                QNR-ERROR-FILE-NOT-FOUND
                (lambda () (qnr-load-quiz FILENAME-NON-EXISTENT-FILE)))

(qnr-test-error "open empty invalid JSON: empty file"
                QNR-ERROR-INVALID-JSON
                (lambda ()
                  (qnr-load-quiz
                   (string-concatenate (list PREFIX FILENAME-EMPTY-FILE)))))

(qnr-test-error "open empty invalid JSON: lorem ipsum paragraphs"
                QNR-ERROR-INVALID-JSON
                (lambda ()
                  (qnr-load-quiz
                   (string-concatenate (list PREFIX FILENAME-LOREM-IPSUM)))))

(qnr-test-error "open empty invalid JSON: missing closing bracket"
                QNR-ERROR-INVALID-JSON
                (lambda ()
                  (qnr-load-quiz
                   (string-concatenate
                    (list PREFIX FILENAME-MISSING-CLOSING-BRACKET)))))


(test-equal "Access query of valid JSON"
  "Name one of the two longest rivers in the United Stated."
  (qnr-question-dto-query
   (car
    (qnr-question-dto-list-questions
     (qnr-load-quiz
      (string-concatenate
       (list PREFIX "valid-single-question.json")))))))

(test-end TEST-SUITE-NAME)

