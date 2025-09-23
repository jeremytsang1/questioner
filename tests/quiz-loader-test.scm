(use-modules (srfi srfi-64)
             (util test)
             (src quiz-loader))

(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(test-begin TEST-SUITE-NAME)

(test-assert "Fail to open file not found"
  (catch 'qnr-error-file-not-found
    (lambda () (qnr-load-quiz "does-not-exist.txt")
            #f)
    (lambda (key . args) #t)))


(test-end TEST-SUITE-NAME)

