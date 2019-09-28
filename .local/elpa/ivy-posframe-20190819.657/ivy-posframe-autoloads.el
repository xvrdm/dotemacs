;;; ivy-posframe-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "ivy-posframe" "ivy-posframe.el" (0 0 0 0))
;;; Generated autoloads from ivy-posframe.el

(defvar ivy-posframe-mode nil "\
Non-nil if Ivy-Posframe mode is enabled.
See the `ivy-posframe-mode' command
for a description of this minor mode.
Setting this variable directly does not take effect;
either customize it (see the info node `Easy Customization')
or call the function `ivy-posframe-mode'.")

(custom-autoload 'ivy-posframe-mode "ivy-posframe" nil)

(autoload 'ivy-posframe-mode "ivy-posframe" "\
Display ivy via posframe.

\(fn &optional ARG)" t nil)

(autoload 'ivy-posframe-enable "ivy-posframe" "\


\(fn)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "ivy-posframe" '(#("ivy-posframe-" 0 13 (face font-lock-function-name-face fontified t)))))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; ivy-posframe-autoloads.el ends here
