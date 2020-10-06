;; prog-lsp.el --- init-file for emacs language server protocol
;;; Commentary:
;;

;;; Code:
;;;

;;; Language server protocol
(cond
 ;; Use nox as client.
 ((eq 'nox user/lsp-client)
  (use-package nox
    :load-path "lisp/nox"
    :config
    (setq nox-server-programs user/nox-server-programs)
    (dolist (hook user/nox-list)
      (add-hook hook '(lambda () (nox-ensure)))))
  )

 ;; Use lsp-mode as client
 ((eq 'lsp-mode user/lsp-client)
  (use-package lsp-mode
    :ensure t
    :init
    (setq lsp-keymap-prefix "C-c l")
    :hook (
	   (c-mode . lsp-deferred)
	   (c++-mode . lsp-deferred)
	   (python-mode . lsp-deferred)
	   (lsp-mode . lsp-enable-which-key-integration)
	   )
    :config
    (setq lsp-enable-snippet nil)
    (setq lsp-modeline-diagnostics-enable nil)
    :commands (lsp lsp-deferred)
    )

 (use-package lsp-ui
  :ensure t
  :config
  (setq lsp-ui-doc-enable nil)
  :commands lsp-ui-mode)

(use-package lsp-ivy
  :ensure t
  :commands lsp-ivy-workspace-symbol)

(use-package dap-mode
  :after (lsp-mode)
  :ensure t)
 ))

;;; Flycheck
(use-package flycheck-mode
  :ensure flycheck
  :defer t
  :init
  (progn
    (setq flycheck-standard-error-navigation nil
	  flycheck-global-modes nil))
  :bind
  (("C-c e b" . 'flycheck-buffer)
   ("C-c e c" . 'flycheck-clear)
   ("C-c e h" . 'flycheck-describe-checker)
   ("C-c e s" . 'flycheck-select-checker)
   ("C-c e x" . 'flycheck-explain-error-at-point))
  :hook prog-mode)

(provide 'prog-common)
;;; prog-common.el ends here
