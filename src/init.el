;;; init.el -*- lexical-binding: t; -*-
(require 'use-package)
(setq custom-file (locate-user-emacs-file "custom.el"))
(with-eval-after-load 'package
  (setq package-archives nil))
(setq use-package-always-defer nil
      use-package-enable-imenu-support t)
(when init-file-debug
  (setq use-package-verbose t
	use-package-minimum-reported-time 0
	use-package-expand-minimally nil
	use-package-compute-statistics t))

(use-package emacs
  :ensure nil
  :init
  (setq backup-directory-alist `(("." . "~/.cache/saves")))
  (setq window-sides-vertical t) ;; Left and right side windows occupy full frame height
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
  (setq-default fill-column 80)
  (set-face-attribute 'fill-column-indicator nil
                      :foreground "#717C7C" ; katana-gray
                      :background "transparent")
  (global-display-fill-column-indicator-mode 1)
  (setq-default line-spacing 0.2)
  (menu-bar-mode -1)
  (setq initial-scratch-message nil)
  (defun display-startup-echo-area-message ()
    (message ""))
  (defalias 'yes-or-no-p 'y-or-n-p)
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))
  (let ((font-family "IosevkaCadmus Nerd Font")
	(font-height 95))
    (set-face-attribute
     'default nil
     :font
     (font-spec
      :family "IosevkaCadmus Nerd Font"
      :weight 'normal
      :size 9.5))

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
  (add-to-list 'face-font-rescale-alist
	       '("Atkinson Hyperlegible Next" . 1.2)))

(use-package ouroboros
  :config
  (load-theme 'ouroboros-dark :no-confirm))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package general
  :preface
  (eval-and-compile
    (require 'general)
    (general-create-definer dysthesis/gleader-def
      :prefix "SPC"))
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
  :config
  (vertico-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook
            #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :hook
  (dired-mode . nerd-icons-dired-mode))

(use-package nerd-icons-ibuffer
  :hook
  (ibuffer-mode . nerd-icons-ibuffer-mode))

(use-package vertico-multiform
  :ensure nil
  :after vertico
  :custom
  (vertico-multiform-commands '((consult-imenu buffer indexed reverse)
				(consult-ripgrep buffer reverse)
				(t reverse)))
  :config
  (require 'vertico-buffer)
  (require 'vertico-indexed)
  (require 'vertico-reverse)
  (vertico-multiform-mode))

(use-package marginalia
  :after vertico
  :config
  (marginalia-mode))

(use-package which-key
  :ensure nil
  :after (vertico)
  :config
  (setq which-key-show-early-on-C-h t
	which-key-idle-delay 1e6 ; 11 days
	which-key-idle-secondary-delay 0.05)
  (which-key-mode))

(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :after (:and embark consult)
  :demand t ; only necessary if you have the hook below
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :ensure nil
  :init
  (savehist-mode))

(use-package orderless
  :demand t
  :preface
  (eval-when-compile
    (require 'orderless))
  :custom
  (completion-styles '(orderless basic flex))
  (completion-category-overrides
   '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package consult
  :demand t
  :functions (consult-xref consult-register-window consult-register-format)
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  (advice-add #'register-preview :override #'consult-register-window)

  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  (require 'consult-flymake)
  (require 'consult-imenu)
  ;; Accept VCS markers as project root markers
  (setopt project-vc-extra-root-markers '(".projectile" ".git")))

(use-package nucleo-completion
  :config
  (nucleo-completion-ensure-module)

  (add-to-list
   'completion-category-overrides
   '(eglot-capf
     (styles nucleo basic))))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.05)
  (corfu-count 10)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-sort-override-function nil)
  :config
  (global-corfu-mode))

(use-package corfu-popupinfo
  :ensure nil
  :after corfu
  :config
  (corfu-popupinfo-mode t))

(use-package corfu-history
  :ensure nil
  :after corfu
  :config
  (corfu-history-mode t))

(use-package nerd-icons)

(use-package nerd-icons-corfu
  :after corfu
  :init (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :after corfu
  :functions (cape-keyword)
  :init
  ;; Path completion
  (add-to-list 'completion-at-point-functions #'cape-file)
  ;; Complete elisp in Org or Markdown mode
  (add-to-list 'completion-at-point-functions #'cape-elisp-block) 
  ;; Keyword/Snipet completion
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  :config
  (require 'cape-keyword))

(use-package tempel
  :demand t
  ;; Require trigger prefix before template name when completing.
  ;; :custom
  ;; (tempel-trigger-prefix "<")

  :bind (("M-+" . tempel-complete) ;; Alternative tempel-expand
         ("M-*" . tempel-insert)
	 (:map tempel-map
	       ([backtab] . tempel-previous)
	       ([tab] . tempel-next)))
  :init

  ;; Setup completion at point
  (defun tempel-setup-capf ()
    ;; Add the Tempel Capf to `completion-at-point-functions'.
    ;; `tempel-expand' only triggers on exact matches. Alternatively use
    ;; `tempel-complete' if you want to see all matches, but then you
    ;; should also configure `tempel-trigger-prefix', such that Tempel
    ;; does not trigger too often when you don't expect it. NOTE: We add
    ;; `tempel-expand' *before* the main programming mode Capf, such
    ;; that it will be tried first.
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      completion-at-point-functions)))

  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)

  ;; Optionally make the Tempel templates available to Abbrev,
  ;; either locally or globally. `expand-abbrev' is bound to C-x '.
  (add-hook 'prog-mode-hook #'tempel-abbrev-mode)
  :config
  (global-tempel-abbrev-mode))

(use-package tempel-collection
  :after tempel)

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package forge
  :after magit
  :custom (auth-sources '("~/.authinfo.gpg")))

(use-package diff-hl
  :init
  (set-fringe-mode 8)
  (setq-default fringes-outside-margins t)

  :custom
  (diff-hl-draw-borders nil)
  (diff-hl-side 'left)

  ;; more responsive updates.
  (diff-hl-show-staged-changes nil)

  :config
  (defun dysthesis/diff-hl-define-thin-bitmap (&rest _)
    (let* ((scale
            (if (and (boundp 'text-scale-mode-amount)
                     (numberp text-scale-mode-amount))
                (expt text-scale-mode-step text-scale-mode-amount)
              1))
           (spacing
            (or (and (display-graphic-p)
                     (default-value 'line-spacing))
                0))
           (total-spacing
            (pcase spacing
              ((pred numberp) spacing)
              (`(,above . ,below) (+ above below))))
           (h (+ (ceiling (* (frame-char-height) scale))
                 (if (floatp total-spacing)
                     (truncate
                      (* (frame-char-height) total-spacing))
                   total-spacing)))
           (w (min
               (frame-parameter
                nil
                (intern (format "%s-fringe" diff-hl-side)))
               diff-hl-bmp-max-width)))

      (when (zerop w)
        (setq w diff-hl-bmp-max-width))

      (define-fringe-bitmap
        'diff-hl-bmp-middle
        (make-vector
         h
         (string-to-number
          (let ((half-w (1- (/ w 2))))
            (concat
             (make-string half-w ?1)
             (make-string (- w half-w) ?0)))
          2))
        nil nil 'center)))

  (advice-add #'diff-hl-define-bitmaps
              :after
              #'dysthesis/diff-hl-define-thin-bitmap)

  (defun dysthesis/diff-hl-bitmap-from-type (type _pos)
    (if (eq type 'delete)
        'diff-hl-bmp-delete
      'diff-hl-bmp-middle))

  (setq diff-hl-fringe-bmp-function
        #'dysthesis/diff-hl-bitmap-from-type)

  (defun dysthesis/diff-hl-transparent-faces (&rest _)
    (dolist (face '(diff-hl-insert
                    diff-hl-delete
                    diff-hl-change))
      (set-face-background face nil)))

  (dysthesis/diff-hl-transparent-faces)

  (add-hook 'enable-theme-functions
            #'dysthesis/diff-hl-transparent-faces)

  (add-hook 'magit-pre-refresh-hook
            #'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook
            #'diff-hl-magit-post-refresh)

  (global-diff-hl-mode))

(use-package smartparens
  :hook (prog-mode text-mode markdown-mode)
  :config (require 'smartparens-config))

(use-package apheleia
  :hook (prog-mode markdown-mode)
  :config
  (push '(alejandra . ("alejandra")) apheleia-formatters)
  (setf (alist-get 'nix-mode apheleia-mode-alist) '(alejandra)))

(use-package treesit
  :ensure nil
  :demand t
  :custom
  (treesit-font-lock-level 4)
  :config
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
           '(("\\.go\\'"              . go-ts-mode)
             ("/go\\.mod\\'"          . go-mod-ts-mode)
             ("\\.ts\\'"              . typescript-ts-mode)
             ("\\.tsx\\'"             . tsx-ts-mode)
             ("\\.ya?ml\\'"           . yaml-ts-mode)
             ("\\.toml\\'"            . toml-ts-mode)
             ("\\.json\\'"            . json-ts-mode)
             ("Dockerfile\\(?:\\..*\\)?\\'" . dockerfile-ts-mode)))
    (add-to-list 'auto-mode-alist mapping)))

(use-package treesit-fold
  :preface
  (defconst dysthesis/treesit-function-like-type-regexp
    (concat
     (regexp-opt
      '("function"
        "method"
        "constructor"
        "destructor"
        "lambda"
        "closure"
        "procedure"
        "subroutine"
        "macro"))
     "\\|\\`fn\\(?:[_-]?\\(?:decl\\(?:aration\\)?\\|def\\(?:inition\\)?\\|item\\)\\)\\'")
    "Regexp matching Tree-sitter nodes representing function-like constructs.")

  (defun dysthesis/treesit-function-like-node-p (node)
    "Return non-nil when NODE represents a function-like construct."
    (when node
      (let ((case-fold-search t))
        (string-match-p
         dysthesis/treesit-function-like-type-regexp
         (treesit-node-type node)))))

  (defun dysthesis/treesit-function-fold-node-p (node)
    "Return non-nil when foldable NODE is a function or its body.

Some grammars make the whole function the foldable node, while
others make only its body/block foldable."
    (or
     ;; Python, Ruby, Elisp, Haskell, etc. may make the function node
     ;; itself the foldable thing.
     (dysthesis/treesit-function-like-node-p node)

     ;; Rust, C, C++, Go, Java, JavaScript, etc. generally make the
     ;; body/block foldable instead.
     (dysthesis/treesit-function-like-node-p
      (treesit-node-parent node))))

  (defun dysthesis/treesit-multiline-node-p (node)
    "Return non-nil when NODE extends beyond its starting line."
    (save-excursion
      (goto-char (treesit-node-start node))
      (> (treesit-node-end node)
         (line-end-position))))

  (defun dysthesis/treesit-fold-function-bodies ()
    "Fold every function-like body in the current Tree-sitter buffer.

Only consider nodes already supported by `treesit-fold', so its
language-specific range functions continue to determine exactly
which characters disappear."
    (when (and (bound-and-true-p treesit-fold-mode)
               (treesit-parser-list))
      (when-let* ((fold-ranges
                   (alist-get major-mode treesit-fold-range-alist))
                  (root
                   (treesit-buffer-root-node)))
        (let* ((patterns
                (seq-mapcat
                 (lambda (fold-range)
                   `((,(car fold-range)) @fold))
                 fold-ranges))
               (query
                (treesit-query-compile
                 (treesit-node-language root)
                 patterns))
               (nodes
                (treesit-query-capture root query))
               ;; Avoid refreshing the gutter once per function.
               (refresh-indicators
                (bound-and-true-p treesit-fold-indicators-mode)))

          (let ((treesit-fold-indicators-mode nil)
                (treesit-fold-on-fold-hook nil))
            (save-excursion
              (dolist (capture nodes)
                (let ((node (cdr capture)))
                  (when
                      (and
                       (dysthesis/treesit-function-fold-node-p node)
                       ;; Match `treesit-fold-close-all': don't bother
                       ;; folding constructs entirely on one line.
                       (dysthesis/treesit-multiline-node-p node))
                    (treesit-fold-close node))))))

          (when (and refresh-indicators
                     (fboundp 'treesit-fold-indicators-refresh))
            (treesit-fold-indicators-refresh))))))

  :custom
  ;; Show how much code disappeared.
  (treesit-fold-line-count-show t)
  (treesit-fold-line-count-format "  … %d lines  … ")

  ;; Keep the gutter implementation cheap.
  (treesit-fold-indicators-render-method 'partial)

  ;; Use the right fringe if the left is occupied by Git/diff markers.
  (treesit-fold-indicators-fringe 'right-fringe)

  :config
  (set-face-attribute
   'treesit-fold-replacement-face nil
   :inherit 'shadow
   :foreground "#5a5a5a"
   :background 'unspecified
   :box nil
   :weight 'light)

  (set-face-attribute
   'treesit-fold-replacement-mouse-face nil
   :inherit 'highlight
   :foreground 'unspecified
   :box nil)

  ;; Make fold structure itself subdued.
  (set-face-attribute
   'treesit-fold-fringe-face nil
   :inherit 'shadow)

  (with-eval-after-load 'treesit-fold-indicators
    (define-fringe-bitmap
      'treesit-fold-indicators-fr-plus
      [#b00010000
       #b00011000
       #b00011100
       #b00011000
       #b00010000]
      nil nil 'center)

    (define-fringe-bitmap
      'treesit-fold-indicators-fr-minus-tail
      [#b00000000
       #b00000000
       #b00100010
       #b00010100
       #b00001000]
      nil nil 'center))
  :hook
  ((treesit-fold-mode . treesit-fold-line-comment-mode)
   (treesit-fold-mode . dysthesis/treesit-fold-function-bodies)))

(use-package treesit-fold-indicators
  :ensure nil
  :hook (after-init . global-treesit-fold-indicators-mode))

(use-package nix-mode
  :mode "\\.nix\\'"
  :hook (nix-mode . eglot-ensure))

;; This assumes you've installed the package via MELPA.
(use-package ligature
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
  :demand t
  :config (solaire-global-mode +1))

(use-package ghostel
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
  :ensure nil
  :hook (eshell-load . ghostel-eshell-visual-command-mode))

(use-package ghostel-compile
  :ensure nil
  :hook (after-init . ghostel-compile-global-mode))

(use-package ghostel-comint
  :ensure nil
  :hook (after-init . ghostel-comint-global-mode))

(use-package evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

(use-package markdown-ts-mode
  :ensure nil
  :mode ("\\.md\\'" "\\.mdx\\'" "\\.markdown\\'")
  :config
  (require 'markdown-ts-mode-x))

(use-package zig-mode
  :mode ("\\.zig\\'"))

(use-package envrc
  :hook (after-init . envrc-global-mode))

(use-package eglot
  :ensure nil
  :defer t
  :custom 
  (eglot-sync-connect nil) ;; Do not block emacs while connecting to LSP
  (eglot-event-buffer-config '(:size 0 :format short)) ;; Disable event logging
  (eglot-cache-session-completions t)
  (eglot-advertise-cancellation t)
  (eglot-code-action-indications nil) ;; avoid another periodic lsp request competing with completion
  :init
  (defun eglot-ensure-local-only ()
    "Enable Eglot only on local buffers."
    (unless (file-remote-p default-directory) (eglot-ensure)))
  :hook
  (zig-mode . eglot-ensure-local-only)
  (nix-mode . eglot-ensure-local-only)
  (rust-ts-mode . eglot-ensure-local-only))

(use-package dape
  :preface
  (defun dysthesis/dape--codelldb-dir-default ()
    "Compute the codelldb adapter directory from the environment."
    (let ((dir (getenv "CODELLDB_DIR")))
      (if (and dir (not (string= dir "")))
          dir
        (expand-file-name "debug-adapters" user-emacs-directory))))

  (defcustom dysthesis/dape-codelldb-dir (dysthesis/dape--codelldb-dir-default)
    "Directory containing the codelldb debug adapter."
    :type 'directory)

  (defun dysthesis/dape--codelldb-command ()
    "Return codelldb from PATH."
    (or (executable-find "codelldb")
	(user-error "codelldb not found in PATH")))

  (defun dysthesis/dape--refresh-codelldb-configs ()
    "Refresh codelldb entries in `dape-configs`."
    (when (boundp 'dape-configs)
      (dolist (name '(codelldb-cc codelldb-rust))
        (let ((cfg (alist-get name dape-configs)))
          (when cfg
            (setf (alist-get name dape-configs)
                  (plist-put (copy-tree cfg)
                             'command
                             #'dysthesis/dape--codelldb-command)))))))

  (defun dysthesis/dape-refresh-adapter-dir (&rest _)
    "Refresh codelldb adapter settings from the current environment."
    (setq dysthesis/dape-codelldb-dir (dysthesis/dape--codelldb-dir-default))
    (dysthesis/dape--refresh-codelldb-configs))
  (dysthesis/dape-refresh-adapter-dir)
  (with-eval-after-load 'dape
    (dysthesis/dape-refresh-adapter-dir))
  ;; Keep `dape-adapter-dir` in sync when direnv updates environment vars.
  (with-eval-after-load 'direnv
    (advice-add 'direnv-update-directory-environment :after
                #'dysthesis/dape-refresh-adapter-dir))
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  ;; (setq dape-key-prefix "\C-x\C-a")

  :hook
  ;; Save breakpoints on quit
  (kill-emacs . dape-breakpoint-save)
  ;; Load breakpoints on startup
  (after-init . dape-breakpoint-load)

  :custom
  ;; Turn on global bindings for setting breakpoints with mouse
  (dape-breakpoint-global-mode +1)

  ;; Info buffers to the right
  ;; (dape-buffer-window-arrangement 'right)
  ;; Info buffers like gud (gdb-mi)
  (dape-buffer-window-arrangement 'gud)
  ;; (dape-info-hide-mode-line nil)


  :config
  (let ((common
         `(ensure dape-ensure-command
		  command-cwd dape-command-cwd
		  command ,#'dysthesis/dape--codelldb-command
		  port :autoport
		  :type "lldb"
		  :request "launch"
		  :cwd "."
		  :args []
		  :stopOnEntry nil)))

    (add-to-list
     'dape-configs
     `(codelldb-cc
       modes (c-mode c-ts-mode c++-mode c++-ts-mode)
       command-args ("--port" :autoport)
       ,@common
       :program "a.out"))
    (add-to-list
     'dape-configs
     `(codelldb-zig
       modes (zig-mode zig-ts-mode)
       ensure dape-ensure-command
       command-cwd dape-command-cwd
       command ,#'dysthesis/dape--codelldb-command
       command-args ("--port" :autoport)
       port :autoport

       :type "lldb"
       :request "launch"
       :cwd "."
       :program
       ,(lambda ()
	  (file-name-concat
	   "zig-out"
	   "bin"
	   (file-name-nondirectory
            (directory-file-name (dape-cwd)))))
       :args []
       :stopOnEntry nil))
    (add-to-list
     'dape-configs
     `(codelldb-rust
       modes (rust-mode rust-ts-mode)
       command-args
       ("--port" :autoport
        "--settings" "{\"sourceLanguages\":[\"rust\"]}")
       ,@common
       :program
       ,(lambda ()
          (file-name-concat
           "target" "debug"
           (file-name-nondirectory
            (directory-file-name (dape-cwd))))))))
  ;; Pulse source line (performance hit)
  (add-hook 'dape-display-source-hook #'pulse-momentary-highlight-one-line)

  ;; Kill compile buffer on build success
  (add-hook 'dape-compile-hook #'kill-buffer))

;; For a more ergonomic Emacs and `dape' experience
(use-package repeat
  :ensure nil
  :custom
  (repeat-mode +1))

(use-package writeroom-mode
  :commands (writeroom-mode)
  :config (dysthesis/gleader-def 'normal
	    "t w" '(writeroom-mode :wk "[T]oggle [W]riteroom mode")))
(use-package kirigami
  :custom
  ;; Add Kirigami to the menu bar and context menu (`context-menu-mode').
  (kirigami-show-menu-bar t)
  (kirigami-show-context-menu t)
  :config
  ;; Configure Kirigami to replace the default Evil-mode folding key bindings
  (with-eval-after-load 'evil
    (define-key evil-normal-state-map "zo" 'kirigami-open-fold)
    (define-key evil-normal-state-map "zO" 'kirigami-open-fold-rec)
    (define-key evil-normal-state-map "zc" 'kirigami-close-fold)
    (define-key evil-normal-state-map "za" 'kirigami-toggle-fold)
    (define-key evil-normal-state-map "zr" 'kirigami-open-folds)
    (define-key evil-normal-state-map "zm" 'kirigami-close-folds))
  (kirigami-global-mode 1))

(use-package prescient
  :custom
  ;; Do not disturb the original candidate ordering merely because
  ;; two candidates have identical Prescient scores.
  (prescient-sort-length-enable nil)
  :config
  (prescient-persist-mode 1))

(use-package vertico-prescient
  :after (vertico prescient)
  :custom
  ;; Orderless remains responsible for matching.
  (vertico-prescient-enable-filtering nil)
  ;; Prescient contributes only adaptive sorting.
  (vertico-prescient-enable-sorting t)
  ;; Respect completion sources which supply their own ranking.
  (vertico-prescient-override-sorting nil)

  :config
  (vertico-prescient-mode 1))

(use-package gcmh
  :demand
  :config
  (gcmh-mode 1))

(use-package rustic
  :mode ("\\.rs\\'" . rustic-mode)
  :hook (rustic-mode . rust-ts-mode)
  :custom
  (rustic-lsp-client 'eglot))

(use-package nerd-icons)
;; Autoload Nerd Icons only when the mode line actually needs them.
;; This avoids loading nerd-icons while default.el is byte-compiled.
(autoload 'nerd-icons-icon-for-buffer "nerd-icons" nil nil)
(autoload 'nerd-icons-octicon "nerd-icons" nil nil)
(autoload 'nerd-icons-faicon "nerd-icons" nil nil)


;;;; Faces
(defun dysthesis/mode-line-major-mode ()
  (condition-case nil
      (concat
       (nerd-icons-icon-for-mode major-mode)
       " "
       (format-mode-line mode-name))
    (error
     (format-mode-line mode-name))))

(defface dysthesis/mode-line-buffer
  '((t (:inherit mode-line-buffer-id
		 :weight bold)))
  "Face for the current buffer.")

(defface dysthesis/mode-line-secondary
  '((t (:inherit shadow
		 :slant italic)))
  "Face for secondary mode-line information.")

(defface dysthesis/mode-line-dim
  '((t (:inherit shadow)))
  "Face for low-priority mode-line information.")

(defface dysthesis/mode-line-lsp
  '((t (:inherit success
		 :weight semi-bold)))
  "Face for active LSP information.")

(defface dysthesis/mode-line-evil-normal
  '((t (:inherit mode-line-emphasis
		 :weight bold)))
  "Face for Evil normal state.")

(defface dysthesis/mode-line-evil-insert
  '((t (:inherit success
		 :weight bold
		 :underline t)))
  "Face for Evil insert state.")

(defface dysthesis/mode-line-evil-visual
  '((t (:inherit font-lock-constant-face
		 :weight bold
		 :slant italic
		 :underline t)))
  "Face for Evil visual state.")

(defface dysthesis/mode-line-evil-replace
  '((t (:inherit error
		 :weight bold
		 :underline t)))
  "Face for Evil replace state.")

(defface dysthesis/mode-line-evil-operator
  '((t (:inherit warning
		 :weight bold
		 :slant italic)))
  "Face for Evil operator state.")

(defface dysthesis/mode-line-evil-motion
  '((t (:inherit shadow
		 :weight bold
		 :slant italic)))
  "Face for Evil motion state.")

(defface dysthesis/mode-line-evil-emacs
  '((t (:inherit shadow
		 :weight bold)))
  "Face for Evil Emacs state.")


;;;; Evil state

(defface dysthesis/mode-line-git
  '((((background dark))
     (:foreground "#5a5a5a"))
    (((background light))
     (:foreground "#888888")))
  "Face for Git information.")

(defun dysthesis/mode-line-evil ()
  (when (and (mode-line-window-selected-p)
             (boundp 'evil-local-mode)
             (symbol-value 'evil-local-mode)
             (boundp 'evil-state))
    (let ((state
           (pcase (symbol-value 'evil-state)
             ('normal
              (propertize "NOR"
                          'face 'dysthesis/mode-line-evil-normal))
             ('insert
              (propertize "INS"
                          'face 'dysthesis/mode-line-evil-insert))
             ('visual
              (propertize "VIS"
                          'face 'dysthesis/mode-line-evil-visual))
             ('replace
              (propertize "REP"
                          'face 'dysthesis/mode-line-evil-replace))
             ('operator
              (propertize "OPR"
                          'face 'dysthesis/mode-line-evil-operator))
             ('motion
              (propertize "MOT"
                          'face 'dysthesis/mode-line-evil-motion))
             ('emacs
              (propertize "EMC"
                          'face 'dysthesis/mode-line-evil-emacs))
             (_ nil))))
      (when state
        (concat state "  ")))))

;;;; Buffer

(defun dysthesis/mode-line-buffer-icon ()
  (condition-case nil
      (concat (nerd-icons-icon-for-buffer) " ")
    (error "")))

(defun dysthesis/mode-line-buffer-state ()
  (cond
   (buffer-read-only
    (condition-case nil
        (concat
         (propertize
          (nerd-icons-octicon "nf-oct-lock")
          'face 'dysthesis/mode-line-dim)
         " ")
      (error "RO ")))

   ((buffer-modified-p)
    (propertize "● "
                'face 'warning))))


;;;; Git / VC
(defun dysthesis/mode-line-vc ()
  (when (and (mode-line-window-selected-p)
             vc-mode)
    (let* ((raw
            (string-trim
             (substring-no-properties vc-mode)))
           (branch
            (replace-regexp-in-string
             "\\`[^@!?:-]+[@!?:-]"
             ""
             raw)))
      (condition-case nil
          (concat
           "  "
           (propertize
            (nerd-icons-octicon "nf-oct-git_branch")
            'face 'dysthesis/mode-line-git)
           " "
           (propertize branch
                       'face 'dysthesis/mode-line-git))
        (error
         (concat
          "  "
          (propertize branch
                      'face 'dysthesis/mode-line-git)))))))

;;;; Eglot

(defun dysthesis/mode-line-eglot-render (symbol)
  "Render Eglot mode-line component SYMBOL if available."
  (when (boundp symbol)
    (let ((rendered (format-mode-line symbol)))
      (unless (equal rendered "")
        rendered))))

(defun dysthesis/mode-line-eglot ()
  (when (and (mode-line-window-selected-p)
             (boundp 'eglot--managed-mode)
             (symbol-value 'eglot--managed-mode))

    (let* ((session
            (dysthesis/mode-line-eglot-render
             'eglot-mode-line-session))

           (error-state
            (dysthesis/mode-line-eglot-render
             'eglot-mode-line-error))

           (pending
            (dysthesis/mode-line-eglot-render
             'eglot-mode-line-pending-requests))

           (progress
            (dysthesis/mode-line-eglot-render
             'eglot-mode-line-progress))

           (action
            (dysthesis/mode-line-eglot-render
             'eglot-mode-line-action-suggestion))

           (status
            (delq nil
                  (list error-state
                        pending
                        progress
                        action))))
      (concat
       ;; LSP icon.
       (condition-case nil
           (nerd-icons-faicon "nf-fa-code")
         (error "LSP"))
       " "
       (propertize "LSP"
                   'face 'dysthesis/mode-line-lsp)
       (when (and session
                  (not (equal session "")))
         (concat
          " "
          (propertize
           (substring-no-properties session)
           'face 'dysthesis/mode-line-secondary)))
       ;; Preserve Eglot's own faces for errors/progress/actions.
       (when status
         (concat
          " "
          (mapconcat #'identity status "/")))
       "  "))))


;;;; Mode line
(setq-default
 mode-line-format
 '(" "
   (:eval
    (dysthesis/mode-line-evil))
   (:eval
    (dysthesis/mode-line-buffer-state))
   (:eval
    (dysthesis/mode-line-buffer-icon))
   (:propertize "%b"
                face dysthesis/mode-line-buffer)
   (:eval
    (dysthesis/mode-line-vc))
   mode-line-format-right-align
   (:eval
    (dysthesis/mode-line-eglot))
   (:eval
    (propertize
     (dysthesis/mode-line-major-mode)
     'face 'dysthesis/mode-line-secondary))
   "  "
   (:propertize "%l:%c"
                face dysthesis/mode-line-dim)
   " "))
