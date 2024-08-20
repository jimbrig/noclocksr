"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

if_unquiet <- function(expr) {
  opt <- getOption("noclocks.quiet", getOption("usethis.quiet", default = FALSE))

  if (!opt) {
    force(expr)
  }
}
