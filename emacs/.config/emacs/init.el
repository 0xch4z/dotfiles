;;; init.el ---  -*- lexical-binding: t; -*-

(setq inhibit-startup-message t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-dialog-box nil
      use-short-answers t
      custom-file (expand-file-name "custom.el" my-emacs-state-directory)
      backup-directory-alist
      `(("." . ,(expand-file-name "backups/" my-emacs-state-directory)))
      auto-save-file-name-transforms
      `((".*" ,(expand-file-name "auto-save/" my-emacs-cache-directory) t))
      completion-ignore-case t
      read-file-name-completion-ignore-case t
      completion-cycle-threshold 3
      tab-always-indent 'complete)

(make-directory (expand-file-name "backups/" my-emacs-state-directory) t)
(make-directory (expand-file-name "auto-save/" my-emacs-cache-directory) t)
(load custom-file 'noerror 'nomessage)

(set-default-coding-systems 'utf-8)
(setq-default indent-tabs-mode nil
              tab-width 4)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(column-number-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(global-so-long-mode 1)
(recentf-mode 1)
(repeat-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(winner-mode 1)

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         straight-base-dir))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t
      use-package-always-defer t)

(dolist (package '(eglot eldoc external-completion flymake jsonrpc project seq xref))
  (straight-use-package `(,package :type built-in)))

(use-package doom-themes
  :straight (doom-themes
             :type git
             :host github
             :repo "doomemacs/themes"
             :files (:defaults "themes/*.el" "themes/*/*.el" "extensions/*.el"))
  :demand t
  :config
  (load-theme 'doom-tokyo-night t))

(use-package nerd-icons
  :straight (nerd-icons
             :type git
             :host github
             :repo "rainstormstudio/nerd-icons.el"
             :files (:defaults "data"))
  :demand t)

(use-package doom-modeline
  :custom
  (doom-modeline-buffer-file-name-style 'truncate-upto-project)
  (doom-modeline-icon t)
  (doom-modeline-major-mode-icon t)
  (doom-modeline-minor-modes nil)
  :init
  (doom-modeline-mode 1))

(use-package which-key
  :straight nil
  :init
  (which-key-mode 1))

(which-function-mode 1)
(global-hl-line-mode 1)
(show-paren-mode 1)

;; Search and navigation
(use-package vertico
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("<escape>" . minibuffer-keyboard-quit))
  :custom
  (vertico-count 15)
  (vertico-cycle t)
  :init
  (vertico-mode 1))

(use-package vertico-posframe
  :straight (:host github :repo "tumashu/vertico-posframe")
  :after vertico
  :demand t
  :custom
  (vertico-posframe-width 100)
  (vertico-posframe-height 17)
  (vertico-posframe-min-width 70)
  (vertico-posframe-min-height 10)
  (vertico-posframe-border-width 1)
  (vertico-posframe-poshandler #'posframe-poshandler-frame-center)
  (vertico-posframe-show-minibuffer-rules nil)
  :config
  (set-face-attribute 'vertico-posframe nil
                      :background "#1a1b26"
                      :foreground "#c0caf5")
  (set-face-attribute 'vertico-posframe-border nil
                      :background "#7aa2f7")
  (vertico-posframe-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult
  :commands (consult-fd consult-find consult-ripgrep))

(defun my/project-root ()
  (if-let* ((project (project-current)))
      (project-root project)
    default-directory))

(defun my/project-find-file ()
  (interactive)
  (let ((root (my/project-root)))
    (if (executable-find "fd")
        (consult-fd root)
      (consult-find root))))

(defun my/project-live-grep ()
  (interactive)
  (consult-ripgrep (my/project-root)))

;; Go development
(defun my/go-before-save ()
  (when (eglot-managed-p)
    (ignore-errors (eglot-code-action-organize-imports))
    (eglot-format-buffer)))

(defun my/go-mode-setup ()
  (yas-minor-mode 1)
  (eglot-ensure)
  (add-hook 'before-save-hook #'my/go-before-save nil t))

(defun my/eglot-signature-mode ()
  (eglot-signature-mode (if (eglot-managed-p) 1 -1)))

(use-package eglot
  :straight nil
  :custom
  (eglot-autoshutdown t)
  (eglot-workspace-configuration
   '(:gopls
     (:usePlaceholders t
      :gofumpt t
      :staticcheck t
      :analyses (:unusedparams t)))))

(use-package eglot-booster
  :straight (:type git :host github :repo "jdtsmith/eglot-booster")
  :custom
  (eglot-booster-io-only t)
  (eglot-booster-no-remote-boost t)
  :init
  (with-eval-after-load 'eglot
    (require 'eglot-booster)
    (eglot-booster-mode 1)))

(use-package eglot-signature
  :straight (:type git :host github :repo "zsxh/eglot-signature")
  :hook (eglot-managed-mode . my/eglot-signature-mode)
  :custom
  (eglot-signature-max-width 90)
  :init
  (with-eval-after-load 'eglot
    (eglot-signature-setup)))

(use-package flymake
  :straight nil
  :demand t
  :custom
  (flymake-no-changes-timeout 0.3)
  (flymake-show-diagnostics-at-end-of-line 'short))

(use-package yasnippet
  :commands yas-minor-mode)

(use-package go-mode
  :mode (("\\.go\\'" . go-mode)
         ("/go\\.mod\\'" . go-dot-mod-mode))
  :hook ((go-mode . my/go-mode-setup)
         (go-dot-mod-mode . eglot-ensure)))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-count 12)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :init
  (global-corfu-mode)
  :config
  (corfu-history-mode 1)
  (corfu-popupinfo-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history))

(use-package nerd-icons-corfu
  :after corfu
  :demand t
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

;; Vim emulation
(use-package evil
  :init
  (setq evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo
        evil-want-C-i-jump nil
        evil-want-C-u-scroll t)
  :demand t
  :config
  (evil-mode 1)
  (evil-set-leader '(normal visual motion) (kbd "SPC"))
  (evil-define-key '(normal visual motion) 'global
    (kbd "SPC f f") #'my/project-find-file
    (kbd "SPC f g") #'my/project-live-grep))

(use-package org
  :straight nil
  :hook (org-mode . visual-line-mode)
  :custom
  (org-hide-emphasis-markers t)
  (org-hide-leading-stars t)
  (org-pretty-entities t)
  (org-startup-indented t)
  (org-startup-with-inline-images t))

(use-package kitty-graphics
  :straight (:host github :repo "cashmeredev/kitty-graphics.el")
  :demand t
  :custom
  (kitty-graphics-max-width 100)
  (kitty-graphics-max-height 32)
  (kitty-graphics-cache-size 128)
  (kitty-graphics-doc-view-resolution-scale 2.0)
  (kitty-graphics-org-image-scale 'fit)
  (kitty-graphics-org-image-fit-width 0.8)
  (kitty-graphics-org-image-fit-height 24)
  (kitty-graphics-markdown-image-scale 'fit)
  (kitty-graphics-markdown-image-fit-width 0.8)
  (kitty-graphics-markdown-image-fit-height 24)
  (kitty-graphics-shr-scale 'fit)
  (kitty-graphics-shr-fit-width 0.7)
  (kitty-graphics-shr-fit-height 24)
  (kitty-graphics-heading-scales '((1 . 1.8) (2 . 1.4) (3 . 1.2)))
  (kitty-graphics-heading-sizes-auto t)
  (kitty-graphics-heading-scan-visible-only t)
  :config
  (kitty-graphics-setup))
