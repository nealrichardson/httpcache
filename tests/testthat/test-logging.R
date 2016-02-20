context("Logging")

test_that("Log", {
    skip("Update these tests")
    with(temp.option(querycache.log=""), {
        msg <- capture.output(z <- crGET(getOption("crunch.api")))
        msg <- strsplit(msg, " ")
        expect_identical(length(msg), 2L)
        expect_identical(msg[[1]][2], "CACHE")
        expect_identical(msg[[1]][3], "HIT")
        expect_identical(msg[[2]][2], "HTTP")
        expect_identical(msg[[2]][3], "GET")
    })
})
