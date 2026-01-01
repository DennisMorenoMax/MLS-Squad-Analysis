library(shiny)
library(dplyr)
library(ggplot2)
library(janitor)

function(input, output, session) {
  
  # Load MLS data from GitHub
  players <- read.csv(
    "https://raw.githubusercontent.com/DennisMorenoMax/MLS-Squad-Analysis/refs/heads/main/players_mls_25.csv",
    stringsAsFactors = FALSE
  ) %>%
    clean_names() %>%
    mutate(minutes_played = as.numeric(minutes_played))
  
  # Update team selector
  observe({
    updateSelectInput(
      session,
      inputId = "team",
      choices = sort(unique(players$team)),
      selected = sort(unique(players$team))[1]
    )
  })
  
  # Update minutes slider based on selected team
  observe({
    req(input$team)
    
    team_data <- players %>% 
      filter(team == input$team)
    
    max_minutes <- max(team_data$minutes_played, na.rm = TRUE)
    
    updateSliderInput(
      session,
      inputId = "minutes_played_range",
      min = 0,
      max = max_minutes,
      value = c(0, max_minutes)
    )
  })
  
  # Reactive filtered data
  filtered <- reactive({
    req(input$team, input$minutes_played_range)
    
    players %>%
      filter(
        team == input$team,
        minutes_played >= input$minutes_played_range[1],
        minutes_played <= input$minutes_played_range[2]
      )
  })
  
  # Render plot
  output$plot_minutes <- renderPlot({
    ggplot(filtered(), aes(
      x = reorder(player_name, minutes_played),
      y = minutes_played
    )) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(
        title = paste("Minutes Played –", input$team),
        x = "Player",
        y = "Minutes Played"
      ) +
      theme_minimal()
  })
  
  # Render table
  output$table_players <- renderTable({
    filtered()
  })
}
