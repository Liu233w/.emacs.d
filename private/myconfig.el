;;load add-on
(require 'smart-compile)

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
  (setq temporary-file-directory "c:/users/wwwlsmcom/appData/local/temp"))

;;设置窗口位置为屏库左上角(0,0)
;;(set-frame-position (selected-frame) 0 0)
;;设置宽和高,我的十寸小本是110,33,大家可以调整这个参数来适应自己屏幕大小
(when *win64*
  (set-frame-width (selected-frame) 80)
  (set-frame-height (selected-frame) 20))

;;; 设置行号宽度
(setq linum-format 'dynamic)

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

;;配置flymake自动查错
(autoload 'flymake-find-file-hook "flymake" "" t)
(add-hook 'find-file-hook 'flymake-find-file-hook)
(setq flymake-gui-warnings-enabled nil)
(setq flymake-log-level 0)

;;设置markdown
  '(markdown-command
   "pandoc -f markdown -t html -s -c %path%/markdown-style.css --mathjax --highlight-style espresso")

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

;;smart-compile
(global-set-key (kbd "<f9>") 'smart-compile)

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

;;设置光标粗细
;;(setq cursor-type 'hollow)

;;add c++11 support
(require 'font-lock)

(defun --copy-face (new-face face)
  "Define NEW-FACE from existing FACE."
  (copy-face face new-face)
  (eval `(defvar ,new-face nil))
  (set new-face new-face))

(--copy-face 'font-lock-label-face  ; labels, case, public, private, proteced, namespace-tags
             'font-lock-keyword-face)
(--copy-face 'font-lock-doc-markup-face ; comment markups such as Javadoc-tags
             'font-lock-doc-face)
(--copy-face 'font-lock-doc-string-face ; comment markups
             'font-lock-comment-face)

(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)


(add-hook 'c++-mode-hook
          '(lambda()
             (font-lock-add-keywords
              nil '(;; complete some fundamental keywords
                    ("\\<\\(void\\|unsigned\\|signed\\|char\\|short\\|bool\\|int\\|long\\|float\\|double\\)\\>" . font-lock-keyword-face)
                    ;; add the new C++11 keywords
                    ("\\<\\(alignof\\|alignas\\|constexpr\\|decltype\\|noexcept\\|nullptr\\|static_assert\\|thread_local\\|override\\|final\\)\\>" . font-lock-keyword-face)
                    ("\\<\\(char[0-9]+_t\\)\\>" . font-lock-keyword-face)
                    ;; PREPROCESSOR_CONSTANT
                    ("\\<[A-Z]+[A-Z_]+\\>" . font-lock-constant-face)
                    ;; hexadecimal numbers
                    ("\\<0[xX][0-9A-Fa-f]+\\>" . font-lock-constant-face)
                    ;; integer/float/scientific numbers
                    ("\\<[\\-+]*[0-9]*\\.?[0-9]+\\([ulUL]+\\|[eE][\\-+]?[0-9]+\\)?\\>" . font-lock-constant-face)
                    ;; user-types (customize!)
                    ("\\<[A-Za-z_]+[A-Za-z_0-9]*_\\(t\\|type\\|ptr\\)\\>" . font-lock-type-face)
                    ("\\<\\(xstring\\|xchar\\)\\>" . font-lock-type-face)
                    ))
             ) t)