;; For my own sanity, I'm using this.
; https://cl-cookbook.sourceforge.net/strings.html#manip
(defun replace-all (string part replacement &key (test #'char=))
    "Returns a new string in which all the occurences of the part 
    is replaced with replacement."
    (with-output-to-string (out)
      (loop with part-length = (length part)
            for old-pos = 0 then (+ pos part-length)
            for pos = (search part string
                              :start2 old-pos
                              :test test)
            do (write-string string out
                             :start old-pos
                             :end (or pos (length string)))
            when pos do (write-string replacement out)
            while pos)))

;; Parsing
(defun many-replace (string replacements)
  (loop for (from to) in replacements
        do (setf string (replace-all string from to)))
  string)

(defun hammer-into-shape (s)
  (concatenate 'string
               (many-replace s '(("Card " "(")
                                 (": " " (")
                                 (" | " ") (")))
               "))"))

(defun parse ()
  (loop for line = (read-line nil nil)
        while line
        collect
        (read-from-string (hammer-into-shape line))))

;; Common
(defun card-matches (card)
  (let ((winning (first card))
        (mine (second card)))
       (length (intersection winning mine))))

;; Part 1
(defun score (matches)
  (floor (expt 2 matches) 2))

(defun part1 (cards)
  (reduce '+ (mapcar 'score (mapcar 'card-matches cards))))

;; Part 2
(defun update-impl (list n inc)
  (if (and list (> n 0))
      (cons (+ inc (first list)) (update-impl (rest list) (- n 1) inc))
      (if (> n 0)
          (cons inc (update-impl list (- n 1) inc))
          list)))

(defun update (counts matches)
  "Increment the first n elements of a list by inc,
  extending the list if necessary"
  (update-impl (rest counts) matches (first counts)))

(defun solve (cards counts)
  (if cards (+ (first counts)
               (solve (rest cards)
               (update counts (card-matches (first cards)))))
            0))

(defun part2 (cards)
  (solve cards (make-list (length cards) :initial-element 1)))

(setf input (mapcar #'rest (parse)))
(format t "Part 1: ~d~%" (part1 input))
(format t "Part 2: ~d~%" (part2 input))
