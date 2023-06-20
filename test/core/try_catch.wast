;; Test try-catch blocks.

(module
  (tag $e0 (export "e0"))
  (func (export "throw") (throw $e0))
)

(register "test")

(module
  (tag $imported-e0 (import "test" "e0"))
  (func $imported-throw (import "test" "throw"))
  (tag $e0)
  (tag $e1)
  (tag $e2)
  (tag $e-i32 (param i32))
  (tag $e-f32 (param f32))
  (tag $e-i64 (param i64))
  (tag $e-f64 (param f64))

  (func $throw-if (param i32) (result i32)
    (local.get 0)
    (i32.const 0) (if (i32.ne) (then (throw $e0)))
    (i32.const 0)
  )

  (func (export "simple-throw-catch") (param i32) (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do (local.get 0) (i32.eqz) (if (then (throw $e0)) (else)) (i32.const 42))
        (catch $e0 $h)
      )
      (return)
    )
    (drop) (i32.const 23)
  )

  (func (export "unreachable-not-caught")
    (block $h (result exnref)
      (try (do (unreachable)) (catch_all $h))
      (return)
    )
    (drop)
  )

  (func $div (param i32 i32) (result i32)
    (local.get 0) (local.get 1) (i32.div_u)
  )
  (func (export "trap-in-callee") (param i32 i32) (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do (local.get 0) (local.get 1) (call $div))
        (catch_all $h)
      )
      (return)
    )
    (drop) (i32.const 11)
  )

  (func (export "catch-complex-1") (param i32) (result i32)
    (block $h1 (result exnref)
      (try (result i32)
        (do
          (block $h0 (result exnref)
            (try (result i32)
              (do
                (if (i32.eqz (local.get 0))
                  (then (throw $e0))
                  (else
                    (if (i32.eq (local.get 0) (i32.const 1))
                      (then (throw $e1))
                      (else (throw $e2))
                    )
                  )
                )
                (i32.const 2)
              )
              (catch $e0 $h0)
            )
            (br 1)
          )
          (drop) (i32.const 3)
        )
        (catch $e1 $h1)
      )
      (return)
    )
    (drop) (i32.const 4)
  )

  (func (export "catch-complex-2") (param i32) (result i32)
    (block $h0 (result exnref)
      (block $h1 (result exnref)
        (try (result i32)
          (do
            (if (i32.eqz (local.get 0))
              (then (throw $e0))
              (else
                (if (i32.eq (local.get 0) (i32.const 1))
                  (then (throw $e1))
                  (else (throw $e2))
                )
              )
            )
            (i32.const 2)
          )
          (catch $e0 $h0)
          (catch $e1 $h1)
        )
        (return)
      )
      (return (i32.const 4))
    )
    (drop) (i32.const 3)
  )

  (func (export "throw-catch-param-i32") (param i32) (result i32)
    (block $h (result i32 exnref)
      (try (result i32)
        (do (local.get 0) (throw $e-i32) (i32.const 2))
        (catch $e-i32 $h)
      )
      (return)
    )
    (drop) (return)
  )

  (func (export "throw-catch-param-f32") (param f32) (result f32)
    (block $h (result f32 exnref)
      (try (result f32)
        (do (local.get 0) (throw $e-f32) (f32.const 0))
        (catch $e-f32 $h)
      )
      (return)
    )
    (drop) (return)
  )

  (func (export "throw-catch-param-i64") (param i64) (result i64)
    (block $h (result i64 exnref)
      (try (result i64)
        (do (local.get 0) (throw $e-i64) (i64.const 2))
        (catch $e-i64 $h)
      )
      (return)
    )
    (drop) (return)
  )

  (func (export "throw-catch-param-f64") (param f64) (result f64)
    (block $h (result f64 exnref)
      (try (result f64)
        (do (local.get 0) (throw $e-f64) (f64.const 0))
        (catch $e-f64 $h)
      )
      (return)
    )
    (drop) (return)
  )

  (func $throw-param-i32 (param i32) (local.get 0) (throw $e-i32))
  (func (export "catch-param-i32") (param i32) (result i32)
    (block $h (result i32 exnref)
      (try (result i32)
        (do (i32.const 0) (call $throw-param-i32 (local.get 0)))
        (catch $e-i32 $h)
      )
      (return)
    )
    (drop)
  )

  (func (export "catch-imported") (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do (call $imported-throw (i32.const 1)))
        (catch $imported-e0 $h)
      )
      (return)
    )
    (drop) (i32.const 2)
  )

  (func (export "catchless-try") (param i32) (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do
          (try (result i32)
            (do (call $throw-if (local.get 0)))
          )
        )
        (catch $e0 $h)
      )
      (return)
    )
    (drop) (i32.const 1)
  )

  (func $throw-void (throw $e0))
  (func (export "return-call-in-try-catch")
    (block $h (result exnref)
      (try (result exnref)
        (do (return_call $throw-void))
        (catch $e0 $h)
      )
    )
    (drop)
  )

  (table funcref (elem $throw-void))
  (func (export "return-call-indirect-in-try-catch")
    (block $h (result exnref)
      (try (result exnref)
        (do (return_call_indirect (i32.const 0)))
        (catch $e0 $h)
      )
    )
    (drop)
  )
)

(assert_return (invoke "simple-throw-catch" (i32.const 0)) (i32.const 23))
(assert_return (invoke "simple-throw-catch" (i32.const 1)) (i32.const 42))

(assert_trap (invoke "unreachable-not-caught") "unreachable")

(assert_return (invoke "trap-in-callee" (i32.const 7) (i32.const 2)) (i32.const 3))
(assert_trap (invoke "trap-in-callee" (i32.const 1) (i32.const 0)) "integer divide by zero")

(assert_return (invoke "catch-complex-1" (i32.const 0)) (i32.const 3))
(assert_return (invoke "catch-complex-1" (i32.const 1)) (i32.const 4))
(assert_exception (invoke "catch-complex-1" (i32.const 2)))

(assert_return (invoke "catch-complex-2" (i32.const 0)) (i32.const 3))
(assert_return (invoke "catch-complex-2" (i32.const 1)) (i32.const 4))
(assert_exception (invoke "catch-complex-2" (i32.const 2)))

(assert_return (invoke "throw-catch-param-i32" (i32.const 0)) (i32.const 0))
(assert_return (invoke "throw-catch-param-i32" (i32.const 1)) (i32.const 1))
(assert_return (invoke "throw-catch-param-i32" (i32.const 10)) (i32.const 10))

(assert_return (invoke "throw-catch-param-f32" (f32.const 5.0)) (f32.const 5.0))
(assert_return (invoke "throw-catch-param-f32" (f32.const 10.5)) (f32.const 10.5))

(assert_return (invoke "throw-catch-param-i64" (i64.const 5)) (i64.const 5))
(assert_return (invoke "throw-catch-param-i64" (i64.const 0)) (i64.const 0))
(assert_return (invoke "throw-catch-param-i64" (i64.const -1)) (i64.const -1))

(assert_return (invoke "throw-catch-param-f64" (f64.const 5.0)) (f64.const 5.0))
(assert_return (invoke "throw-catch-param-f64" (f64.const 10.5)) (f64.const 10.5))

(assert_return (invoke "catch-param-i32" (i32.const 5)) (i32.const 5))

(assert_return (invoke "catch-imported") (i32.const 2))

(assert_return (invoke "catchless-try" (i32.const 0)) (i32.const 0))
(assert_return (invoke "catchless-try" (i32.const 1)) (i32.const 1))

(assert_exception (invoke "return-call-in-try-catch"))
(assert_exception (invoke "return-call-indirect-in-try-catch"))

(module
  (func $imported-throw (import "test" "throw"))
  (tag $e0)

  (func (export "imported-mismatch") (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do
          (block $h0 (result exnref)
            (try (result i32)
              (do
                (i32.const 1)
                (call $imported-throw)
              )
              (catch $e0 $h0)
            )
            (return)
          )
          (drop) (i32.const 2)
        )
        (catch_all $h)
      )
      (return)
    )
    (drop) (i32.const 3)
  )
)

(assert_return (invoke "imported-mismatch") (i32.const 3))

(assert_malformed
  (module quote "(module (func (catch_all)))")
  "unexpected token"
)

(assert_malformed
  (module quote "(module (tag $e) (func (catch $e)))")
  "unexpected token"
)

(assert_malformed
  (module quote
    "(module (func (try (do) (catch_all 0) (catch_all 0))))"
  )
  "unexpected token"
)

(assert_invalid
  (module
    (func (result i32) 
      (try (result i32) (do))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (func (result i32)
      (try (result i32) (do (i64.const 42)))
    )
  )
  "type mismatch"
)

(assert_invalid
  (module
    (tag)
    (func
      (try (do) (catch 0 0))
    )
  )
  "type mismatch"
)
(assert_invalid
  (module
    (tag (param i64))
    (func (result i32 exnref)
      (try (result i32) (do (i32.const 42)) (catch 0 0))
    )
  )
  "type mismatch"
)
