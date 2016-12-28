Sys.setlocale("LC_COLLATE", "C") ## What CRAN does
set.seed(999)
options(warn=1)

public({
    source("helper-mocks.R")
    cacheKeys <- httpcache:::cacheKeys
})
