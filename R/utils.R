"%||%" <- function(a, b) {
  if (!is.null(a)) a else b
}

# Helper function to extract the source file from the function's attributes
.get_function_source_file <- function(func_name, ns) {
  func <- ns[[func_name]]

  # Check if the function has a "srcref" attribute to get its source file
  src_ref <- attr(func, "srcref")

  if (!is.null(src_ref)) {
    # Extract the source file path from the "srcfile" attribute within srcref
    src_file <- attr(src_ref, "srcfile")
    if (!is.null(src_file) && !is.null(src_file$filename)) {
      return(as.character(src_file$filename)) # Return the source file path
    }
  }

  return(NA) # Return NA if the function's source file cannot be determined
}

get_function_srcfile <- function(fun, ns = parent.frame()) {
  if (is.character(fun)) {
    fun <- get(fun, envir = ns)
  }

  if (!is.function(fun)) {
    rlang::abort("Argument {.arg fun} must be a function or character string")
  }

  src_ref <- attr(fun, "srcref")

  if (!is.null(src_ref)) {
    src_file <- attr(src_ref, "srcfile")
    if (!is.null(src_file) && !is.null(src_file$filename)) {
      return(as.character(src_file$filename))
    }
  }

  return(NA)
}

#' Get Source Code of a Function's Definition
#'
#' @family Utility
#'
#' @description
#' This function retrieves the source code of a function's definition by
#' simply wrapping `attr(fun, "srcref")` to pull the "source reference"
#' attribute of the function.
#'
#' This is more useful than simply printing the function definition by
#' excluding `()` because it provides the actual source code
#' (and comments, formatting, etc.) of the function definition.
#'
#' @param fun An R function
#'
#' @return The source code of the function's definition.
#'
#' @export
#'
#' @seealso [base::srcfile()]
#'
#' @examples
#' get_function_definition(print)
get_function_definition <- function(fun) {
  attr(fun, "srcref")
}


if_unquiet <- function(expr) {
  opt <- getOption("noclocks.quiet", getOption("usethis.quiet", default = FALSE))

  if (!opt) {
    force(expr)
  }
}
