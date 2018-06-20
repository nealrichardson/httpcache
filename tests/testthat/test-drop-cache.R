context("Cache invalidation functions")

test_that("popQuery", {
    expect_identical(popQuery("https://github.com/nealrichardson/?is=awesome"),
        "https://github.com/nealrichardson/")
})

urls <- c("https://exampleXcom:8080/",
          "https://example.com:8080/",
          "https://exampleeeeeecom:8080/",
          "https://example+com:8080/",
          "https://example.com:8080/?foo=bar",
          "https://example.com:8080foo=bar")
test_that("regexEscape", {
    expect_identical(grep(regexEscape("example.com"), urls), c(2L, 5L, 6L))
    expect_identical(grep(regexEscape("example+com"), urls), 4L)
    expect_identical(grep(regexEscape("example.com:8080/?foo=bar"), urls), 5L)
})



public({
    clearCache()
    ## Load some stuff into the cache

    test_that("Initial cache load", {
        with_fake_http({
            expect_GET(GET("https://github.com/"))
            expect_GET(GET("https://github.com/nealrichardson/"))
            expect_GET(GET("https://github.com/nealrichardson/httpcache/"))
            expect_GET(GET("https://github.com/nealrichardson/httr/"))
            expect_GET(GET("http://google.com/"))
            expect_GET(GET("http://google.co.uk/"))
        })
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
