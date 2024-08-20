
#  ------------------------------------------------------------------------
#
# Title : Minification Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-17
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------

.minify_languages <- c(
  "html",
  "css",
  "js",
  "json"
)

.minify_req <- function(lang, code) {

  base_url <- "https://www.toptal.com/developers/jsmin/api/minify"

  req <- httr2::request(base_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/x-www-form-urlencoded"
    ) |>
    httr2::req_body_form(
      input = paste(code, collapse = "\n")
    )

  res <- httr2::req_perform(req) |>
    httr2::resp_check_status()

  res |> httr2::resp_body_string()

}

# minify_css -------------------------------------------------------------

#' Minify CSS
#'
#' @description
#' Minify CSS
#'
#' @param css A character vector of CSS code
#'
#' @return A character vector of minified CSS code
#'
#' @export
minify_css <- function(css) {

  base_url <- "https://www.toptal.com/developers/cssminifier/api/raw"

  req <- httr2::request(base_url) |>
    httr2::req_method("POST") |>
    httr2::req_headers(
      "Content-Type" = "application/x-www-form-urlencoded"
    ) |>
    httr2::req_body_form(
      input = paste(css, collapse = "\n")
    )

  res <- httr2::req_perform(req) |>
    httr2::resp_check_status()

  res |> httr2::resp_body_string()
}
