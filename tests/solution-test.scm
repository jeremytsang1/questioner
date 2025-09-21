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

;; Validating choices at the choice level ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(qnr-test-error-message
 "construct <solution> from choices with empty choice"
 QNR-ERROR-KEY-CHOICE-CONSTRUCTION
 QNR-ERROR-MSG-CHOICE-EMPTY
 (lambda () (qnr-make-solution '(("foo" "bar") () ("baz") ("bop"))
                               SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

;; Validating choices at the <solution> level ;;;;;;;;;;;;;;;;;;;;;;;
(qnr-test-error-message
 "construct <solution> wrong type choices: integer"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
 (lambda () (qnr-make-solution 12345 SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "construct <solution> wrong type choices: string"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
 (lambda ()
   (qnr-make-solution "hello" SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "construct <solution> wrong type choices: symbol"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
 (lambda ()
   (qnr-make-solution 'goodbye SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "construct <solution> wrong type choices: character"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-CHOICES-WRONG-TYPE
 (lambda ()
   (qnr-make-solution #\a SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "construct <solution> wrong value choices: empty list"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-CHOICES-EMPTY
 (lambda ()
   (qnr-make-solution '() SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "construct <solution> wrong value choices: duplicates across choices"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-DUPLICATE-CHOICES
 (lambda ()
   (qnr-make-solution '(("foo" "bar" "baz") ("alpha" "beta" "foo" "gamma"))
                      SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

;; Formatted Solution ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "whitespace format choices upon <solution> creation"
  '(("foo"))
  (qnr-choices (qnr-make-solution '(("    foo         "))
                                  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal "delete duplicates and excess whitespace upon <solution> creation"
  '(("alpha" "beta" "gamma")
    ("a" "b" "c")
    ("alfa" "bravo charlie"))
  (qnr-choices
   (qnr-make-solution
    '(("    alpha     " "alpha  " "beta" "gamma")
      ("a" "b" "c" "b" "a")
      ("alfa" "bravo    charlie" "  bravo charlie"))
    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-end TEST-SUITE-NAME)
