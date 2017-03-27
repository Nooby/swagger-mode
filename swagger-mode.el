;;; swagger-mode.el --- Swagger Helper Mode.

;; Copyright (C) 2017  Giuliano Di Pasquale

;; Author: Giuliano Di Pasquale <dipasqualegiuliano@gmail.com>
;; URL: https://github.com/Nooby/swagger-mode
;; Keywords: tools
;; Version: 0
;; Package-Requires: ((emacs "24"))

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;;; Swagger Mode is a Minor Mode that offers compile and preview functions for Swagger Codegen.

;;; Code:

;;; Settings
;;;###autoload
(defgroup swagger nil
  "Minor mode for Swagger Codegen."
  :link '(url-link "https://github.com/Nooby/swagger-mode")
  :group 'programming
  :prefix "swagger-")

(defcustom swagger-codegen-cli "swagger-codegen"
  "Path to the Swagger Codegen cli."
  :group 'swagger
  :type 'string)

(defcustom swagger-command-template "generate -i %s -l %s -o %s"
  "Template to generate swagger command."
  :group 'swagger
  :type 'string)

(defcustom swagger-compile-lang "html2"
  "Language Template for preview compilation."
  :group 'swagger
  :type 'string)

(defcustom swagger-preview-lang "html2"
  "Language Template for preview compilation."
  :group 'swagger
  :type 'string)

;;; Variables
(make-variable-buffer-local
 (defvar swagger-out-path "out"
   "Output path for compilation."))

(make-variable-buffer-local
 (defvar swagger-out-preview-path nil
   "Output path for the preview compilation."))

;;; Funcs
(defun swagger--compile (path lang out)
  "Compile PATH with the LANG template to path OUT."
  (let ((buffer "*swagger-compile*")
        (arguments (format swagger-command-template path lang out)))
    (when (get-buffer buffer)
      (kill-buffer buffer))
    (let ((return (call-process swagger-codegen-cli nil buffer t arguments)))
      (if (not (eq return 0))
          (pop-to-buffer (get-buffer buffer)))
      return)))

(defun swagger-compile (lang)
  "Compile Swagger File with template LANG."
  (interactive "sLang: ")
  (unless lang (setq lang swagger-preview-lang))
  (swagger--compile (buffer-file-name) lang swagger-out-path))

(defun swagger-export ()
  "Compile Swagger file with standard settings."
  (interactive)
  (swagger--compile (buffer-file-name)
                    swagger-compile-lang
                    swagger-out-path))

(defun swagger-preview ()
  "Preview Swagger file in default browser."
  (interactive)
  (let* ((ret (swagger--compile (buffer-file-name)
                                swagger-preview-lang
                                swagger-out-preview-path))
         (file_url (concat "file://" swagger-out-preview-path "/index.html")))
    (if (eq ret 0)
        (browse-url file_url))))

(defun swagger-after-save-handler ()
  "Used in 'after-save-hook'."
  (when (bound-and-true-p swagger-mode)
    (swagger--compile (buffer-file-name)
                      swagger-preview-lang
                      swagger-out-preview-path)))

;;; Mode Setup
;;;###autoload
(define-minor-mode swagger-mode
  "Minor mode for Swagger Codegen"
  :lighter " swagger"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "M-s c") 'swagger-compile)
            (define-key map (kbd "M-s e") 'swagger-export)
            (define-key map (kbd "M-s p") 'swagger-preview)
            map)

  (unless swagger-out-preview-path
    (setq swagger-out-preview-path
          (make-temp-file "swagger" t)))

  (if (bound-and-true-p swagger-mode)
      (add-hook 'after-save-hook 'swagger-after-save-handler nil t)
    (remove-hook 'after-save-hook 'swagger-after-save-handler t)))

(provide 'swagger-mode)
;;; swagger-mode.el ends here
