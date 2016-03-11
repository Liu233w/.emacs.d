
;;加载slime
;;(slime-setup)
(unless *cygwin*
  (require 'slime-autoloads))

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

;;设置临时文件夹位置，否则会报错
(when *win64*
  (let ((shellout (shell-command-to-string "set localappdata")))
    (setq temporary-file-directory
          (concatenate 'string
                       (substring shellout
                                  (+ 1 (position ?= shellout)))
                       "\\temp\\"))))
;;  (setq temporary-file-directory "c:/users/wwwlsmcom/appData/local/temp")


;;设置窗口位置为屏库左上角(0,0)
;;(set-frame-position (selected-frame) 0 0)
;;设置宽和高,我的十寸小本是110,33,大家可以调整这个参数来适应自己屏幕大小
(when *win64*
  (defun reset-fream-size ()
    (set-frame-width (selected-frame) 80)
    (set-frame-height (selected-frame) 20))
  (add-hook 'new-frame 'reset-fream-size)
  (reset-fream-size))

;;; 启动server，便于与tc配合
(server-start)

;;setting Font
(if *win64*
    (progn
      ;; Setting English Font
      (set-face-attribute
       'default nil :font "Consolas 20")
      ;; Chinese Font
      (dolist (charset '(kana han cjk-misc bopomofo))
        (set-fontset-font (frame-parameter nil 'font)
                          charset
                          (font-spec :family "Microsoft Yahei" :size 21))))
  (set-default-font "文泉驿等宽微米黑-20"))

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

;;启动server
(server-start)

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

;; For my language code setting (UTF-8)
(set-language-environment "utf-8")
;; (set-keyboard-coding-system 'utf-8)
;; (set-clipboard-coding-system 'utf-8)
;; (set-terminal-coding-system 'utf-8)
;; (set-buffer-file-coding-system 'utf-8)
;; (set-default-coding-systems 'utf-8)
;; (set-selection-coding-system 'utf-8)
;; (modify-coding-system-alist 'process "*" 'utf-8)
;; (setq default-process-coding-system '(utf-8 . utf-8))
;; (setq-default pathname-coding-system 'utf-8)
;; (set-file-name-coding-system 'utf-8)
(prefer-coding-system 'utf-8-auto)

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

;;光标在行中时复制或剪切整行
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

;;gdb调试时打开多窗口
;;(setq gdb-many-windows t)

;;扩展选择
(global-set-key (kbd "C-@") 'er/expand-region)

;;矩形编辑
(global-set-key (kbd "C-, n") 'mc/mark-next-lines)
(global-set-key (kbd "C-, l") 'mc/mark-next-like-this)
(global-set-key (kbd "C-, a") 'mc/mark-all-like-this)

;;load add-on
(require 'smart-compile)
(global-set-key (kbd "<f9>") 'smart-compile)

;;在evil中使用C-q回到normal模式，如果想要输入特殊字符请使用C-q
(define-key evil-insert-state-map (kbd "C-q") 'evil-force-normal-state)
