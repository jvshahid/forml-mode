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

(defvar forml-keywords-regexp
  (regexp-opt '("open" "Functor" "Monad")))

(defvar forml-string-regexp "\".*\"")

;; The language keywords
(defvar forml-font-lock-keywords
  ;; order matters but how ?
  `((,forml-string-regexp . font-lock-string-face)
    (,forml-keywords-regexp . font-lock-keyword-face)))

;;;
(define-derived-mode forml-mode fundamental-mode
  "Forml"
  "Major mode for editing Forml."

  ;; code for syntax highlighting
  (setq font-lock-defaults '((forml-font-lock-keywords)))

  ;; perl style comment: "# ..."
  (modify-syntax-entry ?- "- 12" forml-mode-syntax-table)
  (modify-syntax-entry ?\n ">" forml-mode-syntax-table)

  ;; no tabs
  (setq indent-tabs-mode nil))

;;; autoload
(add-to-list 'auto-mode-alist '("\\.forml$" . forml-mode))
