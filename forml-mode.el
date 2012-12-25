;; forml-mode.el --- Major mode to edit Forml files in Emacs

;; Copyright (C) 2012 John Shahid

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

;;; autoload
(add-to-list 'auto-mode-alist '("\\.forml$" . forml-mode))

(provide 'forml-mode)
