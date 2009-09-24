(asdf:defsystem :thune
  :description "A straightforward IRC bot."
  :depends-on (:ircl :cl-fad :split-sequence)
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
            :componenets
            ((:file "misc")))))