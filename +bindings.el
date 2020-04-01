;;;  -*- lexical-binding: t; -*-

(map! :n "C-h" 'evil-window-left
      :n "C-j" 'evil-window-down
      :n "C-k" 'evil-window-up
      :n "C-l" 'evil-window-right

      ;; Use this binding to harmonize with ivy/swiper
      :n "C-'" 'avy-goto-line

      ;; quit
      "s-q" (λ! ()
                (nc/delete-frame-and-stay))

      ;; evilify movement
      (:map evil-treemacs-state-map
        "C-h" 'evil-window-left
        "C-l" 'evil-window-right)

      ;; window
      (:leader
        (:prefix "w"
          :desc "Select window" :n "w" #'ace-window))

      (:map minibuffer-local-map
        "C-n" 'next-line-or-history-element
        "C-p" 'previous-line-or-history-element)

      ;; c++ bindings
      (:localleader
        :map c++-mode-map
        (:prefix-map ("d" . "debug")
          :desc "Set breakpoint" :n "b" #'gud-break
          :desc "Remove breakpoint" :n "B" #'gud-remove
          :desc "Jump here" :n "j" #'gud-jump
          :desc "Continue" :n "c" #'gud-cont
          :desc "Next" :n "n" #'gud-next
          :desc "Step" :n "s" #'gud-step
          :desc "Run" :n "r" #'gud-run
          :desc "Up" :n "u" #'gud-up
          :desc "Down" :n "d" #'gud-down
          :desc "Kill" :n "K" #'nc/gud-kill-all-buffers
          :desc "Start" :n "g" #'nc/gdb-mi-new-frame))

      ;; common lisp bindings
      (:localleader
        :map lisp-mode-map
        :desc "Sly connect" "\"" #'sly-connect)

      ;; create custom leader bindings
      (:leader
        :desc "Resume Avy" :n "\"" #'avy-resume
        (:prefix "o"
          :desc "Open brain" :n "b" #'org-brain-visualize
          :desc "Open chat" :n "c" #'erc-switch-to-buffer
          :desc "Open debugger" :n "d" #'+dap-hydra/body
          :desc "Open mail" :n "m" #'=notmuch
          :desc "Open (pass-)store" :n "s" #'pass
          :desc "Open (ivy-pass-)store" :n "S" #'ivy-pass
          :desc "Open gerrit" :n "G" #'gci-list-changes)
        (:prefix "s"
          :desc "Search Youtube" :n "y" #'ivy-youtube)
        (:prefix "h"
          :desc "Keycast" :n "L" #'global-command-log-mode)))
