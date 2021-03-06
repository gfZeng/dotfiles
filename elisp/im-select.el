;; Based on https://gist.github.com/celadevra/7ae45920e2494fbc38ef

;; In your .emacs:
;;
;; (setq load-path (cons "/path/to/im-select" load-path))
;; (module-load "/path/to/im-select/im-select-module.so")
;; (require 'im-select)
;;

;; switch to English input method when switching to normal mode
;; and switch back when entering insert/replace modes
;; need external script support, currently mac-only

(defvar im-select-command "/usr/local/bin/im-select")

(defun osx-im-select (&optional im)
  (unless (executable-find "im-select")
    (error (message "`im-select' im-select-command not found")))
  (if im
      (shell-command (concat im-select-command " " im))
    (string-trim (shell-command-to-string im-select-command))))

(defvar default-im "com.apple.keylayout.ABC" "Default ascii-only input method")
(defvar prev-im (osx-im-select)
 "IM that I use when starting Emacs and exiting insert mode")

(defun should-enable-im-select()
  (interactive)
  ;; (message "current-buffer = %s, window-buffer = %s"
  ;;          (current-buffer)
  ;;          (window-buffer (selected-window)))
  (eq (current-buffer)
     (window-buffer (selected-window))))
  ;; (eq major-mode 'org-mode))

(defun im-use-english ()
  "Switch to English input method on a Mac. im-select is a tool
provided at http://git.io/ndA8Mw"
  (interactive)
  (when (should-enable-im-select)
    (cond ((eq system-type 'darwin)
           (osx-im-select default-im)))))

(defun im-remember ()
  "Remember the input method being used in insert mode,
so we can switch to it in other modes."
  (interactive)
  (when (should-enable-im-select)
    (cond ((eq system-type 'darwin)
           (setq prev-im (osx-im-select))))))



(defun im-use-prev ()
  "Use previous input method.
If previous input method is not defined, use default method"
  (interactive)
  (when (should-enable-im-select)
    (cond ((eq system-type 'darwin)
           (if prev-im
               (osx-im-select prev-im)
             (osx-im-select default-im))))))

(add-hook 'evil-normal-state-entry-hook 'im-use-english)
(add-hook 'evil-insert-state-entry-hook 'im-use-prev)
(add-hook 'evil-insert-state-exit-hook 'im-remember)
(add-hook 'evil-hybrid-state-entry-hook 'im-use-prev)
(add-hook 'evil-hybrid-state-exit-hook 'im-remember)
(add-hook 'evil-replace-state-entry-hook 'im-use-prev)
(add-hook 'evil-replace-state-exit-hook 'im-remember)
(add-hook 'evil-emacs-state-entry-hook 'im-use-english)

;; (remove-hook 'evil-normal-state-entry-hook 'im-use-english)
;; (remove-hook 'evil-insert-state-entry-hook 'im-use-prev)
;; (remove-hook 'evil-insert-state-exit-hook 'im-remember)
;; (remove-hook 'evil-replace-state-entry-hook 'im-use-prev)
;; (remove-hook 'evil-replace-state-exit-hook 'im-remember)
;; (remove-hook 'evil-emacs-state-entry-hook 'im-use-english)

(provide 'im-select)
