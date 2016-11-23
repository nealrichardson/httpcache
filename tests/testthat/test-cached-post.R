context("cachedPOST")

public({
    clearCache()
    test_that("Cache gets set on cachedPOST", {
        expect_length(cacheKeys(), 0)
        with_mock_HTTP({
            a <- cachedPOST("https://app.crunch.io/api/")
            b <- cachedPOST("https://app.crunch.io/api/", body='{"user":"me"}')
        })
        expect_length(cacheKeys(), 2)
        expect_true(setequal(cacheKeys(),
            c("https://app.crunch.io/api/?POST",
             "https://app.crunch.io/api/?POST&BODY=aec2de8a85873530777f26424e086337")))
        expect_identical(content(a), "https://app.crunch.io/api/")
        expect_identical(content(b), '{"user":"me"}')
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            ## Now read from cache
            expect_identical(content(cachedPOST("https://app.crunch.io/api/")),
                "https://app.crunch.io/api/")
            expect_identical(content(cachedPOST("https://app.crunch.io/api/",
                body='{"user":"me"}')),
                '{"user":"me"}')
        })
        test_that("But uncached() prevents reading from the cache", {
            expect_error(uncached(cachedPOST("https://app.crunch.io/api/")),
                "POST https://app.crunch.io/api/")
            expect_error(uncached(cachedPOST("https://app.crunch.io/api/",
                body='{"user":"me"}')),
                'POST https://app.crunch.io/api/ {"user":"me"}',
                fixed=TRUE)
        })
        test_that("GETs don't read from cachedPOST cache", {
            expect_error(uncached(GET("https://app.crunch.io/api/")),
                "GET https://app.crunch.io/api/")
        })
        test_that("And POSTs with different payloads don't read the wrong cache", {
            expect_error(cachedPOST("https://app.crunch.io/api/", body="wrong"),
                "POST https://app.crunch.io/api/ wrong")
        })
    })
})
