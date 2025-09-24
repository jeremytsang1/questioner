(use-modules (srfi srfi-64)
             (util test)
             (src quiz-loader))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define NON-EXISTENT-FILE "does-not-exist.txt")

(test-begin TEST-SUITE-NAME)

(qnr-test-error "Fail to open file not found"
                QNR-ERROR-FILE-NOT-FOUND
                (lambda () (qnr-load-quiz NON-EXISTENT-FILE)))

(qnr-test-error "Open empty invalid JSON: empty file"
                'qnr-error-invalid-json
                (lambda () (qnr-load-quiz "./tests/input-files/empty-quiz.json")))

(test-end TEST-SUITE-NAME)

