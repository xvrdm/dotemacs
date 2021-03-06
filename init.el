;; init.el  -*- lexical-binding: t; mode: emacs-lisp; coding:utf-8; fill-column: 80 -*-
;;; Commentary:
;; Base init file to load config. Use "outshine-cycle-buffer" (<Tab> and <S-Tab>
;; in org style) to navigate through sections, and "imenu" to locate individual
;; use-package definition.

;;; Startup
;;;; Speed up startup
;; Help speed up emacs initialization
;; See https://blog.d46.us/advanced-emacs-startup/
;; and http://tvraman.github.io/emacspeak/blog/emacs-start-speed-up.html
;; and https://www.reddit.com/r/emacs/comments/3kqt6e/2_easy_little_known_steps_to_speed_up_emacs_start/

(defvar cpm--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;;;; Garbage collection
;; Adjust garbage collection thresholds during startup, and thereafter
;; see http://akrl.sdf.org
;; https://gitlab.com/koral/gcmh
;; NOTE: The system linked above generates too many GC pauses so I'm using my own mixed setup
;; https://github.com/purcell/emacs.d/blob/3b1302f2ce3ef2f69641176358a38fd88e89e664/init.el#L24

(let ((normal-gc-cons-threshold (* 20 1024 1024))
      (init-gc-cons-threshold (* 128 1024 1024)))
  (setq gc-cons-threshold init-gc-cons-threshold)
  (add-hook 'emacs-startup-hook
            (lambda () (setq gc-cons-threshold normal-gc-cons-threshold))))

(defmacro k-time (&rest body)
  "Measure and return the time it takes evaluating BODY."
  `(let ((time (current-time)))
     ,@body
     (float-time (time-since time))))

;; When idle for 15sec run the GC no matter what.
(defvar k-gc-timer
  (run-with-idle-timer 15 t
                       (lambda ()
                         (message "Garbage Collector has run for %.06fsec"
                                  (k-time (garbage-collect))))))

;;;; Check Errors
;; Produce backtraces when errors occur
(setq debug-on-error nil)

;;;; Clean View
;; Disable start-up screen
(setq-default inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq initial-scratch-message "")
(setq frame-inhibit-implied-resize t)

;; UI - Disable visual cruft
(unless (eq window-system 'ns)
  (menu-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

;; Quick start scratch buffer
(setq initial-major-mode 'fundamental-mode)

;; echo buffer
;; Don't display any message
;; https://emacs.stackexchange.com/a/437/11934
(defun display-startup-echo-area-message ()
  (message ""))

;; And bury the scratch buffer, don't kill it
(defadvice kill-buffer (around kill-buffer-around-advice activate)
  (let ((buffer-to-kill (ad-get-arg 0)))
    (if (equal buffer-to-kill "*scratch*")
        (bury-buffer)
      ad-do-it)))

;;;; Directory Variables
;;  We're going to define a number of directories that are used throughout this
;;  configuration to store different types of files.

(defconst cpm-emacs-dir (expand-file-name user-emacs-directory)
  "The path to the emacs.d directory.")

(defconst cpm-local-dir (concat cpm-emacs-dir ".local/")
  "Root directory for local Emacs files. Use this as permanent
  storage for files that are safe to share across systems (if
  this config is symlinked across several computers).")

(defconst cpm-temp-dir (concat cpm-local-dir "temp/")
  "Directory for non-essential file storage. Used by
  `cpm-etc-dir' and `cpm-cache-dir'.")

(defconst cpm-etc-dir (concat cpm-temp-dir "etc/")
  "Directory for non-volatile storage. These are not deleted or
  tampered with by emacs functions. Use this for dependencies
  like servers or config files that are stable (i.e. it should be
  unlikely that you need to delete them if something goes
  wrong).")

(defconst cpm-cache-dir (concat cpm-temp-dir "cache/")
  "Directory for volatile storage. Use this for transient files
  that are generated on the fly like caches and temporary files.
  Anything that may need to be cleared if there are problems.")

(defconst cpm-elisp-dir (concat cpm-local-dir "elisp/")
  "Where personal elisp packages and scripts are stored.")

(defconst cpm-setup-dir (concat cpm-emacs-dir "setup-config/")
  "Where the setup-init files are stored.")

;;;; System Variables
(defconst sys/macp
  (eq system-type 'darwin)
  "Are we running on a Mac system?")

(defconst sys/mac-x-p
  (and (display-graphic-p) sys/macp)
  "Are we running under X on a Mac system?")

;;;; Path Settings
;; Directory paths
(dolist (dir (list cpm-local-dir cpm-etc-dir cpm-cache-dir cpm-elisp-dir cpm-setup-dir))
  (unless (file-directory-p dir)
    (make-directory dir t)))

;; Exec path -- Emacs won't know where to load things without this
(defconst cpm-local-bin (concat (getenv "HOME") "/bin") "Local execs.")
(defconst usr-local-bin "/usr/local/bin")
(defconst usr-local-sbin "/usr/local/sbin")
(setenv "PATH" (concat usr-local-bin ":" usr-local-sbin ":" (getenv "PATH") ":" cpm-local-bin))
(setq exec-path (append exec-path (list cpm-local-bin usr-local-sbin usr-local-bin)))


;;;; Security
;; Properly verify outgoing ssl connections.
;; See https://glyph.twistedmatrix.com/2015/11/editor-malware.html

(setq gnutls-verify-error t
      tls-checktrust gnutls-verify-error
      tls-program (list "gnutls-cli --x509cafile %t -p %p %h"
                        ;; compatibility fallbacks
                        "gnutls-cli -p %p %h"
                        "openssl s_client -connect %h:%p -no_ssl2 -no_ssl3 -ign_eof")
      nsm-settings-file (expand-file-name "network-security.data" cpm-cache-dir))
;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=34341
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;;;; Byte Compile Warnings
;; Disable certain byte compiler warnings to cut down on the noise. This is a
;; personal choice and can be removed if you would like to see any and all byte
;; compiler warnings.
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

;;;; Package Initialization Settings
;; we're setting `package-enable-at-startup` to nil so that packages will not
;; automatically be loaded for us since use-package will be handling that.

(eval-and-compile
  (setq package-user-dir (concat cpm-local-dir "elpa/"))
  (setq load-prefer-newer t ;; use newest version of file
        ;; Ask package.el to not add (package-initialize) to .emacs
        package--init-file-ensured t)
  ;; don't set if emacs 27
  (when (version< emacs-version "27.0")
    (setq package-enable-at-startup nil))
  ;; make the package directory
  (unless (file-directory-p package-user-dir)
    (make-directory package-user-dir t)))


;;;; Load Path
;; We're going to set the load path ourselves so that we don't have to call
;; `package-initialize` at runtime and incur a large performance hit. This
;; load-path will actually be faster than the one created by
;; `package-initialize` because it appends the elpa packages to the end of the
;; load path. Otherwise any time a builtin package was required it would have to
;; search all of third party paths first.
(eval-and-compile
  (setq load-path (append load-path (directory-files package-user-dir t "^[^.]" t)))
  (push cpm-setup-dir load-path))

;;; Use-Package Settings
;; I tell use-package to always defer loading packages unless explicitly told
;; otherwise. This speeds up initialization significantly as many packages are
;; only loaded later when they are explicitly used. But it can also cause
;; problems:
;; https://github.com/jwiegley/use-package#loading-packages-in-sequence. I also
;; put a lot of loading of packages off until after some number of seconds of idle. The
;; latter means package loading stays out of my way if I'm doing, e.g., a quick
;; restart-and-check of something in emacs.

(setq use-package-always-defer t
      use-package-verbose t
      use-package-minimum-reported-time 0.01
      use-package-enable-imenu-support t
      use-package-always-ensure t)

(eval-when-compile
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ;; ("gnu" . "https://elpa.gnu.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ;; https://github.com/emacs-china/emacswiki-elpa
                           ("emacswiki" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/emacswiki/")
                           ))
  (require 'package)
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package))

;; initialize packages after evil has loaded
(add-hook 'evil-after-load-hook 'package-initialize)
;; refresh package list after load
(with-eval-after-load 'evil (package-refresh-contents 'async))

;;;; Benchmark Init
(use-package benchmark-init
  :ensure t
  ;; demand when using
  ;; :demand t
  :config
  ;; To disable collection of benchmark data after init is done.
  (add-hook 'emacs-startup-hook 'benchmark-init/deactivate))

;;;; Paradox Package Management
;; Better interface for package management https://github.com/Malabarba/paradox
(use-package paradox
  :commands (paradox-list-packages paradox-upgrade-packages)
  :init
  (setq paradox-github-token nil)
  :config
  (add-to-list 'evil-emacs-state-modes 'paradox-menu-mode)
  (setq paradox-execute-asynchronously nil
        ;; Show all possible counts
        paradox-display-download-count t
        paradox-display-star-count t
        ;; Don't star automatically
        paradox-automatically-star nil))

;;;; Quelpa
;; Get emacs packages from anywhere:
;; https://github.com/quelpa/quelpa#installation and use with use-package:
;; https://github.com/quelpa/quelpa-use-package
;; I don't use quelpa-use-package because it doesn't play well with byte-compilation

(use-package quelpa
  :ensure t
  :commands (quelpa quelpa-upgrade)
  :init
  ;; disable checking Melpa
  (setq quelpa-update-melpa-p nil)
  ;; don't use Melpa at all
  (setq quelpa-checkout-melpa-p nil)
  ;; quelpa dir settings
  (setq quelpa-dir (concat cpm-local-dir "quelpa"))
  ;; make sure package-initialize has been called before calling quelpa
  ;; (advice-add 'quelpa-upgrade :before #'package-initialize)
  )

;; (quelpa
;;  '(quelpa-use-package
;;    :fetcher git
;;    :url "https://github.com/quelpa/quelpa-use-package.git"))
;; (require 'quelpa-use-package)
;; (quelpa-use-package-activate-advice)


;;;; El-Patch
;; Package for helping advise other packages
(use-package el-patch
  :ensure t
  :defer 1
  :config
  (setq el-patch-enable-use-package-integration t))

(eval-when-compile
  (require 'el-patch))

;;;; Auto-compile
;; Automatically byte-recompile changed elisp libraries
(use-package auto-compile
  :ensure t
  :defer 1
  :config
  (setq auto-compile-display-buffer nil)
  (setq auto-compile-mode-line-counter t)
  (setq auto-compile-update-autoloads t)
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

;;; Personal Information
;; Give emacs some personal info
(setq user-full-name "Colin McLear"
      user-mail-address "mclear@fastmail.com")

;;; Load Modules
;; Load all the setup modules

;;;; Core Modules
;; These are the "can't live without" modules
(require 'setup-libraries)
(require 'setup-keybindings)
(require 'setup-evil)
(require 'setup-settings)
(require 'setup-dired)
(require 'setup-ivy)
(require 'setup-helm)

;;;; Other Modules
(require 'setup-ui)
(require 'setup-functions-macros)
(require 'setup-modeline)
(require 'setup-theme)
(require 'setup-osx)
(require 'setup-windows)
(require 'setup-navigation)
(require 'setup-search)
(require 'setup-vc)
(require 'setup-shell)
(require 'setup-org)
(require 'setup-writing)
(require 'setup-projects)
(require 'setup-programming)
(require 'setup-pdf)
(require 'setup-calendars)
(require 'setup-completion)
(require 'setup-dashboard)
(require 'setup-posframe)
(require 'setup-testing)

;;; Config Helper Functions

;;;; Config Navigation
;; Function to navigate config files
(defun cpm/find-files-setup-config-directory ()
  "use counsel to find setup files"
  (interactive)
  (counsel-find-file cpm-setup-dir))
  ;; (helm-find-files-1 cpm-setup-dir))

;; Function to search config files
(defun cpm/search-setup-config-files ()
  "use counsel rg to search all config files"
  (interactive)
  (counsel-rg nil cpm-setup-dir))
;; (helm-do-ag cpm-setup-dir))

;; Load init file
(defun cpm/load-init-file ()
  "load the base init file"
  (interactive)
  (load-file (concat user-emacs-directory "init.el")))

;;;; Byte Compile Config Files
;; https://emacsredux.com/blog/2013/06/25/boost-performance-by-leveraging-byte-compilation/
(defun cpm/byte-compile-dotemacs ()
  "Byte compile all files in the .emacs.d base directory"
  (interactive)
  (shell-command-to-string "trash ~/.emacs.d/*.elc && trash ~/.emacs.d/setup-config/*.elc")
  (byte-recompile-directory user-emacs-directory 0 t))

(defun cpm/delete-byte-compiled-files ()
  "Delete byte-compiled files"
  (interactive)
  (shell-command-to-string "trash ~/.emacs.d/*.elc && trash ~/.emacs.d/setup-config/*.elc"))


;; reset file-name-handler-alist
(add-hook 'emacs-startup-hook (lambda ()
                                (setq file-name-handler-alist cpm--file-name-handler-alist)))

;; Startup time
(message (format "Emacs ready in %.2f seconds with %d garbage collections."
                 (float-time
                  (time-subtract after-init-time before-init-time)) gcs-done))
(put 'narrow-to-page 'disabled nil)
