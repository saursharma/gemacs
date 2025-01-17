(progn
  (setq user-full-name "Abhinav Kumar"
        user-mail-address "abhinavkumar@google.com")
  (when window-system

    ;; Transparency. Set this before setting up your theme. The theme may
    ;; configure itself to use better colors for transparency.
    ;;(set-frame-parameter (selected-frame) 'alpha '(<aemctive> [<inactive>]))
    (set-frame-parameter (selected-frame) 'alpha '(85 70))
    (add-to-list 'default-frame-alist '(alpha 85 70))

    ;; (require 'monokai-theme)
    ;; (require 'github-theme)
    ;; (require 'tango-2-theme)
    (require 'burp-theme)
    )
  )
(provide 'abhinavkumar)
