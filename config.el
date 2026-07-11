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
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(use-package evil-tutor)

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
    "c l" '(comment-line :wk "Comment line"))

  (a2z/leader-key
    "b" '(:ignore t :wk "Buffer")
    "b b" '(switch-to-buffer :wk "Switch buffer")
    "b k" '(kill-current-buffer :wk "Kill this buffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer"))

  (a2z/leader-key
    "e" '(:ignore t :wk "Evaluate")
    "e b" '(eval-buffer :wk "Evaluate Buffer")
    "e d" '(eval-defun :wk "Evaluate Defun")
    "e e" '(eval-expression :wk "Evaluate Expression")
    "e r" '(eval-region :wk "Evaluate Region"))

  (a2z/leader-key
    "h" '(:ignore t :wk "Help")
    "h f" '(describe-function :wk "Describe Function")
    "h v" '(describe-variable :wk "Describe Variable"))

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
    "t" '(:ignore t :wk "Toggle")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t t" '(visual-line-mode :wk "Toggle visual line mode")
    "t v" '(vterm-toggle :wk "Toggle vterm"))
  
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

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package buffer-move)

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner (expand-file-name "./images/emacs-dash.png" user-emacs-directory))  ;; use custom image as banner
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package diminish)

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

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)
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
  (ivy-set-display-transformer 'ivy-switch-buffer 'ivy-rich-switch-buffer-transformer))



(use-package toc-org
  :commands toc-org-enable
  :init
  (add-hook 'org-mode-hook 'toc-org-mode)
  (add-hook 'markdown-mode-hook 'toc-org-mode))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(electric-indent-mode -1)

(require 'org-tempo)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :hook org-mode prog-mode)

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
