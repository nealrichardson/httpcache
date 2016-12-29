context("Cache with GET query parameters")

public({
    clearCache()
    base.url <- "https://app.crunch.io/api/users/"
    long.query <- list(query=paste(rep("Q", 10000), collapse=""))
    url.with.query <- paste0(base.url, "?query=", long.query[["query"]])
    test_that("Checking cache even with cache off doesn't fail on long query", {
        with_fake_HTTP({
            expect_GET(z <- uncached(GET(base.url, query=long.query)),
                url.with.query
            )
        })
        expect_identical(z$url, url.with.query)
    })

    clearCache()
    test_that("cache gets set on GET even with long query", {
        with_fake_HTTP({
            expect_GET(GET(base.url, query=long.query), url.with.query)
        })
        expect_true(hitCache(buildCacheKey(base.url, query=long.query)))
    })
    without_internet({
        test_that("Can read cache with query params even with no connection", {
            expect_identical(GET(base.url, query=long.query)$url,
                url.with.query)
        })
        test_that("Caching respects GET query parameters", {
            ## This is a cache miss because the query param is different
            expect_error(GET(base.url, query=list(a=1)))
        })
    })
})
