(use-modules (srfi srfi-64)
             (util test)
             (src quiz-loader))

;; Test Helpers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (construct-path dirname basename)
  "Assumes DIRNAME ends in appropriate file-name-separator-string."
  (string-concatenate (list dirname basename)))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
(define PATH-NON-EXISTENT-FILE
  (construct-path PREFIX "does-not-exist.txt"))
(define PATH-EMPTY-FILE
  (construct-path PREFIX "empty-quiz.json"))
(define PATH-LOREM-IPSUM
  (construct-path PREFIX "invalid-json-lorem-ipsum.json"))
(define PATH-MISSING-CLOSING-BRACKET
  (construct-path PREFIX "invalid-json-missing-closing-bracket.json"))
(define PATH-VALID-SINGLE-QUERY
  (construct-path PREFIX "valid-single-question.json"))
(define PATH-INVALID-MISSING-TOP-LEVEL-RECORD-FIELD
  (construct-path PREFIX "invalid-parsed-missing-top-level-record-field.json"))
(define PATH-INVALID-NO-QUESTIONS
  (construct-path PREFIX "invalid-parsed-empty-questions-array.json"))
(define PATH-INVALID-QUESTION-WRONG-TYPE
  (construct-path PREFIX "invalid-parsed-question-wrong-type.json"))
(define PATH-INVALID-MISSING-FIELD-QUERY
  (construct-path PREFIX "invalid-parsed-missing-field-query.json"))
(define PATH-INVALID-WRONG-TYPE-QUERY
  (construct-path PREFIX "invalid-parsed-wrong-type-query.json"))
(define PATH-INVALID-MISSING-FIELD-CHOICES
  (construct-path PREFIX "invalid-parsed-missing-field-choices.json"))
(define PATH-INVALID-WRONG-TYPE-CHOICES-OUTER-VECTOR
  (construct-path PREFIX "invalid-parsed-wrong-type-choices-outer-vector.json"))
(define PATH-INVALID-MISSING-FIELD-EXPECTED-RESPONSE-COUNT
  (construct-path PREFIX "invalid-parsed-missing-field-expected-response-count.json"))
(define PATH-INVALID-WRONG-TYPE-EXPECTED-RESPONSE-COUNT
  (construct-path PREFIX "invalid-parsed-wrong-type-expected-response-count.json"))

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)

(qnr-test-error "open invalid file: non-existent file"
                QNR-ERROR-FILE-NOT-FOUND
                (lambda () (qnr-load-quiz-file PATH-NON-EXISTENT-FILE)))

(qnr-test-error "open empty invalid JSON: empty file"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-EMPTY-FILE)))

(qnr-test-error "open empty invalid JSON: lorem ipsum paragraphs"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-LOREM-IPSUM)))

(qnr-test-error "open empty invalid JSON: missing closing bracket"
                QNR-ERROR-JSON-PARSING
                (lambda () (qnr-load-quiz-file PATH-MISSING-CLOSING-BRACKET)))

(test-equal "access query of valid json"
  "Name one of the two longest rivers in the United Stated."
  (qnr-dto-question-query
   (car
    (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY))))

(test-equal "access choices of valid json"
  #(#("Missouri" "Missouri River") #("Mississippi" "Mississippi River"))
  (qnr-dto-question-choices
   (car
    (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY))))

(test-equal "access expected response count of valid json"
  1
  (qnr-dto-question-expected-response-count
   (car
    (qnr-load-quiz-file PATH-VALID-SINGLE-QUERY))))

(qnr-test-error "invalid parsed: missing top level record field"
                QNR-ERROR-PARSED-NO-TOP-LEVEL-FIELD
                (lambda ()
                  (qnr-load-quiz-file
                   PATH-INVALID-MISSING-TOP-LEVEL-RECORD-FIELD)))

(qnr-test-error "invalid parsed: empty quiz"
                QNR-ERROR-PARSED-EMPTY-QUESTIONS
                (lambda () (qnr-load-quiz-file PATH-INVALID-NO-QUESTIONS)))

(qnr-test-error "invalid parsed: question wrong type as string"
                QNR-ERROR-PARSED-QUESTION-NOT-JSON-OBJECT
                (lambda ()
                  (qnr-load-quiz-file PATH-INVALID-QUESTION-WRONG-TYPE)))

(qnr-test-error "invalid parsed: missing field query"
                QNR-ERROR-PARSED-MISSING-QUERY
                (lambda ()
                  (qnr-load-quiz-file PATH-INVALID-MISSING-FIELD-QUERY)))

(qnr-test-error "invalid parsed: wrong type query"
                QNR-ERROR-PARSED-WRONG-TYPE-QUERY
                (lambda ()
                  (qnr-load-quiz-file PATH-INVALID-WRONG-TYPE-QUERY)))

(qnr-test-error "invalid parsed: missing field choices"
                QNR-ERROR-PARSED-MISSING-CHOICES
                (lambda ()
                  (qnr-load-quiz-file PATH-INVALID-MISSING-FIELD-CHOICES)))

(qnr-test-error "invalid parsed: wrong type choices outer vector"
                QNR-ERROR-PARSED-WRONG-TYPE-CHOICES
                (lambda ()
                  (qnr-load-quiz-file
                   PATH-INVALID-WRONG-TYPE-CHOICES-OUTER-VECTOR)))

(qnr-test-error "invalid parsed: missing field expected-response-count"
                QNR-ERROR-PARSED-MISSING-EXPECTED-RESPONSE-COUNT
                (lambda ()
                  (qnr-load-quiz-file
                   PATH-INVALID-MISSING-FIELD-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error "invalid parsed: wrong type expected-response-count"
                QNR-ERROR-PARSED-WRONG-TYPE-EXPECTED-RESPONSE-COUNT
                (lambda ()
                  (qnr-load-quiz-file
                   PATH-INVALID-WRONG-TYPE-EXPECTED-RESPONSE-COUNT)))

(test-end TEST-SUITE-NAME)
