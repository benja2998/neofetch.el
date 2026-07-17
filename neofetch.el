;; neofetch.el  -*- lexical-binding: t; -*-

;; Neofetch program written in pure Emacs Lisp. Does not require any external programs and runs on any operating system.
;; Copyright (C) 2026 benja2998

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;;
;;; Utils
;;;

(defun neofetch--pairs-to-plist (pairs)
  "Convert PAIRS into a plist.

PAIRS is expected to be a list of (\"key\" value) elements.

As an example, '((\"a\" 1) (\"b\" help)) is converted to (:a 1 :b help)."
  (apply #'append
		 (mapcar (lambda (p)
				   (list (intern (concat ":" (car p)))
						 (cadr p)))
				 pairs)))

(defun neofetch--get-file-contents (filename)
  "Return the contents of file FILENAME.

Signals an error when FILENAME can't be read."
  (with-temp-buffer
	(insert-file-contents filename)
	(buffer-string)))

(defun neofetch--get-file-contents-of-first-readable-file (&rest filenames)
  "Return the contents of the first readable file in FILENAMES.

If no file can be read, return nil."
  (when-let* ((file (seq-find #'file-readable-p filenames)))
	(neofetch--get-file-contents file)))

;;;
;;; Exclusive to the 'android' 'system-type'.
;;;

(defun neofetch--android-get-prop (prop)
  "Return an Android system property or nil."
  (car (ignore-error 'error
		 (process-lines "getprop" prop))))

(defun neofetch--android-get-pretty-name ()
  "Return a pretty representation of the OS name for Android systems.

Return nil if no pretty representation could be found."
  (let* ((release (neofetch--android-get-prop "ro.product.build.version.release")))
	(format "Android %s" release)))

;;;
;;; Exclusive to the 'gnu/linux' 'system-type'.
;;;

(defun neofetch--gnu-linux-read-os-release ()
  "Return the contents of the \"os-release\" file.

If no \"os-release\" file could be read, return nil.

For details: https://www.man7.org/linux/man-pages/man5/os-release.5.html"
  (neofetch--get-file-contents-of-first-readable-file "/etc/os-release" "/usr/lib/os-release"))

(defun neofetch--gnu-linux-get-os-release-plist ()
  "Return a plist with OS identification data for GNU/Linux systems.

For details: https://www.man7.org/linux/man-pages/man5/os-release.5.html"
  (neofetch--pairs-to-plist
   (mapcar (lambda (cons)
			 `(,(string-replace "_" "-" (downcase (car cons)))
			   ,(string-replace "\"" "" (or (cadr cons) ""))))
		   (mapcar (lambda (line)
					 (split-string line "="))
				   (split-string (or (neofetch--gnu-linux-read-os-release) "") "\n" t)))))

(defun neofetch--gnu-linux-get-distro-pretty-name ()
  "Return a pretty representation of the OS name for GNU/Linux systems.

Return nil if no pretty representation could be found."
  (plist-get (neofetch--gnu-linux-get-os-release-plist) :pretty-name))

;;;
;;; Common
;;;

(defun neofetch--get-os-pretty-name ()
  "Return a pretty representation of the OS name."
  (pcase system-type
	('gnu			"GNU Hurd")
	('gnu/linux     (or (neofetch--gnu-linux-get-distro-pretty-name)
						"GNU/Linux"))
	('gnu/kfreebsd	"GNU/FreeBSD")
	('darwin		"Darwin")			; GNU-Darwin / macOS
	('ms-dos		"MS-DOS")
	('windows-nt	"Microsoft Windows")
	('cygwin		"Cygwin")
	('haiku			"Haiku")
	('android		(or (neofetch--android-get-pretty-name)
						"Android"))
	(_ (symbol-name system-type))))

;;;
;;; Entry point
;;;

(defun neofetch (&optional logo-path)
  "Neofetch program written in pure Emacs Lisp. Does not require any external programs and runs on any operating system."

  (catch 'not-in-eshell
	(if (not (eq major-mode 'eshell-mode))
		(throw 'not-in-eshell "Not in eshell")
	  )
	)

  (when (display-graphic-p)
	(when logo-path
	  (insert-image (create-image logo-path))
	  (insert (format "\n"))
	  )
	)

  (insert (concat
		  ;;; username@hostname

		   (propertize (user-login-name) 'font-lock-face '(:foreground "purple"))
		   "@"
		   (propertize (system-name) 'font-lock-face '(:foreground "purple"))
		   (format "\n")

		  ;;; Horizontal line

		   "-------------------------"

		   (format "\n")

		  ;;; OS: system-type

		   (propertize "OS" 'font-lock-face '(:foreground "cyan"))
		   (format ": %s\n" (neofetch--get-os-pretty-name))

		  ;;; Emacs version: emacs-version

		   (propertize "Emacs version" 'font-lock-face '(:foreground "cyan"))
		   (format ": %s\n" emacs-version)

		  ;;; Emacs uptime: emacs-uptime

		   (propertize "Emacs uptime" 'font-lock-face '(:foreground "cyan"))
		   ": "
		   (emacs-uptime)
		   (format "\n")

		  ;;; Emacs startup time: emacs-init-time

		   (propertize "Emacs startup time" 'font-lock-face '(:foreground "cyan"))
		   ": "
		   (emacs-init-time)
		   (format "\n")

		  ;;; Processors: num-processors

		   (propertize "Processors" 'font-lock-face '(:foreground "cyan"))
		   ": "
		   (format "%s" (num-processors))
		   (format "\n")

		  ;;; Running Emacs sub-processes: process-count

		   (propertize "Running Emacs sub-processes" 'font-lock-face '(:foreground "cyan"))
		   ": "
		   (format "%s" (length (process-list)))
		   (format "\n")
		   ))
  (eshell-interrupt-process)
  (keyboard-quit)
  )

(provide 'neofetch)
