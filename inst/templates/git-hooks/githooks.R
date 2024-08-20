
#  ------------------------------------------------------------------------
#
# Title : Git Hooks Encryption Helpers
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------

encrypt_cfg_file <- function(
    cfg_file = Sys.getenv("R_CONFIG_FILE", "config.yml"),
    key = "NOCLOCKS_ENCRYPTION_KEY",
    ...
) {

  if (is.null(Sys.getenv(key)) || !httr2::secret_has_key(key)) {
    rlang::abort(
      "Encryption key not found. Please set the encryption key environment variable."
    )
  }

  cfg_file <- fs::path(cfg_file)
  cfg_file_encrypted <- fs::path_ext_remove(cfg_file) |>
    paste0(".encrypted.yml") |>
    fs::path()

  fs::file_copy(
    cfg_file,
    cfg_file_encrypted,
    overwrite = TRUE
  )

  httr2::secret_encrypt_file(
    path = cfg_file_encrypted,
    key = key
  )

  cli::cli_alert_success("Successfully encrypted the config file: {.file cfg_file_encrypted}")

  return(config::get())

}

decrypt_cfg_file <- function(
    cfg_file = Sys.getenv("R_CONFIG_FILE", "inst/config/config.yml"),
    key = "NOCLOCKS_ENCRYPTION_KEY"
) {

  if (!httr2::secret_has_key(key)) {
    rlang::abort(
      glue::glue(
        "Encryption key: {key} not found.",
        "Please set the encryption key in your environment variables."
      )
    )
  }

  cfg_file <- fs::path(cfg_file)
  cfg_file_encrypted <- fs::path_ext_remove(cfg_file) |>
    paste0(".encrypted.yml") |>
    fs::path()

  cfg_file_decrypted <- httr2::secret_decrypt_file(
    path = cfg_file_encrypted,
    key = key
  )

  fs::file_move(
    cfg_file_decrypted,
    cfg_file
  )

  cli::cli_alert_success("Successfully decrypted the config file: {.file cfg_file}")
  cli::cli_alert_info("The decrypted file is now the active config file.")

  ignores <- c(
    "*",
    "!.gitignore",
    "!*.encrypted.yml",
    "!*.md",
    "!*.R"
  )

  usethis::use_git_ignore(
    ignores,
    directory = dirname(cfg_file)
  )

  cli::cli_alert_success("Setup gitignore for config.")

  Sys.setenv("R_CONFIG_FILE" = cfg_file)
  cli::cli_alert_info("Set `R_CONFIG_FILE` to: {.file cfg_file}")

  return(config::get())

}
