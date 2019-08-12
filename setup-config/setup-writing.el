;; Writing

;;; Spelling
(use-package ispell
  :commands (ispell-word ispell-region ispell-buffer)
  :config
  (when (executable-find "aspell")
    (setq ispell-program-name "aspell")
    ;; Please note ispell-extra-args contains ACTUAL parameters passed to aspell
    (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))))
  ;; (when (executable-find "hunspell")
  ;;   (setq-default ispell-program-name "hunspell")
  ;;   (setq ispell-extra-args   '("-d en_US"))
  ;;   (setq ispell-really-hunspell t)))

  ;; Save a new word to personal dictionary without asking
  ;; (setq ispell-silently-savep nil)

  ;; (setq-default ispell-program-name "/usr/local/bin/aspell")
  ;; (setq ispell-extra-args
  ;;     (list "--sug-mode=fast" ;; ultra|fast|normal|bad-spellers
  ;;           "--lang=en_US"
  ;;           "--ignore=3")))

(use-package flyspell
  :config
  (setq flyspell-abbrev-p t
        flyspell-use-global-abbrev-table-p t
        flyspell-issue-message-flag nil
        flyspell-issue-welcome-flag nil)
  :hook ((markdown-mode . flyspell-mode)
         (org-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)))

(use-package flyspell-correct-ivy
  :general
  (:states '(normal insert emacs) :keymaps 'flyspell-mode-map
   "C-;" 'flyspell-auto-correct-previous-word
   "C-:" 'flyspell-correct-word-generic))

(with-eval-after-load 'hydra
  (defhydra hydra-spelling (:color blue)
  "
  ^
  ^Spelling^          ^Errors^            ^Checker^
  ^────────^──────────^──────^────────────^───────^───────
  _q_ quit            _<_ previous        _c_ correction
  ^^                  _>_ next            _d_ dictionary
  ^^                  _f_ check           _m_ mode
  ^^                  ^^                  ^^
  "
  ("q" nil)
  ("<" flyspell-correct-previous :color pink)
  (">" flyspell-correct-next :color pink)
  ("c" ispell)
  ("d" ispell-change-dictionary)
  ("f" flyspell-buffer :color pink)
  ("m" flyspell-mode)))

;;; Abbrev
(use-package abbrev
  :ensure nil
  :defer 2
  :config
  ;; (add-hook 'text-mode-hook #'abbrev-mode)
  (setq abbrev-file-name (concat cpm-local-dir "abbrev/.abbrev_defs")
        save-abbrevs 'nil)
  (if (file-exists-p abbrev-file-name)
      (quietly-read-abbrev-file)))

;;; Helm Bibtex
(use-package helm-bibtex
  :commands helm-bibtex
  :config
  ;; Set insert citekey with markdown citekeys for org-mode
  (setq bibtex-completion-format-citation-functions
        '((org-mode    . bibtex-completion-format-citation-pandoc-citeproc)
        (latex-mode    . bibtex-completion-format-citation-cite)
        (markdown-mode . bibtex-completion-format-citation-pandoc-citeproc)
        (default       . bibtex-completion-format-citation-default)))
  (setq bibtex-completion-display-formats
        '((t . "${author:36} ${title:*} ${year:4} ${=has-pdf=:1}${=has-note=:1} ${=type=:7}")))
  ;; Set default action for helm-bibtex as inserting citation
  (helm-delete-action-from-source "Insert citation" helm-source-bibtex)
  (helm-add-action-to-source "Insert citation" 'helm-bibtex-insert-citation helm-source-bibtex 0)
  (setq bibtex-completion-pdf-symbol "⌘")
  (setq bibtex-completion-notes-symbol "✎")
  (setq bibtex-completion-notes-template-one-file "* ${author} (${date}): ${title} \n :PROPERTIES:\n :INTERLEAVE_PDF: ${file}\n :Custom_ID: ${=key=}\n :END:\n [[pdfview:${file}][file link]]")
  (setq bibtex-completion-notes-template-multiple-files
        "---\ntitle: '${author} (${year}): ${title}'\nnocite: |\n   @${=key=}\n---\n\n[PDF Link](${file})\n\n")
  (setq bibtex-completion-bibliography "~/Dropbox/Work/bibfile.bib"
        bibtex-completion-library-path "~/Dropbox/Work/be-library/"
        bibtex-completion-pdf-field nil
        bibtex-completion-notes-path "~/Dropbox/Notes/zettel/reading-notes"
        ;; bibtex-completion-additional-search-fields '(keywords)
        bibtex-completion-notes-extension ".md"
        helm-bibtex-full-frame nil))

;;; Markdown
(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'"       . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :init
  ;; markdown hooks
  (add-hook 'markdown-mode-hook
            '(lambda ()
               (turn-on-flyspell) (auto-fill-mode) (centered-cursor-mode) (git-gutter-mode 1)   (hl-todo-mode)))
  (setq markdown-command
        (concat
         "/usr/local/bin/pandoc"
         " --from=markdown --to=html"
         " --standalone --mathjax --highlight-style=pygments"
         " --css=/Users/roambot/.pandoc/pandoc.css"
         " --quiet"
         " --number-sections"
         " --lua-filter=/Users/roambot/dotfiles/pandoc/cuthead.lua"
         " --lua-filter=/Users/roambot/dotfiles/pandoc/date.lua"
         " --metadata-file=/Users/roambot/dotfiles/pandoc/metadata.yml"
         " --metadata=reference-section-title:'References & Further Reading'"
         " --filter pandoc-citeproc"
         ;; " --bibliography=/Users/Roambot/Dropbox/Work/bibfile.bib"
         ))

  (setq markdown-enable-math nil
        markdown-enable-wiki-links t
        markdown-nested-imenu-heading-index t
        markdown-open-command "~/bin/mark.sh"
        markdown-footnote-location 'immediately
        markdown-unordered-list-item-prefix "-   "
        markdown-use-pandoc-style-yaml-metadata t)
  :config
  ;; remove strikout comment face
  (set-face-attribute 'markdown-comment-face nil :weight 'bold :strike-through nil))

;; macro: delete backslashes in paragraph to cleanup markdown conversion
(fset 'cpm/md-delete-backslash
   (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ("\361\361f\\x" 0 "%d")) arg)))

;;; Markdown TOC
(use-package markdown-toc
  :ensure t
  :after markdown
  :hook (markdown-mode . markdown-toc))

;;; Pandoc
(use-package pandoc-mode
  :commands (cpm/pandoc-convert-to-pdf run-pandoc pandoc-convert-to-pdf)
  :config
  (setq pandoc-use-async t)
  ;; stop pandoc from just hanging forever and not completing conversion
  ;; see https://github.com/joostkremers/pandoc-mode/issues/44
  (setq pandoc-process-connection-type nil)
  (progn
    (defun run-pandoc ()
      "Start pandoc for the buffer and open the menu"
      (interactive)
      (pandoc-mode)
      (pandoc-main-hydra/body))
    (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings)

  (defun cpm/pandoc-convert-to-pdf ()
   (interactive)
   (cond
   ((eq major-mode 'org-mode)
    (call-interactively 'org-pandoc-export-to-latex-pdf-and-open))
   (t
    (call-interactively 'pandoc-convert-to-pdf) (cpm/pandoc-pdf-open) (evil-window-prev 1))))

  (defun cpm/pandoc-command-line-convert-to-pdf ()
   "convert to pdf"
   (interactive)
   (evil-ex "!pandoc -s -N -V mainfont=Optima --pdf-engine=xelatex --bibliography=~/Dropbox/Work/bibfile.bib --template=~/.pandoc/pandoc-templates/default.latex -o '%.pdf' '%'"))

  (defun cpm/pandoc-pdf-open ()
   "Open created PDF file"
   (interactive)
   (find-file-other-window (concat (file-name-sans-extension buffer-file-name) ".pdf"))))
  :init
  (progn
    (setq pandoc-data-dir (concat cpm-local-dir "pandoc-mode/"))
    ;; help pandoc find xelatex
    (setenv "PATH" (concat (getenv "PATH") ":/Library/TeX/texbin"))))

;;; Writeroom
(use-package writeroom-mode
  :commands (writeroom-mode)
  :config
  (setq writeroom-fullscreen-effect 'maximized)
  (setq writeroom-width 90)
  (setq writeroom-mode-line t)
  (setq writeroom-bottom-divider-width 0))

;; Set up a distraction free space
(defun distraction-free ()
  "distraction free writing"
  (interactive)
  (git-gutter-mode 0)
  (linum-mode 0)
  (centered-cursor-mode)
  (writeroom-mode)
  )

;;; Interleave (Notes)
(use-package interleave
  :commands interleave-mode)
(use-package lorem-ipsum
  :commands (Lorem-ipsum-insert-sentences Lorem-ipsum-insert-list Lorem-ipsum-insert-paragraphs)
  :config
  (lorem-ipsum-use-default-bindings)
  )

;;; Palimpsest (make archive)
(use-package palimpsest
  :diminish palimpsest-mode
  :hook ((markdown-mode org-mode) . palimpsest-mode)
  :config
  (setq palimpsest-trash-file-suffix ".archive"))

;;; Latex Packages
;; Basic settings
(use-package auctex
  :mode (("\\.tex\\'" . latex-mode)
         ("\\.latex\\'" . latex-mode))
  :commands (latex-mode LaTeX-mode plain-tex-mode)
  :init
  (progn
    (add-hook 'LaTeX-mode-hook #'LaTeX-preview-setup)
    (add-hook 'LaTeX-mode-hook #'flyspell-mode)
    (add-hook 'LaTeX-mode-hook #'turn-on-reftex)
    (setq-default TeX-engine 'xetex)
    (setq TeX-auto-save t
          TeX-parse-self t
          TeX-save-query nil
          TeX-PDF-mode t)
    (setq-default TeX-master nil)))

(use-package preview
  :ensure nil
  :after auctex
  :commands LaTeX-preview-setup
  :init
  (progn
    (setq-default preview-scale 1.4
      preview-scale-function '(lambda () (* (/ 10.0 (preview-document-pt)) preview-scale)))))

(use-package reftex
  :commands turn-on-reftex
  :init
  (progn
    (setq reftex-plug-into-AUCTeX t)))

(use-package bibtex
  :defer t
  :mode ("\\.bib" . bibtex-mode)
  :init
  (progn
    (setq bibtex-align-at-equal-sign t)
    (add-hook 'bibtex-mode-hook (lambda () (set-fill-column 120)))))


;; Auto-fill for LaTeX
(defun schnouki/latex-auto-fill ()
  "Turn on auto-fill for LaTeX mode."
  (turn-on-auto-fill)
  (set-fill-column 80)
  (setq default-justification 'left))
(add-hook 'LaTeX-mode-hook #'schnouki/latex-auto-fill)

;; Compilation command
(add-hook 'LaTeX-mode-hook (lambda () (setq compile-command "latexmk -pdflatex=xelatex -f -pdf %f")))

;; Prevent ispell from verifying some LaTeX commands
;; http://stat.genopole.cnrs.fr/dw/~jchiquet/fr/latex/emacslatex
(defvar schnouki/ispell-tex-skip-alists
      '("cite" "nocite"
  "includegraphics"
  "author" "affil"
  "ref" "eqref" "pageref"
  "label"))
(setq ispell-tex-skip-alists
      (list
       (append (car ispell-tex-skip-alists)
         (mapcar #'(lambda (cmd) (list (concat "\\\\" cmd) 'ispell-tex-arg-end)) schnouki/ispell-tex-skip-alists))
       (cadr ispell-tex-skip-alists)))

;; Indentation with align-current in LaTeX environments
(defvar schnouki/LaTeX-align-environments '("tabular" "tabular*"))
(add-hook 'LaTeX-mode-hook
    (lambda ()
      (require 'align)
      (setq LaTeX-indent-environment-list
      ;; For each item in the list...
      (mapcar (lambda (item)
          ;; The car is an environment
          (let ((env (car item)))
            ;; If this environment is in our list...
            (if (member env schnouki/LaTeX-align-environments)
          ;; ...then replace this item with a correct one
          (list env 'align-current)
        ;; else leave it alone
        item)))
        LaTeX-indent-environment-list))))

;; Use dvipdfmx to convert DVI files to PDF in AUCTeX
(eval-after-load 'tex
  '(add-to-list 'TeX-command-list
                '("DVI to PDF" "dvipdfmx %d" TeX-run-command t t) t))

;; SyncTeX (http://www.emacswiki.org/emacs/AUCTeX#toc19)
(defun synctex/un-urlify (fname-or-url)
  "A trivial function that replaces a prefix of file:/// with just /."
  (if (string= (substring fname-or-url 0 8) "file:///")
      (substring fname-or-url 7)
    fname-or-url))

;;; Grammar
(use-package typo
  :ensure t
  :defer 2
  :config
  (typo-global-mode))

;;; Notes / Deft
(use-package deft
  :ensure t
  :commands (deft deft-open-file-other-window big-notes deft-new-file-named)
  :general
  (:keymaps 'deft-mode-map :states '(normal motion)
            "o" 'cpm/deft-open
            "p" 'cpm/deft-open-preview)
  (:keymaps 'deft-mode-map :states '(insert)
            "C-j" 'evil-next-line
            "C-k" 'evil-previous-line
            "C-o" 'cpm/deft-open
            "C-p" 'cpm/deft-open-preview)
  :config
  (add-to-list 'evil-insert-state-modes 'deft-mode)
  ;; basic settings for use with zettel
  (setq deft-directory (concat (getenv "HOME") "/Dropbox/notes/zettel/")
        deft-recursive t
        deft-use-filename-as-title t
        deft-separator " "
        deft-extensions '("md" "txt" "org")
        deft-default-extension "md")
  ;; file renaming rules
  (setq deft-file-naming-rules
        '((noslash . "-")
          (nospace . "-")
          (case-fn . downcase)))
  (setq deft-strip-summary-regexp
        (concat "\\("
                "[\n\t]" ;; blank
                "\\|^#\\+[a-zA-Z_]+:.*$" ;;org-mode metadata
                ;;yaml metadata
                "\\|^\\-\\{3\\}$"
                "\\|^[a-zA-Z_]+:.*$"
                "\\|@[a-zA-Z_].*$"
                ;; line beginning with markdown links
                "\\|^\\[.*$"
                "\\|^# .*$" ;; md titles
                "\\)"))

  ;;function to run deft in specified directory
  (defun any-deft (dir)
    "Run deft in directory DIR"
    (setq deft-directory dir)
    (switch-to-buffer "*Deft*")
    (kill-this-buffer)
    (require 'org)
    (deft))
  (defun big-notes ()
    "Goto main notes with deft"
    (interactive)
    (any-deft "~/Dropbox/Notes")
    (kill-this-buffer)
    (any-deft "~/Dropbox/Notes"))
  (defun cpm/deft-open ()
    (interactive)
    (deft-open-file-other-window t))
  (defun cpm/deft-open-preview ()
    (interactive)
    (deft-open-file-other-window)))

;;; Zetteldeft
(use-package zetteldeft
  :ensure t
  :load-path cpm-elisp-dir
  :git "https://github.com/EFLS/zetteldeft.git"
  ;; :defer 1
  :commands (zd-deft-new-search zd-new-file zd-new-file-and-link cpm/zettel-dired)
  :config
  ;; use dired to navigate notes
  (defun cpm/zettel-dired ()
    (interactive)
    (find-file "~/Dropbox/Notes/zettel")
    (peep-dired))
  (setq zd-id-format "%Y-%m%d-%H%M")
  (setq zd-id-regex "[0-9]\\{4\\}\\(-[0-9]\\{2,\\}\\)\\{2\\}")
  (setq zd-tag-regex "[#][a-z-]+")
  (setq zd-link-indicator "")
  (setq zd-title-prefix "title: ")

  ;; modify functions for workfolow

  ;; add brackets for wikilink treatment
  (defun zd-list-entry-file-link (zdFile)
    "Insert ZDFILE as list entry."
    (insert " - " (concat zd-link-indicator "[["(file-name-base zdFile)"]]") "\n"))

  (defun zd-insert-list-links-missing (zdSrch)
    "Insert a list of links to all deft files with a search string ZDSRCH.
In contrast to `zd-insert-list-links' only include links not yet present
in the current file.
Can only be called from a file in the zetteldeft directory."
    (interactive (list (read-string "search string: ")))
    (zd--check)
    (let (zdThisID zdCurrentIDs zdFoundIDs zdFinalIDs)
      (setq zdCurrentIDs (zd-extract-links (buffer-file-name)))
                                        ; filter IDs from search results
      (dolist (zdFile (zd-get-file-list zdSrch))
        (push (zd-lift-id zdFile) zdFoundIDs))
                                        ; create new list with unique ids
      (dolist (zdID zdFoundIDs)
        (unless (member zdID zdCurrentIDs)
          (push zdID zdFinalIDs)))
                                        ; remove the ID of the current buffer from said list
      (setq zdThisID (zd-lift-id (file-name-base (buffer-file-name))))
      (setq zdFinalIDs (delete zdThisID zdFinalIDs))
                                        ; finally find full title for each ID and insert it
      (if zdFinalIDs
          (dolist (zdID zdFinalIDs)
            (setq zdID (zd-id-to-full-title zdID))
            (insert " - " (concat zd-link-indicator "[["zdID"]]" "\n")))
                                        ; unless the list is empty, then insert a message
        (insert (format zd-list-links-missing-message zdSrch)))))

  ;; fix search functions
  (defun zd-avy-tag-search ()
    "Call on avy to jump and search tags indicated with #."
    (interactive)
    (save-excursion
      (avy-jump zd-tag-regex)
      (zd-search-at-point)))

  (defun zd-avy-link-search ()
    "Call on avy to jump and search link ids indicated with [[.
Opens immediately if there is only one result."
    (interactive)
    (save-excursion
      (avy-goto-char-2 ?\[?\[)
      (zd-search-global (zd-lift-id (zd-get-thing-at-point)))))

  (defun zd-avy-file-search (&optional otherWindow)
    "Call on avy to jump to link ids indicated with [[ and use it to search for filenames.
Open that file (when it is the only search result, and in another window if OTHERWINDOW)."
    (interactive)
    (save-excursion
      (avy-goto-char-2 ?\[?\[)
      (forward-char)
      (zd-search-filename (zd-lift-id (zd-get-thing-at-point)) otherWindow)))

  (defun zd-avy-file-search-ace-window ()
    "Call on avy to jump to link ids indicated with [[ and use it to search for filenames.
When there is only one search result, as there should be, open that file in a window selected through `ace-window'."
    (interactive)
    (require 'ace-window)
    (save-excursion
      (avy-goto-char ?\[?\[)
      (let ((ID (zd-lift-id (zd-get-thing-at-point))))
        (select-window (aw-select "Select window..."))
        (zd-search-filename ID))))
  )





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'setup-writing)