
#  ------------------------------------------------------------------------
#
# Title : HTML Utilities
#    By : Jimmy Briggs
#  Date : 2024-08-12
#
#  ------------------------------------------------------------------------


# internal ----------------------------------------------------------------



# exported ----------------------------------------------------------------

#' Shiny HTML Utilities
#'
#' @name utils_html
#'
#' @description
#' - `flucol()`: Shiny Fluid Row + Column Layout
#' - `icon_text()`: Icon Text
#'
#' @details
#' These functions provide utility functions for working with HTML and Shiny UI
#' elements. They are designed to simplify the creation of common UI elements
#' and layouts.
#'
#' @return
#' - `flucol()`: Returns a [shiny::fluidRow()] wrapping a [shiny::column()] containing
#'  the provided UI elements
#' - `icon_text()`: Returns a `<span>` tag containing the provided icon and text.
#'
#' @seealso [shiny::fluidRow()], [shiny::column()], [shiny::icon()]
NULL

# flucol ------------------------------------------------------------------

#' Shiny Fluid Row + Column Layout
#'
#' @rdname utils_html
#'
#' @description
#' Create a fluid row with multiple columns. This function is a wrapper around
#' [shiny::fluidRow()] and [shiny::column()]. It allows for the creation of
#' multiple columns with varying widths and offsets, or just as a shorthand
#' for `shiny::fluidRow(shiny::column(width = 12, ...))`.
#'
#' @param ... Elements to include within the columns. These can be any valid
#'   HTML tags or Shiny UI elements.
#' @param width Integer for the width to use for the column
#' @param offset Integer for the offset to use for the column
#'
#' @return Returns a [shiny::fluidRow()] wrapping a [shiny::column()] containing
#'   the provided UI elements
#'
#' @export
#'
#' @importFrom shiny fluidRow column
#' @importFrom cli cli_abort
#'
#' @examples
#' flucol(
#'   htmltools::tags$h1("Hello World!")
#' )
flucol <- function(..., width = 12, offset = 0) {

  if (!is.numeric(width) || width < 1 || width > 12) {
    cli::cli_abort("Invalid width provided: {.field {width}}. Must be an integer between 1 and 12.")
  }

  shiny::fluidRow(
    shiny::column(
      width = width,
      offset = offset,
      ...
    )
  )

}


# icon_text ---------------------------------------------------------------

#' Icon Text
#'
#' @rdname utils_html
#'
#' @description
#' Create a `<span>` tag containing an icon and text. Useful for displaying
#' icons next to text, typically for labels and titles.
#'
#' @param icon Either a character string representing a shiny icon or a shiny icon tag
#'   created with [shiny::icon()]. If a character string is provided, it will be
#'   converted to a shiny icon tag.
#' @param text Character string to display next to the provided icon.
#'
#' @return Returns a `<span>` tag containing the provided icon and text.
#'
#' @export
#'
#' @importFrom htmltools tagHasAttribute tags
#' @importFrom shiny icon
#'
#' @examples
#' # provide plain text icon
#' icon_text("table", "Table") |> htmltools::browsable()
#'
#' # provide shiny icon tag
#' icon_text(shiny::icon("table"), "Table") |> htmltools::browsable()
icon_text <- function(icon, text) {

  if (!inherits(icon, "shiny.tag") && !is.null(icon) && is.character(icon)) {
    tryCatch({
      icon <- shiny::icon(icon)
    }, error = function(e) {
      stop("icon must be a valid shiny icon tag")
    })
  }

  htmltools::tagHasAttribute(icon, attr = "aria-label")
  stopifnot(
    inherits(icon, "shiny.tag")
  )

  htmltools::tags$span(
    style = "display: inline-flex; align-items: center;",
    icon,
    htmltools::tags$span(
      style = "margin-left: 0.5em;",
      text
    )
  )
}




