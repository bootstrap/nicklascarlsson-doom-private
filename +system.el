;;; +system.el -*- lexical-binding: t; -*-

;; A collection of system utilty functionality


;;
;; Network manager
(use-package! enwc
  :config
  ;; Customize settings
  (setq enwc-default-backend 'nm
        enwc-display-mode-line nil
        enwc-wireless-device "wlp3s0"
        enwc-wired-device "lo"
        enwc-ask-to-save-interfaces nil
        enwc-warn-if-already-setup nil)
  ;; Ensure enwc buffer is delegated to the popup system.
  (defadvice! +popup--enwc-pop-to-buffer ()
    "Use `pop-to-buffer' instead of `switch-to-buffer' to open buffer.'"
    :before #'enwc
    (pop-to-buffer "*ENWC*"))
  ;; Customize popup buffer
  (set-popup-rule! "*ENWC*" :size 0.3 :side 'bottom :select t :autosave t))


;;
;; Netmacs
(use-package! libnetmacs
  :load-path "~/opensource/libnetmacs")
(use-package! netmacs
  :load-path "~/opensource/netmacs")


;;
;; Process manager
(use-package! proced
  :config
  ;; (set-popup-rule! "*Proced*" :size 0.4 :side 'bottom :select t :autosave t)
  )

;;
;; Disk usage
(use-package! disk-usage
  :config
  (map!
   :map disk-usage-mode-map
   :desc "Reset cache" :nmi "r" #'disk-usage-reset-cache
   :desc "Dired here" :nmi "D" (λ! () (dired default-directory))))


;;
;; Pulse audio control
(use-package! pulseaudio-control
  ;; TODO: Implement transient to control the separate functions?
  )

;;
;; Bluetooth
(use-package! bluetooth
  :config

  ;; Ensure bluetooth buffer is delegated to the popup system.
  (defadvice! +popup--bluetooth-pop-to-buffer ()
    "Use `pop-to-buffer' instead of `switch-to-buffer' to open buffer.'"
    :before #'bluetooth-list-devices
    (pop-to-buffer "*Bluetooth*"))

  ;; Configure popup rule
  (set-popup-rule! "*Bluetooth*" :size 0.3 :side 'bottom :select t :autosave t)

  ;; Keybindings
  (map!
   :map bluetooth-mode-map
   :desc "Connect" :n "c" #'bluetooth-connect
   :desc "Disconnect" :n "x" #'bluetooth-disconnect
   :desc "Information" :n "RET" #'bluetooth-show-device-info
   :desc "Remove" :n "X" #'bluetooth-remove-device
   (:prefix ("t" . "Toggle")
     :desc "Power" :n  "p" #'bluetooth-toggle-power
     :desc "Pairable" :n "P" #'bluetooth-toggle-pairable
     :desc "Discoverable" :n "d" #'bluetooth-toggle-discoverable
     :desc "Blocked" :n "b" #'bluetooth-toggle-blocked
     :desc "Trusted" :n "t" #'bluetooth-toggle-trusted)
   (:prefix ("d" . "Discover")
     :desc "Begin" :n "b" #'bluetooth-start-discovery
     :desc "Stop" :n "s" #'bluetooth-stop-discovery)))


;;
;; yequake
(use-package! yequake
  :config
  (setq yequake-frames
        '(("elfeed"
           (buffer-fns . (elfeed))
           (width . 0.75)
           (height . 0.5)
           (alpha . 0.95)
           (frame-parameters . ((undecorated . t)
                                (skip-taskbar . t)
                                (sticky . t))))
          ("org-agenda"
           (buffer-fns . (org-agenda-list))
           (width . 0.75)
           (height . 0.5)
           (alpha . 0.95)
           (frame-parameters . ((undecorated . t)
                                (skip-taskbar . t)
                                (sticky . t))))
          ("org-capture"
           (buffer-fns . (yequake-org-capture))
           (width . 0.75)
           (height . 0.5)
           (alpha . 0.95)
           (frame-parameters . ((undecorated . t)
                                (skip-taskbar . t)
                                (sticky . t)))))))


;;
;; Gerrit-CI
(use-package! gci
  :load-path "~/opensource/gerrit-ci"
  :config
  (setq gci-gerrit-project "src"
        gci-gerrit-url "gerrit.zenuity.com"
        gci-gerrit-email "niklas.carlsson@zenuity.com"
        gci-job--parse-regexp  "^-\\s-*src--check-src-\\(.*\\)-src\\b\\s-*\\(\\bhttps.*/\\)\\s-*:\\s-*\\(\\b.*\\b\\)\\s-*in\\s-*\\(\\b.*\\b\\)"
        gci-zuul-url "https://se1dev013.ad.zenuity.com/zuul/status.json"
        gci-zuul-ca-cert "/home/nikcar/src/mono/stringent/tools/zuul/se1dev013.ad.zenuity.com")

  (defadvice! +gci/list-changes-a ()
    "Split windows."
    :before #'gci-list-changes
   (gci-close-all-buffers)
   (switch-to-buffer-other-window "*gci-changes*"))

  (set-popup-rule! "\\*gci-*" :ignore t)

  ;; Keymap
  (map!
   (:map gci-mode-map
     :n "^" #'navigel-open-parent
     :n "?" #'gci-dispatch
     :n "b" #'gci-browse
     :n "f" #'counsel-imenu
     :n "l" #'gci-changes-transient
     :n "m" #'gci-message-transient
     :n "o" #'gci-imenu-open
     :n "p" #'gci-list-patch-sets
     :n "r" #'gci-refresh-changes
     :n "RET" #'gci-list-jobs)
   (:map gci-change-mode-map
     :n "^" #'navigel-open-parent
     :n "f" #'counsel-imenu
     :n "o" #'gci-imenu-open
     :n "b" #'gci-browse)))


;; GoCD
(use-package! gocd
  :init
  (use-package! navigel
    :load-path "~/opensource/navigel"
    :ensure nil)
  (require 'auth-source-pass)
  :load-path "~/opensource/gocd"
  :ensure nil
  :config
  (setq gocd-url "https://gocd.zenuity.com"
        gocd-email "niklas.carlsson@zenuity.com"
        gocd-secret (+pass-get-secret "work/zenuity/login")
        gocd-gerrit-url "gerrit.zenuity.com"
        gocd-pipeline-favorites '("z1_vehicle--master"))

  ;; Popup windows
  (set-popup-rule! "\\*gocd-*" :size 0.3 :side 'bottom :select t :autosave 'ignore)

  ;; Keymap
  (map!
   (:map gocd-tablist-mode-map
     :n "m" #'tablist-mark-forward
     :n "u" #'tablist-unmark-forward
     :n "d" #'gocd-pipeline-diff)))


;;
;; Magit Gerrit
(use-package! magit-gerrit
  :config
  (setq magit-gerrit-popup-prefix "R"))


;;
;; Conflicts
(use-package! emacs-conflict
  :config
  (defun +emacs-conflict-show-conflicts-dired-at-point ()
    "Show conflicts at point."
    (interactive)
    (emacs-conflict-show-conflicts-dired (dired-get-file-for-visit))))

;;
;; Notifications
(use-package! alert
  :config
  (setq alert-default-style 'libnotify)

  (defun nc/compile-start-time (_process)
    "Record the start time of the compilation."
    (setq-local compile-start-time (time-to-seconds)))
  (add-hook 'compilation-start-hook 'nc/compile-start-time)

  (defun nc/compile-notify-finish (_buffer string)
    "Conditionally show a notification when a compilation finishes.
Always notify about compilations that are failing. Notify about successful ones
if they have been running for enough time."
    (let* ((duration-threshold 10)
           (compilation-end-time (time-to-seconds))
           (compile-duration (float-time (time-subtract compilation-end-time compile-start-time))))
      (if (string-match "^finished" string)
          (when (> compile-duration duration-threshold)
            (alert "Compilation finished OK!" :title "Compilation Successful" :severity 'moderate :category 'compile :id 'compile-ok))
        (alert "Compilation Failed" :title "Compilation Failed" :severity 'high :category 'compile :id 'compile-fail))))
  (add-hook 'compilation-finish-functions 'nc/compile-notify-finish))


;;
;; Lock screen
(use-package! zone
  :config
  (defun +zone/all-windows ()
    "Make zone clone the current buffer on to all windows before running zone."
    (interactive)
    (let* ((current-window (car (window-list)))
           (all-windows (window-list))
           (zone-buffer (get-buffer-create "*zone*")))
      ;; Make a copy of the current buffer,
      ;; this way it works even for buffers like eshell
      (nc/buffer-copy "*zone-copy*")
      ;; Visit all windows and switch to the soon to be used zone-buffer
      (while all-windows
        (select-window (car  all-windows))
        (setq  all-windows (cdr  all-windows))
        (switch-to-buffer "*zone*"))
      ;; Switch back to the starting window and change that to zone-copy buffer
      (select-window current-window)
      (switch-to-buffer "*zone-copy*")
      ;; Start zone on current buffer, creates the buffer *zone*
      (zone)))

  (defun +zone/all-frames ()
    "Make current buffer be shown on all windows/frames and run zone."
    ;; TODO: integrate with bspwm later, don't need to run on frames that are
    ;; hidden, or on desktop that aren't currently shown.
    (interactive)
    (let ((start-frame (selected-frame))
          (start-window (selected-window))
          (current-frame)
          (windows)
          (zone-buffer (get-buffer-create "*zone*")))
      ;; copy the current window
      (nc/buffer-copy "*zone-copy*")
      ;; As long as we haven't returned to the starting frame
      (while (not (eq current-frame start-frame))
        ;; get all the windows on the current frame
        (setq windows (window-list))
        (while windows
          (select-window (car windows))
          (setq windows (cdr windows))
          (switch-to-buffer "*zone*"))
        ;; switch to next frame
        (select-frame (next-frame current-frame nil))
        ;; make next frame current
        (setq current-frame (selected-frame)))
      ;; Switch back to the starting frame and window and change that to zone-copy buffer
      (select-frame start-frame)
      (select-window start-window)
      (switch-to-buffer "*zone-copy*")
      ;; Give the windows a chance to catch up, the position becomes inacurate otherwise
      (sit-for 0.1)
      ;; Start zone on current buffer, creates the buffer *zone*
      (zone)))


  (defun +zone/lock-screen ()
    "Lock screen using (zone) and pyxtrlock calls +zone/all-windows and runs pyxtrlock."
    (interactive)
    (save-window-excursion
      (set-process-sentinel
       (start-process "my-lock" nil "my-lock")
       '(lambda (process event)
          ;; Kill the *zone-copy* upon unlocking (don't need it anymore)
          (kill-buffer "*zone-copy*")))
      (+zone/all-frames)))

  ;; bindings
  (map!
   :desc "Lock and run" :nvi "<f2>" '+zone/lock-screen))
