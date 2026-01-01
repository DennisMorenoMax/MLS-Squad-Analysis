library(shiny)
library(shinydashboard)

dashboardPage(
  
  dashboardHeader(title = "MLS Season 2025 Player Stats"),
  
  dashboardSidebar(
    selectInput(
      inputId = "team",
      label = "Choose a Team:",
      choices = NULL,
      selected = NULL
    ),
    
    sliderInput(
      inputId = "minutes_played_range",
      label = "Minutes Played Range:",
      min = 0,
      max = 3500,
      value = c(0, 3500)
    )
  ),
  
  dashboardBody(
    fluidRow(
      box(
        title = "Minutes Played by Player – MLS 2025",
        status = "primary",
        solidHeader = TRUE,
        width = 12,
        plotOutput("plot_minutes", height = 500)
      )
    ),
    
    fluidRow(
      box(
        title = "Filtered Player Data – MLS 2025",
        status = "info",
        solidHeader = TRUE,
        width = 12,
        tableOutput("table_players")
      )
    )
  )
)
