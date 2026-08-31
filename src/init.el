;;; init.el -*- lexical-binding: t; -*-

(require 'package)
;; Enable MELPA for more packages
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             t)

(require 'use-package)
(setq use-package-always-defer nil
      use-package-enable-imenu-support t)
(when init-file-debug
  (setq use-package-verbose t
	use-package-minimum-reported-time 0
	use-package-expand-minimally nil
	use-package-compute-statistics t))

(use-package emacs
  :init
  ;; Disable bidirectional text scanning, since we almost always use English anyways.
  (setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
  (setq bidi-inhibit-bpa t)
  ;; Increase process output buffer. Modern LSPs send big responses, so a larger buffer
  ;; means less read calls that Emacs has to make, at the cost of a slight memory usage bump.
  (setq read-process-output-max (* 4 1024 1024)) ;; 4 MB
  ;; Don't render cursors in non-selected windows, it's a waste of compute
  (setq-default cursor-in-non-selected-windows nil)
  (setq highlight-nonselected-windows nil)
  ;; Resize windows proportionally
  (setq window-combination-resize t)
  (scroll-bar-mode -1)
  (tool-bar-mode -1)
  (tooltip-mode -1)
  (set-fringe-mode 10)
  (setq-default line-spacing 0.2)
  (load-theme 'modus-vivendi :no-confirm)
  (menu-bar-mode -1)
  (let* ((font-size 10)
				 (font-height (* font-size 10)))
    (set-face-attribute 'default nil :font "IosevkaCadmus Nerd Font" :height font-height)
    (set-fontset-font t nil (font-spec :size font-size :name "IosevkaCadmus Nerd Font"))
    (custom-theme-set-faces
     'user
     `(variable-pitch ((t (:family "Atkinson Hyperlegible Next" :height ,font-height))))
     `(fixed-pitch ((t (:family "IosevkaCadmus Nerd Font" :height ,font-height))))))
  (add-to-list 'face-font-rescale-alist '("Atkinson Hyperlegible Next" . 1.2)))

(use-package meow
  :ensure t
  :demand t
  :custom
  (meow-use-clipboard t)
  :init
  (defvar-keymap dysthesis/window-map
    "s" #'dysthesis/split-window-below
    "v" #'dysthesis/split-window-right
    "h" #'windmove-left
    "l" #'windmove-right
    "j" #'windmove-down
    "k" #'windmove-up
    "c" #'delete-window)
  (defun dysthesis/split-window-below ()
    "Split horizontally and select the new window"
    (interactive)
    (select-window (split-window-below)))
  (defun dysthesis/split-window-right ()
    "Split vertically and select the new window"
    (interactive)
    (select-window (split-window-right)))
  (defun dysthesis/meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; Use SPC (0-9) for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore))
    ;; Consult bindings
    (meow-leader-define-key
     '("f" . consult-fd)
     '("i" . consult-imenu)
     '("b" . switch-to-buffer)
     '("/" . consult-ripgrep))
    ;; Pane navigation bindings
    (meow-normal-define-key
     (cons "C-w" dysthesis/window-map))
    (meow-motion-define-key
     (cons "C-w" dysthesis/window-map)))
  :config
  (dysthesis/meow-setup)
  (meow-global-mode 1))

(custom-set-faces
 '(fixed-pitch ((t (:family "IosevkaCadmus Nerd Font" :height 100))))
 '(variable-pitch ((t (:family "Atkinson Hyperlegible Next" :height 100)))))

(use-package vertico
  :ensure t
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :demand t
  :custom
  (completion-styles '(orderless basic flex))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package consult
    :ensure t
    :functions (consult-xref consult-register-window consult-register-format)
    :hook (completion-list-mode . consult-preview-at-point-mode)
    :init
    (setq register-preview-delay 0.5
          register-preview-function #'consult-register-format)

    (advice-add #'register-preview :override #'consult-register-window)

    (setq xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)
    :config
    ;; Accept VCS markers as project root markers
    (setopt project-vc-extra-root-markers '(".projectile" ".git")))

(use-package corfu
  :ensure t
  :demand t
  :hook (corfu-mode . dysthesis/corfu-completion)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  :init
  (defun dysthesis/orderless-fast-dispatch (word index total)
    (and (= index 0)
	 (= total 1)
	 (length< word 4)
	 (cons 'orderless-literal-prefix word)))
  (orderless-define-completion-style orderless-fast
    (orderless-style-dispatchers '(dysthesis/orderless-fast-dispatch))
    (orderless-matching-styles '(orderless-literal orderless-regexp)))
  (defun dysthesis/corfu-completion ()
    "Cheaper orderless ordering for corfu"
    (setq-local completion-styles '(orderless-fast basic)
		completion-category-defaults nil
		completion-category-overrides nil))
  (global-corfu-mode))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

(use-package smartparens
  :ensure t
  :hook (prog-mode text-mode markdown-mode)
  :config (require 'smartparens-config))
