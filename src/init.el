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
  (setq display-line-numbers-type 'relative)
  (add-hook 'prog-mode-hook #'display-line-numbers-mode)
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
  (menu-bar-mode -1)
  (let ((font-family "IosevkaCadmus Nerd Font")
	(font-height 95))
    (set-face-attribute 'default nil
			:family font-family
			:height font-height
			:weight 'normal)

    (custom-theme-set-faces
     'user
     `(variable-pitch
       ((t (:family "Atkinson Hyperlegible Next"
		    :height ,font-height))))
     `(fixed-pitch
       ((t (:family ,font-family
		    :height 1.0)))))
    (add-to-list 'face-font-rescale-alist
		 '("Atkinson Hyperlegible Next" . 1.2)))
  (add-to-list 'face-font-rescale-alist '("Atkinson Hyperlegible Next" . 1.2)))

(use-package modus-alabaster
  :vc (:url "https://github.com/dysthesis/minimal.el"
	    :rev :newest)
  :config
  (load-theme 'modus-alabaster-dark :no-confirm))

(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config (evil-collection-init))

(use-package general
  :ensure t
  :after evil
  :config
  ;; * Mode Keybindings
  (general-define-key
   :states 'normal
   :keymaps 'emacs-lisp-mode-map
   ;; or xref equivalent
   "K" 'elisp-slime-nav-describe-elisp-thing-at-point)
  ;; `general-def' can be used instead for `evil-define-key'-like syntax
  (general-def 'normal emacs-lisp-mode-map
    "K" 'elisp-slime-nav-describe-elisp-thing-at-point)

  ;; * Prefix Keybindings
  ;; :prefix can be used to prevent redundant specification of prefix keys
  ;; again, variables are not necessary and likely not useful if you are only
  ;; using a definer created with `general-create-definer' for the prefixes
  ;; (defconst dysthesis/gleader "SPC")
  ;; (defconst dysthesis/glocal-leader "SPC m")

  (general-create-definer dysthesis/gleader-def
    ;; :prefix dysthesis/gleader
    :prefix "SPC")

  (dysthesis/gleader-def 'normal
    "." '(find-file :wk "Find file")
    "TAB" '(comment-line :wk "Comment lines")
    "p" '(:keymap project-prefix-map
		  :package project
		  :wk "+Project"))
  (dysthesis/gleader-def 'normal
    "f" '(:ignore t :wk "Find")
    "f r" '(consult-recent-file :wk "Recent files")
    "f f" '(consult-fd :wk "Consult fd")
    "f g" '(consult-ripgrep :wk "Ripgrep search in files")
    "f l" '(consult-line :wk "Find line")
    "f i" '(consult-imenu :wk "Consult imenu"))
  (dysthesis/gleader-def 'normal
    "g" '(:ignore t :wk "Git")
    "g g" '(magit-status :wk "Magit status"))
  (dysthesis/gleader-def 'normal
    "b" '(:ignore t :wk "Buffer Bookmarks")
    "b b" '(consult-buffer :wk "Switch buffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b i" '(ibuffer :wk "Ibuffer")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b j" '(consult-bookmark :wk "Bookmark jump"))
  (dysthesis/gleader-def 'normal
    "d" '(:ignore t :wk "Dired")
    "d v" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current"))
  (dysthesis/gleader-def 'normal
    "e" '(:ignore t :wk "Eglot Evaluate")
    "e e" '(eglot-reconnect :wk "Eglot Reconnect")
    "e f" '(eglot-format :wk "Eglot Format")
    "e l" '(consult-flymake :wk "Consult Flymake")
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

  ;; to prevent your leader keybindings from ever being overridden (e.g. an evil
  ;; package may bind "SPC"), use :keymaps 'override
  (dysthesis/gleader-def
    :states 'normal
    :keymaps 'override
    "a" 'org-agenda)
  ;; or
  (dysthesis/gleader-def 'normal 'override
    "a" 'org-agenda)
  ;; * Settings
  ;; change evil's search module after evil has been loaded (`setq' will not work)
  (general-setq evil-search-module 'evil-search))

(use-package vertico
  :ensure t
  :custom
  (vertico-multiform-commands '((consult-imenu buffer indexed reverse)
				(consult-ripgrep buffer reverse)
				(execute-extended-command unobtrusive)
				(t indexed reverse)))
  :init
  (vertico-multiform-mode)
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

(use-package orderless
  :ensure t
  :demand t
  :preface
  (eval-when-compile
    (require 'orderless))
  :custom
  (completion-styles '(orderless basic flex))
  (completion-category-overrides
   '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t)
  :config
  (defun dysthesis/orderless-fast-dispatch (word index total)
    (and (= index 0)
         (= total 1)
         (length< word 4)
         (cons 'orderless-literal-prefix word)))

  (orderless-define-completion-style orderless-fast
    (orderless-style-dispatchers
     '(dysthesis/orderless-fast-dispatch))
    (orderless-matching-styles
     '(orderless-literal orderless-regexp))))

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
  (corfu-popupinfo-delay '(0.5 . 0.2))
  :init
  (defun dysthesis/corfu-completion ()
    "Use cheaper Orderless matching for Corfu."
    (setq-local completion-styles '(orderless-fast basic)
                completion-category-defaults nil
                completion-category-overrides nil))
  :config
  (corfu-popupinfo-mode t)
  (corfu-history-mode t)
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

(use-package apheleia
  :ensure t
  :hook (prog-mode markdown-mode)
  :config (apheleia-global-mode +1))

(use-package treesit
  :ensure nil
  :demand t
  :custom
  (treesit-font-lock-level 4)
  :config
  (add-to-list
   'treesit-language-source-alist
   '(yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml"
	  :commit "b733d3f5f5005890f324333dd57e1f0badec5c87")
   t)
  ;; Prefer Tree-sitter implementations whenever both old and new
  ;; major modes exist.
  (dolist (mapping
           '((sh-mode       . bash-ts-mode)
             (c-mode        . c-ts-mode)
             (c++-mode      . c++-ts-mode)
             (c-or-c++-mode . c-or-c++-ts-mode)
             (css-mode      . css-ts-mode)
             (java-mode     . java-ts-mode)
             (js-mode       . js-ts-mode)
             (js-json-mode  . json-ts-mode)
             (python-mode   . python-ts-mode)
             (ruby-mode     . ruby-ts-mode)))
    (add-to-list 'major-mode-remap-alist mapping))

  ;; Languages for which the Tree-sitter mode is itself the natural
  ;; file association.
  (dolist (mapping
           '(("\\.rs\\'"              . rust-ts-mode)
             ("\\.go\\'"              . go-ts-mode)
             ("/go\\.mod\\'"          . go-mod-ts-mode)
             ("\\.ts\\'"              . typescript-ts-mode)
             ("\\.tsx\\'"             . tsx-ts-mode)
             ("\\.ya?ml\\'"           . yaml-ts-mode)
             ("\\.toml\\'"            . toml-ts-mode)
             ("\\.json\\'"            . json-ts-mode)
             ("Dockerfile\\(?:\\..*\\)?\\'" . dockerfile-ts-mode)))
    (add-to-list 'auto-mode-alist mapping)))

(use-package treesit-fold
  :ensure t
  :hook
  (after-init . global-treesit-fold-indicators-mode)
  (treesit-fold-mode . treesit-fold-line-comment-mode))

(use-package nix-mode
  :ensure t
  :mode "\\.nix\\'"
  :hook (nix-mode . eglot-ensure))

(use-package treesit-langs
  :commands treesit-langs-major-mode-setup)

;; This assumes you've installed the package via MELPA.
(use-package ligature
  :ensure t
  :config
  ;; Enable the "www" ligature in every possible major mode
  (ligature-set-ligatures 't '("www"))
  ;; Enable traditional ligature support in eww-mode, if the
  ;; `variable-pitch' face supports it
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  ;; Enable all Cascadia Code ligatures in programming modes
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                                       "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://"))
  ;; Enables ligature checks globally in all buffers. You can also do it
  ;; per mode with `ligature-mode'.
  (global-ligature-mode t))

(use-package solaire-mode
  :ensure t
  :demand t
  :config (solaire-global-mode +1))

(use-package ghostel
  :ensure t
  :bind (("C-x m" . ghostel)
         :map ghostel-semi-char-mode-map
         ("C-s"  . consult-line)
         ("M-<backspace>" . ghostel-backward-kill-word)
         ;; ;; I'm used to go up/down the shell history with M-n/p from eshell
         ;; ;; Simulate this behavior in ghostel by sending C-p and C-n
         ("M-p" . (lambda () (interactive) (ghostel-send-key "p" "ctrl")))
         ("M-n" . (lambda () (interactive) (ghostel-send-key "n" "ctrl")))
         :map project-prefix-map
         ("m" . ghostel-project)
         ("M" . ghostel-project-list-buffers))
  :config
  (defun ghostel-send-C-k-and-kill ()
    "Send `C-k' to ghostel.
Like normal Emacs `C-k'.  Kill to end of line and put content in kill-ring."
    (interactive)
    (kill-ring-save (point) (line-end-position))
    (ghostel-send-key "k" "ctrl"))

  (add-to-list 'project-switch-commands '(ghostel-project "Ghostel") t)
  (add-to-list 'project-switch-commands '(ghostel-project-list-buffers "Ghostel buffers") t)
  (add-to-list 'ghostel-eval-cmds '("magit-status-setup-buffer" magit-status-setup-buffer)))

(use-package ghostel-eshell
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :hook (after-init . ghostel-compile-global-mode))

(use-package ghostel-comint
  :hook (after-init . ghostel-comint-global-mode))

(use-package evil-ghostel
  :ensure t
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(use-package markdown-ts-mode
  :ensure nil
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :config
  (require 'markdown-ts-mode-x))
