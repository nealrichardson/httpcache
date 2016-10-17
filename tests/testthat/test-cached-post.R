context("cachedPOST")

public({
    clearCache()

    test_that("Cache gets set on cachedPOST", {
        expect_length(cacheKeys(), 0)
        with_mock_HTTP({
            a <- cachedPOST("https://beta.crunch.io/api/")
            b <- cachedPOST("https://beta.crunch.io/api/", body='{"user":"me"}')
        })
        expect_length(cacheKeys(), 2)
        expect_true(setequal(cacheKeys(),
            c("https://beta.crunch.io/api/?POST",
             "https://beta.crunch.io/api/?POST&BODY=aec2de8a85873530777f26424e086337")))
        expect_null(a$response)
        expect_identical(b$response, '{"user":"me"}')
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            ## Now read from cache
            expect_null(cachedPOST("https://beta.crunch.io/api/")$response)
            expect_identical(cachedPOST("https://beta.crunch.io/api/",
                body='{"user":"me"}')$response,
                '{"user":"me"}')
        })
        test_that("But uncached() prevents reading from the cache", {
            expect_error(uncached(cachedPOST("https://beta.crunch.io/api/")),
                "POST https://beta.crunch.io/api/")
            expect_error(uncached(cachedPOST("https://beta.crunch.io/api/",
                body='{"user":"me"}')),
                'POST https://beta.crunch.io/api/ {"user":"me"}',
                fixed=TRUE)
        })
        test_that("GETs don't read from cachedPOST cache", {
            expect_error(uncached(GET("https://beta.crunch.io/api/")),
                "GET https://beta.crunch.io/api/")
        })
        test_that("And POSTs with different payloads don't read the wrong cache", {
            expect_error(cachedPOST("https://beta.crunch.io/api/", body="wrong"),
                "POST https://beta.crunch.io/api/ wrong")
        })
    })
})
