#  ------------------------------------------------------------------------
#
# Title : Initialize Configuration
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------


# cfg_init ----------------------------------------------------------------

#' Initialize Configuration Setup
#'
#' @description
#' This function initializes the configuration setup by creating the configuration file,
#' encrypted configuration file, and configuration template file.
#'
#' It also sets the `R_CONFIG_FILE` environment variable to the path of the configuration file.
#'
#' @details
#' The `cfg_init()` function creates the following files:
#' - `config.yml`: The configuration file containing the configuration settings.
#' - `config.encrypted.yml`: The encrypted configuration file.
#' - `config.template.yml`: The configuration template file.
#' - `.gitignore`: The gitignore file to ignore the configuration files.
#' - `README.md`: The README file with instructions on how to use the configuration files.
#'
#' @param path Path to the configuration directory. Defaults to `inst/config`.
#' @param cfg A list of configuration settings. Defaults to an empty list.
#' @param cfg_file Path to the configuration file. Defaults to `config.yml`.
#' @param cfg_file_encrypted Path to the encrypted configuration file. Defaults to `config.encrypted.yml`.
#' @param cfg_file_template Path to the configuration template file. Defaults to `config.template.yml`.
#' @param encryption_key_name The name of the environment variable that contains the encryption key.
#'   Defaults to `NOCLOCKS_ENCRYPTION_KEY`.
#' @param overwrite Overwrite the existing configuration files. Defaults to `FALSE`.
#' @param symlink Create a symlink to the configuration file. Defaults to `TRUE`.
#' @param ... Additional arguments passed to other functions.
#'
#' @return Invisibly returns the configuration settings.
#'
#' @seealso [config::get()]
#'
#' @export
#'
#' @importFrom fs dir_create dir_exists file_exists file_move link_create path path_abs path_ext_remove
#' @importFrom yaml write_yaml
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom rlang abort
#' @importFrom glue glue
#' @importFrom purrr map map_chr
#' @importFrom config get
#' @importFrom usethis use_git_ignore
cfg_init <- function(
    path = here::here("inst/config"),
    cfg = list(default = list(NULL)),
    cfg_file = "config.yml",
    cfg_file_encrypted = "config.encrypted.yml",
    cfg_file_template = "config.template.yml",
    encryption_key_name = "NOCLOCKS_ENCRYPTION_KEY",
    overwrite = FALSE,
    symlink = TRUE,
    ...) {
  cfg_dir <- fs::path(path)
  if (!fs::dir_exists(cfg_dir)) {
    fs::dir_create(cfg_dir)
  }

  validate_cfg(cfg)

  cfg_file <- fs::path(path, cfg_file)
  cfg_file_encrypted <- fs::path(path, cfg_file_encrypted)
  cfg_file_template <- fs::path(path, cfg_file_template)

  if (fs::file_exists(cfg_file) && !overwrite) {
    cli::cli_abort("Config file {.file {cfg_file}} already exists.")
  } else {
    yaml::write_yaml(cfg, cfg_file)
    cli::cli_alert_success("Successfully created the config file: {.file {cfg_file}}")
  }

  if (fs::file_exists(cfg_file_encrypted) && !overwrite) {
    cli::cli_abort("Encrypted config file {.file {cfg_file_encrypted}} already exists.")
  } else {
    encrypt_cfg_file(cfg_file, encryption_key_name)
  }

  if (fs::file_exists(cfg_file_template) && !overwrite) {
    cli::cli_abort("Config file template {cfg_file_template} already exists.")
  } else {
    cfg_template <- create_cfg_template(cfg_file, cfg_file_template)
    cli::cli_alert_success("Successfully created the config file template: {.file {cfg_file_template}}")
  }

  ignores <- c(
    "*",
    "!.gitignore",
    "!*.encrypted.yml",
    "!*.template.yml",
    "!*.md",
    "!*.R",
    "!config.d/"
  )

  usethis::use_git_ignore(
    ignores,
    directory = fs::path_rel(cfg_dir, here::here())
  )

  cli::cli_alert_success("Setup gitignore for config.")

  # test that can decrypt
  cfg_file_backup <- fs::path_ext_remove(cfg_file) |>
    paste0(".backup.yml") |>
    fs::path()
  if (fs::file_exists(cfg_file_backup)) {
    fs::file_delete(cfg_file_backup)
  }
  fs::file_move(cfg_file, cfg_file_backup)
  decrypt_cfg_file(cfg_file_encrypted)

  Sys.setenv("R_CONFIG_FILE" = cfg_file)
  cli::cli_alert_info("Set `R_CONFIG_FILE` to: {.file {cfg_file}}")

  if (symlink) {
    cfg_from <- cfg_file |> normalizePath()
    cfg_link <- file.path(here::here(), "config.yml") |> normalizePath(mustWork = FALSE)

    if (.Platform$OS.type == "windows") {
      cmd <- paste0("cmd.exe /c mklink ", cfg_link, " ", cfg_from)
      cli::cli_alert_info("Running command to setup symlink: {.code {cmd}}")
      system(cmd, intern = TRUE)
    } else {
      fs::link_create(cfg_file, cfg_link, symbolic = TRUE)
    }
  }

  return(invisible(config::get()))
}

# cfg_d_init --------------------------------------------------------------

#' Configuration Sub-Directory Initialization
#'
#' @description
#' This function initializes the configuration sub-directory setup by creating
#' a sub-directory: `config.d/` in the root `config/` directory to house
#' configuration files for different environments or purposes that can be
#' merged together.
#'
#' @param path Path to the configuration directory. Defaults to `inst/config`.
#' @param configs A list of configuration lists for different environments or purposes.
#'   The list should contain named lists of configuration settings where the
#'   names represent what will be used for the name of the configuration file.
#'   See details for more information and examples.
#' @param ignore Add a `.gitignore` to the `config.d/` directory to ignore the
#'   generated configuration files? Default is `TRUE`.
#' @param overwrite Overwrite the existing configuration files. Defaults to `FALSE`.
#' @param merge Merge the configuration files from the `config.d/` directory into
#'  the `config.yml` file? Defaults to `TRUE`.
#' @param templates Create configuration template files for each configuration file?
#'   Defaults to `FALSE`.
#' @param include_encrypted Create encrypted configuration files for each configuration file?
#'   Defaults to `FALSE`.
#' @param ... Additional arguments passed to other functions.
#'
#' @return Invisibly returns the merged configuration settings.
#'
#' @seealso [cfg_init()] and [config::merge()]
#'
#' @export
#'
#' @importFrom fs dir_create dir_exists file_exists path path_ext_remove path_rel
#' @importFrom yaml write_yaml
#' @importFrom cli cli_alert_success cli_alert_info cli_alert_danger cli_abort
#' @importFrom purrr map map_chr walk walk2
#' @importFrom stats setNames
#' @importFrom config get merge
#' @importFrom usethis use_git_ignore
cfg_d_init <- function(
    path = here::here("inst/config"),
    configs = list(example = list(default = list(NULL))),
    merge = TRUE,
    ignore = TRUE,
    overwrite = FALSE,
    templates = FALSE,
    include_encrypted = FALSE,
    ...) {
  cfg_dir <- fs::path_rel(path, here::here())
  cfg_d_dir <- fs::path_rel(fs::path(path, "config.d"), here::here())

  if (!fs::dir_exists(cfg_dir)) {
    fs::dir_create(cfg_dir)
  }

  if (ignore) {
    ignores <- c(
      "*",
      "!.gitignore",
      "!*.encrypted.yml",
      "!*.template.yml",
      "!*.md",
      "!*.R"
    )

    usethis::use_git_ignore(
      ignores,
      directory = cfg_d_dir
    )

    cli::cli_alert_success("Setup gitignore for {.path {cfg_d_dir}}.")
  }

  purrr::walk(configs, validate_cfg)
  cli::cli_alert_success(
    "Successfully validated {.field {length(configs)}} configs passed via {.field configs} argument."
  )

  cfg_d_names <- names(configs)
  cfg_d_files <- purrr::map_chr(cfg_names, ~ glue::glue("{cfg_d_dir}/{.x}.config.yml"))

  purrr::walk2(
    cfg_d_files,
    cfgs,
    function(file, cfg) {
      cfg_file <- fs::path(file)
      if (fs::file_exists(cfg_file) && !overwrite) {
        cli::cli_abort("Config file {.file {cfg_file}} already exists.")
      } else {
        yaml::write_yaml(cfg, cfg_file)
        cli::cli_alert_success("Successfully created the config file: {.file {cfg_file}}")
      }
    }
  )

  if (templates) {
    cfg_d_templates <- purrr::map_chr(cfg_d_files, fs::path_ext_remove) |>
      purrr::map_chr(~ paste0(.x, ".template.yml")) |>
      purrr::map_chr(fs::path)

    purrr::walk2(cfg_d_files, cfg_d_templates, create_cfg_template)
    cli::cli_alert_success(
      "Successfully created {.field {length(cfg_d_templates)}} config file templates: {.field {basename(cfg_d_templates)}}."
    )
  }

  if (include_encrypted) {
    purrr::walk(
      cfg_d_files,
      encrypt_cfg_file
    )

    cfg_d_encrypted_files <- purrr::map_chr(cfg_d_files, fs::path_ext_remove) |>
      purrr::map_chr(~ paste0(.x, ".encrypted.yml")) |>
      purrr::map_chr(fs::path)

    cli::cli_alert_success(
      "Successfully created {.field {length(cfg_d_encrypted_files)}} encrypted config files: {.field {basename(cfg_d_encrypted_files)}}."
    )
  }

  if (merge) {
    cfg_d_cfgs_merged <- purrr::map(cfg_d_files, ~ config::get(file = .x)) |>
      setNames(cfg_d_names)

    base_cfg <- config::get(file = fs::path(path, "config.yml"))

    base_cfg_merged <- list(
      default = config::merge(base_cfg, cfg_d_cfgs_merged)
    )

    yaml::write_yaml(base_cfg_merged, fs::path(path, "config.merged.yml"))

    cli::cli_alert_success(
      "Successfully merged the config files from {.field {cfg_d_dir}} into {.field config.merged.yml}."
    )

    encrypt_cfg_file(fs::path(path, "config.merged.yml"))
  }

  return(invisible(config::get(file = fs::path(path, "config.merged.yml"))))
}
