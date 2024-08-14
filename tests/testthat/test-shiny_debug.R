require(shiny)
require(htmltools)

test_that("shiny_debug_button_ui generates correct UI structure", {

  ui <- shiny_debug_button_ui(
    id = "browser_btn",
    label = "Debug",
    keyboard_shortcut = "Ctrl + Shift + D"
  )

  expect_s3_class(ui, "shiny.tag.list")

  expect_true(
    any(sapply(ui, function(x) inherits(x, "shiny.tag") && x$name == "button"))
  )

  expect_true(
    any(grepl("hide", sapply(ui, function(x) if (inherits(x, "shiny.tag")) x$children[[1]] else "")))
  )
})

test_that("shiny_debug_button_ui generates correct JavaScript for Ctrl + Shift + D", {
  ui <- shiny_debug_button_ui(id = "browser_btn", label = "Debug", keyboard_shortcut = "Ctrl + Shift + D")

  script <- sapply(ui, function(x) if (inherits(x, "shiny.tag") && x$name == "script") x$children[[1]] else "")

  expect_true(any(grepl("if \\(e.ctrlKey && e.shiftKey && e.key === 'd'\\) \\{", script)))
})

test_that("shiny_debug_button_ui generates correct JavaScript for Alt + A", {
  ui <- shiny_debug_button_ui(id = "browser_btn", label = "Debug", keyboard_shortcut = "Alt + A")

  script <- sapply(ui, function(x) if (inherits(x, "shiny.tag") && x$name == "script") x$children[[1]] else "")

  expect_true(any(grepl("e.altKey && e.key === 'a'", script)))
})

test_that("shiny_debug_button_ui handles single key shortcut correctly", {
  ui <- shiny_debug_button_ui(id = "browser_btn", label = "Debug", keyboard_shortcut = "A")

  script <- sapply(ui, function(x) if (inherits(x, "shiny.tag") && x$name == "script") x$children[[1]] else "")

  expect_true(any(grepl("e.key === 'a'", script)))
})

test_that("shiny_debug_button_ui handles custom keyboard shortcut correctly", {
  ui <- shiny_debug_button_ui(id = "browser_btn", label = "Debug", keyboard_shortcut = "Ctrl + Alt + B")

  script <- sapply(ui, function(x) if (inherits(x, "shiny.tag") && x$name == "script") x$children[[1]] else "")

  expect_true(any(grepl("e.ctrlKey && e.altKey && e.key === 'b'", script)))
})
