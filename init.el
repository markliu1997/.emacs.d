;;; init.el --- M.Liu's emacs initilize file

;; Author: M.Liu <liumiaogemini@gmail.com>
;; License: See the LICENSE in the root directory.
;;
;;; Commentary:
;; This file is

;;; Code:
;; (setq debug-on-error t)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Language and coding
(set-language-environment 'Chinese-GB)
(set-keyboard-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)

(defconst *is-a-linux* (eq system-type 'gnu/linux))
(defconst *is-a-win* (eq system-type 'windows-nt))
(defconst *is-a-mac* (eq system-type 'darwin))
;;-----------------------------------------------------------------------

(require 'basic)
(require 'cl)
;;======================================================================

;;; My Functions
;;;=====================================================================================
(defun open-init-file()
  "Find and open the init.el."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun load-init-file()
  "Load init.el."
  (interactive)
  (load-file "~/.emacs.d/init.el")
  )

;;; Rename the current file
(defun rename-this-file-and-buffer (new-name)
  "Rename both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
    (filename (buffer-file-name)))
  (unless filename
    (error "Buffer '%s' is not visiting a file! " name))
  (progn
    (when (file-exists-p filename)
      (rename-file filename new-name 1))
    (set-visited-file-name new-name)
    (rename-buffer new-name))
 ))

(if (fboundp 'with-eval-after-load)
    (defalias 'after-load 'with-eval-after-load)
  (defmacro after-load (feature &rest body)
    "After FEATURE is loaded, evaluate BODY."
    (declare (indent defun))
    `(eval-after-load ,feature
       '(progn ,@body))))

;;-----------------------------------------------------------------------

;; Ensure that themes will be applied even if they have not been customized
(defun reapply-themes ()
  "Forcibly load the themes listed in `custom-enabled-themes'."
  (dolist (theme custom-enabled-themes)
    (unless (custom-theme-p theme)
      (load-theme theme)))
  (custom-set-variables `(custom-enabled-themes (quote ,custom-enabled-themes))))


(defun add-to-hook (fun hooks)
  "Add FUN to HOOKS."
  (dolist (hook hooks)
    (add-hook hook fun)))

(defun add-all-to-list (usr-list vars)
  "USR-LIST get th VARS in."
  (dolist (list vars)
    (add-to-list usr-list list))
  )

(defun tty-setup-theme ()
  "Disable theme when use terminal."
    (disable-theme 'atom-one-dark)
    )
;;=====================================================================================

;;; Basic
;; ===================================================================================
(setq-default make-backup-files nil ;; Don't make a backup file which end with "~"
              visible-bell t ;; Flash the frame to represent a bell
              auto-image-file-mode t
              initial-scratch-message nil
              inhibit-splash-screen t
	            column-number-mode nil
	            line-number-mode nil
              initial-major-mode 'text-mode
              frame-title-format "%b"
	            )

;; Set font
(when *is-a-win*
  (set-frame-font "Consolas 11")) ;; set when the OS is windows
(when *is-a-win*
  (set-fontset-font "fontset-default" 'gb18030 '("DengXian" . "unicode-bmp")))

;; ===================================================================================

;;; Packages
;;=========================================================================================
(setq package--init-file-ensured t
      package-enable-at-startup nil
      package-archives '(("gnu"   . "http://elpa.emacs-china.org/gnu/")
                         ("melpa" . "http://elpa.emacs-china.org/melpa/")
                         ("org"   . "http://elpa.emacs-china.org/org/"))
      )

;;; On-demand installation of packages
(defun require-package (package &optional min-version no-refresh)
  "Install given PACKAGE, optionally requiring MIN-VERSION.
If NO-REFRESH is non-nil, the available package lists will not be
re-downloaded in order to locate PACKAGE."
  (if (package-installed-p package min-version)
      t
    (if (or (assoc package package-archive-contents) no-refresh)
        (if (boundp 'package-selected-packages)
            ;; Record this as a package the user installed explicitly
            (package-install package nil)
          (package-install package))
      (progn
        (package-refresh-contents)
        (require-package package min-version t)))))


(defun maybe-require-package (package &optional min-version no-refresh)
  "Try to install PACKAGE, and return non-nil if successful.
In the event of failure, return nil and print a warning message.
Optionally require MIN-VERSION.  If NO-REFRESH is non-nil, the
available package lists will not be re-downloaded in order to
locate PACKAGE."
  (condition-case err
      (require-package package min-version no-refresh)
    (error
     (message "Couldn't install optional package `%s': %S" package err)
     nil)))


;; Fire up package.el
(package-initialize)

(require 'cl-lib)

(let ((basic-edit-pack-list
       '(dash swiper youdao-dictionary deft
              window-jump avy avy-menu counsel use-package undo-tree multi-term
              cnfonts powerline atom-one-dark-theme diminish list-utils
              company company-quickhelp cl-lib helm yasnippet
              )))
  (dolist (pack basic-edit-pack-list)
    (require-package pack)))

(let ((basic-maybe-pack-list
       '(helm-ebdb)))
  (dolist (pack basic-maybe-pack-list)
    (maybe-require-package pack)))
;;=========================================================================================

;;; Completion
;;=========================================================================================
(require 'pos-tip)
(require 'company)
(add-hook 'prog-mode-hook 'company-mode) ;; Only load company mode when you are programming
(setq-default company-backends (delete 'company-semantic company-backends))

(setq tab-always-indent 'complete)
(add-to-list 'completion-styles 'initials t)
(add-hook 'after-init-hook 'company-quickhelp-mode)

(require 'yasnippet)
(add-hook 'prog-mode-hook 'yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)

(require 'helm-config)
(helm-mode 1)
;;=========================================================================================

;;; Require *.el files
;; ===================================================================================
(defconst pack-dir
  (expand-file-name "elpa" user-emacs-directory )
  "Packages install by package-initilize.")

;; ===================================================================================

;;; Face
;; ===================================================================================
;; (setq-default custom-enabled-themes '(solarized-light))
(setq solarized-use-variable-pitch nil)
(setq solarized-use-less-bold t)
(setq solarized-use-more-italic t)
(setq solarized-emphasize-indicators nil)
(setq solarized-scale-org-headlines nil)
;; (setq solarized-high-contrast-mode-line t)

(add-hook 'after-init-hook 'reapply-themes)
;; (add-hook 'tty-setup-hook 'tty-setup-theme)
;;------------------------------------------------------------------------------------

(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'set-scroll-bar-mode)
  (set-scroll-bar-mode nil))
;;(when (fboundp 'menu-bar-mode)
;;  (menu-bar-mode -1))
(recentf-mode 1)
(show-paren-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)

;; Set the mode line.
(setq-default mode-line-format ;; set mode line
	            (list
	             "%e" ;; print error message
	             mode-line-front-space
	             '(:eval evil-mode-line-tag) ;; Show evil mode.
	             mode-line-mule-info mode-line-client mode-line-modified
	             mode-line-remote
	             mode-line-frame-identification mode-line-buffer-identification ;; buffer files
	             "   "
	             "["
	             mode-line-position ;; position of this buffer
	             "/%I] "
	             "  "
	             mode-line-modes ;; Major mode and some important minor modes.
	             '(vc-mode vc-mode) ;; version control messages.
	             mode-line-misc-info mode-line-end-spaces)) ;; end of mode line

(add-hook 'prog-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook (lambda () (setq truncate-lines t)))

;;-------------------------------------------------------------------------------------
(defun hide-minor-mode ()
  "This function hide HIDED-LIST from the modeline to save the space of modeline."
  (let ((dim-list
         ;; minor modes list followed will not show in the mode line.
         '(helm-mode company-mode yas-minor-mode abbrev-mode org-autolist-mode
		                 image-mode iimage-mode visual-line-mode eldoc-mode undo-tree-mode))
        )
    (dolist (list dim-list)
      (diminish list)))
  )
(add-hook 'after-init-hook 'hide-minor-mode)
(add-hook 'find-file-hook (lambda () (hide-minor-mode)))

;; (require 'powerline)
;; (powerline-default-theme)
;; ===================================================================================

;;; Deft
;; ===================================================================================
(setq-default deft-extensions '("org")
	      deft-directory "~/notebook"
	      deft-recursive t
	      )
;; ===================================================================================

;;; Program
;;====================================================================================
;; Flycheck
(require-package 'flycheck)
(add-hook 'prog-mode-hook 'flycheck-mode)

;; c/cpp mode
;;-----------------------------------------------------------------------------------
(let ((c-cpp-packages
       '(cc-mode
         clang-format
         company
         company-c-headers
         company-ycmd
         disaster
         flycheck
         semantic
         ycmd
         )))
  (dolist (c-cpp-pkg c-cpp-packages)
    (require-package c-cpp-pkg))
  )

;;; End with package init and start code
(require 'semantic)
(require 'company)
(require 'company-c-headers)

(when *is-a-linux*
  (setq usr-include-path
	'("/usr/include/c++5.4.0")))
(when *is-a-win*
  (setq usr-include-path
	'(
	  "C:\\Program Files\\mingw-w64\\mingw64\\x86_64-w64-mingw32\\include"
	  "C:\\Program Files\\mingw-w64\\mingw64\\include"
	  "C:\\Program Files\\mingw-w64\\mingw64\\lib\\gcc\\x86_64-w64-mingw32\\7.3.0\\include"
	  "C:\\Program Files\\mingw-w64\\mingw64\\lib\\gcc\\x86_64-w64-mingw32\\7.3.0\\include\\c++"
	  )))


(defun c-cpp/cc-mode ()
  "Init cc mode for my Emacs."
  (use-package cc-mode
    :defer t
    :init
    (progn
      (add-to-list 'auto-mode-alist
                   `("\\.h\\'" . ,'c-mode)))
    :config
    (progn
      (require 'compile)
      ;; Disable electric indentation
      ;; (setq-default c-electric-flag nil)
      (setq c-basic-offset 4)
      (setq c-default-style '((java-mode . "java")
                              (other . "linux")))

      (add-to-list 'c-cleanup-list 'space-before-funcall)
;;      (add-to-list 'c-cleanup-list 'compact-empty-funcall)
      (add-to-list 'c-cleanup-list 'comment-close-slash)
      ))
  )

;;-----------------------------------------------------------------------------------

;;-----------------------------------------------------------------------------------

;;====================================================================================

;;; Keybinding
;;====================================================================================
(let ((key-pack-list
       '(evil evil-anzu evil-args evil-cleverparens evil-escape evil-exchange
        evil-goggles evil-iedit-state evil-indent-plus evil-lion evil-lisp-state
        evil-mc evil-nerd-commenter evil-matchit evil-numbers evil-surround
        evil-tutor
        ;; (evil-unimpaired :location (recipe :fetcher local))
        evil-visual-mark-mode
        evil-visualstar
        ;; (hs-minor-mode :location built-in)
        ;; (linum-relative :toggle (version< emacs-version "26"))
        )))
  (dolist (pack key-pack-list)
    (require-package pack)))

;;; Evil
(require 'evil)
(evil-mode 1)

;;; helm
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x C-f") #'helm-find-files)

;;; Org mode global keys
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;;; Youdao search
(global-set-key (kbd "M-s s") 'youdao-dictionary-search-from-input)
(global-set-key (kbd "M-s t") 'youdao-dictionary-search-at-point)

;;; Search
(global-set-key "\C-s" 'helm-swoop-without-pre-input)

;;; Recentf mode
(global-set-key (kbd "\C-cr") 'recentf-open-files)

;;; disaster
(global-set-key (kbd "\C-cd") 'disaster)

;;; windows jump
;;------------------------------------------------------------------------------------
(global-set-key (kbd "M-s h") 'window-jump-right)
(global-set-key (kbd "M-s l") 'window-jump-left)
(global-set-key (kbd "M-s k") 'window-jump-up)
(global-set-key (kbd "M-s j") 'window-jump-down)
;;====================================================================================

(when (file-exists-p custom-file)
  (load custom-file))
