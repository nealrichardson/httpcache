context("Logging")

logfile <- tempfile()
startLog(logfile)

with_mock_HTTP({
    GET("https://github.com/")
    GET("https://github.com/nealrichardson/")
    try(halt("Panic!"), silent=TRUE)
    GET("https://github.com/nealrichardson/httpcache/")
    GET("https://github.com/nealrichardson/")
    suppressMessages(POST("https://github.com/nealrichardson/"))
    GET("https://github.com/nealrichardson/")
})

loglines <- readLines(logfile)
logdf <- loadLogfile(logfile)
cache.summary <- cacheLogSummary(logdf)
req.summary <- requestLogSummary(logdf)

test_that("Log writes to file", {
    expect_identical(length(loglines), 12L)
    expect_equivalent(logdf[,2:4], data.frame(
        scope=c("HTTP", "CACHE", "HTTP", "CACHE", "HTTP", "CACHE", "CACHE",
                "HTTP", "CACHE", "HTTP", "CACHE"),
        verb=c("GET", "SET", "GET", "SET", "GET", "SET", "HIT",
                "POST", "DROP", "GET", "SET"),
        url=c(rep("https://github.com/", 2),
            rep("https://github.com/nealrichardson/", 2),
            rep("https://github.com/nealrichardson/httpcache/", 2),
            rep("https://github.com/nealrichardson/", 5)),
        stringsAsFactors=FALSE))
    expect_equivalent(cache.summary, list(
            counts=structure(c(1L, 1L, 4L), .Names=c("DROP", "HIT", "SET"), class="table"),
            hit.rate=c(HIT=20)
        ))
    expect_equivalent(req.summary$req.time, 166)
})

pruneTimestamp <- function (entry) substr(entry, 21, nchar(entry))

test_that("startLog appending", {
    startLog(logfile, append=TRUE)
    with_mock_HTTP({
        DELETE("https://github.com/nealrichardson/not_a_real_repo/")
    })
    loglines2 <- readLines(logfile)
    expect_identical(length(loglines2), 14L)
    expect_identical(loglines2[1:12], loglines)
    expect_identical(pruneTimestamp(loglines2[13]),
        "HTTP DELETE https://github.com/nealrichardson/not_a_real_repo/ 204 50 ")
    expect_identical(pruneTimestamp(loglines2[14]),
        "CACHE DROP ^https://github.com/nealrichardson/not_a_real_repo/ ")
})

test_that("startLog overwrites log file if exists (by default)", {
    startLog(logfile)
    with_mock_HTTP({
        GET("https://github.com/")
    })
    expect_identical(pruneTimestamp(readLines(logfile)),
        "CACHE HIT https://github.com/ ")
})
