context("Cache with GET query parameters")

public({
    clearCache()
    long.query <- list(query=paste(rep("Q", 10000), collapse=""))
    test_that("Checking cache even with cache off doesn't fail on long query", {
        uncached({
            with_mock_HTTP({
                z <- GET("https://app.crunch.io/api/users/", query=long.query)
            })
        })
        expect_identical(content(z), long.query)
    })

    clearCache()
    test_that("cache gets set on GET even with long query", {
        with_mock_HTTP({
            GET("https://app.crunch.io/api/users/", query=long.query)
        })
        expect_true(hitCache(buildCacheKey("https://app.crunch.io/api/users/",
            query=long.query)))
    })
    without_internet({
        test_that("Can read cache with query params even with no connection", {
            expect_identical(content(GET("https://app.crunch.io/api/users/",
                query=long.query)), long.query)
        })
        test_that("Caching respects GET query parameters", {
            ## This is a cache miss because the query param is different
            expect_error(GET("https://app.crunch.io/api/users/",
                query=list(a=1)))
        })
    })
})
