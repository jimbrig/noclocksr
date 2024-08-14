
#  ------------------------------------------------------------------------
#
# Title : `noclocksr` R Package Development Script
#    By : Jimmy Briggs
#  Date : 2024-08-12
#
#  ------------------------------------------------------------------------


# development packages ----------------------------------------------------



# initialize package ------------------------------------------------------

usethis::create_package("noclocksr")

usethis::use_namespace()
usethis::use_roxygen_md()

usethis::use_package_doc()
usethis::use_tibble()
usethis::use_import_from("rlang", ".data")
usethis::use_import_from("rlang", ".env")
usethis::use_import_from("rlang", "abort")
usethis::use_import_from("cli", "cli_abort")
usethis::use_import_from("glue", "glue")

usethis::use_author(
  "Jimmy", "Briggs",
  role = c("aut", "cre"),
  email = "jimmy.briggs@noclocks.dev",
  comment = c(ORCID = "0000-0002-7489-8787")
)
usethis::use_author(
  "Patrick", "Howard",
  role = c("aut", "rev"),
  email = "patrick.howard@noclocks.dev",
  comment = c(ORCID = "0000-0000-0000-0000")
)
usethis::use_author(
  "No Clocks, LLC",
  role = c("fnd", "cph"),
  email = "dev@noclocks.dev"
)

usethis::use_dev_version()

desc::desc_normalize()
desc::desc_coerce_authors_at_r()

usethis::use_mit_license("No Clocks, LLC")
usethis::use_proprietary_license("No Clocks, LLC")

usethis::use_git()
usethis::use_github()
usethis::use_github_action()
usethis::use_github_labels()

usethis::use_standalone()

usethis::use_readme_md()

# usethis::use_logo()
# usethis::use_make()
# usethis::use_news_md()
# usethis::use_pkgdown()
# usethis::use_pkgdown_github_pages()
# usethis::use_rmarkdown_template()
# usethis::use_rstudio_preferences()
# usethis::use_template()

c(
  "dev",
  "tools",
  "examples",
  "build",
  "src"
) |>
  purrr::walk(usethis::use_directory, ignore = TRUE)

c(
  "inst",
  "inst/assets",
  "inst/assets/fonts",
  "inst/assets/content",
  "inst/assets/html",
  "inst/assets/scripts",
  "inst/assets/styles",
  "inst/assets/images",
  "inst/templates",
  "inst/examples",
  "inst/config",
  "inst/scripts"
) |>
  purrr::walk(usethis::use_directory)


usethis::use_testthat()
usethis::use_spell_check()

usethis::use_directory("dev", ignore = TRUE)


usethis::use_vignette("noclocksr")
usethis::use_vignette("encryption", title = "Encryption")


usethis::use_testthat()
usethis::use_test("shiny_debug")
