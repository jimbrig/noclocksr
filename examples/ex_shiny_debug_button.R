# launch a shiny app with an interactive debug button
# that can be toggled on and off via keyboard shortcut
# the default keyboard shortcut is Ctrl + Alt + D:

if (interactive()) {

  library(shiny)

  ui <- fluidPage(
    shiny_debug_button_ui(id = "browser_btn", label = "Debug")
  )
  server <- function(input, output, session) {
    shiny_debug_button_server("browser_btn")
  }

  shinyApp(ui, server)

}

