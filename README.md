# Swagger Mode

Swagger Mode integrates Swagger Codegen into Emacs as a Minor Mode.

## Install

### MELPA

Not Available Yet

### Manual

* Install Swagger Codegen from https://github.com/swagger-api/swagger-codegen
* Swagger Codegen should be executabel as `swagger-codegen`
* Download `swagger-mode.el`
* Put it in some directory like `~/.emacs.d/local/`
* Add this code into your Emacs configuration:

```
(add-to-list 'load-path
             (expand-file-name "local" user-emacs-directory))

(require 'swagger-mode)
```
