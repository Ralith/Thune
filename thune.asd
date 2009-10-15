(asdf:defsystem :thune
  :description "A straightforward IRC bot."
  :depends-on (#:ircl #:cl-fad #:split-sequence #:montezuma #:drakma #:chanl #:closure-html #:xmls)
  :components
  ((:file "package")
   (:file "util" :depends-on ("package"))
   (:file "handler" :depends-on ("package"))
   (:file "conf" :depends-on ("util" "package"))
   (:file "thune" :depends-on ("conf" "handler" "package"))
   (:file "command" :depends-on ("conf" "handler" "thune" "util" "package"))
   (:module "handlers"
            :depends-on ("conf" "handler" "thune" "util" "package")
            :components
            ((:file "autojoin")
             (:file "combo")
             (:file "revenge")
             (:file "seen")
             (:file "nickserv-auth")
             (:file "fts-logger")
             (:file "nick-track")))
   (:module "commands"
            :depends-on ("command" "package" "handlers")
            :components
            ((:file "misc")
             (:file "admin")
             (:file "help")
             (:file "seen")
             (:file "log-search")
             (:file "google")
             (:file "weather")))))
