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
(define FILENAME-EMPTY-FILE "empty-quiz.json")
(define NON-EXISTENT-FILE "does-not-exist.txt")

(test-begin TEST-SUITE-NAME)

(qnr-test-error "open invalid file: non-existent file"
                QNR-ERROR-FILE-NOT-FOUND
                (lambda () (qnr-load-quiz NON-EXISTENT-FILE)))

(qnr-test-error "open empty invalid JSON: empty file"
                QNR-ERROR-INVALID-JSON
                (lambda ()
                  (qnr-load-quiz
                   (string-concatenate (list PREFIX FILENAME-EMPTY-FILE)))))

(test-end TEST-SUITE-NAME)

