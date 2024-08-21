#  ------------------------------------------------------------------------
#
# Title : Git Hooks
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------

.clean_git_hook_samples <- function(path = ".git/hooks") {
  sample_files <- fs::dir_ls(
    path = path,
    glob = "*.sample"
  )

  sample_files |>
    purrr::walk(fs::file_delete)

  return(invisible(NULL))
}

# cfg_hooks_init ----------------------------------------------------------


#' Initialize Configuration Encryption Git Hooks
#'
#' @param cfg_file Path to config.yml
#' @param overwrite Overwrite existing hooks
#' @param ... Additional arguments passed to other functions
#'
#' @return NULL
#'
#' @export
#'
#' @importFrom cli cli_alert_danger cli_alert_success cli_abort
#' @importFrom fs dir_create dir_exists file_chmod file_copy file_delete file_exists path path_package path_rel
#' @importFrom here here
#' @importFrom usethis use_template
cfg_hooks_init <- function(
    cfg_file = Sys.getenv("R_CONFIG_FILE", here::here("inst/config/config.yml")),
    overwrite = FALSE,
    ...) {
  usethis:::check_uses_git()

  cfg_file <- fs::path_rel(cfg_file, start = here::here())

  if (!fs::file_exists(cfg_file)) {
    cli::cli_alert_danger("Config file {.file {cfg_file}} does not exist.")
    cli::cli_abort("Run {.code {cfg_init()}} to initialize configuration for this project.")
  }

  cfg_file_encrypted <- .get_encrypted_cfg_file(cfg_file)
  cfg_gitignore_file <- paste0(dirname(cfg_file), "/.gitignore")

  hooks_dir <- fs::path_rel(".git/hooks", here::here())
  templates_dir <- fs::path_package(package = "noclocksr", "templates/git-hooks")

  pre_commit_hook_template <- "git-hooks/pre-commit.encryption.template"
  post_checkout_hook_template <- "git-hooks/post-checkout.encryption.template"
  post_merge_hook_template <- "git-hooks/post-merge.encryption.template"
  r_template <- fs::path(templates_dir, "githooks.R")

  pre_commit_hook <- fs::path(hooks_dir, "pre-commit.encryption")
  post_checkout_hook <- fs::path(hooks_dir, "post-checkout.encryption")
  post_merge_hook <- fs::path(hooks_dir, "post-merge.encryption")
  r_file <- fs::path(hooks_dir, "githooks.R")

  if (!fs::dir_exists(hooks_dir)) {
    fs::dir_create(hooks_dir)
  } else {
    .clean_git_hook_samples(hooks_dir)
    if (overwrite) {
      fs::file_delete(pre_commit_hook)
      fs::file_delete(post_checkout_hook)
      fs::file_delete(post_merge_hook)
      fs::file_delete(r_file)
    }
  }

  if (!fs::file_exists(r_file)) {
    fs::file_copy(r_template, r_file)
    cli::cli_alert_success(
      "Copied {.field {basename(r_template)}} to {.field {hooks_dir}}."
    )
  }

  params <- list(
    cfg_file = fs::path_rel(cfg_file, start = hooks_dir),
    cfg_file_encrypted = fs::path_rel(cfg_file_encrypted, start = hooks_dir),
    cfg_gitignore_file = fs::path_rel(cfg_gitignore_file, start = hooks_dir)
  )

  if (!fs::file_exists(pre_commit_hook)) {
    usethis::use_template(
      pre_commit_hook_template,
      pre_commit_hook,
      data = params,
      package = "noclocksr"
    )
    fs::file_chmod(pre_commit_hook, mode = "0744")
  }

  if (!fs::file_exists(post_checkout_hook)) {
    usethis::use_template(
      post_checkout_hook_template,
      post_checkout_hook,
      data = list(
        cfg_file_encrypted = cfg_file_encrypted
      ),
      package = "noclocksr"
    )
    fs::file_chmod(post_checkout_hook, mode = "0744")
  }

  if (!fs::file_exists(post_merge_hook)) {
    usethis::use_template(
      post_merge_hook_template,
      post_merge_hook,
      data = list(
        cfg_file_encrypted = cfg_file_encrypted
      ),
      package = "noclocksr"
    )
    fs::file_chmod(post_merge_hook, mode = "0744")
  }

  return(invisible(NULL))
}
