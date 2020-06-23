(lang dune 2.6)

(name finch)

(version 0.1)

(source
 (github roddyyaga/finch))

(documentation "https://roddyyaga.github.io/finch")

(license MIT)

(authors "Roddy MacSween <github@roddymacsween.co.uk>")

(maintainers "Roddy MacSween <github@roddymacsween.co.uk>")

(generate_opam_files true)

(package
 (name finch)
 (synopsis "Simple and fast site generator")
 (depends
  dune
  core
  (ppx_let
   (>= "v0.12"))
  omd
  yaml
  (jingoo
   (>= "1.4.0"))))
