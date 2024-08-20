#  ------------------------------------------------------------------------
#
# Title : Validate Configuration
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------


#' Validate Configuration
#'
#' @description
#' A simple function to validate a configuration object that uses the `config`
#' package.
#'
#' @details
#' This function verifies that the configuration object is a list and that it
#' contains at least a 'default' configuration.
#'
#' @param cfg Configuration object (list) to validate
#'
#' @return TRUE if the configuration is valid, otherwise an error is thrown.
#' @export
#'
#' @importFrom cli cli_abort
validate_cfg <- function(cfg) {
  if (!is.list(cfg)) {
    cli::cli_abort("Config must be a list.")
  }

  if (!("default" %in% names(cfg))) {
    cli::cli_abort("Config must have a {.field default} configuration.")
  }

  return(TRUE)
}
