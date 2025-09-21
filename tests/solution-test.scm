;;; (tests solution-test) --- Test for module (src solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64) (util test) (src solution) (src choice))

;; Constants ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define TEST-SUITE-NAME (qnr-generate-log-file-name))

(define SINGLE-CHOICE-CHOICES '(("blue")))
(define SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT 1)

;; Tests ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-begin TEST-SUITE-NAME)
(test-equal "verify record type after construction"
  #t
  (qnr-solution? (qnr-make-solution SINGLE-CHOICE-CHOICES
                                    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal "access <solution> choices after construction"
  SINGLE-CHOICE-CHOICES
  (qnr-choices (qnr-make-solution SINGLE-CHOICE-CHOICES
                                  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal "access <solution> expected response count after construction"
  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT
  (qnr-expected-response-count
   (qnr-make-solution SINGLE-CHOICE-CHOICES
                      SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-error "fail to construct <solution> wrong type choices: integer"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-solution 12345 1))

(test-error "fail to construct <solution> wrong type choices: string"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-solution "hello" 1))

(test-error "fail to construct <solution> wrong type choices: symbol"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-solution 'goodbye 1))

(test-error "fail to construct <solution> wrong type choices: character"
            QNR-ERROR-KEY-CHOICE-CONSTRUCTION
            (qnr-make-solution #\a 1))

(test-equal "whitspace format choices upon <solution> creation"
  '(("foo"))
  (qnr-choices (qnr-make-solution '(("    foo         ")) 1)))

(test-end TEST-SUITE-NAME)
