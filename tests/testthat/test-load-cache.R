context("Saving and loading cache")

public({
    clearCache()
    test_that("Cache gets set on GET", {
        expect_length(cacheKeys(), 0)
        with_mock_HTTP({
            a <- GET("https://beta.crunch.io/api/datasets")
            b <- GET("https://beta.crunch.io/api/", query=list(user="me"))
        })
        expect_length(cacheKeys(), 2)
        expect_true(hitCache("https://beta.crunch.io/api/datasets"))
        expect_identical(a$response, 35L)
        expect_identical(a, getCache("https://beta.crunch.io/api/datasets"))
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            expect_identical(GET("https://beta.crunch.io/api/datasets")$response,
                35L)
        })

        f <- tempfile()
        saveCache(f)
        clearCache()
        test_that("Cache is now empty", {
            expect_length(cacheKeys(), 0)
            expect_error(GET("https://beta.crunch.io/api/datasets"),
                "GET https://beta.crunch.io/api/datasets")
        })

        test_that("Can load cache and read from it as before", {
            loadCache(f)
            ## Now read from cache
            expect_identical(GET("https://beta.crunch.io/api/datasets")$response,
                35L)
        })
    })

    test_that("loadCache error handling", {
        f2 <- tempfile()
        a <- 1
        saveRDS(a, file=f2)
        expect_error(loadCache(f2),
            "'loadCache' requires an .rds file containing an environment")
    })
})
