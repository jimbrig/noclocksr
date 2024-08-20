library(shiny)
library(highcharter)
library(DT)
library(bslib)
library(dplyr)
library(togglr)

# cache_dir <- rappdirs::user_cache_dir("toggl")
#
# users <- togglr::get_workspace_users()
#
# client_names <- togglr::get_all_client_names()
# project_names <- togglr::get_all_project_names()
#
# client_data <- togglr::get_all_client_info()



#
# # Load the data (in production, load from the CSV)
toggl_data <- read.csv("toggl_report.csv") |>
  dplyr::select(-c("tid", "project_color")) |>
  dplyr::mutate(
    start = lubridate::as_datetime(start),
    end = lubridate::as_datetime(end),
    updated = lubridate::as_datetime(updated),
    duration_hours = as.numeric(dur) / 3600000
  )

# UI
ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),

  titlePanel("Toggl Time Summary Dashboard"),

  sidebarLayout(
    sidebarPanel(
      selectInput(
        "project",
        "Select Project",
        choices = unique(toggl_data$project),
        selected = unique(toggl_data$project),
        multiple = TRUE,
        selectize = TRUE
      ),
      selectInput(
        "user",
        "Select User",
        choices = unique(toggl_data$user),
        selected = unique(toggl_data$user),
        multiple = TRUE,
        selectize = TRUE
      ),
      dateRangeInput(
        "dateRange",
        "Select Date Range",
        start = min(toggl_data$start),
        end = max(toggl_data$start),
        min = min(toggl_data$start),
        max = max(toggl_data$start),
        format = "yyyy-mm-dd"
      ),
      actionButton("refresh", "Refresh Data"),
      actionButton("filter", "Apply Filter")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Summary", highchartOutput("timeSummaryChart")),
        tabPanel("Tasks", highchartOutput("taskTimeChart")),
        tabPanel("Billable vs Non-Billable", highchartOutput("billableTimeChart")),
        tabPanel("Data Table", DTOutput("dataTable"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {

  cache_dir <- rappdirs::user_cache_dir("toggl")

  toggl_data <- reactive({
    togglr::get_detailled_report(
      memoise_cache_dir = cache_dir,
      max_page = 1000
    )
  }) #|>
    # bindEvent(input$refresh)

  toggl_data_clean <- reactive({
    req(toggl_data())
   toggl_data() |>
      dplyr::select(-c("tid", "project_color", "use_stop", "task", "billable", "is_billable")) |>
      dplyr::mutate(
        start = lubridate::as_datetime(start),
        end = lubridate::as_datetime(end),
        updated = lubridate::as_datetime(updated),
        billable = TRUE,
        billable = ifelse(tolower(client) == "internal", FALSE, TRUE),
        tags = stringr::str_c(unique(unlist(tags)), collapse = ", ")
      )
  }) #|>
    # bindCache(toggl_data()) |>
    # bindEvent(toggl_data())

  filtered_data <- reactive({
    req(toggl_data_clean())
    toggl_data_clean() |>
      filter(project == input$project,
             user == input$user,
             start >= input$dateRange[1],
             start <= input$dateRange[2])
  }) #|>
    # bindEvent(c(input$project, input$user, input$dateRange, toggl_data_clean()),
              # ignoreInit = TRUE, ignoreNULL = FALSE)

  output$timeSummaryChart <- renderHighchart({

    req(filtered_data())

    data_summary <- filtered_data() |>
      group_by(project) |>
      summarise(total_duration = sum(dur)) |>
      arrange(desc(total_duration))

    highchart() |>
      hc_chart(type = "column") |>
      hc_title(text = "Project Time Summary") |>
      hc_xAxis(categories = data_summary$project) |>
      hc_yAxis(title = list(text = "Total Duration (hours)")) |>
      hc_add_series(name = "Duration",
                    data = data_summary$total_duration,
                    colorByPoint = TRUE)
  })

  output$taskTimeChart <- renderHighchart({
    project_data <- filtered_data()

    highchart() |>
      hc_chart(type = "bar") |>
      # hc_title(text = paste("Time Spent on Tasks -", input$project)) |>
      hc_xAxis(categories = project_data$description) |>
      hc_yAxis(title = list(text = "Duration (hours)")) |>
      hc_add_series(name = "Duration",
                    data = project_data$dur,
                    color = project_data$project_hex_color[1])
  })

  output$billableTimeChart <- renderHighchart({
    billable_data <- filtered_data() |>
      group_by(billable) |>
      summarise(total_duration = sum(dur))

    highchart() |>
      hc_chart(type = "pie") |>
      hc_title(text = "Billable vs Non-Billable Time") |>
      hc_add_series(
        name = "Duration",
        data = list(
          list(name = "Billable", y = billable_data$total_duration[billable_data$billable == TRUE]),
          list(name = "Non-Billable", y = billable_data$total_duration[billable_data$billable == FALSE])
        )
      )
  })

  table_prep <- reactive({
    req(filtered_data())

    filtered_data() |>
      dplyr::rename(
        duration = dur,
        currency = cur
      ) |>
      dplyr::mutate(
        project_badge = stringr::str_c(
          "<span class='badge' style='background-color: ", project_hex_color, "; border-radius: 12px; font-size: 0.9em; padding: 5px 10px; color: white; font-weight: bold; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);'>", project, "</span>"
        ),
        billable = as.factor(ifelse(billable, "Yes", "No")),
        duration = prettyunits::pretty_ms(duration),
        start = format(start, "%Y-%m-%d %H:%M:%S"),
        end = format(end, "%Y-%m-%d %H:%M:%S"),
        user = as.factor(user),
        client = as.factor(client),
        # tags = stringr::str_c("<span class='badge' style='background-color: #007bff; border-radius: 12px; font-size: 0.9em; padding: 5px 10px; color: white; font-weight: bold; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);'>", tags, "</span>"),
        updated = format(updated, "%Y-%m-%d %H:%M:%S")
      ) |>
        dplyr::select(
          id,
          user,
          client,
          project_badge,
          billable,
          description,
          duration,
          start,
          end,
          tags,
          updated
        )

  })

  output$dataTable <- renderDT({

    req(table_prep())

    out <- table_prep()

    n_row <- nrow(table_prep())
    n_col <- length(table_prep())

    id <- "time_tbl"

    col_names <- c(
      "ID",
      "User",
      "Client",
      "Project",
      "Billable",
      "Description",
      "Duration",
      "Start",
      "End",
      "Tags",
      "Updated"
    )

    center_cols <- c(
      "id",
      "user",
      "client",
      "project_badge",
      "billable",
      "start",
      "end",
      "duration",
      "updated"
    )

    escape_cols <- c("project_badge")

    long_text_js <- "
    function(data, type, row, meta) {
      return type === 'display' && data.length > 30 ?
        '<span title=\"' + data + '\">' + data.substr(0, 30) + '...</span>' : data;
    }
    "

    cap <- "Time Entry Data"

      datatable(
        table_prep(),
        rownames = FALSE,
        colnames = col_names,
        caption = cap,
        editable = FALSE,
        selection = "none",
        class = "stripe row-border nowrap",
        callback = DT::JS('return table'),
        escape = c(-4),
        style = "bootstrap",
        extensions = c("Buttons", "Scroller"),
        filter = "top",
        options = list(
          autoWidth = TRUE,
          scrollX = TRUE,
          scrollY = 500,
          searching = TRUE,
          dom = '<Bl>tip',
          # pageLength = nrow(table_prep()),
          lengthMenu = list(
            c(-1, 10, 25, 50, 100),
            c("All", 10, 25, 50, 100)
          ),
          columnDefs = list(
            list(
              className = "dt-center",
              targets = center_cols
            ),
            list(
              targets = c("tags", "description"),
              render = JS(long_text_js)
            )
          ),
          buttons = list(
            list(
              extend = "copy",
              text = '<i class="fa fa-paperclip"></i>',
              titleAttr = 'Copy',
              exportOptions = list(columns = 1:(length(table_prep()) - 1),
                                   modifier = list(selected = NULL))
            ),
            list(
              extend = "print",
              text = '<i class="fa fa-print"></i>',
              titleAttr = 'Print',
              autoPrint = FALSE,
              exportOptions = list(columns = 1:(length(table_prep()) - 1),
                                   modifier = list(selected = NULL))
            ),
            list(
              extend = "excel",
              text = '<i class="fa fa-file-excel-o"></i>',
              titleAttr = "Excel",
              title = paste0("Time-", Sys.Date()),
              exportOptions = list(columns = 1:(length(table_prep()) - 1),
                                   modifier = list(selected = NULL))
            ),
            list(
              extend = "csv",
              text = '<i class="fa fa-file-csv"></i>',
              titleAttr = "CSV",
              title = paste0("Time-", Sys.Date()),
              exportOptions = list(columns = 1:(length(table_prep()) - 1),
                                   modifier = list(selected = NULL))
            ),
            list(
              extend = 'pdf',
              text = '<i class="fa fa-file-pdf-o"></i>',
              titleAttr = 'PDF',
              orientation = 'landscape',
              pageSize = "LEGAL",
              download = 'open',
              title = paste0("Schedule-of-Values-", Sys.Date()),
              exportOptions = list(columns = ":visible"),
              modifier = list(selected = NULL)
            ),
            list(
              extend = "colvis",
              text = '<i class = "fa fa-filter"></i>',
              titleAttr = "Column Visibility"#,
              # postfixButtons = 'colvisRestore',
              # collectionLayout = "three-column" #,
              # columns = ':not(.showalways)'
            ),
            list(
              extend = "pageLength",
              text = '<i class="fa fa-list"></i>',
              titleAttr = "Page Length"
            )
          )
        )
      ) #|>
        # DT::formatDate(
        #   columns = c("start", "end", "updated"),
        #   method = "toTimeString"
        # )
    }
  )
}

# Run the application
shinyApp(ui = ui, server = server)
