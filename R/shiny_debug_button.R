#  ------------------------------------------------------------------------
#
# Title : Shiny Debugging
#    By : Jimmy Briggs
#  Date : 2024-08-14
#
#  ------------------------------------------------------------------------

# internal ----------------------------------------------------------------

.keymap <- list(
  "ctrl" = "ctrlKey",
  "shift" = "shiftKey",
  "alt" = "altKey",
  "meta" = "metaKey"  # Command key on Mac
)

.key_to_code <- function(key) {
  .keymap[[tolower(key)]] %||% tolower(key)
}

# shiny_debug_button ------------------------------------------------------

#' Shiny Debug Button
#'
#' @name shiny_debug_button
#'
#' @description
#' Shiny Module that creates a special `DEBUG` button to toggle the `browser()` function in a Shiny application.
#'
#' @details
#' The `shiny_debug_button_ui` function creates a hidden button in the Shiny UI that can be toggled to run the `browser()` function.
#' The `shiny_debug_button_server` function contains the server-side logic to handle the button's functionality.
#'
#' @section Functions:
#' \describe{
#'   \item{\code{\link{shiny_debug_button_ui}}}{Creates the button UI.}
#'   \item{\code{\link{shiny_debug_button_server}}}{Handles server-side logic.}
#' }
#'
#' @example examples/ex_shiny_debug_button.R
NULL

#' Shiny Debug Button UI Function
#'
#' @rdname shiny_debug_button
#'
#' @description
#' - `shiny_debug_button_ui()`: Creates the UI for the Shiny Debug Button.
#'
#' @details
#' This function creates a button that can be used to toggle the `browser()` function in a Shiny application.
#' The button is hidden by default and can be toggled by pressing the keyboard shortcut `Ctrl + Alt + D`
#' (or whatever the user specifies via the `keyboard_shortcut` argument).
#'
#' @param id The ID of the button.
#' @param label The label for the button.
#' @param icon The icon to use for the button. Default is a bug icon.
#' @param hide Whether to hide the button by default. Default is `TRUE`.
#' @param keyboard_shortcut The keyboard shortcut to toggle the button's visibility.
#'   Default is `Ctrl + Alt + D`.
#'
#' @return A UI element containing the hidden button and associated JavaScript.
#'
#' @export
#'
#' @importFrom shiny NS actionButton icon
#' @importFrom htmltools tagList tags HTML
#' @importFrom purrr map_chr
#' @importFrom shinyjs useShinyjs
shiny_debug_button_ui <- function(
    id = "browser",
    label = "Debug",
    icon = shiny::icon("bug"),
    hide = TRUE,
    keyboard_shortcut = "Ctrl + Alt + D"
) {

  ns <- shiny::NS(id)

  btn <- shiny::actionButton(
    inputId = ns("browser_btn"),
    label = label,
    icon = icon
  )

  js_hide <- if (hide) {
    paste0("$('#", ns("browser_btn"), "').hide(); $('#", ns("shortcut_text"), "').show();")
  } else {
    paste0("$('#", ns("shortcut_text"), "').hide();")
  }

  keys <- strsplit(keyboard_shortcut, " \\+ ") |> unlist() |> purrr::map_chr(.key_to_code)

  modifier_keys <- keys[keys %in% c("ctrlKey", "shiftKey", "altKey", "metaKey")]
  main_key <- keys[!keys %in% modifier_keys]

  keys_js <- paste(
    paste(paste0("e.", modifier_keys), collapse = " && "),
    paste0("e.key === '", main_key, "'"),
    sep = " && "
  )

  js_key <- paste0(
    "$(document).on('keydown', function(e) {",
    "if (", keys_js, ") {",
    "    $('#", ns("browser_btn"), "').toggle();",
    "    $('#", ns("shortcut_text"), "').toggle();",
    "  }",
    "});"
  )

  # Text to notify the user about the keyboard shortcut if hidden
  shortcut_text <- if (hide) {
    shiny::div(
      id = ns("shortcut_text"),
      style = "margin-top: 10px; font-size: 90%; color: grey;",
      paste0("Press ", keyboard_shortcut, " to toggle the debug button.")
    )
  } else {
    NULL
  }

  htmltools::tagList(
    shinyjs::useShinyjs(),  # Load ShinyJS if needed
    btn,
    htmltools::tags$script(
      htmltools::HTML(
        paste0(
          "$(document).ready(function() {",
          js_hide,
          js_key,
          "});"
        )
      )
    ),
    shortcut_text
  )
}

#' Shiny Debug Button Server Function
#'
#' @rdname shiny_debug_button
#'
#' @description
#' - `shiny_debug_button_server()`: Handles the server-side logic for the Shiny Debug Button.
#'
#' @param id The ID of the button. Default is `browser`.
#'
#' @return NULL
#'
#' @export
#'
#' @importFrom shiny observeEvent
shiny_debug_button_server <- function(id = "browser") {
  shiny::moduleServer(id, function(input, output, session) {
    observeEvent(input$browser_btn, {
      print("Debug button clicked")  # For debugging
      browser()  # Should trigger the browser() function
    })
  })
}
