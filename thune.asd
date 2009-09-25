(asdf:defsystem :thune
  :description "A straightforward IRC bot."
  :depends-on (:ircl :cl-fad :split-sequence :montezuma)
  :components
  ((:file "util")
   (:file "handler")
   (:file "conf" :depends-on ("util"))
   (:file "thune" :depends-on ("conf" "handler"))
   (:file "command" :depends-on ("conf" "handler" "thune" "util"))
   (:module "handlers"
            :depends-on ("conf" "handler" "thune" "util")
            :components
            ((:file "autojoin")))
   (:module "commands"
            :depends-on ("command")
            :components
            ((:file "misc")
             (:file "admin")))))