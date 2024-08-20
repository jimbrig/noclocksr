

templates_dir <- here::here("inst/templates/git-hooks")

hook_templates <- c(
  "pre-commit.encryption.template",
  "post-checkout.encryption.template",
  "post-merge.encryption.template"
)

hook_templates |>
  purrr::map_chr(~fs::path(templates_dir, .x)) |>
  purrr::walk(function(x) {
    if (!fs::file_exists(x)) {
      fs::file_create(x)
    }
  }) |>
  purrr::walk(fs::file_chmod, mode = "0744")

r_template <- fs::path(templates_dir, "githooks.R")
if (!fs::file_exists(r_template)) {
  fs::file_create(r_template)
}

r_template |>
  fs::file_read() |>
  stringr::str_c(
    "#' @title\n",
    "#' @description\n",
    "#' @param\n",
    "#' @return\n"
  ) |>
  fs::file_write(r_template)
