context("Cache invalidation functions")

public({
    clearCache()
    ## Load some stuff into the cache
    with_mock_HTTP({
        GET("https://github.com/")
        GET("https://github.com/nealrichardson/")
        GET("https://github.com/nealrichardson/httpcache/")
        GET("https://github.com/nealrichardson/httr/")
        GET("http://google.com/")
        GET("http://google.co.uk/")
    })
    test_that("Initial cache load", {
        expect_true(setequal(cacheKeys(),
            c("https://github.com/",
            "https://github.com/nealrichardson/",
            "https://github.com/nealrichardson/httpcache/",
            "https://github.com/nealrichardson/httr/",
            "http://google.com/",
            "http://google.co.uk/")))
    })

    dropOnly("https://github.com/nealrichardson/httpcache/")
    test_that("Only that one cache entry was dropped", {
        expect_true(setequal(cacheKeys(),
            c("https://github.com/",
            "https://github.com/nealrichardson/",
            "https://github.com/nealrichardson/httr/",
            "http://google.com/",
            "http://google.co.uk/")))
    })

    dropCache("https://github.com/")
    test_that("That URL and everything below it is cleared", {
        expect_true(setequal(cacheKeys(),
            c("http://google.com/",
            "http://google.co.uk/")))
    })

    dropPattern("uk/$")
    test_that("dropPattern takes arbitrary regular expressions", {
        expect_true(setequal(cacheKeys(),
            c("http://google.com/")))
    })
})
