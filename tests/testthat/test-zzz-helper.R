context("Various helper functions")

public({
    test_that("If a function is not exported, the public test context errors", {
        expect_error(caching(),
            'could not find function "caching"')
    })
})

## Putting this here just so covr runs it. It obviously does, but not in the
## test suite
try(initCache(), silent=TRUE)
