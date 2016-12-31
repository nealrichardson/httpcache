context("Cached downloads")

public({
    clearCache()
    test_that("Cache gets set on cachedDownload", {
        testfile <- tempfile()
        expect_length(cacheKeys(), 0)
        expect_false(file.exists(testfile))
        with_fake_HTTP({
            expect_message(a <- cachedDownload("helper.R", testfile),
                "DOWNLOAD helper.R")
        })
        expect_identical(cacheKeys(), "helper.R?DOWNLOAD")
        expect_true(file.exists(testfile))
        expect_identical(readLines(testfile), "helper.R")
        expect_equal(a, 0)
    })

    without_internet({
        test_that("When the cache is set, can read from it even with no connection", {
            ## Now read from cache
            testfile2 <- tempfile()
            expect_no_request(b <- cachedDownload("helper.R", testfile2))
            expect_identical(readLines(testfile2), "helper.R")
            expect_equal(b, 0)
        })
        test_that("But uncached() prevents reading from the cache", {
            expect_error(uncached(cachedDownload("helper.R", testfile2)),
                "DOWNLOAD helper.R")
        })

        test_that("cachedDownloads can have cache invalidated", {
            expect_identical(cacheKeys(), "helper.R?DOWNLOAD")
            dropCache("helper")
            expect_length(cacheKeys(), 0)
        })

        test_that("Can't read from cache if it isn't there anymore", {
            expect_error(cachedDownload("helper.R", testfile2),
                "DOWNLOAD helper.R")
        })
    })
})
