;;;  -*- lexical-binding: t; -*-

;; Org-mode
;; customize org-settings
(after! org
  (setq outline-blank-line nil)
  (setq org-cycle-separator-lines 2)
  (setq org-log-done 'time))
;; Turn of highlight line in org-mode
(add-hook 'org-mode-hook (lambda ()
                           (hl-line-mode -1)))
;; automatically redisplay images generated by babel
(add-hook 'org-babel-after-execute-hook 'org-redisplay-inline-images)
;; place latex-captions below figures and tables
(setq org-latex-caption-above nil)
;; Disable line-numbers in org-mode
(add-hook 'org-mode-hook #'doom|disable-line-numbers)
;; Agenda
;; specify the main org-directory
(setq org-directory "~/org")
;; set which directories agenda should look for todos
(setq org-agenda-files '("~/org"
                         "~/org/work"))
;; Org-brain
(def-package! org-brain
  :commands (org-brain-visualize)
  :init (add-to-list 'evil-motion-state-modes 'org-brain-visualize-mode)
  :config
  (add-hook! org-brain-visualize-mode 'visual-line-mode)
  (set-popup-rule! "*org-brain*" :ignore t)
  (setq org-id-locations-file (concat doom-local-dir ".org-id-locations"))
  (push '("b" "Brain" plain #'org-brain-goto-end
          "* %i%?" :empty-lines 1)
        org-capture-templates)
  (setq org-brain-visualize-default-choices 'all) ; could be set to files for increased performance
  (setq org-brain-title-max-length 12)
  (push 'org-brain-visualize-mode evil-snipe-disabled-modes)

  ;; define keybindings
  (map!
   :map org-brain-visualize-mode-map
     :m "C-k" #'evil-window-up
     :m "C-j" #'evil-window-down
     :m "C-h" #'evil-window-left
     :m "C-l" #'evil-window-right
     :m "-" (λ! ()
                (org-brain-visualize-remove-grandparent)
                (org-brain-visualize-remove-grandchild))
     :m "=" (λ! ()
                (org-brain-visualize-add-grandparent)
                (org-brain-visualize-add-grandchild))
     (:desc "add" :prefix "a"
       :m "p" #'org-brain-add-parent
       :m "c" #'org-brain-add-child
       :m "f" #'org-brain-add-friendship
       :m "r" #'org-brain-add-resource
       :m "h" #'org-brain-add-child-headline)

     (:desc "set" :prefix "s"
       :m "a" #'org-brain-visualize-attach
       :m "T" #'org-brain-set-title
       :m "t" #'org-brain-set-tags)

     :m "p" #'org-brain-visualize-paste-resource
     :m "R" (λ! (org-brain-stop-wandering) (revert-buffer))

     (:desc "remove" :prefix "r"
       :m "p" #'org-brain-remove-paren
       :m "c" #'org-brain-remove-child
       :m "f" #'org-brain-remove-friendship)

     (:desc "do" :prefix "d"
       :m "d" #'org-brain-delete-entry
       :m "p" #'org-brain-pin
       :m "a" #'org-brain-archive)

     :m "N" #'org-brain-new-child

     (:desc "view" :prefix "z"
       :m "m" #'org-brain-visualize-mind-map
       :m "b" #'org-brain-visualize-back
       :m "r" #'org-brain-visualize-random
       :m "w" #'org-brain-visualize-wander)
     :m "j" #'forward-button
     :m "k" #'backward-button
     :m "o" #'org-brain-goto-current
     :m "v" #'org-brain-visualize
     :m "q" #'org-brain-visualize-quit))
;; convert ascii-art to unicode for org-brain
(def-package! ascii-art-to-unicode
  :after org-brain
  :config
(defface aa2u-face '((t . nil))
  "Face for aa2u box drawing characters")
(advice-add #'aa2u-1c :filter-return
            (lambda (str) (propertize str 'face 'aa2u-face)))
(defun aa2u-org-brain-buffer ()
  (let ((inhibit-read-only t))
    (make-local-variable 'face-remapping-alist)
    (add-to-list 'face-remapping-alist
                 '(aa2u-face . org-brain-wires))
    (ignore-errors (aa2u (point-min) (point-max)))))
(add-hook 'org-brain-after-visualize-hook #'aa2u-org-brain-buffer))



;; Org-Noter
(def-package! org-noter
  :after org
  :config
  (setq org-noter-always-create-frame nil
        org-noter-auto-save-last-location t)
  (map! :localleader
        :map org-mode-map
        (:prefix-map ("n" . "org-noter")
          :desc "Open org-noter" :n "o" #'org-noter
          :desc "Kill org-noter session" :n "k" #'org-noter-kill-session
          :desc "Insert org-note" :n "i" #'org-noter-insert-note
          :desc "Insert precise org-note" :n "p" #'org-noter-insert-precise-note
          :desc "Sync current note" :n "." #'org-noter-sync-current-note
          :desc "Sync next note" :n "]" #'org-noter-sync-next-note
          :desc "Sync previous note" :n "[" #'org-noter-sync-prev-note)))

;; Hugo
(def-package! ox-hugo
  :defer t                      ;Auto-install the package from Melpa (optional)
  :after ox)

;; ;; LaTeX export
(after! 'org
  (require  'ox-latex)
  ;; (add-to-list 'org-latex-packages-alist '("newfloat" "minted"))
  (setq org-latex-listings 'minted)
  ;; set minted options
  (setq org-latex-minted-options
        '(("frame" "lines")))
  ;; set pdf generation process
  (setq org-latex-pdf-process
        '("xelatex -shell-escape -interaction nonstopmode %f"
          "xelatex -shell-escape -interaction nonstopmode %f"
          "xelatex -shell-escape -interaction nonstopmode %f"))
  (add-to-list 'org-latex-minted-langs '(calc "mathematica"))
  ;; Add org-latex-class
  (add-to-list 'org-latex-classes
               '("zarticle"
                 "\\documentclass[11pt,Wordstyle]{Zarticle}
                    \\usepackage[utf8]{inputenc}
                    \\usepackage{graphicx}
                        [NO-DEFAULT-PACKAGES]
                        [PACKAGES]
                        [EXTRA] "
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}"))))


;; Jira
(def-package! org-jira
  :defer t
  :config
  (setq jiralib-url "https://jira.zenuity.com"
        org-jira-users `("Niklas Carlsson" . ,(shell-command-to-string "printf %s \"$(pass show work/zenuity/login | sed -n 2p | awk '{print $2}')\""))
        jiralib-token `("Cookie". ,(my/init-jira-cookie))))

;; Customization
;; You can define one or more custom JQL queries to run and have your
;; results inserted into, as such:
(setq org-jira-custom-jqls
      '(
        (:jql " project = DUDE AND issuetype != Sub-task AND issuetype != Epic AND resolution = Unresolved AND  (Sprint = EMPTY OR Sprint NOT IN (openSprints(), futureSprints()))"
              :limit 50
              :filename "dude-backlog")
        (:jql " project = DUDE AND issuetype != Sub-task AND sprint in openSprints() AND sprint NOT IN futureSprints()"
              :limit 20
              :filename "dude-current-sprint-user-stories")
        (:jql " project = DUDE AND issuetype = Sub-task AND sprint in openSprints() AND sprint NOT IN futureSprints()"
              :limit 50
              :filename "dude-current-sprint-sub-tasks")
        (:jql " project = DUDE AND issuetype = Epic"
              :limit 20
              :filename "dude-epics")
        (:jql " project = DUDE AND assignee = currentuser() order by created DESC "
              :limit 20
              :filename "dude-niklas")
        ))
;; Please note this feature still requires some testing - things that
;; may work in the existing proj-key named buffers (DUDE.org etc.) may
;; behave unexpectedly in the custom named buffers.

;; One thing you may notice is if you create an issue in this type of
;; buffer, the auto-refresh of the issue will appear in the
;; PROJ-KEY.org specific buffer (you will then need to refresh this
;; JQL buffer by re-running the command C-c ij).

;; The following variable, org-jira-worklog-sync-p, is set to true by
;; default, but this causes an error on my machine when attempting to
;; update issues. I believe I don't have the need for syncing the
;; clocks.
(setq org-jira-worklog-sync-p nil)

;;Streamlined transition flow
;; You can define your own streamlined issue progress flow as such:
; If your Jira is set up to display a status in the issue differently
; than what is shown in the button on Jira, your alist may look like
; this (use the labels shown in the org-jira Status when setting it
; up, or manually work out the workflows being used through standard
; C-c iw options/usage):
 (defconst org-jira-progress-issue-flow
   '(("To Do" . "In Progress")
     ("In Progress" . "Review")
     ("Review" . "Done")))

;;
;; org-capture
;; the following solves an error when in org-capture
(add-hook 'org-capture-mode-hook #'yas-abort-snippet)


;; ;; org-capture snippets
;; ;; http://www.howardism.org/Technical/Emacs/capturing-content.html
;; (require 'which-func)

;; (defun my/org-capture-code-snippet (f)
;;   "Given a file, F, this captures the currently selected text
;; within an Org SRC block with a language based on the current mode
;; and a backlink to the function and the file."
;;   (with-current-buffer (find-buffer-visiting f)
;;     (let ((org-src-mode (replace-regexp-in-string "-mode" "" (format "%s" major-mode)))
;;           (func-name (which-function)))
;;       (my/org-capture-fileref-snippet f "SRC" org-src-mode func-name))))

;; (defun my/org-capture-fileref-snippet (f type headers func-name)
;;   (let* ((code-snippet
;;           (buffer-substring-no-properties (mark) (- (point) 1)))
;;          (file-name   (buffer-file-name))
;;          (file-base   (file-name-nondirectory file-name))
;;          (line-number (line-number-at-pos (region-beginning)))
;;          (initial-txt (if (null func-name)
;;                           (format "From [[file:%s::%s][%s]]:"
;;                                   file-name line-number file-base)
;;                         (format "From ~%s~ (in [[file:%s::%s][%s]]):"
;;                                 func-name file-name line-number
;;                                 file-base))))
;;     (format "
;;    %s

;;    #+BEGIN_%s %s
;; %s
;;    #+END_%s" initial-txt type headers code-snippet type)))
;; ;; Hugo
;; ;; Populates only the EXPORT_FILE_NAME property in the inserted headline.
;; (defun org-hugo-new-subtree-post-capture-template ()
;;   "Returns `org-capture' template string for new Hugo post.
;; See `org-capture-templates' for more information."
;;   (let* ((title (read-from-minibuffer "Post Title: ")) ;Prompt to enter the post title
;;          (fname (org-hugo-slug title)))
;;     (mapconcat #'identity
;;                `(
;;                  ,(concat "* TODO " title)
;;                  ":PROPERTIES:"
;;                  ,(concat ":EXPORT_FILE_NAME: " fname)
;;                  ":END:"
;;                  "%?\n")                ;Place the cursor here finally
;;                "\n")))


;; ;; Org-capture
;; ;; Personal snippets
;; ;; Code snippet
;; (add-to-list 'org-capture-templates
;;              '("s" "Code snippet"  entry
;;                (file "~/org/code/snippets.org")
;;                "* %?\n%(my/org-capture-code-snippet \"%F\")"))
;; ;; Work  capture templates
;; (add-to-list 'org-capture-templates
;;              '("w" "Work entries"))
;; (add-to-list 'org-capture-templates
;;              '("ws" "Code snippet"  entry
;;                (file "~/org/work/snippets.org")
;;                "* %?\n%(my/org-capture-code-snippet \"%F\")"))
;; (add-to-list 'org-capture-templates
;;   '("wt" "Todo" entry (file+headline "~/org/work/todo.org" "Inbox")
;;      "* [ ] %?\n%i" :prepend t :kill-buffer t))
;; (add-to-list 'org-capture-templates
;;               '("h"                ;`org-capture' binding + h
;;                 "Hugo blog post"
;;                 entry
;;                 ;; It is assumed that below file is present in `org-directory'
;;                 ;; and that it has a "Blog Ideas" heading. It can even be a
;;                 ;; symlink pointing to the actual location of all-posts.org!
;;                 (file+olp "todo.org" "Blog Ideas")
;;                 (function org-hugo-new-subtree-post-capture-template)))

;; ;; Org-babel
;; (defun src-block-in-session-p (&optional name)
;;   "Return if src-block is in a session of NAME.
;; NAME may be nil for unnamed sessions."
;;   (let* ((info (org-babel-get-src-block-info))
;;          (lang (nth 0 info))
;;          (body (nth 1 info))
;;          (params (nth 2 info))
;;          (session (cdr (assoc :session params))))

;;     (cond
;;      ;; unnamed session, both name and session are nil
;;      ((and (null session)
;;            (null name))
;;       t)
;;      ;; Matching name and session
;;      ((and
;;        (stringp name)
;;        (stringp session)
;;        (string= name session))
;;       t)
;;      ;; no match
;;      (t nil))))

;; (defun org-babel-restart-session-to-point (&optional arg)
;;   "Restart session up to the src-block in the current point.
;; Goes to beginning of buffer and executes each code block with
;; `org-babel-execute-src-block' that has the same language and
;; session as the current block. ARG has same meaning as in
;; `org-babel-execute-src-block'."
;;   (interactive "P")
;;   (unless (org-in-src-block-p)
;;     (error "You must be in a src-block to run this command"))
;;   (let* ((current-point (point-marker))
;;          (info (org-babel-get-src-block-info))
;;          (lang (nth 0 info))
;;          (params (nth 2 info))
;;          (session (cdr (assoc :session params))))
;;     (save-excursion
;;       (goto-char (point-min))
;;       (while (re-search-forward org-babel-src-block-regexp nil t)
;;         ;; goto start of block
;;         (goto-char (match-beginning 0))
;;         (let* ((this-info (org-babel-get-src-block-info))
;;                (this-lang (nth 0 this-info))
;;                (this-params (nth 2 this-info))
;;                (this-session (cdr (assoc :session this-params))))
;;             (when
;;                 (and
;;                  (< (point) (marker-position current-point))
;;                  (string= lang this-lang)
;;                  (src-block-in-session-p session))
;;               (org-babel-execute-src-block arg)))
;;         ;; move forward so we can find the next block
;;         (forward-line)))))

;; (defun org-babel-kill-session ()
;;   "Kill session for current code block."
;;   (interactive)
;;   (unless (org-in-src-block-p)
;;     (error "You must be in a src-block to run this command"))
;;   (save-window-excursion
;;     (org-babel-switch-to-session)
;;     (kill-buffer)))

;; (defun org-babel-remove-result-buffer ()
;;   "Remove results from every code block in buffer."
;;   (interactive)
;;   (save-excursion
;;     (goto-char (point-min))
;;     (while (re-search-forward org-babel-src-block-regexp nil t)
;;       (org-babel-remove-result))))
