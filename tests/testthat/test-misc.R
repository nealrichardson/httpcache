context("Various helper functions")

test_that("%||%", {
    expect_identical("f" %||% "g", "f")
    expect_identical(NULL %||% "g", "g")
    expect_identical("f" %||% halt("Nooooooo!"), "f")
})

## Putting this here just so covr runs it. It obviously does, but not in the
## test suite
try(initCache(), silent=TRUE)
