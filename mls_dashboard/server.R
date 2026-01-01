library(shiny)
library(dplyr)
library(ggplot2)
library(janitor)
library(readr)
library(scales)
library(ggrepel)

function(input, output, session) {
  
  # Load MLS data
  players <- read_csv(
    "https://raw.githubusercontent.com/DennisMorenoMax/MLS-Squad-Analysis/main/players_mls_25.csv",
    show_col_types = FALSE
  ) %>%
    clean_names() %>%
    mutate(
      minutes_played = as.numeric(minutes_played),
      age = as.integer(difftime(Sys.Date(), birth_date, units = "days") / 365.25),
      
      goals_per_90 = goals / minutes_played * 90,
      xg_per_90 = xgoals / minutes_played * 90,
      assists_per_90 = primary_assists / minutes_played * 90,
      xa_per_90 = xassists / minutes_played * 90
    )
  
  # Team selector
  observe({
    updateSelectInput(
      session,
      "team",
      choices = sort(unique(players$team_name)),
      selected = sort(unique(players$team_name))[1]
    )
  })
  
  # Update minutes slider based on selected team
  observe({
    req(input$team)
    team_data <- players %>% filter(team_name == input$team)
    
    max_minutes <- max(team_data$minutes_played, na.rm = TRUE)
    
    updateSliderInput(
      session,
      "minutes_range",
      min = 0,
      max = max_minutes,
      value = c(0, max_minutes)
    )
  })
  
  # Reactive filtered squad (by team AND minutes)
  squad <- reactive({
    req(input$team, input$minutes_range)
    
    players %>%
      filter(
        team_name == input$team,
        minutes_played >= input$minutes_range[1],
        minutes_played <= input$minutes_range[2]
      )
  })
  
  # ---- SQUAD STRUCTURE ----
  output$plot_positions <- renderPlot({
    squad() %>%
      count(position) %>%
      ggplot(aes(x = reorder(position, n), y = n, fill = position)) +  # reorder by count
      geom_col(fill = "steelblue") +
      labs(
        title = "Players per Position",
        x = "Position",
        y = "Number of Players"
      ) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  output$plot_age_position <- renderPlot({
    squad() %>%
      group_by(position) %>%
      summarise(avg_age = mean(age, na.rm = TRUE)) %>%
      ggplot(aes(x = reorder(position, avg_age), y = avg_age)) +  # reorder positions by avg_age
      geom_col(fill = "steelblue") +
      labs(
        title = "Average Age by Position",
        x = "Position",
        y = "Average Age"
      ) +
      theme_minimal()
  })
  
  output$plot_minutes_position <- renderPlot({
    squad() %>%
      group_by(position) %>%
      summarise(total_minutes = sum(minutes_played, na.rm = TRUE)) %>%
      mutate(
        label = total_minutes
      ) %>%
      ggplot(aes(x = "", y = total_minutes, fill = position)) +
      geom_col(width = 1) +
      coord_polar("y") +
      geom_text_repel(
        aes(label = label),
        position = position_stack(vjust = 0.5),
        size = 5,
        show.legend = FALSE
      ) +
      labs(
        title = "Total Minutes Played by Position",
        fill = "Position"
      ) +
      theme_void()
  })
  
  
  # ---- PERFORMANCE ----
  output$plot_minutes <- renderPlot({
    squad() %>%
      ggplot(aes(
        reorder(player_name, minutes_played),
        minutes_played,
        fill = position
      )) +
      geom_col() +
      coord_flip() +
      labs(
        title = "Minutes Played by Player",
        x = "Player",
        y = "Minutes Played"
      ) +
      theme_minimal()
  })
  
  output$table_players <- renderTable({
    squad() %>%
      select(
        player_name,
        position,
        age,
        nationality,
        minutes_played,
        goals,
        xgoals,
        goals_minus_xgoals,
        primary_assists,
        xassists,
        goals_plus_primary_assists,
        primary_assists_minus_xassists,
        base_salary
      ) %>%
      rename(
        "Player" = player_name,
        "Position" = position,
        "Age" = age,
        "Nationality" = nationality,
        "Minutes Played" = minutes_played,
        "Goals" = goals,
        "xG" = xgoals,
        "xG Efficiency" = goals_minus_xgoals,
        "Assists" = primary_assists,
        "xA" = xassists,
        "G + A" = goals_plus_primary_assists,
        "xA Efficiency" = primary_assists_minus_xassists,
        "Salary (USD)" = base_salary
      ) %>%
      arrange(desc(`Minutes Played`))
  })
  
  
  # ---- VALUE & SALARY ----
  output$plot_salary <- renderPlot({
    squad() %>%
      ggplot(aes(
        x = base_salary,
        y = minutes_played,
        color = position
      )) +
      geom_point(size = 3, alpha = 0.8) +
      geom_text_repel(aes(label = player_name), size = 3, max.overlaps = 10) +
      scale_x_continuous(labels = scales::dollar) +
      labs(
        title = "Salary vs Minutes Played",
        x = "Base Salary (USD)",
        y = "Minutes Played",
        color = "Position"
      ) +
      theme_minimal()
  })
}
