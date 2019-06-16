;; UI & Appearance

;;; Scrolling
(setq auto-window-vscroll nil)
;; the text cursor moves off-screen. Instead, only scroll the minimum amount
;; necessary to show the new line. (A number of 101+ disables re-centering.)
(setq scroll-conservatively 101)

;; Optimize mouse wheel scrolling for smooth-scrolling trackpad use.
;; Trackpads send a lot more scroll events than regular mouse wheels,
;; so the scroll amount and acceleration must be tuned to smooth it out.
(setq
 ;; If the frame contains multiple windows, scroll the one under the cursor
 ;; instead of the one that currently has keyboard focus.
 mouse-wheel-follow-mouse 't
 ;; Completely disable mouse wheel acceleration to avoid speeding away.
 mouse-wheel-progressive-speed nil
 ;; The most important setting of all! Make each scroll-event move 2 lines at
 ;; a time (instead of 5 at default). Simply hold down shift to move twice as
 ;; fast, or hold down control to move 3x as fast. Perfect for trackpads.
 mouse-wheel-scroll-amount '(2 ((shift) . 4) ((control) . 6)))

;;; Fonts
(defvar cpm-font (font-spec :family "InconsolataLGC Nerd Font" :size 13))
(defvar cpm-font2 (font-spec :family "Hasklug Nerd Font" :size 13))
(defvar cpm-font3 (font-spec :family "DejaVuSansMono Nerd Font" :size 13))
(defvar cpm-font4 (font-spec :family "SauceCodePro Nerd Font" :size 13))
(defvar cpm-ligatures nil)
(defvar cpm-vari-font (font-spec :family "Avenir"))
(defvar cpm-unicode-font (font-spec :family "Symbola"))
(set-face-attribute 'default nil :font cpm-font2)
(set-face-attribute 'variable-pitch nil :font cpm-vari-font)
(set-fontset-font t 'unicode cpm-unicode-font nil 'prepend)
(setq-default line-spacing 0.10)

;;; Frames
(setq frame-title-format "\n")
;; (setq frame-title-format '('nil))
    ;; (setq-default frame-title-format
    ;;           '((buffer-file-name "%f" "%b")))
(if (display-graphic-p)
  (progn
  ;; start frame of emacs maximized
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))

  ;; new frames
  (setq default-frame-alist
            '(
              (top . 25)
              (left . 275)
              (width . 106) ;; chars
              (height . 60) ;; lines
              ))))
(use-package ns-auto-titlebar
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

;; https://github.com/d12frosted/homebrew-emacs-plus/blob/master/Formula/emacs-plus.rb#L98
;; https://github.com/d12frosted/homebrew-emacs-plus/issues/55
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Properties-in-Mode.html#Properties-in-Mode
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
;; no border title
;; (setq default-frame-alist '((undecorated . t)))
 (when (not (display-graphic-p))
   (menu-bar-mode -1))

(defun cpm/disable-scroll-bars (frame)
  (modify-frame-parameters frame
                           '((vertical-scroll-bars . nil)
                             (horizontal-scroll-bars . nil))))
(add-hook 'after-make-frame-functions 'cpm/disable-scroll-bars)

;;; Scale Text
(global-set-key (kbd "s-=") 'text-scale-increase)
(global-set-key (kbd "s--") 'text-scale-decrease)
(global-set-key (kbd "s-0") 'text-scale-adjust)

;;; Line Numbers
(use-package line-numbers
  :ensure nil
  ;; :hook (markdown-mode prog-mode)
  :commands display-line-numbers-mode
  :init
  (setq-default display-line-numbers-type 'visual))

;;; Highlight
(use-package highlight-numbers
 :defer t
 :init
 (add-hook 'prog-mode-hook #'highlight-numbers-mode))

(use-package hl-todo
  :defer t
  :init
  ;; (add-hook 'org-mode-hook #'hl-todo-mode)
  (add-hook 'prog-mode-hook #'hl-todo-mode)
  (add-hook 'markdown-mode-hook #'hl-todo-mode))

;;; Icons
(use-package all-the-icons
 :demand t)
;;dependency
(use-package font-lock+
  :defer 1)
;; icons for dired
(use-package all-the-icons-dired
  :defer t
  :init
  (add-hook 'dired-mode-hook 'all-the-icons-dired-mode))

;;; Beacon
(use-package beacon
 :defer 5
 :config
 (beacon-mode 1)
 (add-to-list 'beacon-dont-blink-major-modes 'eshell-mode))

;;; Emoji
(use-package emojify
 :commands (emojify-mode emojify-apropos-emoji)
 ;; :hook ((prog-mode markdown-mode) . emojify-mode)
 :config
 (setq emojify-emojis-dir (concat cpm-etc-dir "emojis")))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'setup-ui)
