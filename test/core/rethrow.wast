;; Test rethrow instruction.

(module
  (tag $e0)
  (tag $e1)

  (func (export "catch-rethrow-0")
    (block $h (result exnref)
      (try
        (do (throw $e0))
        (catch $e0 $h)
      )
      (unreachable)
    )
    (rethrow)
  )

  (func (export "catch-rethrow-1") (param i32) (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do (throw $e0))
        (catch $e0 $h)
      )
      (return)
    )
    (if (param exnref) (i32.eqz (local.get 0))
      (then (rethrow))
      (else (drop))
    )
    (i32.const 23)
  )

  (func (export "catchall-rethrow-0")
    (block $h (result exnref)
      (try (result exnref)
        (do (throw $e0))
        (catch_all $h)
      )
    )
    (rethrow)
  )

  (func (export "catchall-rethrow-1") (param i32) (result i32)
    (block $h (result exnref)
      (try (result i32)
        (do (throw $e0))
        (catch_all $h)
      )
      (return)
    )
    (if (param exnref) (i32.eqz (local.get 0))
      (then (rethrow))
      (else (drop))
    )
    (i32.const 23)
  )

  (func (export "rethrow-nested") (param i32) (result i32)
    (local $exn1 exnref)
    (local $exn2 exnref)
    (block $h1 (result exnref)
      (try (result i32)
        (do (throw $e1))
        (catch $e1 $h1)
      )
      (return)
    )
    (local.set $exn1)
    (block $h2 (result exnref)
      (try (result i32)
        (do (throw $e0))
        (catch $e0 $h2)
      )
      (return)
    )
    (local.set $exn2)
    (if (i32.eq (local.get 0) (i32.const 0))
      (then (rethrow (local.get $exn1)))
    )
    (if (i32.eq (local.get 0) (i32.const 1))
      (then (rethrow (local.get $exn2)))
    )
    (i32.const 23)
  )

  (func (export "rethrow-recatch") (param i32) (result i32)
    (local $e exnref)
    (block $h1 (result exnref)
      (try (result i32)
        (do (throw $e0))
        (catch $e0 $h1)
      )
      (return)
    )
    (local.set $e)
    (block $h2 (result exnref)
      (try (result i32)
        (do
          (if (i32.eqz (local.get 0))
            (then (rethrow (local.get $e)))
          )
          (i32.const 42)
        )
        (catch $e0 $h2)
      )
      (return)
    )
    (drop) (i32.const 23)
  )

  (func (export "rethrow-stack-polymorphism")
    (local $e exnref)
    (block $h (result exnref)
      (try (result f64)
        (do (throw $e0))
        (catch $e0 $h)
      )
      (unreachable)
    )
    (local.set $e)
    (i32.const 1)
    (rethrow (local.get $e))
  )
)

(assert_exception (invoke "catch-rethrow-0"))

(assert_exception (invoke "catch-rethrow-1" (i32.const 0)))
(assert_return (invoke "catch-rethrow-1" (i32.const 1)) (i32.const 23))

(assert_exception (invoke "catchall-rethrow-0"))

(assert_exception (invoke "catchall-rethrow-1" (i32.const 0)))
(assert_return (invoke "catchall-rethrow-1" (i32.const 1)) (i32.const 23))
(assert_exception (invoke "rethrow-nested" (i32.const 0)))
(assert_exception (invoke "rethrow-nested" (i32.const 1)))
(assert_return (invoke "rethrow-nested" (i32.const 2)) (i32.const 23))

(assert_return (invoke "rethrow-recatch" (i32.const 0)) (i32.const 23))
(assert_return (invoke "rethrow-recatch" (i32.const 1)) (i32.const 42))

(assert_exception (invoke "rethrow-stack-polymorphism"))

(assert_invalid (module (func (rethrow))) "type mismatch")
(assert_invalid (module (func (block (rethrow)))) "type mismatch")
