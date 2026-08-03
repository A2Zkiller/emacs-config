(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode)
  ;; Adds :ensure t to all use-package configs by default
  (setq use-package-always-ensure t))

(setq frame-inhibit-implied-resize t)

(use-package catppuccin-theme
  :config
  (load-theme 'catppuccin :no-confirm))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package auctex
  :ensure nil)

(setq org-latex-compiler "pdflatex")
(setq org-preview-latex-default-process 'dvisvgm)

(use-package beacon
  :config
  (setq beacon-blink-when-point-moves-vertically t)
  (beacon-mode 1))

(use-package buffer-move)

;; Move backups (filename~) to separate directory
(setq backup-directory-alist '((".*" . "~/.local/share/Trash/files/")))
;; Move autosaves (#filename#) to separate directory
(make-directory (expand-file-name "autosaves/" user-emacs-directory) t)
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "autosaves/" user-emacs-directory) t)))

(setq create-lockfiles nil)

(use-package company
  :diminish
  :hook (elpaca-after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.0 
	company-minimum-prefix-length 1))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package dashboard
  :after projectile
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner (expand-file-name "./images/emacs-dash.png" user-emacs-directory))  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 3)
                          (projects . 5)))
  (setq dashboard-projects-backend 'projectile)
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook)
  (add-hook 'dashboard-mode-hook (lambda () (display-line-numbers-mode -1))))

(use-package diminish)

(use-package dired-open 
  :config
  (setq dired-open-extensions '(("gif" . "feh")
				("jpg" . "feh")
				("png" . "feh")
				("mp4" . "mpv")
				("mkv" . "mpv"))))

(use-package dired-preview
  :after dired
  :config 
  (setq dired-preview-delay 0.1)
  (dired-preview-global-mode 1))

(use-package envrc
  :hook (elpaca-after-init . envrc-global-mode))

(setq visible-bell 1)

(use-package eglot-booster
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :after eglot
  :config (eglot-booster-mode))

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-redo))

(use-package evil-collection
  :after evil
  :config
  ;;(setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-tutor)

(use-package evil-org
  :after org evil
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  ;; not working in :hook
  (add-hook 'org-mode-hook 'evil-org-mode))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(set-face-attribute 'default nil
		    :font "JetBrainsMono Nerd Font"
		    :height 140
		    :weight 'regular)
(set-face-attribute 'variable-pitch nil
		    :font "Noto Sans"
		    :height 120
		    :weight 'regular)
(set-face-attribute 'fixed-pitch nil
		    :font "JetBrainsMono Nerd Font"
		    :height 140
		    :weight 'regular)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
		    :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
		    :slant 'italic)

;; Emacs Client
(add-to-list 'default-frame-alist '(font . "JetBrainsMono Nerd Font-14"))

(use-package general
  :config
  (general-evil-setup)

  ;; Setup SPC as global leader key
  (general-create-definer a2z/leader-key
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "M-SPC")

  (a2z/leader-key
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f c" '((lambda () (interactive) (find-file (expand-file-name "config.org" user-emacs-directory))) :wk "Edit Config")
    "r c" '((lambda () (interactive) (load-file user-init-file)) :wk "Reload Config")
    "f d" '(dashboard-open :wk "Open dashboard"))

  (a2z/leader-key
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b b" '(switch-to-buffer :wk "Switch to buffer")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-current-buffer :wk "Kill current buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

  (a2z/leader-key
    "c" '(:ignore t :wk "Code / Comments")
    "c l" '(comment-line :wk "Comment line")
    "c c" '(compile :wk "Compile")
    "c r" '(recompile :wk "Recompile")
    "c f" '(eglot-format-buffer :wk "Format buffer")
    "c a" '(eglot-code-actions :wk "Code Actions")
    "c d" '(eldoc :wk "Eldoc")
    "c n" '(flymake-goto-next-error :wk "Goto next error")
    "c p" '(flymake-goto-prev-error :wk "Goto prev error"))
  
  (a2z/leader-key
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open Dired")
    "d j" '(dired-jump :wk "Jump to current buffer dired")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d P" '(dired-preview-mode :wk "Toggle dired preview")
    "d p" '(project-dired :wk "Project Dired"))

  (a2z/leader-key
    "e" '(:ignore t :wk "Evaluate")
    "e b" '(eval-buffer :wk "Evaluate Buffer")
    "e d" '(eval-defun :wk "Evaluate Defun")
    "e e" '(eval-expression :wk "Evaluate Expression")
    "e r" '(eval-region :wk "Evaluate Region"))

  (a2z/leader-key
    "g" '(:ignore t :wk "Git")
    "g g" '(magit :wk "Launch Magit")
    "g j" '(majutsu :wk "Launch Majutsu"))

  (a2z/leader-key
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (a2z/leader-key
    "m" '(:ignore t :wk "Org")
    "m a" '(org-agenda :wk "Org agenda")
    "m e" '(org-export-dispatch :wk "Org export dispatch")
    "m i" '(org-toggle-item :wk "Org toggle item")
    "m t" '(org-todo :wk "Org todo")
    "m B" '(org-babel-tangle :wk "Org babel tangle")
    "m T" '(org-todo-list :wk "Org todo list"))
  
  (a2z/leader-key
    "m b" '(:ignore t :wk "Tables")
    "m b -" '(org-table-insert-hline :wk "Insert hline in table"))
  
  (a2z/leader-key
    "m d" '(:ignore t :wk "Date/deadline")
    "m d t" '(org-time-stamp :wk "Org time stamp"))

  (a2z/leader-key
    "p" '(:ignore t :wk "Project")
    "p k" '(project-kill-buffers :wk "Project kill buffers")
    "p b" '(project-switch-to-buffer :wk "Project switch to buffer")
    "p B" '(project-list-buffers :wk "Project list buffers"))

  (a2z/leader-key
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle visual line mode")
    "t v" '(vterm-toggle :wk "Toggle vterm")
    "t n" '(neotree-toggle :wk "Toggle neotree"))
  
  (a2z/leader-key
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))
  )

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)
(column-number-mode t)
(setq display-line-numbers-type 'relative)

(use-package counsel
  :after ivy
  :config
  (counsel-mode))

(use-package ivy
  :bind
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :init
  (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :init (ivy-rich-mode 1)
  :custom
  (ivy-virtual-abbreviate 'full
			  ivy-rich-switch-buffer-align-virtual-buffer t
			  ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer 'ivy-switch-buffer-transformer))

(setq treesit-font-lock-level 4)

(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

(add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-ts-mode))

(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-ts-mode))

(use-package nix-ts-mode
  :mode "\\.nix\\'")

(add-hook 'nix-ts-mode-hook #'eglot-ensure)

;; Link up nixd and nil
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
	       '(nix-ts-mode . ("rass" "--" "nixd" "--" "nil" "--stdio"))))

(define-derived-mode devenv-nix-ts-mode nix-ts-mode "Devenv-Nix"
  "Derived mode to allow devenv.nix files to use the devenv lsp")

(defun a2z/devenv-nixd-config (&rest _)
  "Fetch nixd's workspace configuration from `devenv lsp --print-config'."
  (condition-case err
      (json-parse-string
       (shell-command-to-string "devenv lsp --quiet --print-config")
       :object-type 'plist
       :array-type 'list)
    (error (message "devenv lsp --print-config failed: %s" err) nil)))

(add-hook 'nix-ts-mode-hook
    (lambda ()
    (when (and (string-match-p "/devenv\\.nix\\'" buffer-file-name)
	   (not (derived-mode-p 'devenv-nix-ts-mode)))
    (devenv-nix-ts-mode))))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
  	       '(devenv-nix-ts-mode . ("devenv" "lsp"))))

(add-hook 'devenv-nix-ts-mode-hook (lambda () (setq-local eglot-workspace-configuration #'a2z/devenv-nixd-config)))
(add-hook 'devenv-nix-ts-mode-hook #'eglot-ensure t)

(with-eval-after-load 'projectile
  (add-to-list 'projectile-project-root-files-bottom-up "devenv.nix"))

(use-package odin-ts-mode
  :ensure (:host github :repo "Sampie159/odin-ts-mode")
  :mode "\\.odin\\'")

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '((odin-mode odin-ts-mode) . ("ols"))))

(add-hook 'odin-ts-mode-hook #'eglot-ensure)

(use-package rust-mode
  :init
  (setq rust-mode-treesitter-derive t))

(use-package rustic
  :init
  (setq rustic-lsp-client 'eglot)
  :config
  (setq rustic-format-on-save t)
  :custom
  (rustic-cargo-use-last-stored-arguments t))

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rustic-mode))
(add-hook 'rustic-mode-hook #'eglot-ensure)

;; Fix rust project freezing on launch (if external file got updated do eglot-reconnect)
(add-hook 'rustic-mode-hook
          (lambda () (setq-local eglot-ignored-server-capabilities '(:didChangeWatchedFiles))))

(use-package slang-ts-mode
  :vc (:url "https://github.com/Vostranox/slang-ts-mode")
  :mode (("\\.slang\\'" . slang-ts-mode)
	("\\.sl\\'" . slang-ts-mode)
	("\\.slangh\\'" . slang-ts-mode)))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(slang-ts-mode . ("slangd"))))

(add-hook 'slang-ts-mode-hook #'eglot-ensure)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 30
	doom-modeline-bar-width 5))

(use-package neotree
  :config
  (setq neo-smart-open t
	neo-show-hidden-files t
	neo-window-width 40
	neo-window-fixed-size nil
	inhibit-impacting-font-caches t
	projectile-switch-project-action 'neotree-projectile-action))

(use-package toc-org
  :commands toc-org-enable
  :init
  (add-hook 'org-mode-hook 'toc-org-mode)
  (add-hook 'markdown-mode-hook 'toc-org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(require 'org-tempo)

(setq org-directory "~/Org")
(add-to-list 'org-agenda-files org-directory)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)))

(use-package rainbow-mode
  :hook org-mode prog-mode)

(electric-pair-mode 1)

;; Do not pair < with > when in org mode (for org-tempo)
(add-hook 'org-mode-hook (lambda ()
			   (setq-local electric-pair-inhibit-predicate
				       `(lambda (c)
					  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))

(global-auto-revert-mode 1)
(delete-selection-mode 1)
(setq use-file-dialog nil)   ;; No file dialog
(setq use-dialog-box nil)    ;; No dialog box
(setq pop-up-windows nil)    ;; No popup windows

(if (not server-mode) (server-start))

(use-package sudo-edit
  :config
  (a2z/leader-key
    "fu" '(sudo-edit :wk "Sudo edit file")
    "fU" '(sudo-edit-find-file :wk "Sudo edit file")))

(use-package vterm)

(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                           (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
		 (display-buffer-reuse-window display-buffer-at-bottom)
		 ;;(display-buffer-reuse-window display-buffer-in-direction)
		 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
		 ;;(direction . bottom)
		 ;;(dedicated . t) ;dedicated is supported in emacs27
		 (reusable-frames . visible)
		 (window-height . 0.3))))

;; required dependency
(use-package transient :ensure t)

(use-package magit)

(use-package majutsu
  :vc (:url "https://github.com/0WD0/majutsu")
  :after magit)

(which-key-mode 1)

(setq which-key-side-window-location 'bottom
      which-key-sort-order #'which-key-key-order-alpha
      which-key-sort-uppercase-first nil
      which-key-add-column-padding 1
      which-key-max-display-columns nil
      which-key-min-display-lines 6
      which-key-side-window-slot -10
      which-key-side-window-max-height 0.25
      which-key-idle-delay 0.8
      which-key-max-description-length 25
      which-key-allow-imprecise-window-fit t
      which-key-separator " → " )
