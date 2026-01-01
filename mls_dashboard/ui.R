library(shiny)
library(shinydashboard)

dashboardPage(
  
  dashboardHeader(title = "MLS Squad Analysis"),
  
  dashboardSidebar(
    
    # Team selector
    selectInput(
      "team",
      "Choose a MLS 2025 Team:",
      choices = NULL
    ),
    
    # Minutes Played slider
    sliderInput(
      "minutes_range",
      "Filter by Minutes Played:",
      min = 0,
      max = 4051,  # placeholder; updated dynamically
      value = c(0, 4050),
      step = 10
    )
  ),
  
  dashboardBody(
    
    tabsetPanel(
      
      # ---- SQUAD OVERVIEW ----
      tabPanel(
        "Squad Overview",
        fluidRow(
          box(width = 6, plotOutput("plot_positions")),
          box(width = 6, plotOutput("plot_age_position"))
        ),
        fluidRow(
          box(width = 12, plotOutput("plot_minutes_position", height = 400))
        )
      ),
      
      # ---- PERFORMANCE ----
      tabPanel(
        "Performance",
        fluidRow(
          box(width = 12, plotOutput("plot_minutes", height = 500))
        ),
        fluidRow(
          box(width = 12, tableOutput("table_players"))
        )
      ),
      
      # ---- VALUE & SALARY ----
      tabPanel(
        "Value & Salary",
        fluidRow(
          box(width = 12, plotOutput("plot_salary", height = 500))
        )
      )
    )
  )
)
