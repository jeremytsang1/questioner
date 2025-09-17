(define-module (util test)
  #:use-module (ice-9 match)
  #:export (qnr-generate-log-file-name))

(define EXPECTED_TEST_SCRIPT_SUFFIX ".scm")
(define EXPECTED_TEST_SCRIPT_ARGUMENT_COUNT
  ;; Argument 1: Directory to write logs.
  1)

;; TODO: Handle this exception using the modern exception handling approach
;; (see 6.11.8.2 Raising and Handling Exceptions)
(define EXCEPTION-INCORRECT-ARG-COUNT
  'qnr-exception-incorrect-test-script-arg-count)
(define EXCEPTION-INCORRECT-ARG-COUNT-MESSAGE
  (format
   #f
   "Test scripts must take exactly ~a argument(s)"
   EXPECTED_TEST_SCRIPT_ARGUMENT_COUNT))

(define (qnr-generate-log-file-name)
  "Create the name of the test file's corresponding log file.

Read directory to write the test log file to from first command line argument.

Use basenames sans extension of the test script as basename sans extension for
log file."
  (let* ((coli-args (command-line)))
    (when (not (= (length coli-args) (1+ EXPECTED_TEST_SCRIPT_ARGUMENT_COUNT)))
      (throw EXCEPTION-INCORRECT-ARG-COUNT
             EXCEPTION-INCORRECT-ARG-COUNT-MESSAGE))
    (let ((test-script-base-name-sans-extension
           (basename (car coli-args) EXPECTED_TEST_SCRIPT_SUFFIX))
          (dir-logs (match coli-args ((script-name dir-logs) dir-logs))))
      (string-concatenate
       (list dir-logs
             file-name-separator-string
             test-script-base-name-sans-extension)))))
