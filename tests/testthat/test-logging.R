context("Logging")

public({
    logfile <- tempfile()
    startLog(logfile)

    test_that("Warming the cache and log", {
        with_fake_http({
            expect_GET(GET("https://github.com/"))
            expect_GET(GET("https://github.com/nealrichardson/"))
            try(halt("Panic!"), silent=TRUE)
            expect_GET(GET("https://github.com/nealrichardson/httpcache/"))
            expect_no_request(GET("https://github.com/nealrichardson/")) ## Cache hit
            expect_GET(GET("https://github.com/nealrichardson/",
                query=list(q=1)))
            expect_PUT(PUT("https://github.com/nealrichardson/"))
            expect_GET(GET("https://github.com/nealrichardson/"))
        })
    })

    loglines <- readLines(logfile)
    logdf <- loadLogfile(logfile)
    cache.summary <- cacheLogSummary(logdf)
    req.summary <- requestLogSummary(logdf)

    test_that("Log writes to file", {
        expect_length(loglines, 14)
        expect_equivalent(logdf[,2:4], data.frame(
            scope=c("HTTP", "CACHE", "HTTP", "CACHE", "HTTP", "CACHE", "CACHE",
                    "HTTP", "CACHE", "HTTP", "CACHE", "HTTP", "CACHE"),
            verb=c("GET", "SET", "GET", "SET", "GET", "SET", "HIT",
                    "GET", "SET", "PUT", "DROP", "GET", "SET"),
            url=c(rep("https://github.com/", 2),
                rep("https://github.com/nealrichardson/", 2),
                rep("https://github.com/nealrichardson/httpcache/", 2),
                "https://github.com/nealrichardson/",
                "https://github.com/nealrichardson/?q=1",
                buildCacheKey("https://github.com/nealrichardson/", query=list(q=1)),
                "https://github.com/nealrichardson/",
                "^https://github[.]com/nealrichardson/",
                rep("https://github.com/nealrichardson/", 2)),
            stringsAsFactors=FALSE))
        expect_false(any(is.na(logdf$timestamp)))
        expect_equivalent(cache.summary, list(
                counts=structure(c(1L, 1L, 5L),
                    .Names=c("DROP", "HIT", "SET"), class="table"),
                hit.rate=c(HIT=100/6)
            ))
        expect_equivalent(req.summary$req.time, 203)
    })

    pruneTimestamp <- function (entry) substr(entry, 25, nchar(entry))

    test_that("startLog appending", {
        startLog(logfile, append=TRUE)
        with_fake_http({
            DELETE("https://github.com/nealrichardson/not_a_real_repo/")
        })
        loglines2 <- readLines(logfile)
        expect_length(loglines2, 16)
        expect_identical(loglines2[1:14], loglines)
        expect_identical(pruneTimestamp(loglines2[15]),
            "HTTP DELETE https://github.com/nealrichardson/not_a_real_repo/ 204 NA 0 0 0 0 0 50")
        expect_identical(pruneTimestamp(loglines2[16]),
            "CACHE DROP ^https://github[.]com/nealrichardson/not_a_real_repo/")
    })

    test_that("startLog overwrites log file if exists (by default)", {
        startLog(logfile)
        with_fake_http({
            GET("https://github.com/")
        })
        expect_identical(pruneTimestamp(readLines(logfile)),
            "CACHE HIT https://github.com/")
        logdf <- loadLogfile(logfile)
        expect_true(is.data.frame(logdf))
        expect_identical(dim(logdf), c(1L, 4L))
    })

    test_that("httr integration + cache behavior + logging to stdout", {
        skip_if_disconnected()
        startLog("") ## Log to stdout
        logs <- capture.output({
            a <- GET("http://httpbin.org/get")
            b <- GET("http://httpbin.org/get")
        })
        expect_identical(grep("HTTP GET", logs), 1L)
        expect_identical(grep("CACHE HIT", logs), 3L)
        ## Check the content returned from httpbin
        expect_true(grepl("httr", httr::content(a)$headers[["User-Agent"]]))
        ## And that the cache returns the same
        expect_true(grepl("httr", httr::content(b)$headers[["User-Agent"]]))
    })
})

## Turn logging off so other tests aren't affected!
options(httpcache.log=NULL)
