context("Autocache requests")

clearCache()

# Get the true GET from httr, not the cache-enabled version from httpcache
# because we're testing that we can inject our cache everywhere.
fun <- function (...) httr::GET(...)

test_that("Cache doesn't get set until we turn it on", {
    expect_length(cacheKeys(), 0)
    with_fake_http({
        expect_GET(a <- fun("https://app.crunch.io/api/datasets"),
            "https://app.crunch.io/api/datasets")
        expect_GET(b <- fun("https://app.crunch.io/api/", query=list(user="me")),
            "https://app.crunch.io/api/?user=me")
    })
    expect_length(cacheKeys(), 0)
})

test_that("When we turn on general caching, all GETs are cached", {
    enable()
    with_fake_http({
        expect_GET(a <- fun("https://app.crunch.io/api/datasets"),
            "https://app.crunch.io/api/datasets")
        expect_GET(b <- fun("https://app.crunch.io/api/", query=list(user="me")),
            "https://app.crunch.io/api/?user=me")
    })
    expect_length(cacheKeys(), 2)
    expect_true(hitCache("https://app.crunch.io/api/datasets"))
    expect_identical(a, getCache("https://app.crunch.io/api/datasets"))
})

without_internet({
    test_that("When the cache is set, can read from it even with no connection", {
        ## Now read from cache
        expect_identical(
            fun("https://app.crunch.io/api/datasets")$url,
            "https://app.crunch.io/api/datasets"
        )
        expect_identical(
            fun("https://app.crunch.io/api/", query=list(user="me"))$url,
            "https://app.crunch.io/api/?user=me"
        )
        ## This one isn't cached though because it has a different querystring
        expect_error(
            fun("https://app.crunch.io/api/", query=list(user="notme")),
            "GET https://app.crunch.io/api/?user=notme",
            fixed=TRUE
        )
    })
    test_that("But uncached() prevents reading from the cache", {
        expect_error(uncached(fun("https://app.crunch.io/api/datasets")),
            "GET https://app.crunch.io/api/datasets")
    })

    disable()
    on.exit(options(httpcache.on=NULL))
    test_that("We can disable caching", {
        expect_error(fun("https://app.crunch.io/api/datasets"),
            "GET https://app.crunch.io/api/datasets")
    })
})

clearCache()

test_that("quietly muffles messages, conditional on httpcache.debug", {
    expect_message(quietly(message("A message!")), NA)
    options(httpcache.debug=TRUE)
    on.exit(options(httpcache.debug=NULL))
    expect_message(quietly(message("A message!")), "A message!")
})
