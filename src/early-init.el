;;; early-init.el -*- lexical-binding: t; -*-

;; Preserve the normal interactive GC policy.
(defvar dysthesis--gc-cons-threshold gc-cons-threshold)
(defvar dysthesis--gc-cons-percentage gc-cons-percentage)

;; Startup is a short allocation burst.  Reduce the number of collections
;; during that burst, then restore the normal policy after startup.
(setq gc-cons-threshold (* 64 1024 1024)
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold dysthesis--gc-cons-threshold
                  gc-cons-percentage dysthesis--gc-cons-percentage)))

;; Avoid window-manager resize negotiations while the initial frame is
;; having its font, bars and fringes established.
(setq frame-inhibit-implied-resize t)

;; Establish geometry before the graphical frame is constructed.
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(left-fringe . 10))
(add-to-list 'default-frame-alist '(right-fringe . 10))
(add-to-list 'default-frame-alist
             '(font . "IosevkaCadmus Nerd Font-10"))

;; Optional: benchmark this before retaining it.
(setq package-quickstart t)
