(defsystem "imageboard-test"
  :defsystem-depends-on ("prove-asdf")
  :author "Cherry"
  :license ""
  :depends-on ("imageboard"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "imageboard"))))
  :description "Test system for imageboard"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
