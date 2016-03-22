;;光标在行首时注释此行
;;说明见http://cmdblock.blog.51cto.com/415170/557978/
(defun qiang-comment-dwim-line (&optional arg)
  "Replacement for the comment-dwim command. If no region is selected and current line is not blank and we are not at the end of the line, then comment current line. Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region (line-beginning-position) (line-end-position))
    (comment-dwim arg)))
(global-set-key "\M-;" 'qiang-comment-dwim-line)

;;ace-jump-mode
(define-key global-map (kbd "C-*") 'ace-jump-mode)

;;go to char
;;from http://www.tuicool.com/articles/J7RRBbe
(defun my-go-to-char (n char)
  "Move forward to Nth occurence of CHAR.
Typing `my-go-to-char-key' again will move forwad to the next Nth
occurence of CHAR."
  (interactive "p\ncGo to char: ")
  (let ((case-fold-search nil))
    (if (eq n 1)
        (progn                            ; forward
          (search-forward (string char) nil nil n)
          (backward-char)
          (while (equal (read-key)
                        char)
            (forward-char)
            (search-forward (string char) nil nil n)
            (backward-char)))
      (progn                              ; backward
        (search-backward (string char) nil nil )
        (while (equal (read-key)
                      char)
          (search-backward (string char) nil nil )))))
  (setq unread-command-events (list last-input-event)))
(global-set-key (kbd "C-S-t") 'my-go-to-char)

;;在evil中使用C-q回到normal模式，如果想要输入特殊字符请使用C-v
(define-key evil-insert-state-map (kbd "C-q") 'evil-force-normal-state)

;;my keys
(nvmap :prefix "SPC"
       "jm" 'my-go-to-char
       "jj" 'ace-jump-char-mode
       "jl" 'ace-jump-line-mode
       "jw" 'ace-jump-word-mode
       )

(require 'key-chord)
(key-chord-mode 1)
;;同时按下fd可以实现esc的功能，可以用于快速退出到普通模式
(key-chord-define-global "fd" 'evil-escape)

;;扩展选择
(global-set-key (kbd "C-@") 'er/expand-region)

;;光标在行中时使用C-w和M-w复制或剪切整行
;;http://www.csdn123.com/html/topnews201408/54/5854.htm
(defadvice kill-ring-save (before slickcopy activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slickcut activate compile)
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

;;在shell中运行已经编译好的当前程序
(defun run-compiled-file ()
  "open a shell to run the file which smart-compile.el has compiled"
  (interactive)
  ;;(smart-compile)
  (let ((file-name (buffer-file-name))))
  (let ((name (substring (buffer-file-name)
                         0 (position ?. (buffer-file-name) :from-end t))))
    (shell)
    (insert name)
    (comint-send-input)))
(global-set-key (kbd "C-<f5>") 'run-compiled-file)

;;使用F10在当前buffer和shell之间来回切换
(defun toggle-shell ()
  "switch current buffer and shell"
  (interactive)
  (if (string-equal (buffer-name) "*shell*")
      (bs-cycle-next)
    (shell)))
(global-set-key (kbd "<f10>") 'toggle-shell)

;;; 在粘贴代码的时候自动排版
(dolist (command '(yank yank-pop))
  (eval
   `(defadvice ,command (after indent-region activate)
      (and (not current-prefix-arg)
           (member major-mode
                   '(emacs-lisp-mode
                     lisp-mode
                     clojure-mode
                     scheme-mode
                     haskell-mode
                     ruby-mode
                     rspec-mode
                     python-mode
                     c-mode
                     c++-mode
                     objc-mode
                     latex-mode
                     js-mode
                     plain-tex-mode))
           (let ((mark-even-if-inactive transient-mark-mode))
             (indent-region (region-beginning) (region-end) nil))))))

;;在插入模式下使用C-O来在光标前插入一个换行符
(define-key evil-insert-state-map (kbd "C-S-o") 'open-line)
;;在普通模式下在下一行增加一个空行，但光标不移动也不进入插入模式
(define-key evil-normal-state-map (kbd "C-S-o")
  '(lambda () (interactive) (save-excursion (evil-open-below 1) (evil-normal-state))))

;;mc-multiple-cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(provide 'init-my-hotkeys)