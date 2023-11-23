
# Libraries needed for this Shiny app

library(tidyverse)
library(shiny)
library(palmerpenguins)
library(shinythemes)
library(DT)
library(plotly)

# Create an object for the app's plot output y variable names
# This will display the following chosen names instead of variable names for both the input choices and the y-axis of the plot
yvars <- c("Flipper length (mm)" = "flipper_length_mm", 
           "Bill depth (mm)" = "bill_depth_mm",
           "Bill length (mm)" = "bill_length_mm")

# Define UI for application 
ui <- fluidPage(

# FEATURE1
# Change the theme to a bootstrap theme "Cerulean" to make the app more colourful
# This makes the app more visually interesting for the user
  bootstrapPage(
    theme = shinytheme("cerulean"),
    
# Center photos on each page of the app
    tags$head(
      tags$style(
        HTML("
        .center-image {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 80vh; /* Adjust height as needed */
        }
        .center-image img {
          max-width: 100%; /* Ensure the image doesn't exceed its container */
          max-height: 100%; /* Ensure the image doesn't exceed its container */
        }
      ")
      )
    ),

# Add a navigation bar with the title of the app
    navbarPage(
      title = "Penguins of the Palmer Archipelago, Antarctica",
      
# FEATURE2
# Create a tabset that contains tabPanel elements, which are useful for dividing the app outputs into multiple independently viewable sections
# This makes the app more organized and easier for a user to navigate
      tabsetPanel(
        
# FEATURE3
# Add an image to the first tab, called Species, with an image of the three penguin species found on the Palmer Archipelago
# This provides useful context for the user in the form of a visual image comparison of the three species
        tabPanel("Species", 
                 div(class = "center-image",
                     tags$figure(
                       tags$img(
                         src = "penguins.png",
                         width = 600,
                         alt = "Picture of Palmer Archipelago penguin species"
                       ),
                       tags$figcaption("Artwork by @allison_horst")
                     )
                 ),
                 verbatimTextOutput("summary")), 
        
# Add another tab called Islands which contains an image that shows a map of the Palmer Archipelago
# The three islands where the penguins are found are labelled on this map, providing spatial context for the user
        tabPanel("Islands", 
                 div(class = "center-image",
                     tags$figure(
                       tags$img(
                         src = "palmer_archipelago.png",
                         width = 600,
                         alt = "Picture of Palmer Archipelago islands"
                       ),
                       tags$figcaption("Graphics by Julian Avila-Jimenez")))),

# FEATURE4
# Add a tab containing a plot allowing the user to explore body size measurements interactively
# Drop-down menu to select the input for the y-axis variable using selectInput. This allows the user to plot the variable of interest to them
# Scatterplot output using plotly, which creates interactive plots, allowing the user to select/de-select data, zoom, download an image of the plot, etc.
            tabPanel("Size Plots", h3("Explore the penguins body size measurements"), 
                     selectInput("yaxis", "Select Y-Axis Variable:",
                                 choices = yvars),
                     tags$p(style = "font-weight:bold; color:black","Hover your mouse over the plot to see the data associated with each point."),
                     verbatimTextOutput("info"),
                plotlyOutput("scatterplot")), 

# FEATURE5
# Add a tab containing an interactive table using data table output (DTOutput)
# The data table contains a search bar, number of entries per page, and each variable can be arranged by size or name
# Add a drop-down menu with selectInput to allow the user to select a species of interest
# Add check boxes with checkboxGroupInput to allow the user to select one or more islands of interest
# All of these together provide the user with many options for customizing the data table to the variables they are interested in
            tabPanel("Tables", h3("Explore the penguins dataset"), p("Choose a species and one or more islands to view the corresponding data table."),
                     selectInput("penguinsp", "Species",  choices= unique(penguins$species)),
                     checkboxGroupInput("islands", "Island",
                                  choices = unique(penguins$island), selected="Torgersen",
                                  inline = TRUE),
                     DTOutput("selected"))
          )
        )
    )
  )


# Define server logic 
server <- function(input, output) {

# Reactive table output subsetted by the inputs in the drop-down menu and check boxes
  output$selected <- renderDT({
    subset(penguins, species %in% input$penguinsp & island %in% input$islands)
  })
  
  
# Reactive scatterplot output using Plotly
  output$scatterplot <- renderPlotly({
    
# Create a scatter plot using ggplot2 of body mass by an input y variable, color denoting species, shape denoting sex, and wrapped by island so each panel displays information for a different island
  p <- penguins %>% drop_na(species, sex, island) %>% ggplot(aes(x = body_mass_g, y = .data[[input$yaxis]], color = species, shape=sex)) +
      geom_point(size=1.5) +
      labs(x = "Body Mass (g)", y= names(yvars[yvars==input$yaxis]), color="Species", shape="Sex & ") +
      facet_wrap(~island)+
      scale_shape_manual(values = c(16,17,15))
  
# Print the plot  
  print(ggplotly(p)) 

# FEATURE6
# Add an event_register function that will enable click events
# This means when a user clicks on a data point on the plot, they will be able to see the data associated with that point
# Continued below with renderText function
  
  ggplotly(p) %>%
    event_register("plotly_click") %>%  # Enable click events
  layout(
    font = list(
      family = "Arial, sans-serif", 
      size = 12, 
      color = "black"  
    )
  )
})
  
# Text output for the Plotly click
# Data associated with the point that the user's mouse is over will be displayed in a box
# This is useful because it enables a user to see the exact data associated with a point, instead of trying to infer from it's position on the plot what the x and y coordinates might be
  
  output$info <- renderText({
    
    req(input$plot_click) 
    click_data <- event_data("plotly_click", source = "scatterplot")
    if (!is.null(click_data)) {
      paste0("Selected Coordinates:\n",
             "Body mass (g) =", click_data[["x"]], "\n",
             input$yaxis, "=", click_data[["y"]], "\n")
    } else {
      "Hover your mouse over the plot to see the data associated with each point."
    }
  
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
