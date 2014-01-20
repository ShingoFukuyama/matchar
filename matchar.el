;;; matchar.el --- Move cursor to a character repeatedly with sequential input. Emacs Lisp -*- coding: utf-8; lexical-binding: t -*-

;; Copyright (C) 2014 by Shingo Fukuyama

;; Version: 0.1
;; Author: Shingo Fukuyama - http://fukuyama.co
;; URL: https://github.com/ShingoFukuyama/matchar
;; Created: Jan 19 2014
;; Keywords: char one character move
;; Package-Requires: ((emacs "24"))

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.

;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;;; Commentary:

;; Config
;; ;; Locate the matchar folder to your path
;; ;; This line is unnecessary, if you get this program from MELPA
;; (add-to-list 'load-path "~/.emacs.d/elisp/matchar")

;; (require 'matchar)

;; ;; Change keybinds to whatever you like :)
;; (global-set-key (kbd "M-f") 'matchar-forward)
;; (global-set-key (kbd "M-b") 'matchar-backward)

;; Usage
;; M-x matchar-forward a a a b b f f ...
;; M-x matchar-backward a a a b b f f ...

;;; Code:

(defgroup matchar nil
  "Open matchar"
  :prefix "matchar-" :group 'convenience)

(defvar matchar-swift-keys
  '("C-n" "C-p" "C-f" "C-b" "C-a" "C-e" "C-SPC" "C-y" "M-y"
    "C-@" "C-k" "C-d" "C-h" "C-t" "C-w" "M-w" "C-j" "C-m")
  "Stop searching and execute command immediately")
(defvar matchar-stop-keys '("C-g") "Just stop search")

(defvar matchar-swift-key-chars
      (mapcar (lambda (x) (aref (kbd x) 0)) matchar-swift-keys))
(defvar matchar-stop-key-chars
      (mapcar (lambda (x) (aref (kbd x) 0)) matchar-stop-keys))

;;; common parts ------------------------

(defun matchar-downcase-char-p ($c) (if (eq $c (downcase $c)) t nil))
(defun matchar-upcase-char-p ($c) (if (eq $c (upcase $c)) t nil))

;;; temporary variable for restore ------------------------

(defvar matchar-blink-cursor-default blink-cursor-mode)
(defvar matchar-cursor-color-default)
(defcustom matchar-cursor-color "#ff6600"
  "Temporarily override the cursor color"
  :group 'matchar
  :type 'string)

;;; core ------------------------

(defun matchar--set-default-cursor-color ()
  (unless (boundp 'matchar-cursor-color-default)
    (set (make-local-variable 'matchar-cursor-color-default)
         (car (loop for ($k . $v) in (frame-parameters)
                    if (eq $k 'cursor-color)
                    collect $v)))))

(defun matchar--restore-face ()
  (if matchar-blink-cursor-default (blink-cursor-mode 1))
  (set-cursor-color matchar-cursor-color-default))

(defun* matchar-forward-1 ()
  (unwind-protect
      (progn
        (if matchar-blink-cursor-default (blink-cursor-mode 0))
        (matchar--set-default-cursor-color)
        (set-cursor-color matchar-cursor-color)
        (re-search-forward "[^\s\t\n\r]" nil t)
        (backward-char)
        (condition-case nil
            (while (let (($c (read-key))
                         ($cn (char-after (point)))
                         (case-fold-search t))
                     (cond ((member $c matchar-swift-key-chars) ;; swift
                            (return-from matchar-forward
                              (execute-kbd-macro (vector $c))))
                           ((member $c matchar-stop-key-chars) ;; stop
                            (return-from matchar-forward
                              (message "search end")))
                           ((matchar-upcase-char-p $c) ;; upper case
                            (setq case-fold-search nil)
                            (unless (and mark-active (eq $c $cn))
                              (forward-char)))
                           ((eq (downcase $cn) $c)
                            (unless (and mark-active (eq $c $cn))
                              (forward-char)))
                           (t (message "")))
                     (if (search-forward (char-to-string $c) nil t)
                         t
                       (message "no more char")
                       ;;nil ;; stop
                       ))
              (unless mark-active (backward-char)))
          (error (message "search stop"))))
    (matchar--restore-face)))

(defun* matchar-backward-1 ()
  (unwind-protect
      (progn
        (if matchar-blink-cursor-default (blink-cursor-mode 0))
        (matchar--set-default-cursor-color)
        (set-cursor-color matchar-cursor-color)
        (re-search-backward "[^\s\t\n\r]" nil t)
        (forward-char)
        (condition-case nil
            (while (let (($c (read-key))
                         (case-fold-search t))
                     (cond ((member $c matchar-swift-key-chars) ;; swift
                            (return-from matchar-backward
                              (execute-kbd-macro (vector $c))))
                           ((member $c matchar-stop-key-chars) ;; stop
                            (return-from matchar-backward
                              (message "search end")))
                           ((matchar-upcase-char-p $c) ;; upper case
                            (setq case-fold-search nil))
                           (t (message "")))
                     (if (search-backward (char-to-string $c) nil t)
                         t
                       (message "no more char")
                       ;;nil ;; stop
                       )))
          (error (message "search stop"))))
    (matchar--restore-face)))

;;;###autoload
(defun matchar-forward ()
  (interactive)
  (matchar-forward-1))

;;;###autoload
(defun matchar-backward ()
  (interactive)
  (matchar-backward-1))

(provide 'matchar)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; matchar.el ends here
