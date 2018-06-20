context("cachedPOST")

public({
    clearCache()
    test_that("Cache gets set on cachedPOST", {
        expect_length(cacheKeys(), 0)
        with_fake_http({
            expect_POST(a <<- cachedPOST("https://app.crunch.io/api/"),
                "https://app.crunch.io/api/")
            expect_POST(b <<- cachedPOST("https://app.crunch.io/api/",
                body='{"user":"me"}'),
                'https://app.crunch.io/api/ {"user":"me"}')
        })
        expect_length(cacheKeys(), 2)
        expect_true(setequal(cacheKeys(),
            c("https://app.crunch.io/api/?POST",
             "https://app.crunch.io/api/?POST&BODY=aec2de8a85873530777f26424e086337")))
        expect_identical(a$url, "https://app.crunch.io/api/")
        expect_identical(content(b), list(user="me"))
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            ## Now read from cache
            expect_no_request(
                expect_identical(cachedPOST("https://app.crunch.io/api/"), a)
            )
            expect_no_request(
                expect_identical(cachedPOST("https://app.crunch.io/api/",
                    body='{"user":"me"}'), b)
            )
        })
        test_that("But uncached() prevents reading from the cache", {
            uncached({
                expect_POST(cachedPOST("https://app.crunch.io/api/"),
                    "https://app.crunch.io/api/")
                expect_POST(cachedPOST("https://app.crunch.io/api/",
                    body='{"user":"me"}'),
                    'https://app.crunch.io/api/ {"user":"me"}')
            })
        })
        test_that("GETs don't read from cachedPOST cache", {
            expect_GET(uncached(GET("https://app.crunch.io/api/")),
                "https://app.crunch.io/api/")
        })
        test_that("And POSTs with different payloads don't read the wrong cache", {
            expect_POST(cachedPOST("https://app.crunch.io/api/", body="wrong"),
                "https://app.crunch.io/api/ wrong")
        })
    })
})
