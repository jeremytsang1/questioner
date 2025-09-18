(define-module (src question)
  #:use-module (srfi srfi-9)
  #:export (qnr-make-question
            qnr-query
            qnr-solutions
            qnr-expected-response-count))

(define-record-type <question>
  (qnr-make-question query solutions expected-response-count)
  qnr-question?
  (query qnr-query)
  (solutions qnr-solutions)
  (expected-response-count qnr-expected-response-count))
