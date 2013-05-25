;; -*- coding: utf-8 -*-

(require 'ruby-mode)

(defgroup hrb nil
  "Hilight Ruby Block (HRB)"
  :tag "Hilight Ruby Block"
  :group 'hrb)

(defcustom hrb-highlight-face 'highlight
  "Face for block hilighting."
  :type	 'face
  :group 'hrb)

(defcustom hrb-delay 0.50
  "Seconds before showing matching keyword/end"
  :type	 'number
  :group 'hrb)

(defconst hrb-keywords
  (list
   "for" "while" "until" "if" "class" "module"
   "case" "unless" "def" "begin" "do" "end")
  "Keywords to show matching for")


(defvar hrb-timer nil)
(defvar hrb-overlay nil)

(define-minor-mode hrb-mode
  "Highlight the current ruby block when on a block keyword (if, unless etc) or on an end like show-paren-mode"
  :init-value t :global nil :keymap nil :lighter " HRB"

  (if hrb-mode
      (progn
        (when hrb-timer
          (cancel-timer hrb-timer))
        (setq hrb-timer
              (run-with-idle-timer hrb-delay t 'hrb-timer-hook))
        )
      (when hrb-timer
        (cancel-timer hrb-timer)
        (setq hrb-timer nil)
        )
    )
  )

(defun hrb-timer-hook ()
  (if (eq major-mode 'ruby-mode)
      (hrb-execute)
    (setq hrb-mode nil))
  )

(defun hrb-execute ()
  "Mode hook: executed everytime we get in idle state"

  (let (
        (cword (current-word))
        (cface (get-text-property (point) 'face)) ; we need this to avoid hilighting in a string
        )
    (when (and (member cword hrb-keywords)
               (equal cface 'font-lock-keyword-face))
      (let (
            (start (hrb-keyword-start (point)))
            (pos (hrb-keyword-position (point)))
            )
        (hrb-hilight start pos)
        )
      )
    )
  )


(defun hrb-keyword-start (pos)
  (save-excursion
    (goto-char pos)

    (if (string= (current-word) "end")
        (progn
          (skip-chars-forward "A-Za-z0-9")
          (setq pos (point))
          )

      (progn
        (skip-chars-backward "A-Za-z0-9")
        (setq pos (point))
        )
      )
    )

  pos
  )

(defun hrb-keyword-position (pos)
  (save-excursion
    (goto-char pos)

    (if (string= (current-word) "end")
        (progn
          (ruby-beginning-of-block) ;; search for matching keyword
          (setq pos (point))
          )

      (progn
        (ruby-end-of-block)
        (right-word)
        (setq pos (point))
        )
      )
    )

  pos
  )


(defun hrb-hilight (start end)
  (if hrb-overlay
      (move-overlay hrb-overlay start end)
    (setq hrb-overlay (make-overlay start end))
    )

  (overlay-put hrb-overlay
               'face hrb-highlight-face)

  (add-hook 'pre-command-hook 'hrb-stop-hilight)
  )

(defun hrb-stop-hilight ()
  "Remove overlay when done"
  (remove-hook 'pre-command-hook 'hrb-stop-hilight)
  (when hrb-overlay
      (delete-overlay hrb-overlay))
  )

(provide 'hrb-mode)
;; eof
