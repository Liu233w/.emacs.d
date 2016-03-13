;;设置临时文件夹位置，否则会报错
;; (when *win64*
;;   (let ((shellout (shell-command-to-string "set localappdata")))
;;     (setq temporary-file-directory
;;           (substitute ?/ ?\\
;;                       (concatenate 'string
;;                                    (substring shellout
;;                                               (+ 1 (position ?= shellout)))
;;                                    "\\temp"))))
;; (setq temporary-file-directory "c:/users/wwwlsmcom/appData/local/temp")


;;设置窗口位置为屏库左上角(0,0)
;;(set-frame-position (selected-frame) 0 0)
;;设置宽和高,我的十寸小本是110,33,大家可以调整这个参数来适应自己屏幕大小
(when (or *win64* *cygwin*)
  (defun reset-frame-size ()
    (interactive)
    (set-frame-width (selected-frame) 80)
    (set-frame-height (selected-frame) 20))
  (reset-frame-size))

;;; 启动server，便于与tc配合
(server-start)

;;setting Font
(if (or *win64* *cygwin*)
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

;; For my language code setting (UTF-8)
(set-language-environment "chinese-GBK")
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

(provide 'init-my-others)
