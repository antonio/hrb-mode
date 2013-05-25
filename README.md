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

;; enable hrb-mode
(hrb-mode t)
```

## Features to come

* Hilight only keywords
* Mixed hilighting: hilight keywords when keyword is visible, hilight region otherwise

## Contribution

Contribution is always welcome! Just fork, make your changes and create a pull request.
