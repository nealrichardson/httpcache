Sys.setlocale("LC_COLLATE", "C") # What CRAN does
set.seed(999)
options(warn = 1)

httptest::public({
  cacheKeys <- httpcache:::cacheKeys
  content <- httr::content
})
