;;;; FYI: read DOS text files 'find-file-literally'

(setq inhibit-startup-message t)
(setq inhibit-splash-screen t)
(menu-bar-mode nil)
(setq column-number-mode t)
(setq ispell-program-name  "aspell")

(custom-set-variables
 ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
 ;; Your init file should contain only one such instance.
 ;; '(auto-save-list-file-prefix (cond ((eq system-type (quote ms-dos)) "~/_emacs.d/auto-save.list/_s") (t "/var/tmp/lesnist/.emacs.d/auto-save-list/.saves-")))
 '(menu-bar-mode nil)
 '(tool-bar-mode nil nil (tool-bar)))
(custom-set-faces
 ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
 ;; Your init file should contain only one such instance.
 )

(when (>= emacs-major-version 22) (require 'ido) (ido-mode t) 
      (defun ido-execute ()
	(interactive)
	(call-interactively
	 (intern
	  (ido-completing-read
	   "M-x "
	   (let (cmd-list)
	     (mapatoms (lambda (S) (when (commandp S) (setq cmd-list (cons (format "%S" S) cmd-list)))))
	     cmd-list)))))
    
      (global-set-key "\M-x" 'ido-execute)

;; Make numbered backup
(setq version-control t)
(setq kept-new-versions 3)
(setq kept-old-versions 1)
(setq delete-old-versions t) ;; excess middle versions are deleted without a murmur

;;
;; EnablingFontLock
;;
;; Here's what you can put in your ~/.emacs file to enable font-lock
;; globally. It works for both Emacs and XEmacs.

(if (fboundp 'global-font-lock-mode)
    (global-font-lock-mode 1); Emacs
  (setq font-lock-auto-fontify t)); XEmacs
