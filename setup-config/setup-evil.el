;;; Evil Mode

(use-package evil
  :defer .1 ;; don't block emacs when starting, load evil immediately after startup
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  :config
  (progn
    ;; Cursor shape and color
    (defcustom dotemacs-evil/emacs-cursor
      "red"
      "The color of the cursor when in Emacs state."
      :type 'color
      :group 'dotemacs-evil)

    (defcustom dotemacs-evil/emacs-insert-mode
      nil
      "If non-nil, insert mode will act as Emacs state."
      :type 'boolean
      :group 'dotemacs-evil)

    ;; move over visual lines like normal lines
    (general-define-key :states '(motion normal)
      "j"   #'evil-next-visual-line
      "k"   #'evil-previous-visual-line)

    (setq evil-search-module 'evil-search)
    (setq evil-magic 'very-magic)
    ;; (setq evil-want-C-i-jump nil)
    ;; Set colors for cursor states
    (setq evil-emacs-state-cursor '("SkyBlue2" box))
    (setq evil-normal-state-cursor '("DarkGoldenrod2" box))
    (setq evil-visual-state-cursor '("gray" box))
    (setq evil-insert-state-cursor '("chartreuse3" (bar . 2)))
    (setq evil-replace-state-cursor '("red" hbar))
    (setq evil-motion-state-cursor  '("plum3" box))
    (setq evil-operator-state-cursor '("red" hollow))
    ;; (setq evil-visual-state-tag "VISUAL")
                                        ;use insert in commits automatically
    (add-hook 'git-commit-mode-hook 'evil-insert-state)
    (evil-set-initial-state 'dashboard-mode 'motion)
    (evil-set-initial-state 'messages-buffer-mode 'motion)
    (evil-set-initial-state 'magit-log-edit-mode 'insert)
    (evil-set-initial-state 'org-agenda-mode 'motion)
    (evil-set-initial-state 'org-export-dispatch 'motion)
    ;; evil-normal-state is preferred, so revert when idle
    (run-with-idle-timer 60 t 'evil-normal-state)
    ;; don't echo evil state
    (setq evil-echo-state nil)
    ;; don't move cursor back when exiting insert state
    (setq evil-move-cursor-back nil)
    ;; move by visual lines
    (setq evil-respect-visual-line-mode t)
    ;; Use counsel to provide :ls
    (evil-ex-define-cmd "buffers" 'counsel-ibuffer)
    ;; evil everywhere
    (evil-mode 1)))

;;; Evil Collection
(use-package evil-collection
  :ensure t
  :after evil
  :hook (evil-after-load-hook . evil-collection-init)
  :custom (evil-collection-company-use-tng nil)
  :init
  (evil-collection-init))

;;; Evil Indent
(use-package evil-indent-textobject :commands (evil-indent))

;;; Evil Surround
(use-package evil-surround
  :defer 1
  :commands (evil-surround-region evil-surround-change evil-surround-delete)
  :general
  (:states '(visual)
   "s" 'evil-surround-region
   "S" 'evil-substitute)
  :config (global-evil-surround-mode 1))

(use-package evil-embrace
  :after evil-surround
  :demand t
  :hook ((markdown org) . embrace-org-mode-hook)
  :config
  (with-eval-after-load 'evil-surround
    (evil-embrace-enable-evil-surround-integration))
  (setq evil-embrace-show-help-p nil)
  (add-hook 'org-mode-hook 'embrace-org-mode-hook)
  (defun embrace-markdown-mode-hook ()
    (dolist (lst '((?* "*" . "*")
                   (?\ "\\" . "\\")
                   (?$ "$" . "$")
                   (?/ "/" . "/")))
      (embrace-add-pair (car lst) (cadr lst) (cddr lst))))
  (add-hook 'markdown-mode-hook 'embrace-markdown-mode-hook))

;;; Evil Comments
(use-package evil-commentary
  :commands (evil-commentary evil-commentary-line)
  :config
  (evil-commentary-mode))

;;; Evil Undo
;; there are problems but there doesn't seem to be a workaround
;; https://github.com/emacs-evil/evil/issues/1074 and
;; http://ergoemacs.org/emacs/emacs_best_redo_mode.html
;; So disable undo-tree; have to do this manually b/c it is automatically loaded by evil
(use-package undo-tree
  :config
  (global-undo-tree-mode -1))

;; (use-package undo-tree
;;   ;; :commands (undo-tree-undo undo-tree-redo undo-tree-visualize)
;;   :init
;;   (setq undo-tree-visualizer-timestamps t)
;;   (setq undo-tree-visualizer-diff t)
;;   (setq undo-tree-enable-undo-in-region nil)
;;   ;; supposedly causes errors in undo read
;;   ;; see https://emacs.stackexchange.com/a/34214/11934
;;   (setq undo-tree-enable-undo-in-region nil)
;;   ;; stop littering - set undo directory
;;   (let ((undo-dir (concat cpm-cache-dir "undo")))
;;     (setq undo-tree-history-directory-alist `(("." . ,undo-dir)))
;;     (unless (file-directory-p undo-dir)
;;       (make-directory undo-dir t)))
;;   (setq undo-tree-auto-save-history nil)
;;   :config
;;   (global-undo-tree-mode -1))

;; trying another undo package
;; https://gitlab.com/ideasman42/emacs-undo-fu
(use-package undo-fu
  :general
  (:states '(normal)
   "u" 'undo-fu-only-undo
   "\C-r" 'undo-fu-onlu-redo)
  (:states '(normal insert motion emacs)
   "s-z" 'undo-fu-only-undo
   "s-Z" 'undo-fu-only-redo))

;; persistent undo across sessions
(use-package undo-fu-session
  :after evil
  :config
  (setq undo-fu-session-file-limit 50)
  (setq undo-fu-session-directory (concat cpm-cache-dir "undo-fu-session"))
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'")))
(with-eval-after-load 'undo
  (global-undo-fu-session-mode))


;;; Evil Multi-Cursor
(use-package evil-visualstar
  :commands (evil-visualstar/begin-search-forward evil-visualstar/begin-search-backward))

(use-package evil-multiedit
  :ensure t
  :after evil-visualstar
  :config
  ;; Default keybindings
  ;; Highlights all matches of the selection in the buffer.
  (define-key evil-visual-state-map "R" 'evil-multiedit-match-all)

  ;; Match the word under cursor (i.e. make it an edit region). Consecutive presses will
  ;; incrementally add the next unmatched match.
  (define-key evil-normal-state-map (kbd "M-d") 'evil-multiedit-match-and-next)
  ;; Match selected region.
  (define-key evil-visual-state-map (kbd "M-d") 'evil-multiedit-and-next)
  ;; Insert marker at point
  (define-key evil-insert-state-map (kbd "M-d") 'evil-multiedit-toggle-marker-here)

  ;; Same as M-d but in reverse.
  (define-key evil-normal-state-map (kbd "M-D") 'evil-multiedit-match-and-prev)
  (define-key evil-visual-state-map (kbd "M-D") 'evil-multiedit-and-prev)

  ;; OPTIONAL: If you prefer to grab symbols rather than words, use
  ;; `evil-multiedit-match-symbol-and-next` (or prev).

  ;; Restore the last group of multiedit regions.
  (define-key evil-visual-state-map (kbd "C-M-D") 'evil-multiedit-restore)

  ;; RET will toggle the region under the cursor
  (define-key evil-multiedit-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)

  ;; ...and in visual mode, RET will disable all fields outside the selected region
  (define-key evil-motion-state-map (kbd "RET") 'evil-multiedit-toggle-or-restrict-region)

  ;; For moving between edit regions
  (define-key evil-multiedit-state-map (kbd "C-n") 'evil-multiedit-next)
  (define-key evil-multiedit-state-map (kbd "C-p") 'evil-multiedit-prev)
  (define-key evil-multiedit-insert-state-map (kbd "C-n") 'evil-multiedit-next)
  (define-key evil-multiedit-insert-state-map (kbd "C-p") 'evil-multiedit-prev)

  ;; Ex command that allows you to invoke evil-multiedit with a regular expression, e.g.
  (evil-ex-define-cmd "ie[dit]" 'evil-multiedit-ex-match))

(use-package evil-mc
  :ensure t
  :commands (evil-mc-make-all-cursors evil-mc-make-and-goto-next-match))


;;; Evil Numbers
(use-package evil-numbers
  :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-pt)
  :init
  (general-define-key
   :states '(normal visual insert emacs)
   "H-s" 'evil-numbers/inc-at-pt
   "H-a" 'evil-numbers/dec-at-pt))

;;; Evil Owl (Markers)
(use-package evil-owl
  :ensure t
  :after evil
  :general
  (:keymaps 'evil-owl-popup-map
   "C-j" #'evil-owl-scroll-popup-down
   "C-k" #'evil-owl-scroll-popup-up)
  :config
  (setq evil-owl-display-method 'posframe
        evil-owl-extra-posframe-args '(:width 50 :height 20 :internal-border-width 10 :background-color "#073642")
        evil-owl-max-string-length 50)
  (setq evil-owl-header-format      "%s"
        evil-owl-register-format    " %r: %s"
        evil-owl-local-mark-format  " %m: %s"
        evil-owl-global-mark-format " %m: %b %s"
        evil-owl-separator          "\n"
        evil-owl-idle-delay 0.25)
  (evil-owl-mode))

;;; End Evil-Packages
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'setup-evil)

