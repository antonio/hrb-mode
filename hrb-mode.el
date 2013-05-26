;; -*- coding: utf-8 -*-

;;; hrb-block.el - highlight ruby blocks

;; Copyright (C) 2013 Christian Kruse

;; Author: Christian Kruse <cjk@defunct.ch>
;; Version: 0.0.2
;; Keywords: languages, faces, ruby

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.	If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

(require 'ruby-mode)

(defgroup hrb nil
  "Hilight Ruby Block (HRB)"
  :tag "Hilight Ruby Block"
  :group 'hrb)

(defcustom hrb-hilight-keyword-face 'show-paren-match-face
  "Face for keyword hilighting."
  :type	 'face
  :group 'hrb)

(defcustom hrb-hilight-block-face 'highlight
  "Face for block hilighting."
  :type	 'face
  :group 'hrb)

(defcustom hrb-delay 0.50
  "Seconds before showing matching keyword/end"
  :type	 'number
  :group 'hrb)

(defcustom hrb-hilight-mode 'complete
  "Describes how to hilight the ruby blocks. Default is complete.

Choces are as follows:

nil      => nothing
complete => hilight complete block
keywords => hilight only keywords
mixed    => hilight keywords if both are visible, hilight block if not"
  :type	 '(choice
           (const :tag "nothing" nil)
           (const :tag "keywords" keywords)
           (const :tag "complete block" complete)
           (const :tag "mixed mode" mixed))
  :group 'hrb
  )

(defconst hrb-keywords
  (list
   "for" "while" "until" "if" "class" "module"
   "case" "unless" "def" "begin" "do" "end")
  "Keywords to show matching for")


(defvar hrb-timer nil)
(defvar hrb-overlay nil)
(defvar hrb-overlay-1 nil)

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
      (condition-case err
          (hrb-execute)
        (error
         (setq hrb-mode nil)
         (message "Error: %S; disabling hrb-mode" err)))
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
            (pos (hrb-keyword-start (hrb-keyword-position (point))))
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
        (setq pos (point))
        )
      )
    )

  pos
  )


(defun hrb-do-hilight-keywords (start end)
  (save-excursion
    (goto-char start)
    (let (
          start1
          end1
          )

      (skip-chars-forward "A-Za-z0-9")
      (setq start1 (point))

      (skip-chars-backward "A-Za-z0-9")
      (setq end1 (point))

      (if hrb-overlay
          (move-overlay hrb-overlay start1 end1)
        (setq hrb-overlay (make-overlay start1 end1))
        )
      (overlay-put hrb-overlay
                   'face hrb-hilight-keyword-face)
      )

    (goto-char end)
    (let (
          start1
          end1
          )

      (skip-chars-forward "A-Za-z0-9")
      (setq start1 (point))

      (skip-chars-backward "A-Za-z0-9")
      (setq end1 (point))

      (if hrb-overlay-1
          (move-overlay hrb-overlay-1 start1 end1)
        (setq hrb-overlay-1 (make-overlay start1 end1))
        )
      (overlay-put hrb-overlay-1
                   'face hrb-hilight-keyword-face)
      )
    )
  )

(defun hrb-do-hilight-complete (start end)
  (if hrb-overlay
      (move-overlay hrb-overlay start end)
    (setq hrb-overlay (make-overlay start end))
    )

  (overlay-put hrb-overlay
               'face hrb-hilight-block-face)
  )

(defun hrb-do-hilight-mixed (start end)
  (catch 'return
    (save-excursion
      (goto-char start)

      (skip-chars-forward "A-Za-z0-9")
      (when (not (pos-visible-in-window-p (point)))
        (hrb-do-hilight-complete start end)
        (throw 'return t)
        )

      (skip-chars-backward "A-Za-z0-9")
      (when (not (pos-visible-in-window-p (point)))
        (hrb-do-hilight-complete start end)
        (throw 'return t)
        )

      (goto-char end)

      (skip-chars-forward "A-Za-z0-9")
      (when (not (pos-visible-in-window-p (point)))
        (hrb-do-hilight-complete start end)
        (throw 'return t)
        )

      (skip-chars-backward "A-Za-z0-9")
      (when (not (pos-visible-in-window-p (point)))
        (hrb-do-hilight-complete start end)
        (throw 'return t)
        )

      )

    (hrb-do-hilight-keywords start end)
    )
  )

(defun hrb-hilight (start end)
  (cond
   ((equal hrb-hilight-mode 'complete)
    (hrb-do-hilight-complete start end)
    )

   ((equal hrb-hilight-mode 'keywords)
    (hrb-do-hilight-keywords start end)
    )

   ((equal hrb-hilight-mode 'mixed)
    (hrb-do-hilight-mixed start end)
    )
   )

  (add-hook 'pre-command-hook 'hrb-stop-hilight)
  )

(defun hrb-stop-hilight ()
  "Remove overlay when done"
  (remove-hook 'pre-command-hook 'hrb-stop-hilight)

  (when hrb-overlay
      (delete-overlay hrb-overlay))
  (when hrb-overlay-1
      (delete-overlay hrb-overlay-1))
  )

(provide 'hrb-mode)

;; eof
