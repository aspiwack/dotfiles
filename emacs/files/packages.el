;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; To install a package with Doom you must declare them here and run 'doom sync'
;; on the command line, then restart Emacs for the changes to take effect -- or


;; To install SOME-PACKAGE from MELPA, ELPA or emacsmirror:
;; (package! some-package)

;; To install a package directly from a remote git repo, you must specify a
;; `:recipe'. You'll find documentation on what `:recipe' accepts here:
;; https://github.com/radian-software/straight.el#the-recipe-format
;; (package! another-package
;;   :recipe (:host github :repo "username/repo"))

;; If the package you are trying to install does not contain a PACKAGENAME.el
;; file, or is located in a subdirectory of the repo, you'll need to specify
;; `:files' in the `:recipe':
;; (package! this-package
;;   :recipe (:host github :repo "username/repo"
;;            :files ("some-file.el" "src/lisp/*.el")))

;; If you'd like to disable a package included with Doom, you can do so here
;; with the `:disable' property:
;; (package! builtin-package :disable t)

;; You can override the recipe of a built in package without having to specify
;; all the properties for `:recipe'. These will inherit the rest of its recipe
;; from Doom or MELPA/ELPA/Emacsmirror:
;; (package! builtin-package :recipe (:nonrecursive t))
;; (package! builtin-package-2 :recipe (:repo "myfork/package"))

;; Specify a `:branch' to install a package from a particular branch or tag.
;; This is required for some packages whose default branch isn't 'master' (which
;; our package manager can't deal with; see radian-software/straight.el#279)
;; (package! builtin-package :recipe (:branch "develop"))

;; Use `:pin' to specify a particular commit to install.
;; (package! builtin-package :pin "1a2b3c4d5e")


;; Doom's packages are pinned to a specific commit and updated from release to
;; release. The `unpin!' macro allows you to unpin single packages...
;; (unpin! pinned-package)
;; ...or multiple packages
;; (unpin! pinned-package another-pinned-package)
;; ...Or *all* packages (NOT RECOMMENDED; will likely break things)
;; (unpin! t)

(package! ace-window)
(package! aidermacs)
(package! attrap)
(package! avy)
(package! boon)
(package! breadcrumb)
;; (package! cape)
;; (package! corfu)
(package! counsel)
(package! catppuccin-theme)
(package! darcsum)
(package! default-text-scale)
(package! dune)
(package! eat)
(package! dash) ;; dependency of elastic-modes
;; (package! elastic-indent
;;   :recipe (:type git :host github :repo "jyp/elastic-modes")
;;   :pin "c577e8921a4d9bd77742729707152bc557fae3e2"
;;   )
;; (package! elastic-table
;;   :recipe (:type git :host github :repo "jyp/elastic-modes")
;;   :pin "c577e8921a4d9bd77742729707152bc557fae3e2"
;;   )
(package! envrc)
(package! flycheck)
;; (package! flyspell)
(package! flyspell-correct)
;; (package! flyspell-correct-helm)
(package! forge)
;; (package! haskell-mode)
;; (package! helm)
;; (package! helm-projectile)
;; (package! helm-rg)
(package! helpful)
;; (package! hindent)
(package! htmlize)
(package! justl)
(package! just-mode)
;; (package! magit)
(package! markdown-mode)
(package! math-symbol-lists)
;; (package! multiple-cursors)
;; (package! nerd-icons-completion)
;; (package! nerd-icons-dired)
(package! nickel-mode)
(package! nix-mode)
(package! opam)
(package! org-modern :disable t)
(package! org-bullets)
(package! ott-mode
  :recipe (:type git :host github :repo "ott-lang/ott" :files ("emacs/*"))
  :pin "fc38245836ef29de862580864fa762163bc87b97"
  )
(package! polymode)
(package! powerline)
(package! rainbow-delimiters)
;; (package! rust-mode)
(package! swiper)
;; (package! terraform-mode)
;; (package! tuareg)
;; (package! typst-mode)
;; (package! ws-butler)
;; (package! yaml-mode)
(package! yasnippet)
