;;; (src solution)
;; Description: Defines a `<solution>` for a `<question>`. A `<solution>`
;; represents a set of `<choice>`s and the the expected number of responses the
;; testee can be expected to respond with for their answer to be considered
;; correct.

(define-module (src solution)
  #:use-module (srfi srfi-9)
  #:export (qnr-make-solution
            qnr-solution?
            qnr-choices))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Constructors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-record-type <qnr-solution>
  (qnr-make-solution choices expected-response-count)
  qnr-solution?
  (choices qnr-choices)
  (expected-response-count qnr-expected-response-count))
