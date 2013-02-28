;;; init.el -- Emacs configuration in a single file.
;;
;; Copyright (C) 2012 Google Inc.
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;
;; Author: yesudeep@google.com (Yesudeep Mangalapilly)
;;
;;; This file is NOT a part of GNU Emacs.


(eval-when-compile
  (require 'cl))

;; Dear Emacs, please don't make me wait at startup.
(modify-frame-parameters nil '((wait-for-wm . nil)))

(setq redisplay-dont-pause t)

(set-locale-environment "en_US.UTF-8")

;; ======================================================================
;; Initial configuration.
;; ======================================================================
(setq config-dir (file-name-directory (or (buffer-file-name)
                                          load-file-name)))
(add-to-list 'load-path config-dir)

;; Directory paths.
(setq goog-site-lisp-dir (expand-file-name
                          (concat config-dir "site-lisp")))

;; Load-path.
(add-to-list 'load-path goog-site-lisp-dir)

;; Add all subdirectories of site-lisp to load path.
(let ((default-directory goog-site-lisp-dir))
  (normal-top-level-add-subdirs-to-load-path))

;; Network-specific configuration is loaded from goog-network-dir.
(setq goog-network-name "corp.google.com"
      goog-network-dir (format "~/.%s/emacs.d/" goog-network-name)
      goog-network-re ".*[.]corp[.]google[.]com")

;; ======================================================================
;; Platform detection.
;; ======================================================================
(defun goog/platform/is-darwin-p ()
  "Determines whether the system is darwin-based (Mac OS X)"
  (interactive)
  (string-equal system-type "darwin"))

(defun goog/platform/is-linux-p ()
  "Determines whether the system is GNU/Linux-based."
  (interactive)
  (string-equal system-type "gnu/linux"))


;; ======================================================================
;; Package management.
;; ======================================================================
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))
(defvar default-packages '(
                           ;; slime
                           ;; slime-js
                           ;; slime-repl
                           ;; smex   ;; Don't use this one. el-get works.
                           ace-jump-mode
                           ac-slime
                           ;; auto-complete ;; Use the el-get version.
                           autopair
                           clojure-mode
                           clojure-test-mode
                           clojurescript-mode
                           dart-mode
                           evil-numbers
                           fastnav
                           fill-column-indicator
                           find-things-fast
                           ;; go-mode
                           helm
                           highlight-symbol
                           ido-ubiquitous
                           iedit
                           ioccur
                           js2-mode
                           key-chord
                           less-css-mode
                           loccur
                           magit
                           maxframe
                           melpa
                           ;; move-text
                           ;; multiple-cursors
                           nav
                           nrepl
                           paredit
                           perspective
                           rainbow-mode
                           switch-window
                           undo-tree
                           ;; yasnippet
                           yaml-mode
                           zencoding-mode

                           ;; Themes.
                           ;; django-theme
                           ;; github-theme
                           ;; inkpot-theme
                           ;; ir-black-theme
                           ;; ir_black-theme
                           ;; monokai-theme
                           ;; tango-2-theme
                           ;; tron-theme
                           ;; twilight-theme
                           ;; ujelly-theme
                           ;; underwater-theme
                           ;; zenburn-theme
                           ))
(dolist (p default-packages)
  (when (not (package-installed-p p))
    (package-install p)))

;; ----------------------------------------------------------------------
;; Installs el-get.
;; ----------------------------------------------------------------------
;; El-get manages packages for GNU Emacs and can install, load, configure
;; and uninstall packages for you easily.
;;
;; @see http://github.com/dimitri/el-get/
;; @see http://www.emacswiki.org/emacs/el-get
;; ----------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (url-retrieve
   "https://raw.github.com/dimitri/el-get/master/el-get-install.el"
   (lambda (s)
     (let (el-get-master-branch)
       (goto-char (point-max))
       (eval-print-last-sexp)))))

;; ----------------------------------------------------------------------
;; El-get packages.
;; ----------------------------------------------------------------------
;; NOTE: Use el-get packages only if we do not have stable packages
;; in elpa, melpa, marmalade.
;; ----------------------------------------------------------------------
(setq
 el-get-sources
 '(el-get
   (:name smex              ;; a better (ido-like) M-x
          :after (progn
                   (setq smex-save-file "~/.emacs.d/.smex-items")
                   (global-set-key (kbd "M-x") 'smex)
                   (global-set-key (kbd "M-X") 'smex-major-mode-commands)))

   ;; (:name smart-forward
   ;;        :website "https://github.com/magnars/smart-forward.el#readme"
   ;;        :description "Smarter movement forwards and backwards."
   ;;        :type github
   ;;        :pkgname "magnars/smart-forward.el"
   ;;        :depends (expand-region)
   ;;        :post-init (progn
   ;;                     (require 'smart-forward)))

   (:name go-mode
          :website "http://github.com/dominikh/go-mode.el#readme"
          :description "An improved go-mode."
          :type github
          :pkgname "dominikh/go-mode.el"
          :post-init (progn
                       (require 'go-mode)))

   ;; (:name emacs-git-gutter
   ;;        :website "https://github.com/syohex/emacs-git-gutter#readme"
   ;;        :description "Show git diff status for a buffer in the gutter."
   ;;        :type github
   ;;        :pkgname "syohex/emacs-git-gutter"
   ;;        :depends (fringe-helper)
   ;;        :post-init (progn
   ;;                     (require 'git-gutter)
   ;;                     ;; (require 'git-gutter-fringe) ;; If you want the fringe version.
   ;;                     (add-hook 'after-save-hook
   ;;                               (lambda ()
   ;;                                 (if (zerop (call-process-shell-command "git rev-parse --show-toplevel"))
   ;;                                     (git-gutter))))
   ;;                     ))
   ))

(setq
 goog:el-get-packages
 '(el-get
   ;; pymacs
   auto-complete
   yasnippet
   coffee-mode
   ;; clojure-mode
   ;; fill-column-indicator
   ;; js2-mode
   powerline
   expand-region
   jedi ;; Python autocompletion using jedi, python-epc, and autocomplete.
   ;; auto-async-byte-compile ;; This is nothing but trouble.
   ;; ioccur
   multiple-cursors
   js2-refactor
   ;; pydoc-info
   projectile
   ))
;; Synchronize el-get packages.
(setq goog:el-get-packages
      (append
       goog:el-get-packages
       (loop for src in el-get-sources collect (el-get-source-name src))))
(el-get 'sync goog:el-get-packages)
;;(el-get 'wait)

;; Load our definitions.
(require 'goog-defuns)

;; ======================================================================
;; Vanilla Emacs preferences.
;; ======================================================================

;; Maximize the Emacs frame on startup.
;; TODO(yesudeep): resolve a bug where it hides the first line of every buffer.
;;(require 'maxframe)
;;(add-hook 'window-setup-hook 'maximize-frame t)

(when window-system
  (blink-cursor-mode nil)
  (global-font-lock-mode 1)
  (global-hl-line-mode)
  (mouse-wheel-mode t)
  (scroll-bar-mode -1)
  (setq frame-title-format '(buffer-file-name "%f" ("%b")))
  (tool-bar-mode -1)
  (tooltip-mode -1)
  )

(setq-default indent-tabs-mode nil
              indicate-empty-lines t
              indicate-buffer-boundaries (quote left)
              require-final-newline t
              ;; next-line-add-newlines nil     ;; Don't add newlines past EOF.
              )

(setq
      auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
      backup-directory-alist `((".*" . ,temporary-file-directory))
      color-theme-is-global t
      diff-switches "-u"
      ediff-window-setup-function 'ediff-setup-windows-plain
      inhibit-startup-message t
      mouse-yank-at-point t
      oddmuse-directory (concat user-emacs-directory "oddmuse")
      read-file-name-completion-ignore-case 't
      save-place-file (concat user-emacs-directory "places")
      sentence-end-double-space nil
      shift-select-mode t            ;; Some of my users want this.
      uniquify-buffer-name-style 'forward
      visible-bell t
      )


(add-hook 'snippet-mode-hook (lambda ()
                               (setq require-final-newline nil)
                               ;; Don't enable this for snippets.
                               ))

(progn
  (column-number-mode 1)             ;; show column numbers in mode line.
  (delete-selection-mode 1)          ;; Overwrite selection; DWIM.
  (fset 'yes-or-no-p 'y-or-n-p)      ;; y or n is better than yes or no.
  (global-auto-revert-mode 1)        ;; Auto-reflect on-disk changes.
  (global-linum-mode 1)              ;; line numbers in left gutter.
  (global-subword-mode t)            ;; Use subword navigation.
  (line-number-mode 1)               ;; show line numbers in the mode line.
  )

(progn
  (show-paren-mode t)                ;; Highlight matching parentheses.
  ;; (setq show-paren-style 'expression)
  )

;; Cua mode without the nonsense.
(setq cua-enable-cua-keys nil)       ;; Turn off Windows key bindings.
(cua-mode t)                         ;; Rectangular selections are awesome.
(cua-selection-mode nil)             ;; No shift-arrow style marking.

(progn
  (setq desktop-dirname config-dir

        desktop-enable t
        desktop-restore-eager 5
        desktop-load-locked-desktop t
        desktop-files-not-to-save "^$"  ;; Reload tramp paths.
        desktop-save 'if-exists
        )
  (desktop-save-mode t)           ;; Save sessions.
  (desktop-load-default)          ;; Load the desktop on startup.
  )

;; Better buffer names.
(require 'uniquify)
;; (setq uniquify-buffer-name-style 'reverse)

;; ----------------------------------------------------------------------
;; Backups.
;; ----------------------------------------------------------------------
;; (setq backup-by-copying t             ;; don't clobber symlinks
;;       backup-directory-alist
;;       '(("." . "~/.emacs.d/saves"))   ;; don't litter my fs tree
;;       delete-old-versions t
;;       kept-new-versions 6
;;       kept-old-versions 2
;;       version-control t)              ;; use versioned backups
;; (setq backup-directory-alist `(("." . "~/.saves")))
;; (setq backup-by-copying nil)
;; (setq make-backup-files nil)             ;; No backup files ~
(setq backup-directory-alist
          `((".*" . "~/.emacs.d/saves")))
(setq auto-save-file-name-transforms
      `((".*" "~/.emacs.d/saves" t)))

;; ----------------------------------------------------------------------
;; Fonts
;; ----------------------------------------------------------------------
(when window-system
  (when (goog/platform/is-darwin-p)
    ;; Monaco is clean. The default is too small in the GUI.
    (set-face-font 'default "Monaco-13")
    ;; Mac OS X-specific font anti-aliasing.
    (setq mac-allow-anti-aliasing t)))

;; Scroll faster.
(setq mouse-wheel-scroll-amount '(7 ((shift) . 1) ((control) . nil)))


;; Enables mouse support scrolling when using Emacs in the terminal.
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] '(lambda ()
                               (interactive)
                               (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                               (interactive)
                               (scroll-up 1)))
  ;; (defun track-mouse (e))
  (setq mouse-sel-mode t))

;; ----------------------------------------------------------------------
;; Editing and searching.
;; ----------------------------------------------------------------------
(setq-default fill-column 80)     ;; right margin and fill column.
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-watchwords)
(add-hook 'prog-mode-hook 'turn-on-watchwords)

(defun goog/prog-mode-common/setup ()
  "Applies settings common to all programming language modes."
  (auto-fill-mode 1)
  (set (make-local-variable 'fill-nobreak-predicate)
       (lambda ()
         (not (eq (get-text-property (point) 'face)
                  'font-lock-comment-face)))))
(add-hook 'prog-mode-common-hook 'goog/prog-mode-common/setup)

;; Use whitespace mode. Cleans up trailing spaces, shows tabs, unnecessary
;; whitespace, end of file newline, bad indentation, text overrunning the
;; margin, etc.
(require 'whitespace)
(global-whitespace-mode t)
(setq whitespace-style
      '(face empty indentation lines-tail newline tabs trailing)
      whitespace-action '(auto-cleanup warn-read-only)
      whitespace-line-column 80)
;; Disabled space-mark newline-mark because it makes code very hard to read.
(setq whitespace-display-mappings
      '((space-mark   ?\    [?\xB7]     [?.])       ;; space
        (space-mark   ?\xA0 [?\xA4]     [?_])       ;; hard space
        (newline-mark ?\n   [?\xB6 ?\n] [?$ ?\n])   ;; end-of-line
        ))

(require 're-builder)
(setq reb-re-syntax 'string)

;; Enable this if you need it.
;; (add-hook 'prog-mode-hook '(lambda () (rainbow-mode)))

;; ----------------------------------------------------------------------
;; Clipboard and kill-ring.
;; ----------------------------------------------------------------------
(setq x-select-enable-clipboard t) ;; <3 clipboard copy-paste.
;; https://github.com/bbatsov/emacs-prelude/commit/d26924894b31d5dc3a8b2813719579baccc2b433
(when (goog/platform/is-darwin-p)
  (defun goog/clipboard/copy-from-osx ()
    "Pastes from the OS X clipboard."
    (shell-command-to-string "pbpaste"))
  (defun goog/clipboard/paste-to-osx (text &optional push)
    "Copies text into the OS X clipboard."
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))
  (setq interprogram-cut-function 'goog/clipboard/paste-to-osx
        interprogram-paste-function 'goog/clipboard/copy-from-osx))

;; SlickCopy. Makes the kill commands work on the line if nothing is selected.
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (message "Current line is copied.")
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))

(defadvice kill-region (before slick-copy activate compile)
  "When called interactively with no active region, cut the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))

;; Whitespace-aware kill-line.
(defadvice kill-line (after kill-line-cleanup-whitespace activate compile)
  "Cleans up whitespace on `kill-line'."
  (if (not (bolp))
      (delete-region (point) (progn (skip-chars-forward " \t") (point)))))

;; ----------------------------------------------------------------------
;; Project navigation.
;; ----------------------------------------------------------------------
(require 'projectile)
(projectile-global-mode) ;; Enable in all buffers.
;; (set projectile-enable-caching t) ;; It's not automatic.

;; ----------------------------------------------------------------------
;; File and directory navigation.
;; ----------------------------------------------------------------------
(defun ibuffer-ido-find-file ()
  "Like `ido-find-file', but default to the directory of the buffer
at point."
  (interactive
   (let ((default-directory (let ((buf (ibuffer-current-buffer)))
                              (if (buffer-live-p buf)
                                  (with-current-buffer buf
                                    default-directory)
                                default-directory))))
     (ido-find-file-in-dir default-directory))))

(setq find-file-wildcards t)
(eval-after-load "ido"
  '(progn
     (ido-mode t)
     (eval-after-load "ido-ubiquitous"
       '(progn
          (ido-ubiquitous t)
          ))
     (setq ido-save-directory-list-file (concat config-dir ".ido.last")
           ido-use-filename-at-point 'guess
           ido-enable-flex-matching t
           confirm-nonexistent-file-or-buffer nil
           ido-create-new-buffer 'always)

     ;; Display ido results vertically, rather than horizontally.
     ;; From the Emacs wiki.
     (setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]" " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))
     (defun goog/config/ido-mode/disable-line-trucation ()
       (set (make-local-variable 'truncate-lines) nil))
     (add-hook 'ido-minibuffer-setup-hook 'goog/config/ido-mode/disable-line-trucation)
     (global-set-key [(control tab)] 'ido-switch-buffer)

     (defun goog/config/ido-mode/cycle-with-up-and-down-arrow-keys ()
       "Allow the up and down arrow keys to cycle through `ido-mode' results."
       (define-key ido-completion-map (kbd "<up>") 'ido-prev-match)
       (define-key ido-completion-map (kbd "<down>") 'ido-next-match)
       )
     (add-hook 'ido-setup-hook 'goog/config/ido-mode/cycle-with-up-and-down-arrow-keys)
     ))

;; ----------------------------------------------------------------------
;; Recent files.
;; ----------------------------------------------------------------------
(autoload 'recentf "recentf" t)
(setq recentf-auto-cleanup 'never) ;; Disable before we start recentf for tramp.
(recentf-mode t)
(setq recentf-max-saved-items 400)
(defun ido-recentf-open ()
  "Use `ido-completing-read' to \\[find-file] a recent file"
  (interactive)
  (if (find-file (ido-completing-read "Find recent file: " recentf-list))
      (message "Opening file...")
    (message "Aborting")))


;; ======================================================================
;; goog/paredit
;; ======================================================================
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code." t)

;; Lispy languages
(setq goog/paredit/lisp-modes '(
                                emacs-lisp
                                lisp
                                lisp-interaction
                                scheme
                                clojure
                                clojurescript))

;; Non lispy languages.
(setq goog/paredit/non-lisp-modes '(
;;                                    js
;;                                    js2
;;                                    javascript
;;                                    python
                                    java
                                    c))

(defun goog/paredit/singlequote (&optional n)
  "Insert a pair of single-quotes.
With a prefix argument N, wrap the following N S-expressions in
single-quotes, escaping intermediate characters if necessary. If
the region is active, `transient-mark-mode' is enabled, and the
region's start and end fall in the same parenthesis depth, insert
a pair of single-quotes around the region, again escaping
intermediate characters if necessary. Inside a comment, insert a
literal single-quote. At the end of a string, move past the
closing single-quote. In the middle of a string, insert a
backslash-escaped single-quote. If in a character literal, do
nothing. This prevents accidentally changing a what was in the
character literal to become a meaningful delimiter
unintentionally."
  (interactive "P")
  (cond ((paredit-in-string-p)
         (if (eq (cdr (paredit-string-start+end-points))
                 (point))
             (forward-char)             ; We're on the closing quote.
             (insert ?\\ ?\' )))
        ((paredit-in-comment-p)
         (insert ?\' ))
        ((not (paredit-in-char-p))
         (paredit-insert-pair n ?\' ?\' 'paredit-forward-for-quote))))

(defun goog/paredit/lisp ()
  "Enables paredit mode for lisp."
  (paredit-mode +1))

(defun goog/paredit/non-lisp ()
  "Enables paredit mode for non-lisp languages. Does not insert
spaces before opening parentheses. See:
https://gist.github.com/879305"
  (add-to-list (make-local-variable
                'paredit-space-for-delimiter-predicates)
               (lambda (_ _) nil))
  (enable-paredit-mode))


;; Enable paredit-mode for these major modes.
(dolist (mode goog/paredit/lisp-modes)
  (add-hook (intern (format "%s-mode-hook" mode)) 'goog/paredit/lisp))

(dolist (mode goog/paredit/non-lisp-modes)
  (add-hook (intern (format "%s-mode-hook" mode)) 'goog/paredit/non-lisp))


(require 'eldoc) ; if not already loaded
(eldoc-add-command
 'paredit-backward-delete
 'paredit-close-round)

;; (defun maybe-map-paredit-newline ()
;;   (unless (or (eq major-mode 'inferior-emacs-lisp-mode) (minibufferp))
;;     (local-set-key (kbd "RET") 'paredit-newline)))

;; (add-hook 'paredit-mode-hook 'maybe-map-paredit-newline)

(eval-after-load 'paredit
  '(progn
     ;; These are handy everywhere, not just in lisp modes
     (global-set-key (kbd "M-(") 'paredit-wrap-round)
     (global-set-key (kbd "M-[") 'paredit-wrap-square)
     (global-set-key (kbd "M-{") 'paredit-wrap-curly)

     (global-set-key (kbd "M-)") 'paredit-close-round-and-newline)
     (global-set-key (kbd "M-]") 'paredit-close-square-and-newline)
     (global-set-key (kbd "M-}") 'paredit-close-curly-and-newline)

     (dolist (binding (list (kbd "C-<left>") (kbd "C-<right>")
                            (kbd "C-M-<left>") (kbd "C-M-<right>")))
       (define-key paredit-mode-map binding nil))

     ;; Disable kill-sentence, which is easily confused with the kill-sexp
     ;; binding, but doesn't preserve sexp structure
     (define-key paredit-mode-map [remap kill-sentence] nil)
     (define-key paredit-mode-map [remap backward-kill-sentence] nil)))

;; Compatibility with other modes
(defadvice enable-paredit-mode (before disable-autopair activate)
  (setq autopair-dont-activate t)
  (autopair-mode -1))
;; (suspend-mode-during-cua-rect-selection 'paredit-mode)

;; Use paredit in the minibuffer
(defun conditionally-enable-paredit-mode ()
  "Enable paredit during lisp-related minibuffer commands."
  (if (memq this-command paredit-minibuffer-commands)
      (enable-paredit-mode)))
(add-hook 'minibuffer-setup-hook 'conditionally-enable-paredit-mode)

(defvar paredit-minibuffer-commands '(eval-expression
                                      pp-eval-expression
                                      eval-expression-with-eldoc)
  "Interactive commands for which paredit should be enabled in
the minibuffer.")

;; ----------------------------------------------------------------------
;; goog/elisp
;; ----------------------------------------------------------------------
(defun goog/elisp/load-current-module ()
  "Loads the current Elisp module."
  (interactive)
  (load-file buffer-file-name))

(defun goog/elisp/load-directory (dir)
  "Loads all elisp modules from a given directory."
  (when (file-exists-p dir)
    (mapc 'load (directory-files dir t "^[^#].*el"))))

(defun goog/elisp/load-if-exists (name)
  "Loads an elisp module if it exists."
  (when (file-exists-p name)
    (load name)))

(defun goog/elisp/reload-configuration ()
  "Reloads the init.el module from the Emacs configuration directory."
  (interactive)
  ;; (load-file (concat config-dir "init.el"))
  (load-file "~/.emacs.d/init.el")
  (yas/reload-all))

(defun goog/elisp/eval-after-init (form)
  "Add `(lambda () FORM)' to `after-init-hook'.

    If Emacs has already finished initialization, also eval FORM
immediately."
  (let ((func (list 'lambda nil form)))
    (add-hook 'after-init-hook func)
    (when after-init-time
      (eval form))))

;; ======================================================================
;; Packages
;; ======================================================================

;; Git integration.
(autoload 'magit-status "magit" nil t)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key [(f9)] 'magit-status)
(eval-after-load "magit"
  '(progn
     (setq magit-completing-read-function 'magit-ido-completing-read)
     ))

(eval-after-load "autopair-autoloads"
  '(progn
     (require 'autopair)))
(eval-after-load "autopair"
  '(progn
     (autopair-global-mode)
     (setq autopair-autowrap t)

     ;; Prevents: http://code.google.com/p/autopair/issues/detail?id=32
     (add-hook 'sldb-mode-hook
               #'(lambda ()
                   (setq autopair-dont-activate t) ;; emacs < 24
                   (autopair-mode -1)              ;; emacs >= 24
                   ))
     (set-default 'autopair-dont-activate
                  #'(lambda ()
                      (eq major-mode 'sldb-mode)))
     (add-hook 'go-mode-hook
               '(lambda ()
                  (push '(?' . ?') (getf autopair-extra-pairs :code))
                  (push '(?" . ?") (getf autopair-extra-pairs :code))
                  ))
     ))


(require 'undo-tree)

(autoload 'nav "nav" nil t)
(global-set-key (kbd "C-x C-a") 'nav)

(autoload 'move-text-up "move-text" nil t)
(autoload 'move-text-down "move-text" nil t)
(global-set-key [M-S-up] 'move-text-up)
(global-set-key [M-S-down] 'move-text-down)

(require 'switch-window)

;; Need to test this properly.
;; Disabled because it causes Emacs to hang or misbehave.
;; (when window-system
;;   (require 'fill-column-indicator)
;;   (define-globalized-minor-mode global-fci-mode fci-mode
;;     (lambda () (fci-mode 1)))
;;   (global-fci-mode 1))

(autoload 'expand-region "expand-region" nil t)
(autoload 'contract-region "expand-region" nil t)
(global-set-key (kbd "M-8") 'er/expand-region)
(global-set-key (kbd "M-7") 'er/contract-region)

;; (autoload 'smart-forward "smart-forward" nil t)
;; (global-set-key (kbd "M-<up>") 'smart-up)
;; (global-set-key (kbd "M-<down>") 'smart-down)
;; (global-set-key (kbd "M-<right>") 'smart-forward)
;; (global-set-key (kbd "M-<left>") 'smart-backward)

(require 'ace-jump-mode)
(define-key global-map (kbd "C-c C-SPC") 'ace-jump-mode)

(require 'fastnav)
(global-set-key "\M-z" 'fastnav-zap-up-to-char-forward)
(global-set-key "\M-Z" 'fastnav-zap-up-to-char-backward)
(global-set-key "\M-s" 'fastnav-jump-to-char-forward)
(global-set-key "\M-S" 'fastnav-jump-to-char-backward)
(global-set-key "\M-r" 'fastnav-replace-char-forward)
(global-set-key "\M-R" 'fastnav-replace-char-backward)
(global-set-key "\M-i" 'fastnav-insert-at-char-forward)
(global-set-key "\M-I" 'fastnav-insert-at-char-backward)
(global-set-key "\M-j" 'fastnav-execute-at-char-forward)
(global-set-key "\M-J" 'fastnav-execute-at-char-backward)
(global-set-key "\M-k" 'fastnav-delete-char-forward)
(global-set-key "\M-K" 'fastnav-delete-char-backward)
(global-set-key "\M-m" 'fastnav-mark-to-char-forward)
(global-set-key "\M-M" 'fastnav-mark-to-char-backward)
(global-set-key "\M-p" 'fastnav-sprint-forward)
(global-set-key "\M-P" 'fastnav-sprint-backward)

;; Find things fast.
(autoload 'ftf-find-file "find-things-fast" nil t)
(autoload 'ftf-grepsource "find-things-fast" nil t)
(global-set-key (kbd "C-x f") 'ftf-find-file)
;; (global-set-key (kbd "C-x f") 'projectile-find-file)
(global-set-key (kbd "<f6>") 'ftf-grepsource)

;; Highlight current symbol.
(require 'highlight-symbol)
(defun goog/config/highlight-symbol-mode/setup ()
  (when window-system
    (highlight-symbol-mode)
    (setq highlight-symbol-idle-delay 0.1)))
(add-hook 'text-mode-hook 'goog/config/highlight-symbol-mode/setup)
(add-hook 'prog-mode-hook 'goog/config/highlight-symbol-mode/setup)
;; Why does js2-mode not inherit from prog-mode?
(add-hook 'js2-mode-hook 'goog/config/highlight-symbol-mode/setup)

;; ----------------------------------------------------------------------
;; Mark and edit multiple regions.
;; ----------------------------------------------------------------------
(require 'iedit)
(put 'narrow-to-region 'disabled nil)  ;; Allow narrowing to work.

(require 'multiple-cursors)
;; From active region to multiple cursors:
(global-set-key (kbd "C-, C-l") 'mc/edit-lines)
(global-set-key (kbd "C-, C-e") 'mc/edit-ends-of-lines)
(global-set-key (kbd "C-, C-a") 'mc/edit-beginnings-of-lines)

;; Cursor at mouse down.
;; (global-unset-key (kbd "M-<down-mouse-1>"))
;; (global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)
;; (global-set-key (kbd "s-<mouse-1>") 'mc/add-cursor-on-click)

;; Rectangular region mode
;; (global-set-key (kbd "C-, C-,") 'set-rectangular-region-anchor)

;; Mark more like this.
(global-set-key (kbd "C-, C-;") 'mc/mark-all-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-, C-h") 'mc/mark-all-symbols-like-this)
(global-set-key (kbd "C-, C-d") 'mc/mark-all-symbols-like-this-in-defun)
(global-set-key (kbd "C-, C-,") 'mc/mark-all-like-this-dwim)
(global-set-key (kbd "C-, C-r") 'mc/mark-all-in-region)


(require 'sgml-mode)
(autoload 'rename-sgml-tag "rename-sgml-tag" nil t)
(define-key sgml-mode-map (kbd "C-c C-r") 'rename-sgml-tag)

(require 'perspective)
(persp-mode)

(require 'helm-config)
(helm-mode 1)


;; ======================================================================
;; Auto-complete and snippets.
;; ======================================================================
(require 'dabbrev)

;; Conflicts bindings with iedit.
;; (add-hook 'prog-mode-common-hook (lambda ()
;;                                    (flyspell-prog-mode)))
;; (add-hook 'js2-mode-hook (lambda ()
;;                            (flyspell-prog-mode)))
;; (setq flyspell-issue-message-flag nil)

(require 'yasnippet)
(setq yas/snippet-dirs
      '("~/.emacs.d/snippets"  ;; Our snippets.
        ;; Add more paths here if you like.
        ))
(yas/global-mode 1)  ;; or M-x yas/reload-all to reload yasnippet.

(require 'auto-complete)
(require 'auto-complete-config)
(require 'go-autocomplete)
(ac-config-default)
(setq ac-ignore-case t
      ac-use-fuzzy t
      ac-auto-start 0
      ac-auto-show-menu 0.2
      ac-expand-on-auto-complete nil
      ac-dwim t)

;; Use TAB to complete, not cycle.
(define-key ac-completing-map "\t" 'ac-complete)
;; Disable RET completion.
(define-key ac-completing-map "\r" nil)
(define-key ac-completing-map [return] nil)

(setq ac-use-menu-map t)
(define-key ac-menu-map (kbd "C-n") 'ac-next)
(define-key ac-menu-map (kbd "C-p") 'ac-previous)

(define-key ac-mode-map (kbd "M-TAB") 'auto-complete)


;; (global-auto-complete-mode t)
;; Dirty fix to enable AC everywhere without bothering about the ac-modes list.
(define-globalized-minor-mode real-global-auto-complete-mode
  auto-complete-mode (lambda ()
                       (if (not (minibufferp (current-buffer)))
                         (auto-complete-mode 1))
                       ))
(real-global-auto-complete-mode t)

;; ;; Use Emacs' built-in TAB completion hooks to trigger AC (Emacs >= 23.2)
;; (setq tab-always-indent 'complete)  ;; use 'complete when auto-complete
;;                                     ;; is disabled
;; (add-to-list 'completion-styles 'initials t)
;; ;; hook AC into completion-at-point
;; (defun set-auto-complete-as-completion-at-point-function ()
;;   (setq completion-at-point-functions '(auto-complete)))
;; (add-hook 'auto-complete-mode-hook
;;           'set-auto-complete-as-completion-at-point-function)

;; Set up sources for autocompletion.
(setq-default ac-sources
              '(ac-source-abbrev
                ac-source-dictionary
                ac-source-filename
                ac-source-files-in-current-dir
                ac-source-imenu
                ;; ac-source-words-in-all-buffer
                ac-source-words-in-buffer
                ac-source-words-in-same-mode-buffers
                ac-source-yasnippet
                ))

;; (global-auto-complete-mode t)
;; Dirty fix to enable AC everywhere without bothering about the ac-modes list.
(define-globalized-minor-mode real-global-auto-complete-mode
  auto-complete-mode (lambda ()
                       (if (not (minibufferp (current-buffer)))
                         (auto-complete-mode 1))
                       ))
(real-global-auto-complete-mode t)

;; Not required since we've enabled auto-complete-mode above globally.
;; (dolist (mode '(
;;                 clojure-mode
;;                 clojurescript-mode
;;                 css-mode
;;                 csv-mode
;;                 erc-mode
;;                 espresso-mode
;;                 go-mode
;;                 haml-mode
;;                 haskell-mode
;;                 html-mode
;;                 js3-mode
;;                 less-css-mode
;;                 lisp-mode
;;                 log-edit-mode
;;                 magit-log-edit-mode
;;                 markdown-mode
;;                 nxml-mode
;;                 org-mode
;;                 sass-mode
;;                 sh-mode
;;                 smarty-mode
;;                 text-mode
;;                 textile-mode
;;                 tuareg-mode
;;                 yaml-mode
;;                 ))
;;   (add-to-list 'ac-modes mode))


;; ======================================================================
;; Programming-specific.
;; ======================================================================

;; Additional faces.
(defvar font-lock-operator-face 'font-lock-operator-face)
(defface font-lock-operator-face
  '((((type tty) (class color)) nil)
    (((class color) (background light))
     (:foreground "dark red"))
    (t nil))
  "Used for operators."
  :group 'font-lock-faces)
(defvar font-lock-end-statement-face 'font-lock-end-statement-face)
(defface font-lock-end-statement-face
  '((((type tty) (class color)) nil)
    (((class color) (background light))
     (:foreground "DarkSlateBlue"))
    (t nil))
  "Used for end statement symbols."
  :group 'font-lock-faces)
(defvar font-lock-operator-keywords
  '(("\\([][|!.+=&/%*,<>(){}:^~-]+\\)" 1 font-lock-operator-face)
    (";" 0 font-lock-end-statement-face)))

;; Automatically set executable permissions on executable script files.
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)


;; ----------------------------------------------------------------------
;; Define automatic mode detection for file types.
;; ----------------------------------------------------------------------
(setq auto-mode-alist
      (append '(
                ;; YAML.
                ("\\.yaml$" . yaml-mode)
                ("\\.yml" . yaml-mode)

                ;; CSS.
                ("\\.gss" . css-mode)

                ;; HTML.
                ("\\.tmpl" . html-mode)  ;; Server-side template extension.
                ("\\.mustache" . html-mode)  ;; Mustache template extension.
                ("\\.ng" . html-mode)    ;; Angular templates.

                ;; Dart lang.
                ("\\.dart$" . dart-mode)

                ;; Python.
                ("\\wscript$" . python-mode)
                ("\\SConstruct" . python-mode)
                ("\\SConscript" . python-mode)
                ("\\BUILD$" . python-mode)

                ;; JavaScript.
                ("\\.js$" . js2-mode)
                ("\\.json$" . js2-mode)

                ;; Configuration files.
                ("\\(?:\\.gitconfig\\|\\.gitmodules\\|config\\)$" . conf-mode)
                )
              auto-mode-alist))

;; ----------------------------------------------------------------------
;; IELM.
;; ----------------------------------------------------------------------
(defun goog/config/ielm-mode/setup ()
  "Configures \\[ielm]."

  ;; Autocomplete.
  (setq ac-sources '(ac-source-functions
                     ac-source-variables
                     ac-source-features
                     ac-source-symbols
                     ac-source-words-in-same-mode-buffers))
  (add-to-list 'ac-modes 'inferior-emacs-lisp-mode)
  (auto-complete-mode 1))

(add-hook 'ielm-mode-hook 'goog/config/ielm-mode/setup)


;; ----------------------------------------------------------------------
;; sh-mode
;; ----------------------------------------------------------------------
(defun goog/config/sh-mode/setup ()
  "Configures `sh-mode'."

  ;; Coding style.
  (setq sh-basic-offset 2
        sh-indentation 2))

(add-hook 'sh-mode-hook 'goog/config/sh-mode/setup)


;; ----------------------------------------------------------------------
;; html-mode
;; ----------------------------------------------------------------------
(defun goog/config/html-mode/setup ()
  "Configures `html-mode'."

  ;; Coding style.
  (set (make-local-variable 'sgml-basic-offset) 2)
  (setq indent-tabs-mode nil)  ;; Don't use tabs to indent.

  ;; Autocompletion.
  (zencoding-mode 1))

(add-hook 'html-mode-hook 'goog/config/html-mode/setup)


;; ----------------------------------------------------------------------
;; CSS mode.
;; ----------------------------------------------------------------------

(require 'less-css-mode)
(defun goog/config/css-mode/setup ()
  "Configures `css-mode'."

  ;; Coding style.
  (setq less-css-indent-level 2
        css-indent-offset 2
        indent-tabs-mode nil
        require-final-newline 't
        tab-width 2)

  ;; Autocomplete.
  (setq ac-sources '(
                     ac-source-words-in-buffer
                     ac-source-abbrev
                     ac-source-symbols
                     ac-source-variables
                     ac-source-words-in-same-mode-buffers
                     ac-source-yasnippet
                     ac-source-css-property
                     )))
(add-hook 'css-mode-hook 'goog/config/css-mode/setup)
(add-hook 'less-css-mode-hook 'goog/config/css-mode/setup)


;; ----------------------------------------------------------------------
;; Dart.
;; ----------------------------------------------------------------------
(autoload 'dart-mode "dart-mode" "Edit Dart code." t)


;; ----------------------------------------------------------------------
;; Go.
;; ----------------------------------------------------------------------
(autoload 'go-mode "go-mode" nil t)

(defun goog/config/go-mode/execute-buffer ()
  "Formats, compiles and executes the Go code in the current buffer."
  (interactive)
  (gofmt)
  (save-buffer)
  (compile (concat "go run " buffer-file-name)))

(defun goog/config/go-mode/build-buffer ()
  "Formats and compiles the Go code in the current buffer."
  (interactive)
  (gofmt)
  (save-buffer)
  (compile (concat "go build " buffer-file-name)))

(defun goog/config/go-mode/setup ()
  "Configures `go-mode'."
  ;; Set up coding style.
  (setq tab-width 2)

  ;; Keyboard bindings.
  (define-key go-mode-map (kbd "C-c l f") 'gofmt)
  (define-key go-mode-map (kbd "C-x C-e") 'goog/config/go-mode/execute-buffer)
  (define-key go-mode-map (kbd "C-c C-e") 'goog/config/go-mode/execute-buffer)
  (define-key go-mode-map (kbd "C-c C-b") 'goog/config/go-mode/build-buffer)  )

(add-hook 'before-save-hook 'gofmt-before-save)
(add-hook 'go-mode-hook 'goog/config/go-mode/setup)


;; ----------------------------------------------------------------------
;; JavaScript
;; ----------------------------------------------------------------------
(autoload 'js2-mode "js2-mode" nil t)
(eval-after-load "js2-mode"
  '(progn
     (add-hook 'js2-mode-hook 'goog/config/js-mode/setup)
     (add-hook 'js2-mode-hook
               '(lambda ()
                  (font-lock-add-keywords nil font-lock-operator-keywords t))
               t t)
     ))
(add-hook 'js-mode-hook 'goog/config/js-mode/setup)

(defun goog/config/js-mode/setup ()
  "Configures `js-mode' and `js2-mode'."

  ;; Coding style.
  (setq js-indent-level 2
        espresso-indent-level 2
        c-basic-offset 2
        js2-basic-offset 2
        js2-indent-on-enter-key nil
        js2-enter-indents-newline t
        js2-mode-squeeze-spaces nil
        ;; js2-bounce-indent-p t
        js2-auto-indent-p t)

  ;; Keyboard bindings.
  (define-key js2-mode-map (kbd "C-c l l")
    'goog/config/js-mode/gjslint-buffer)
  (define-key js2-mode-map (kbd "C-c l d")
    'goog/config/js-mode/gjslint-dir)
  (define-key js2-mode-map (kbd "C-c l D")
    'goog/config/js-mode/fixjsstyle-dir)
  (define-key js2-mode-map (kbd "C-c l f")
    'goog/config/js-mode/fixjsstyle-buffer)
  (define-key js2-mode-map (kbd "C-c l F")
    'goog/config/js-mode/fixjsstyle-buffer-compile)
  (define-key js2-mode-map (kbd "C-c l h")
    'goog/config/js-mode/jshint)

  ;; Keychords.
  (key-chord-define js2-mode-map ";;"  "\C-e;")
  (key-chord-define js2-mode-map ",,"  "\C-e,"))

;; Tools for Javascript.
(defun goog/config/js-mode/gjslint-buffer ()
  "Runs gjslint in strict mode on the current buffer."
  (interactive)
  (compile (concat "gjslint --strict --unix_mode --closurized_namespaces=goog,appkit,jfk,bulletin,tvt " buffer-file-name)))

(defun goog/config/js-mode/gjslint-dir ()
  "Runs gjslint in strict mode on the parent directory of the file in the
current buffer."
  (interactive)
  (compile (concat "gjslint --strict --unix_mode --closurized_namespaces=goog,appkit,jfk,bulletin,tvt -r "
                   (file-name-directory buffer-file-name))))

(defun goog/config/js-mode/fixjsstyle-buffer ()
  "Runs fixjsstyle in strict mode on the buffer."
  (interactive)
  (shell-command (concat "fixjsstyle --strict " buffer-file-name)))

(defun goog/config/js-mode/fixjsstyle-dir ()
  "Runs fixjsstyle in strict mode on the parent directory of the file in
the current buffer."
  (interactive)
  (compile (concat "fixjsstyle --strict -r " (file-name-directory
                                              buffer-file-name))))

(defun goog/config/js-mode/fixjsstyle-buffer-compile ()
  "Runs fixjsstyle in strict mode on the current buffer and shows
compilation output."
  (interactive)
  (compile (concat "fixjsstyle --strict " buffer-file-name)))

(defun goog/config/js-mode/jshint-buffer ()
  "Runs jshint on the current buffer."
  (interactive)
  (compile (concat "jshint " buffer-file-name)))

;; Load swank-js.
;; (add-hook 'after-init-hook
;;           #'(lambda ()
;;               (when (locate-library "slime-js")
;;                 (require 'setup-slime-js))))


;; ----------------------------------------------------------------------
;; Python.
;; ----------------------------------------------------------------------
(setq jedi:setup-keys t
      jedi:complete-on-dot t)
(add-to-list 'interpreter-mode-alist '("python" . python-mode))
(add-hook 'python-mode-hook 'goog/config/python-mode/setup)
(font-lock-add-keywords
 'python-mode
 '(;; Adds object and str and fixes it so that keywords that often appear
   ;; with : are assigned as builtin-face
   ("\\<\\(object\\|str\\|else\\|except\\|finally\\|try\\|\\)\\>" 0 py-builtins-face)
   ;; FIXME: negative or positive prefixes do not highlight to this regexp
   ;; but does to one below
   ("\\<[\\+-]?[0-9]+\\(.[0-9]+\\)?\\>" 0 'font-lock-constant-face)
   ("\\([][{}()~^<>:=,.\\+*/%-]\\)" 0 'widget-inactive-face)))

(defun goog/config/python-mode/setup ()
  "Configures `python-mode'."
  (setq indent-tabs-mode nil
        require-final-newline 't
        tab-width 2
        python-indent-offset 2
        python-indent 2
        py-indent-offset 2)

  ;; Auto-complete configuration.
  (setq ac-auto-start 0)

  ;; Autopairing triple quotes.
  (setq autopair-handle-action-fns
        (list #'autopair-default-handle-action
              #'autopair-python-triple-quote-action))
  ;; Configure jedi.
  (jedi:setup))

;; ----------------------------------------------------------------------
;; Clojure.
;; ----------------------------------------------------------------------
(add-hook 'nrepl-interaction-mode-hook
          'nrepl-turn-on-eldoc-mode)
(add-hook 'slime-repl-mode-hook
          (defun clojure-mode-slime-font-lock ()
            (require 'clojure-mode)
            (let (font-lock-mode)
              (clojure-mode-font-lock-setup))))

;; ======================================================================
;; Keyboard bindings.
;; ======================================================================
;; Reload the user init file.
(global-set-key (kbd "C-.") 'goog/elisp/reload-configuration)

;; Open recent files using `ido-mode'.
(global-set-key (kbd "C-x C-r") 'ido-recentf-open)

;; Helm find files.
(global-set-key (kbd "M-F") 'helm-for-files)

;; Shift region left or right.
(global-set-key (kbd "s-]") 'shift-right)
(global-set-key (kbd "s-[") 'shift-left)
(global-set-key (kbd "RET") 'newline-and-indent)
;; (define-key global-map (kbd "RET") 'newline-and-indent)

;; ibuffer.
(global-set-key [(f8)] 'ibuffer)

;; Increase/decrease/reset font size.
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-reset)

;; Use regex searches by default
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)

;; Killing and yanking.
(global-set-key (kbd "<delete>") 'delete-char)
(global-set-key (kbd "M-<delete>") 'kill-word)

;; Line insertion
(global-set-key (kbd "S-<return>") 'insert-blank-line-below)
(global-set-key (kbd "M-S-<return>") 'insert-blank-line-above)
(global-set-key (kbd "s-<return>") 'insert-blank-line-below-next-line)

;; Line or region duplication.
(global-set-key (kbd "C-c C-d") 'duplicate-current-line-or-region)

;; Toggle identifier case.
(global-set-key (kbd "C-x t c") 'toggle-identifier-naming-style)

;; Comment what I really mean.
(global-set-key (kbd "M-;") 'comment-dwim-line)

;; Sort lines
(global-set-key (kbd "C-c s") 'sort-lines)

;; Jump easily between beginning and end of defuns.
(global-set-key (kbd "s-<up>") 'beginning-of-defun)
(global-set-key (kbd "s-<down>") 'end-of-defun)

;; Parentheses matching.
(global-set-key (kbd "M-0") 'goto-match-paren)

;; Quotes.
(global-set-key (kbd "C-'") 'toggle-quotes)

;; Transpose parameters.
(global-set-key (kbd "s-t") 'transpose-params)

;; Perspectives.
(global-set-key (kbd "s-<left>") 'persp-prev)
(global-set-key (kbd "s-<right>") 'persp-next)

;; Helm.
(global-set-key (kbd "C-c h") 'helm-mini)

;; Evil numbers.
(global-set-key (kbd "M-_") 'evil-numbers/dec-at-pt)
(global-set-key (kbd "M-+") 'evil-numbers/inc-at-pt)

;; I don't use F2 much, so binding it here to highlight symbol.
(global-set-key [(control f2)] 'highlight-symbol-at-point)
(global-set-key [f2] 'highlight-symbol-next)
(global-set-key [(shift f2)] 'highlight-symbol-prev)
(global-set-key [(meta f2)] 'highlight-symbol-prev)

;; Search, search, search.
;; (require 'loccur)
(global-set-key [(f7)] 'multi-occur-in-this-mode) ;; Find in all buffers.
(global-set-key [(meta o)] 'ido-goto-symbol)     ;; Jump to symbol.
;; (global-set-key [(control meta o)] 'loccur-current)     ;; Current word.
;; (global-set-key [(meta shift o)] 'ioccur)               ;; Interactive occur.

;; ;; defines shortcut for the interactive loccur command
;; (global-set-key [(meta shift o)] 'loccur)
;; ;; ;; defines shortcut for the loccur of the previously found word
;; (global-set-key [(control shift o)] 'loccur-previous-match)


;; ----------------------------------------------------------------------
;; Key chords
;; ----------------------------------------------------------------------
;; Let the power to type multiple keys at the same time be yours.
(require 'key-chord)
(key-chord-mode 1)
(setq key-chord-two-keys-delay 0.05)

(key-chord-define-global "hj" 'undo)
(key-chord-define-global "jk" 'dabbrev-expand)
(key-chord-define-global ";'" 'ido-recentf-open)
(key-chord-define-global ",." 'ido-find-file)

;; ----------------------------------------------------------------------
;; Now load host, os, network-specific configuration.
;; ----------------------------------------------------------------------
(progn
  ;; ~/.emacs.d/*
  (setq goog-local-hosts-dir (concat config-dir "host/"))
  (setq goog-local-users-dir (concat config-dir "user/"))
  (setq goog-local-os-dir (concat config-dir "os/"))

  ;; ~/.example.com/*.
  (setq goog-network-hosts-dir (concat goog-network-dir "host/"))
  (setq goog-network-users-dir (concat goog-network-dir "user/"))

  ;; ~/.emacs.d/hosts/dhcp-172-26-239-50.hyd.corp.google.com.el
  (setq goog-hostname-config (concat goog-local-hosts-dir system-name ".el"))

  ;; ~/.emacs.d/users/<username>.el
  (setq goog-username-config (concat goog-local-users-dir user-login-name ".el"))

  ;; ~/.emacs.d/hosts/dhcp-172-26-239-50.hyd.corp.google.com/*.el
  (setq goog-hostname-dir (concat goog-local-hosts-dir system-name))

  ;; ~/.emacs.d/users/<username>/*.el
  (setq goog-username-dir (concat goog-local-users-dir user-login-name))

  ;; ~/.emacs.d/os/<os-type>/*.el
  ;; TODO(yesudeep): os-type needs to be normalized from system-type. For
  ;; example, Linux is represented by "gnu/linux" which cannot be a reliably
  ;; valid directory name.
  (setq goog-os-dir (concat goog-local-os-dir (format "%s" system-type)))

  (goog/elisp/eval-after-init
   '(progn
      (message "Network: %s" goog-network-name)
      (message "Hostname: %s" system-name)
      (message "Username: %s" user-login-name)

      ;; --------------------------------------------------
      ;; Network wide.
      ;; --------------------------------------------------
      (when (string-match goog-network-re system-name)
        (goog/elisp/load-directory goog-network-dir)
        (goog/elisp/load-directory goog-network-hosts-dir)
        (goog/elisp/load-directory goog-network-users-dir))

      ;; --------------------------------------------------
      ;; Local
      ;; --------------------------------------------------
      (goog/elisp/load-if-exists goog-hostname-config)
      (goog/elisp/load-if-exists goog-username-config)

      (goog/elisp/load-directory goog-hostname-dir)
      (goog/elisp/load-directory goog-username-dir)
      (goog/elisp/load-directory goog-os-dir)
      )))

;;; init.el ends here.
