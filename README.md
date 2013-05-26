## Synopsis

**hrb-mode** is an Emacs minor-mode for hilighting Ruby blocks just like `(show-paren-mode t)`.

![hrb-mode Screenshot](https://github.com/ckruse/hrb-mode/raw/master/screenshots/hilight-mode-region.png)

## Installation

Just clone this repository and add this directory to your `load-path`:

```lisp
(add-to-list 'load-path "~/emacs.d/hrb-mode")
(require 'hrb-mode)

;; show region immediately
(setq hrb-delay 0)

;; set different face for hilighting
(setq hrb-hilight-face 'highlight)

;; hilight only keywords
(setq hrb-hilight-mode 'keywords)

;; hilight complete block
(setq hrb-hilight-mode 'complete)

;; hilight keywords if both are visible, hilight complete block otherwise
(setq hrb-hilight-mode 'mixed)

;; enable hrb-mode
(hrb-mode t)
```

## Contribution

Contribution is always welcome! Just fork, make your changes and create a pull request.
