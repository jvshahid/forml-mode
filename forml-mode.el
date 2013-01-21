;; forml-mode.el --- Major mode to edit Forml files in Emacs
;; Copyright (C) 2013 John Shahid

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

(require 'font-lock)

(defconst forml-mode-version "0.1"
  "The version of `forml-mode'.")

(defgroup forml nil
  "A Formal major mode."
  :group 'languages)

(defcustom forml-tab-width tab-width
  "The tab width to use when indenting."
  :type 'integer
  :group 'forml)

(defcustom forml-mode-hook nil
  "Hook called by `forml-mode'."
  :type 'hook
  :group 'forml)

(setq forml-keywords-regexp
      (regexp-opt '("open" "module" "private" "as" "do" "do!" "let" "inline" "yield" "var"
                    "if" "then" "else" "when" "and" "or" "lazy" "in" "is" "isnt") 'words))

(setq forml-keywords-symbol-regex
      (regexp-opt '("<-" "->" "\s |\s " "λ" "|>" "<|")))

(setq forml-operators-regex
      (regexp-opt
       '("*" "/" "==" "!=" "/=" "||" "&&" "+" "-" "++" "::" ":::" "<=" ">=" "<:") 'symbols))

(setq forml-type-regexp "\\<[[:upper:]]\\w+\\>")

(setq forml-fun-inline-def-regexp
      "^\\W*\\(?:inline\\|let\\|var\\)\\s +(?\\(\\w+\\))?[^=\n]+=[^=][^\n]*$")

(setq forml-fun-def-regexp
      "^\\W*\\(\\w+\\)[^=\n]+=[^=][^\n]*$")

(setq forml-fun-def-paran-regexp
      "^\\W*(\\(\\w+\\))[^=\n]+=[^=][^\n]*$")

(setq forml-fun-decl-regexp
      "(?\\(\\w+\\))?[ \t]*:")

(setq forml-constant-regexp
      "[0-9\\.]+\\|true\\|false")

(setq forml-nil-regexp
      "nil")

;; The language keywords
(setq forml-font-lock-keywords
  ;; order matters but how ?
    `((,forml-keywords-regexp           . font-lock-keyword-face)
      (,forml-keywords-symbol-regex     . font-lock-keyword-face)
      (,forml-type-regexp               . font-lock-type-face)
      (,forml-constant-regexp           . font-lock-constant-face)
      (,forml-operators-regex           . font-lock-variable-name-face)
      (,forml-nil-regexp                . font-lock-constant-face)
      (,forml-fun-decl-regexp           . (1 font-lock-function-name-face))
      (,forml-fun-inline-def-regexp     . (1 font-lock-function-name-face))
      (,forml-fun-def-paran-regexp      . (1 font-lock-function-name-face))
      (,forml-fun-def-regexp            . (1 font-lock-function-name-face))))

(defun forml-mode-parse-buffer-name (name)
  (if (string-match
       "forml-javascript-\\(.*\\)-\\([[:digit:]]+\\)-\\([[:digit:]]+\\)"
       name)
      (progn
        (let ((name (match-string 1 name))
              (beg (string-to-number (match-string 2 name)))
              (end (string-to-number (match-string 3 name))))
          (list name beg end)))
    (error "What the fuck ?")))

(defun forml-mode-pad-buffer (buffer nospaces)
  (save-excursion
    (set-buffer buffer)
    (let ((lines (count-lines (point-min) (point-max))))
      (dolist (i (number-sequence 2 lines))
           (goto-line i)
           (end-of-line)
           (if (> (current-column) 0)
               (progn
                 (beginning-of-line)
                 (insert-char ? nospaces)))))))

(defun forml-mode-copy-javascript-content-back ()
  (interactive)
  (let* ((temp-buffer      (current-buffer))
         (temp-buffer-name (buffer-name temp-buffer))
         (delim            (forml-mode-parse-buffer-name temp-buffer-name))
         (name             (pop delim))
         (buffer           (get-buffer name))
         (beg              (pop delim))
         (end              (pop delim)))
    (if (and buffer
             (switch-to-buffer buffer)
             (= (char-after beg) ?`)
             (= (char-after end) ?`))
        ;; we're inside a javascript string
        (save-excursion
          (goto-char beg)
          (forml-mode-pad-buffer temp-buffer (+ (current-column) 1))
          (goto-char end)
          (delete-region (+ beg 1) end)
          (insert-buffer-substring-no-properties temp-buffer)
          (kill-buffer temp-buffer)))))

(defun forml-mode-open-javascript-buffer (beg end)
  (let* ((buffer-name (concat "forml-javascript-"
                             (buffer-name) "-"
                             (number-to-string beg) "-"
                             (number-to-string end)))
         (old-buffer (current-buffer))
         (new-buffer (get-buffer-create buffer-name)))
    ;; (split-window-right)
    ;; (other-window 1)
    (switch-to-buffer new-buffer)
    (javascript-mode)
    (local-set-key (kbd "C-x C-s") 'forml-mode-copy-javascript-content-back)
    (insert-buffer-substring-no-properties old-buffer (+ beg 1) end)
    (indent-region (point-min) (point-max))))

(defun forml-mode-inside-string? (point)
  (eq (get-text-property point 'face) 'font-lock-string-face))

(defun forml-mode-find-string-del (backward)
  (save-excursion
    (let* ((fun (if backward 're-search-backward 're-search-forward))
           (limit (if backward (point-min) (point-max)))
           (found (funcall fun "\"\\|`" limit t)))
      (if found
          (let* ((outside (if backward (- (point) 1) (point)))
                 (delim (if backward (+ outside 1) (- outside 1))))
            (if (forml-mode-inside-string? outside)
                (progn
                  (goto-char outside)
                  (forml-mode-find-string-del backward))
              delim))
        ;; what the fuck, where's the string delimiter
        ))))

(defun forml-mode-is-javascript-string? (point)
  (if (forml-mode-inside-string? point)
      ;; we're inside a string quote, find out whether it is a string or javascript string
      (progn
        (let ((start (forml-mode-find-string-del t))
              (end (forml-mode-find-string-del nil)))
          (if (and (= (char-after start) ?`) (= (char-after end) ?`))
              (list start end))))
    nil))

(defun forml-mode-edit-javascript ()
  "Edit the javascript under the point or create a new javascript string.
   The command will open a new buffer with the content of the javascript
   string and set the mode of the new buffer to javascript-mode"
  (interactive)
  (let ((buffer-delim (forml-mode-is-javascript-string? (point))))
    (if buffer-delim
        (let* ((beg (pop buffer-delim))
               (end (pop buffer-delim)))
          (forml-mode-open-javascript-buffer beg end))
      (let* ((beg (point))
             (end (+ beg 1)))
        (insert "``")
        (goto-char end)
        (forml-mode-open-javascript-buffer beg end)))))

;;;
(define-derived-mode forml-mode fundamental-mode
  "Forml"
  "Major mode for editing Forml."

  ;; code for syntax highlighting
  (setq font-lock-defaults '((forml-font-lock-keywords)))

  ;; _ can be part of identifier
  (modify-syntax-entry ?_ "w" forml-mode-syntax-table)
  (modify-syntax-entry ?+ "w" forml-mode-syntax-table)
  (modify-syntax-entry ?- "w" forml-mode-syntax-table)
  (modify-syntax-entry ?/ "w" forml-mode-syntax-table)
  (modify-syntax-entry ?* "w" forml-mode-syntax-table)
  (modify-syntax-entry ?^ "w" forml-mode-syntax-table)
  (modify-syntax-entry ?? "w" forml-mode-syntax-table)
  (modify-syntax-entry ?> "w" forml-mode-syntax-table)
  (modify-syntax-entry ?< "w" forml-mode-syntax-table)
  (modify-syntax-entry ?= "w" forml-mode-syntax-table)
  (modify-syntax-entry ?| "w" forml-mode-syntax-table)
  (modify-syntax-entry ?& "w" forml-mode-syntax-table)
  (modify-syntax-entry ?! "w" forml-mode-syntax-table)
  (modify-syntax-entry ?: "w" forml-mode-syntax-table)

  (modify-syntax-entry ?\" "\"" forml-mode-syntax-table)
  (modify-syntax-entry ?` "\"" forml-mode-syntax-table)

  ;; comments
  (modify-syntax-entry ?- "- 12" forml-mode-syntax-table)
  (modify-syntax-entry ?\n ">" forml-mode-syntax-table)

  ;; no tabs
  (setq indent-tabs-mode nil))


(define-key forml-mode-map (kbd "C-c C-j") 'forml-mode-edit-javascript)

;;; autoload
(add-to-list 'auto-mode-alist '("\\.forml$" . forml-mode))

(provide 'forml-mode)
