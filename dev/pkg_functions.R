
#  ------------------------------------------------------------------------
#
# Title : `noclocksr` Package Functions
#    By : Jimmy Briggs
#  Date : 2024-08-12
#
#  ------------------------------------------------------------------------

c(
  "utils",
  "utils_html"
) |>
  purrr::walk(usethis::use_r, open = FALSE) |>
  purrr::walk(usethis::use_test, open = FALSE)
