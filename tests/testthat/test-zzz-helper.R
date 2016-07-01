context("Various helper functions")

test_that("currently_offline", {
    with_mock_HTTP({
        expect_false(currently_offline("http://example.com/"))
    })
    without_internet({
        expect_true(currently_offline("http://example.com/"))
    })
})

test_that("Functions not exported can be found", {
    expect_true(.internalFunction())
})

public({
    test_that("If a function is not exported, the public test context errors", {
        expect_error(.internalFunction(),
            'could not find function ".internalFunction"')
    })
})

## Putting this here just so covr runs it. It obviously does, but not in the
## test suite
try(initCache(), silent=TRUE)
