;;; early-init.el ---  -*- lexical-binding: t; -*-

(defvar my-emacs-cache-directory
  (expand-file-name "emacs/" (or (getenv "XDG_CACHE_HOME") "~/.cache/")))
(defvar my-emacs-data-directory
  (expand-file-name "emacs/" (or (getenv "XDG_DATA_HOME") "~/.local/share/")))
(defvar my-emacs-state-directory
  (expand-file-name "emacs/" (or (getenv "XDG_STATE_HOME") "~/.local/state/")))

(dolist (directory (list my-emacs-cache-directory
                         my-emacs-data-directory
                         my-emacs-state-directory))
  (make-directory directory t))

(setq package-enable-at-startup nil
      frame-inhibit-implied-resize t
      straight-base-dir my-emacs-data-directory)

(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (expand-file-name "eln-cache/" my-emacs-cache-directory)))

(menu-bar-mode -1)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
