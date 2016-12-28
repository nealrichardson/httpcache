context("Various helper functions")

test_that("currently_offline", {
    with_fake_HTTP({
        expect_false(currently_offline("http://example.com/"))
    })
    without_internet({
        expect_true(currently_offline("http://example.com/"))
    })
})

## Putting this here just so covr runs it. It obviously does, but not in the
## test suite
try(initCache(), silent=TRUE)
