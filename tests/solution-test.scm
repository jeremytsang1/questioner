;;; (tests solution-test) --- Test for module (src quiz solution)
;; Usage: guile -L . tests/answer-test.scm LOG-DIRECTORY # From project root.
#!/usr/local/bin/guile -s
!#

(use-modules (srfi srfi-64) (util test) (src quiz solution) (src quiz choice))

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
  (qnr-solution-choices (qnr-make-solution SINGLE-CHOICE-CHOICES
                                  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal "access <solution> expected response count after construction"
  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT
  (qnr-solution-expected-response-count
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

;; Validating `expected-response-count` ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(qnr-test-error-message
 "construct <solution> wrong type expected-response-count: string"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES "foo")))

(qnr-test-error-message
 "construct <solution> wrong type expected-response-count: list"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES (list 3 4 6))))

(qnr-test-error-message
 "construct <solution> wrong type expected-response-count: non-integral number"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES 3.14159)))

(qnr-test-error-message
 "construct <solution> wrong type expected-response-count: boolean"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-WRONG-TYPE
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES #f)))

(qnr-test-error-message
 "construct <solution> wrong value expected-response-count: negative"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES -27)))

(qnr-test-error-message
 "construct <solution> wrong value expected-response-count: zero"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-NON-POSITIVE-EXPECTED-RESPONSE-COUNT
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES 0)))

(qnr-test-error-message
 "construct <solution> wrong value expected-response-count: greater than length of choices"
 QNR-ERROR-KEY-SOLUTION-CONSTRUCTION
 QNR-ERROR-MSG-SOLUTION-EXPECTED-RESPONSE-COUNT-EXCEEDS-CHOICES-LENGTH
 (lambda () (qnr-make-solution SINGLE-CHOICE-CHOICES 5)))

;; Formatted Solution ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal "whitespace format choices upon <solution> creation"
  '(("foo"))
  (qnr-solution-choices (qnr-make-solution '(("    foo         "))
                                  SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal "delete duplicates and excess whitespace upon <solution> creation"
  '(("alpha" "beta" "gamma")
    ("a" "b" "c")
    ("alfa" "bravo charlie"))
  (qnr-solution-choices
   (qnr-make-solution
    '(("    alpha     " "alpha  " "beta" "gamma")
      ("a" "b" "c" "b" "a")
      ("alfa" "bravo    charlie" "  bravo charlie"))
    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

;; Operations On Valid <solution> Objects ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test-equal
    "Show primary correct answers for single-choice <solution>"
  '("foo")
  (qnr-get-primary-correct-answers
   (qnr-make-solution
    '(("foo" "bar" "baz" "bop"))
    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(test-equal
    "Show primary correct answers for single-choice <solution>"
  '("alpha" "a" "alfa")
  (qnr-get-primary-correct-answers
   (qnr-make-solution
    '(("alpha" "beta" "gamma")
      ("a" "b" "c")
      ("alfa" "bravo charlie"))
    SINGLE-RESPONSE-EXPECTED-RESPONSE-COUNT)))

(qnr-test-error-message
 "Detect when there are no responses"
 QNR-ERROR-KEY-SOLUTION
 QNR-ERROR-MSG-SOLUTION-FIND-WRONG-ANSWERS-FROM-EMPTY-RESPONSE
 (lambda () (qnr-find-wrong-answers (qnr-make-solution '(("foo")) 1) '())))

(qnr-test-error-message
 "Detect when number of responses less than solution's expected response count"
 QNR-ERROR-KEY-SOLUTION
 QNR-ERROR-MSG-SOLUTION-RESPONSES-LENGTH-MISMATCH
 (lambda ()
   (qnr-find-wrong-answers
    (qnr-make-solution '(("foo" "bar") ("baz" "bop") ("hello" "world")) 3)
    '("a" "b"))))

(qnr-test-error-message
 "Detect when number of responses more than solution's expected response count"
 QNR-ERROR-KEY-SOLUTION
 QNR-ERROR-MSG-SOLUTION-RESPONSES-LENGTH-MISMATCH
 (lambda ()
   (qnr-find-wrong-answers
    (qnr-make-solution '(("foo" "bar") ("baz" "bop") ("hello" "world")) 2)
    '("a" "b" "c" "d" "e"))))

(qnr-test-error-message
 "Detect when responses contains empty string"
 QNR-ERROR-KEY-SOLUTION
 QNR-ERROR-MSG-SOLUTION-RESPONSE-MADE-OF-WHITESPACE
 (lambda ()
   (qnr-find-wrong-answers
    (qnr-make-solution '(("foo" "bar") ("baz" "bop") ("hello" "world")) 3)
    '("a" "b" ""))))

(test-equal "Find wrong answers: correctly answers 1-reponse 1-choice question"
  '()
  (qnr-find-wrong-answers (qnr-make-solution '(("foo")) 1) '("foo")))

(test-equal "Incorrectly answer 1-alternative 1-response 1-choice question"
  '("bar")
  (qnr-find-wrong-answers (qnr-make-solution '(("foo")) 1) '("bar")))

(test-equal "Correctly answer multi-alternative 1-response 1-choice question"
  '()
  (qnr-find-wrong-answers (qnr-make-solution '(("foo" "bar" "baz" "bop")) 1)
                          '("baz")))

(test-equal "Incorrectly answer multi-alternative 1-response 1-choice question"
  '("hello")
  (qnr-find-wrong-answers (qnr-make-solution '(("foo" "bar" "baz" "bop")) 1)
                          '("hello")))

(test-equal "Correctly answer 1-alternative multi-choice 1-response: version 1"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha") ("beta") ("gamma")) 1)
   '("alpha")))

(test-equal "Correctly answer 1-alternative multi-choice 1-response: version 2"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha") ("beta") ("gamma")) 1)
   '("beta")))

(test-equal "Correctly answer 1-alternative multi-choice 1-response: version 3"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha") ("beta") ("gamma")) 1)
   '("gamma")))

(test-equal "Incorrectly answer 1-alternative multi-choice 1-response"
  '("delta")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha") ("beta") ("gamma")) 1)
   '("delta")))

(test-equal "Correctly answer multi-alternative multi-choice 1-response"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      1)
   '("bravo")))

(test-equal "Incorrectly answer multi-alternative multi-choice 1-response"
  '("delta")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      1)
   '("delta")))

(test-equal "Incorrectly answer 1-alternative multi-choice multi-response"
  '("rho" "sigma")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha")
                        ("beta")
                        ("gamma"))
                      2)
   '("rho" "sigma")))

(test-equal "Partially incorrect 1-alternative multi-choice multi-response"
  '("rho")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha")
                        ("beta")
                        ("gamma"))
                      2)
   '("rho" "gamma")))

(test-equal "Repeated response 1-alternative multi-choice multi-response"
  '("gamma")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha")
                        ("beta")
                        ("gamma"))
                      2)
   '("gamma" "gamma")))

(test-equal "Repeated response multi-alternative multi-choice multi-response"
  '("gamma")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      3)
   '("gamma" "gamma" "alpha")))

(test-equal "Correct multi-alternative multi-choice multi-response"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      3)
   '("alpha" "b" "charlie")))

(test-equal "Partially incorrect multi-alternative multi-choice multi-response"
  '("pi" "phi")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      3)
   '("alpha" "pi" "phi")))

(test-equal "Entirely incorrect multi-alternative multi-choice multi-response"
  '("one" "two" "three")
  (qnr-find-wrong-answers
   (qnr-make-solution '(("alpha" "a" "alfa")
                        ("beta" "b" "bravo")
                        ("gamma" "c" "charlie"))
                      3)
   '("one" "two" "three")))

(test-equal "Entirely incorrect multi-alternative multi-choice multi-response"
  '()
  (qnr-find-wrong-answers
   (qnr-make-solution '(("mouse")
                        ("duck" "chicken" "budgie" "quail" "robin")
                        ("fly" "ant" "ladybug"))
                      2)
   '("mouse" "ant")))

(test-end TEST-SUITE-NAME)
