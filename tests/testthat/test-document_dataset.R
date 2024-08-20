library(glue)
library(fs)
library(purrr)


test_that("document_dataset creates the expected documentation", {
  # Create a sample dataset
  data(mtcars)

  # Temporary file for testing
  temp_file <- fs::path_temp("test_mtcars.R")

  # Call the function
  document_dataset(
    mtcars,
    name = "mtcars",
    description = "Motor Trend Car Road Tests",
    source = "Henderson and Velleman (1981)",
    col_descs = c(
      "Miles per Gallon",
      "Number of Cylinders",
      "Displacement",
      "Horsepower",
      "Rear Axle Ratio",
      "Weight (per 1000 lbs)",
      "1/4 mile time",
      "V/S",
      "Transmission (0 = automatic, 1 = manual)",
      "Number of forward gears",
      "Number of carburetors"
    ),
    file = temp_file,
    overwrite = TRUE
  )

  # Read the file content
  result <- readLines(temp_file)

  # Check that the file is not empty
  expect_true(length(result) > 0)

  # Check for specific content
  expect_true(any(grepl("mtcars", result)))
  expect_true(any(grepl("Motor Trend Car Road Tests", result)))
  expect_true(any(grepl("Miles per Gallon", result)))

  # Clean up
  fs::file_delete(temp_file)
})

test_that("document_dataset respects overwrite and append flags", {
  # Create a sample dataset
  data(mtcars)

  # Temporary file for testing
  temp_file <- fs::path_temp("test_mtcars.R")

  # First, create a file with some content
  writeLines("Initial content", temp_file)

  # Call the function with append = TRUE
  document_dataset(
    mtcars,
    name = "mtcars",
    description = "Motor Trend Car Road Tests",
    source = "Henderson and Velleman (1981)",
    col_descs = c(
      "Miles/(US) gallon",
      "Number of cylinders",
      "Displacement (cu.in.)",
      "Gross horsepower",
      "Rear axle ratio",
      "Weight (1000 lbs)",
      "1/4 mile time",
      "V/S",
      "Transmission (0 = automatic, 1 = manual)",
      "Number of forward gears",
      "Number of carburetors"
    ),
    file = temp_file,
    append = TRUE
  )

  # Read the file content
  result <- readLines(temp_file)

  # Check that the file contains the initial content and new content
  expect_true(any(grepl("Initial content", result)))
  expect_true(any(grepl("mtcars", result)))

  # Call the function with overwrite = TRUE
  document_dataset(
    mtcars,
    name = "mtcars",
    description = "Motor Trend Car Road Tests",
    source = "Henderson and Velleman (1981)",
    col_descs = c(
      "Miles/(US) gallon",
      "Number of cylinders",
      "Displacement (cu.in.)",
      "Gross horsepower",
      "Rear axle ratio",
      "Weight (1000 lbs)",
      "1/4 mile time",
      "V/S",
      "Transmission (0 = automatic, 1 = manual)",
      "Number of forward gears",
      "Number of carburetors"
    ),
    file = temp_file,
    overwrite = TRUE
  )

  # Read the file content
  result <- readLines(temp_file)

  # Check that the file does not contain the initial content
  expect_false(any(grepl("Initial content", result)))

  # Clean up
  fs::file_delete(temp_file)
})
