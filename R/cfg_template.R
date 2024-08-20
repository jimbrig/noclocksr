#  ------------------------------------------------------------------------
#
# Title : Configuration Template
#    By : Jimmy Briggs
#  Date : 2024-08-20
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom purrr imap
.replace_values <- function(x) {
  if (is.list(x)) {
    purrr::imap(x, function(value, key) {
      if (is.list(value)) {
        .replace_values(value)
      } else {
        .create_placeholder(key)
      }
    })
  } else {
    .create_placeholder(x)
  }
}

#' @keywords internal
#' @noRd
.create_placeholder <- function(name) {
  paste0("<", toupper(name), ">")
}

# cfg_template ------------------------------------------------------------

#' Generate a `config.template.yml` from a `config.yml`
#'
#' @description
#' This function takes a `config.yml` file as input and generates a `config.template.yml`
#' file by replacing values with specific placeholders like `"<APP_NAME>"`, `"<API_KEY>"`, etc.,
#' and ensuring that the placeholders are correctly quoted in the output YAML.
#'
#' @param input_file The path to the input `config.yml` file.
#' @param output_file The path where the generated `config.template.yml` file should be saved.
#'
#' @return None. The function outputs the template file to the specified location.
#'
#' @export
#'
#' @importFrom yaml yaml.load_file
#' @importFrom purrr imap
#'
#' @examples
#' generate_config_template("inst/config/config.yml", "inst/config/config.template.yml")
create_cfg_template <- function(input_file, output_file = NULL) {
  if (is.null(output_file)) {
    output_file <- gsub("\\.yml$", ".template.yml", input_file)
  }

  # Load the config.yml file
  config <- yaml::yaml.load_file(input_file)

  # Helper function to generate placeholders
  create_placeholder <- function(name) {
    paste0("<", toupper(name), ">")
  }

  # Recursively replace values with placeholders
  replace_values <- function(x) {
    if (is.list(x)) {
      purrr::imap(x, function(value, key) {
        if (is.list(value)) {
          replace_values(value)
        } else {
          create_placeholder(key)
        }
      })
    } else {
      create_placeholder(x)
    }
  }

  # Recursively traverse the config and replace values
  config_template <- purrr::imap(config, function(value, key) {
    replace_values(value)
  })

  # Convert the list back to a YAML formatted string
  yaml_content <- yaml::as.yaml(config_template)

  # Ensure placeholders are quoted
  yaml_content <- gsub("(<[A-Z_]+>)", '"\\1"', yaml_content)

  # Write the content to the output file
  writeLines(yaml_content, con = output_file)
}
