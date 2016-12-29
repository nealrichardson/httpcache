context("Caching")

test_that("Cache is on by default", {
    expect_true(is.null(getOption("httpcache.on")))
    expect_true(caching())
})
test_that("httpcache.on option affects caching", {
    on.exit(options(httpcache.on=NULL))
    options(httpcache.on=FALSE)
    expect_false(caching())
    options(httpcache.on=TRUE)
    expect_true(caching())
})

public({
    clearCache()

    test_that("Cache gets set on GET", {
        expect_length(cacheKeys(), 0)
        with_fake_HTTP({
            expect_GET(a <- GET("https://app.crunch.io/api/datasets"),
                "https://app.crunch.io/api/datasets")
            expect_GET(b <- GET("https://app.crunch.io/api/", query=list(user="me")),
                "https://app.crunch.io/api/?user=me")
        })
        expect_length(cacheKeys(), 2)
        expect_true(hitCache("https://app.crunch.io/api/datasets"))
        expect_identical(a, getCache("https://app.crunch.io/api/datasets"))
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            ## Now read from cache
            expect_identical(GET("https://app.crunch.io/api/datasets")$url,
                "https://app.crunch.io/api/datasets")
        })
        test_that("But uncached() prevents reading from the cache", {
            expect_error(uncached(GET("https://app.crunch.io/api/datasets")),
                "GET https://app.crunch.io/api/datasets")
        })
    })

    test_that("PUT busts cache", {
        ## Now bust cache
        with_fake_HTTP({
            expect_PUT(PUT("https://app.crunch.io/api/datasets"),
                "https://app.crunch.io/api/datasets")
        })
        ## See that it's no longer in the cache
        expect_length(cacheKeys(), 1)
        without_internet({
            expect_error(GET("https://app.crunch.io/api/datasets"),
                "GET https://app.crunch.io/api/datasets")
        })
    })

    test_that("PATCH busts cache", {
        without_internet({
            ## It's in the cache
            expect_no_request(q <- GET("https://app.crunch.io/api/",
                query=list(user="me")))
            expect_identical(q$url, "https://app.crunch.io/api/?user=me")
            ## Hey, let's try with the cache API
            expect_identical(getCache(buildCacheKey("https://app.crunch.io/api/",
                query=list(user="me"))), q)
        })
        ## Now bust cache
        with_fake_HTTP({
            expect_PATCH(PATCH("https://app.crunch.io/api/"),
                "https://app.crunch.io/api/")
        })
        ## See that it's no longer in the cache
        expect_length(cacheKeys(), 0)
        without_internet({
            expect_GET(GET("https://app.crunch.io/api/", query=list(user="me")),
                "https://app.crunch.io/api/?user=me")
        })
    })

    test_that("POST busts cache more narrowly by default: setup", {
        with_fake_HTTP({
            expect_GET(a <<- GET("https://app.crunch.io/api/datasets"),
                "https://app.crunch.io/api/datasets")
            expect_GET(b <<- GET("https://app.crunch.io/api/", query=list(user="me")),
                "https://app.crunch.io/api/?user=me")
        })
    })
    without_internet({
        test_that("See that cache is set", {
            ## Now read from cache
            expect_no_request(
                expect_identical(GET("https://app.crunch.io/api/datasets"),
                    a)
            )
            expect_no_request(
                expect_identical(GET("https://app.crunch.io/api/",
                    query=list(user="me")), b)
            )
        })
    })
    with_fake_HTTP({
        test_that("POSTing to a different resource doesn't bust cache", {
            expect_POST(p1 <- POST("https://app.crunch.io/api/"),
                "https://app.crunch.io/api/")
        })
    })
    without_internet({
        test_that("Cache was unaffected by that", {
            ## Now read from cache
            expect_no_request(
                expect_identical(GET("https://app.crunch.io/api/datasets"),
                    a)
            )
            expect_no_request(
                expect_identical(GET("https://app.crunch.io/api/",
                    query=list(user="me")), b)
            )
        })
    })
    with_fake_HTTP({
        test_that("POSTing busts cache narrowly", {
            expect_POST(p2 <- POST("https://app.crunch.io/api/datasets"),
                "https://app.crunch.io/api/datasets")
        })
    })
    without_internet({
        test_that("Only that resource had its cache busted", {
            expect_GET(GET("https://app.crunch.io/api/datasets"),
                "https://app.crunch.io/api/datasets")
            expect_no_request(
                expect_identical(GET("https://app.crunch.io/api/",
                    query=list(user="me")), b)
            )
        })
    })

    test_that("cacheOff stops caching and clears existing cache", {
        clearCache() ## So we're clean
        with_fake_HTTP({
            expect_GET(GET("https://app.crunch.io/api/datasets"))
        })
        expect_length(cacheKeys(), 1)
        cacheOff()
        on.exit(cacheOn()) ## Turn it back on
        expect_length(cacheKeys(), 0)
        with_fake_HTTP({
            expect_GET(a <- GET("https://app.crunch.io/api/datasets"))
        })
        expect_length(cacheKeys(), 0)
        expect_identical(a$url, "https://app.crunch.io/api/datasets")
    })

    test_that("Requests with an invalid URL return a useful error", {
        expect_error(GET(NULL), "Invalid URL: NULL")
        expect_error(cachedPOST(table(1:5)),
            "Invalid URL: structure(c(1L, 1L, 1L, 1L, 1L), .Dim = 5L, .Dimnames = structure(list(",
            fixed=TRUE)
        setClass("TestS4Obj", contains="environment")
        expect_error(cachedDownload(new("TestS4Obj")),
            'Invalid URL: <S4 object of class structure("TestS4Obj", package = ".GlobalEnv")>',
            fixed=TRUE)
    })
})
