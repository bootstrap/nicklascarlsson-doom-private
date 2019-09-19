;;; +system.el -*- lexical-binding: t; -*-

;; A collection of system utilty functionality


;;
;; Network manager
(use-package! enwc
  :config
  ;; TODO: Add custom keymap
  (setq enwc-default-backend 'nm
        enwc-display-mode-line nil)
  (defun nc/enwc ()
    "A custom enwc setup function that is compatible with popup rules."
    (interactive)
    (enwc-setup)
    (enwc-setup-buffer t)
    (enwc-scan t)
    (pop-to-buffer "*ENWC*"))
  (set-popup-rule! "*ENWC*" :size 0.4 :side 'bottom :select t :autosave t)

  )


;;
;; Torrents
(use-package! transmission
  :config
  (setq  transmission-refresh-modes '(transmission-mode
                                      transmission-files-mode
                                      transmission-info-mode
                                      transmission-peers-mode))
  (set-popup-rule! "*transmission*" :size 0.4 :side 'bottom :select t :autosave t))


;;
;; Process manager
(use-package! proced
  :config
  (set-popup-rule! "*Proced*" :size 0.4 :side 'bottom :select t :autosave t))


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
