;;;  -*- lexical-binding: t; -*-

; (map!

;; Override other keys
(map! (:leader
      (:prefix "/"
          :desc "Swiper in buffer"          :n "/" #'swiper)
      ;; File
      (:prefix "f"
      :n "f" #'counsel-fzf)
      ;; Toggle
      (:prefix "t"
        :desc "Zen writing" :n "z" #'writeroom-mode
        :desc "Wrap lines to fit screen" :n "v" #'visual-line-mode
        :desc "Column-indicator" :n "c" #'fci-mode)
      ;; Window
      (:prefix "w"
        :desc "Close all other windows" :n "O" #'delete-other-windows
        :desc "Doom/window/enlargen" :n "o" #'doom/window-enlargen)
      ;; Navigation
      (:prefix "["
       :n "t" #'multi-term-prev)
      (:prefix "]"
       :n "t" #'multi-term-next)
      ;; Open
      (:prefix "r"
       :n "i" #'ivy-resume)
      )
      ;; Vimesque keys
      (:prefix "["
      :n "SPC" #'evil-unimpaired/insert-space-above)
      (:prefix "]"
      :n "SPC" #'evil-unimpaired/insert-space-below)
      ;; Company
      :i "C-k"  #'+company/complete
      ;; Swedish escape
      :i "C-å" #'evil-normal-state
      ;; counsel
      (:after ivy
        (:map ivy-minibuffer-map
          "C-l"      #'ivy-call-and-recenter))
      )

;; Bring back the leader in pdf-tools by unbinding comma
(map!
 :after pdf-view
 :map pdf-view-mode-map
 :nvmei "," nil
 )
