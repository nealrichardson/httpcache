context("Various helper functions")

test_that("is.error", {
    e <- try(halt("error in a box"), silent=TRUE)
    expect_true(is.error(e))
    expect_false(is.error("not an error"))
    expect_false(is.error(NULL))
    expect_false(is.error(NA))
})

test_that("%||%", {
    expect_identical("f" %||% "g", "f")
    expect_identical(NULL %||% "g", "g")
    expect_identical("f" %||% halt("Nooooooo!"), "f")
})
