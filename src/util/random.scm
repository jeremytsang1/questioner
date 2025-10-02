(define-module (src util random)
  #:export (qnr-shuffle))

;; Inspired by https://youtu.be/TGveA1oFhrc?si=uhGdyQxkLGo7abZx&t=387 and
(define (qnr-shuffle lst)
  "Returns a shuffled copy of LST."
  ;; Takes a merge-sort approach
  (if (or (null? lst) (null? (cdr lst)))
      lst
      (let* ((left (get-mid-left lst))
             (right (get-mid-right lst))
             (tmp (cdr right)))
        (merge-random (qnr-shuffle left) (qnr-shuffle right)))))

;; List Bisection ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (get-mid-right lst)
  (traverse-to-mid
   lst
   (lambda (slow) (cdr slow)) ;; What to do when slow reaches middle.
   (lambda (slow recursion) recursion)))

(define (get-mid-left lst)
  (traverse-to-mid
   lst
   (lambda (slow) (list (car slow))) ;; What do do when slow reaches middle.
   (lambda (slow recursion) (cons (car slow) recursion))))

;; Inspired by https://youtu.be/TGveA1oFhrc?si=aPoIE3L46dFQLVka&t=557
(define (traverse-to-mid lst proc-base proc-recur)
  (define* (traverse #:optional (slow lst) (fast (cdr lst)))
    "SLOW reaches middle at the same time that FAST goes OOB."
    (if (or (null? fast) (null? (cdr fast)))
        (proc-base slow)
        (proc-recur slow (traverse (cdr slow) (cddr fast))))) ;; Note the cddr.
  (traverse))
;; Merge ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Inspired by https://cs.gmu.edu/~white/CS363/Scheme/SchemeSamples.html and
;; https://stackoverflow.com/a/12168162
(define (merge-random left right) ; assume left and right are sorted ascending
  (cond ((null? left) right)
        ((null? right) left)
        ((> (random 2 (random-state-from-platform)) 0)
         (cons (car left) (merge-random (cdr left) right)))
        (else
         (cons (car right) (merge-random left (cdr right))))))
