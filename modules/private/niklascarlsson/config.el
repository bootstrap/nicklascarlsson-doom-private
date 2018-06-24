;; Basics
;; Tabs
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;; Zen experienced writing
(def-package! writeroom-mode)

;; Custom functions
(defun evil-unimpaired/insert-space-above (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-above))))

(defun evil-unimpaired/insert-space-below (count)
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-below))))

;; Customize flyspell
(setq flyspell-issue-message-flag nil)
;; Don't ask when killing emacs
(setq confirm-kill-emacs nil)
;; Remove trailing whitespaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)
;; Add spell checking for comments in programming mode
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Set settings
(after! org
  (setq outline-blank-line nil)
  (setq org-cycle-separator-lines 2)
  (setq org-log-done 'time))

;; Hooks
;; Turn of hihglight line in org-mode
 (add-hook 'org-mode-hook (lambda () (hl-line-mode -1)))
;; Automatically switch back to English in normal mode
(cond (IS-LINUX
  (setq prev_lang (substring (shell-command-to-string
                              "gsettings get org.gnome.desktop.input-sources current")
                             7 -1))
  (add-hook 'evil-insert-state-entry-hook
            (lambda ()
              (shell-command (concat
                              "/usr/bin/gsettings set org.gnome.desktop.input-sources current " prev_lang)
                             )
              )
            )

  (add-hook 'evil-insert-state-exit-hook
            (lambda ()
              (setq prev_lang (substring (shell-command-to-string
                                          "gsettings get org.gnome.desktop.input-sources current")
                                         7 -1))
              (shell-command (concat
                              "/usr/bin/gsettings set org.gnome.desktop.input-sources current 1")
                             )
              )
            )
))

;; Append the git-commit hook
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-flyspell)

;; Solve missing variables in terminal
(when IS-MAC
    (setenv "LC_CTYPE" "UTF-8")
    (setenv "LC_ALL" "en_US.UTF-8")
    (setenv "LANG" "en_US.UTF-8")
  )

;; lsp
(def-package! lsp-mode
  :commands (lsp-mode))

;; ccls
(def-package! ccls
  :commands (lsp-ccls-enable)
  :init
  :config
  (setq ccls-executable "/usr/local/bin/ccls"
        ccls-cache-dir (concat doom-cache-dir ".ccls_cached_index")
        ccls-sem-highlight-method 'font-lock)
  (setq ccls-extra-args '("--log-file=/tmp/cq.log"))
  (setq ccls-extra-init-params
        '(:completion (:detailedLabel t) :xref (:container t)
                      :diagnostics (:frequencyMs 5000)))
  (set-company-backend! '(c-mode c++-mode) '(company-lsp))
  )

;; run ccls by default in C++ files
(defun ccls//enable ()
  (condition-case nil
      (lsp-ccls-enable)
    (user-error nil)))

  (use-package ccls
    :commands lsp-ccls-enable
    :init (add-hook 'c-mode-common-hook #'ccls//enable))


;; lsp-company
(def-package! company-lsp
  :after lsp-mode)
(set-company-backend! '(c-mode c++-mode) '(company-lsp company-files company-yasnippet))
(after! lsp-mode
(setq company-lsp-enable-snippet t)
(setq company-lsp-cache-candidates nil)
(setq company-lsp-async t))

;; lsp-flycheck
(require 'lsp-ui-flycheck)
(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-after-open-hook (lambda () (lsp-ui-flycheck-enable 1))))
(add-hook 'c-mode-common-hook 'flycheck-mode) ;; Turn on flycheck for C++ buffers

;; org-images
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)

;; gdb debugging
(setq gdb-many-windows t)

;; fill-column
;; turn it off by default
(remove-hook! (text-mode prog-mode conf-mode) #'turn-on-fci-mode)

;; eshell
;; add fish-like autocompletion
(def-package! esh-autosuggest)
(add-hook 'eshell-mode-hook #'esh-autosuggest-mode)
