context("Caching")

clearCache()
test_that("Cache gets set on GET", {
    expect_identical(length(ls(envir=cache)), 0L)
    with_mock_HTTP({
        a <- GET("https://beta.crunch.io/api/datasets")
        b <- GET("https://beta.crunch.io/api/", query=list(user="me"))
    })
    expect_identical(length(ls(envir=cache)), 2L)
    expect_true("https://beta.crunch.io/api/datasets" %in% ls(envir=cache))
    expect_identical(a$response, 35L)
})

test_that("When the cache is set, can read from it even with no connection", {
    ## Now read from cache
    without_internet({
        expect_identical(GET("https://beta.crunch.io/api/datasets")$response,
            35L)
    })
})

test_that("PUT busts cache", {
    ## Now bust cache
    with_mock_HTTP({
        expect_message(PUT("https://beta.crunch.io/api/datasets"),
            "PUT https://beta.crunch.io/api/datasets ")
    })
    ## See that it's no longer in the cache
    expect_identical(length(ls(envir=cache)), 1L)
    without_internet({
        expect_error(GET("https://beta.crunch.io/api/datasets"),
            "GET https://beta.crunch.io/api/datasets")
    })
})

test_that("PATCH busts cache", {
    without_internet({
        ## It's in the cache
        expect_identical(GET("https://beta.crunch.io/api/",
            query=list(user="me"))$response, 27L)
    })
    ## Now bust cache
    with_mock_HTTP({
        expect_message(PATCH("https://beta.crunch.io/api/"),
            "PATCH https://beta.crunch.io/api/ ")
    })
    ## See that it's no longer in the cache
    expect_identical(length(ls(envir=cache)), 0L)
    without_internet({
        expect_error(GET("https://beta.crunch.io/api/", query=list(user="me")),
            "GET https://beta.crunch.io/api/")
    })
})

clearCache()
test_that("Checking cache even with cache off doesn't fail on long query", {
    uncached({
        with_mock_HTTP({
            z <- GET("https://beta.crunch.io/api/users/",
                query=list(query=rep("Q", 10000)))
        })
    })
    expect_true(is.numeric(z$response))
})

clearCache()
test_that("cache gets set on GET even with long query", {
    with_mock_HTTP({
        GET("https://beta.crunch.io/api/users/",
            query=list(query=rep("Q", 10000)))
    })
    expect_identical(ls(envir=cache),
        "https://beta.crunch.io/api/users/?HASHED_QUERY=38f0ed36c36e7c08ad375cc9a48d1364")
})
without_internet({
    test_that("Can read cache with query params even with no connection", {
        expect_identical(GET("https://beta.crunch.io/api/users/",
            query=list(query=rep("Q", 10000)))$response,
            33L)
    })
    test_that("Caching respects GET query parameters", {
        ## This is a cache miss because the query param is different
        expect_error(GET("https://beta.crunch.io/api/users/",
            query=list(a=1)))
    })
})

test_that("cacheOff stops caching and clears existing cache", {
    expect_identical(length(ls(envir=cache)), 1L)
    cacheOff()
    on.exit(cacheOn()) ## Turn it back on
    expect_identical(length(ls(envir=cache)), 0L)
    with_mock_HTTP({
        a <- GET("https://beta.crunch.io/api/datasets")
    })
    expect_identical(length(ls(envir=cache)), 0L)
    expect_identical(a$response, 35L)
})
