context("Valid year parameter")
library(fars)

test_that("Test that fars_summarize_years() throws an error if file doesn't exist for year supplied", {
  expect_error(object = fars_summarize_years(2027))
  #expect_error(object = fars_summarize_years(2027), regexp = "Column `year` is unknown")
  #expect_warning(object = fars_summarize_years(2027))
  #expect_error(object = fars_summarize_years(2027))
})
