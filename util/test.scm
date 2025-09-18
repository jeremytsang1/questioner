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
    (let ((dir-logs (match coli-args ((script-name dir-logs) dir-logs)))
          ;; Find basename without extension becuase srfi-64 writes the
          ;; extension as ".log".
          (test-script-base-name-sans-extension
           (basename (car coli-args) EXPECTED_TEST_SCRIPT_SUFFIX)))
      (construct-path dir-logs test-script-base-name-sans-extension))))

(define (construct-path directory-name file-basename)
  (string-concatenate
   (list
    directory-name
    ;; Only append the separator if there is not one already present.
    (if (string=? (get-last-char-as-string directory-name)
                  file-name-separator-string)
        ""
        file-name-separator-string)
    file-basename)))

(define (get-last-char-as-string str)
  "Return substring containing the last character of STR.

Assumes STR is not empty."
  (string-take-right str 1))
