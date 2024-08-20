
#  ------------------------------------------------------------------------
#
# Title : Configuration Encryption
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------


#' @keywords internal
#' @noRd
#' @importFrom fs path path_ext_remove
.get_encrypted_cfg_file <- function(cfg_file) {
  fs::path_ext_remove(cfg_file) |>
    paste0(".encrypted.yml") |>
    fs::path()
}



# roxygen -----------------------------------------------------------------

#' Configuration File Encryption/Decryption
#'
#' @name cfg_encrypt
#'
#' @description
#' - `encrypt_cfg_file()` encrypts the configuration file using the encryption key.
#' - `decrypt_cfg_file()` decrypts the configuration file using the encryption key.
#'
#' @details
#' The `encrypt_cfg_file()` function encrypts the configuration file using the encryption key.
#' The `decrypt_cfg_file()` function decrypts the configuration file using the encryption key.
#'
#' @param cfg_file Path to the configuration file. Defaults to the `R_CONFIG_FILE`
#'   environment variable or `inst/config/config.yml`.
#' @param cfg_file_encrypted Path to the encrypted configuration file. Defaults to the
#'   `cfg_file` with the extension `.encrypted.yml`. (Used in `decrypt_cfg_file()` only).
#' @param key The name of the environment variable that contains the encryption key.
#'   Defaults to `NOCLOCKS_ENCRYPTION_KEY`.
#' @param overwrite Logical. Overwrite the existing encrypted file. Defaults to `FALSE`.
#'   Used in `encrypt_cfg_file()` only.
#' @param ... Additional arguments passed to other functions.
#'
#' @seealso [cfg_init()] [cfg_hooks_init()]
#'
#' @return
#' - `encrypt_cfg_file()` returns invisible `0`.
#' - `decrypt_cfg_file()` returns invisible `config::get()`.
NULL


# encrypt -----------------------------------------------------------------

#' @rdname cfg_encrypt
#'
#' @export
#'
#' @importFrom httr2 secret_encrypt_file
#' @importFrom fs file_copy path path_ext_remove file_move
#' @importFrom cli cli_alert_success cli_abort
#' @importFrom glue glue
#' @importFrom purrr map_chr
#' @importFrom usethis use_git_ignore
encrypt_cfg_file <- function(
    cfg_file = Sys.getenv("R_CONFIG_FILE", "inst/config/config.yml"),
    key = "NOCLOCKS_ENCRYPTION_KEY",
    overwrite = FALSE,
    ...
) {

  if (is.null(Sys.getenv(key)) || !httr2::secret_has_key(key)) {
    cli::cli_abort(
      "Encryption key: {.field {key}} not found."
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

  cli::cli_alert_success("Successfully encrypted the config file: {.file {cfg_file_encrypted}}.")
  return(invisible(0))

}


# decrypt -----------------------------------------------------------------

#' @rdname cfg_encrypt
#'
#' @export
#'
#' @importFrom httr2 secret_decrypt_file
#' @importFrom fs file_move path path_ext_remove
#' @importFrom cli cli_alert_success cli_alert_info cli_abort
#' @importFrom glue glue
#' @importFrom usethis use_git_ignore
#' @importFrom config get
decrypt_cfg_file <- function(
  cfg_file = Sys.getenv("R_CONFIG_FILE", "inst/config/config.yml"),
  cfg_file_encrypted = .get_encrypted_cfg_file(cfg_file),
  key = "NOCLOCKS_ENCRYPTION_KEY"
) {

  if (!httr2::secret_has_key(key)) {
    cli::cli_alert_danger("Encryption key: {.field {key}} not found.")
    cli::cli_abort("Please set the encryption key in your environment variables.")
  }

  cfg_file_decrypted <- cfg_file |> fs::path()
  cfg_file_encrypted <- cfg_file_encrypted |> fs::path()

  cfg_file_decrypted_temp <- httr2::secret_decrypt_file(
    path = cfg_file_encrypted,
    key = key
  )

  fs::file_move(
    cfg_file_decrypted_temp,
    cfg_file_decrypted
  )

  cli::cli_alert_success("Successfully decrypted the config file: {.file cfg_file_decrypted}")
  cli::cli_alert_info("The decrypted file is now the active config file.")

  Sys.setenv("R_CONFIG_FILE" = cfg_file_decrypted)
  cli::cli_alert_info("Set `R_CONFIG_FILE` to: {.file {cfg_file_decrypted}}")

  return(invisible(config::get()))

}
