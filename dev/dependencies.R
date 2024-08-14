# No Remotes ----
# Attachments ----
to_install <- c("attachment", "cli", "fs", "glue", "golem", "htmltools", "purrr", "rlang", "shiny", "shinyjs", "tibble", "usethis")
  for (i in to_install) {
    message(paste("looking for ", i))
    if (!requireNamespace(i, quietly = TRUE)) {
      message(paste("     installing", i))
      install.packages(i)
    }
  }

