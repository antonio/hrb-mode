## Synopsis

**hrb-mode** is an Emacs minor-mode for highlighting Ruby blocks just like `(show-paren-mode t)`.

![hrb-mode Screenshot](https://github.com/ckruse/hrb-mode/raw/master/screenshots/highlight-mode-region.png)
![hrb-mode Screenshot](https://github.com/ckruse/hrb-mode/raw/master/screenshots/highlight-mode-keywords.png)

## Installation

Just clone this repository and add this directory to your `load-path`:

```lisp
(add-to-list 'load-path "~/emacs.d/hrb-mode")
(require 'hrb-mode)

;; show region immediately
(setq hrb-delay 0)

;; set different face for highlighting keywords
(setq hrb-highlight-keyword-face 'show-paren-match-face)

;; set different face for highlighting block
(setq hrb-highlight-block-face 'highlight)

;; highlight only keywords
(setq hrb-highlight-mode 'keywords)

;; highlight complete block
(setq hrb-highlight-mode 'complete)

;; highlight keywords if both are visible, highlight complete block otherwise
(setq hrb-highlight-mode 'mixed)

;; enable hrb-mode
(hrb-mode t)
```

## Contribution

Contribution is always welcome! Just fork, make your changes and create a pull request.
