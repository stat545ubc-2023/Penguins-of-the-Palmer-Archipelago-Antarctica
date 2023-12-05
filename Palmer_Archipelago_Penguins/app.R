
# Libraries needed for this Shiny app

library(tidyverse)
library(shiny)
library(shinyjs)
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
  
  # UPDATED FEATURE
  # Change the theme to a bootstrap theme "Cosmo" to make the app more penguin-themed
  # This makes the app more visually interesting for the user
  bootstrapPage(
    theme = shinytheme("cosmo")),
  
  
  # Center photos on each page of the app
  tags$head(
    tags$style(
      HTML("
        /* Change font for the entire app */
        body {
          font-family: 'Arial', sans-serif; /* Change the font family here */
        
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
    
# NEW FEATURE 1
# Create a NAVLIST panel that contains tabPanel elements, which are useful for dividing the app outputs into multiple independently viewable sections
# This makes the app more organized and easier for a user to navigate
    navlistPanel(
      id = "tabset",
      "Learn about penguins!",
      
      
      # FEATURE
      # Add an image to the first tab, called Penguin species, with an image of the three penguin species found on the Palmer Archipelago
      # This provides useful context for the user in the form of a visual image comparison of the three species
      tabPanel("Penguin species", 
               tabsetPanel(
                 id = "speciesTabs",
                 tabPanel("All",
                          
                          div(class = "center-image",
                              tags$figure(
                                tags$img(
                                  src = "penguins.png",
                                  width = 700,
                                  alt = "Picture of Palmer Archipelago penguin species"
                                ),
                                tags$figcaption(style = "text-align: center; margin-top: 10px;","Artwork by @allison_horst")
                              )
                          ),
                          verbatimTextOutput("summary")),
# NEW FEATURE 2
# Add tabs within the species page, one for each species
# Include information about each species and embed a video
                 
                 # Content for Chinstrap species tab  
                 tabPanel("Chinstrap",
                          h3(HTML("<b>Chinstrap penguin facts</b>")),
                          p(HTML("<b>Scientific name</b>: <i>Pygoscelis antarcticus</i>")),
                          tags$ul(
                            tags$li("Chinstrap penguins have a circumpolar distribution"), 
                            tags$li("Their diet consists of krill, shrimp, small fish, and squid"),
                            tags$li("They are generally considered to be the most aggressive and ill-tempered species of penguin")
                          ),
                          tags$iframe(width = "100%", height = "400", frameborder = "0", src="https://www.youtube.com/embed/xlUm-0TSjNA?si=qqg7aoHuqu-dhkqf", allowfullscreen = TRUE)
                          
                 ),
                 # Content for Gentoo species tab  
                 tabPanel("Gentoo",
                          h3(HTML("<b>Gentoo penguin facts</b>")),
                          p(HTML("<b>Scientific name</b>: <i>Pygoscelis papua</i>")),
                          tags$ul(
                            tags$li("Gentoo penguins are the third largest species of penguin, after the emperor and king penguin"), 
                            tags$li("They are the fastest underwater swimmers of all penguins, with speeds up to 36 km/h (22 mph)!"),
                            tags$li("They are most closely related to Adelie penguins")
                          ),
                          tags$iframe(width = "100%", height = "400", frameborder = "0", src="https://www.youtube.com/embed/4LZLyopFpvc?si=By4j3DopWYBr7TyZ", allowfullscreen = TRUE)
                 ),
                 # Content for Adelie species tab 
                 tabPanel("Adelie",
                          h3(HTML("<b>Adelie penguin facts</b>")),
                          p(HTML("<b>Scientific name</b>: <i>Pygoscelis adeliae</i>")),
                          tags$ul(
                            tags$li("Adelie penguins are only found along the coast of the Antarctica continent"), 
                            tags$li("They feed primarily on Antarctic krill but also forage for small fish, amphipods, other krill species, cephalopods, and jellyfish"),
                            tags$li("Adelie penguins that live in the Ross Sea region migrate on average 13,000 km (8,100 miles) each year from their breeding colonies to winter foraging grounds and back again")
                          ),
                          tags$iframe(width = "100%", height = "400", frameborder = "0", src="https://www.youtube.com/embed/YKqXGNNPNaQ?si=Wj-HrtAnYBT8vOn-", allowfullscreen = TRUE)
                 )
               )), 
      
# Add another tab called Palmer Archipelago 
# NEW FEATURE 3
# Add two actions buttons, that will display a map of the region and a photo of the archipelago
# The three islands where the penguins nest are labelled on this map, providing spatial context for the user
# A photo of the Palmer Archipelago provides an image of the area for the user to better visualize the landscape
      tabPanel("Palmer Archipelago", 
               tags$div(
                 style = "text-align: center;", # Center-align the content
                 p(HTML("Click on the buttons below to view a map of the islands and a photo from the archipelago")),
                 actionButton("showImage1", "Nesting islands"),
                 actionButton("showImage2", "Photo of the region")),     
               
               # Placeholder for the displayed image
               div(class = "center-image",
               tags$div(
                 id = "imageDiv", # Set an ID for the div
                 style = "margin-top: 20px;", # Adding margin above the image
                 uiOutput("imageDisplay")
               ))),
      
      
      # FEATURE
      # Add a tab containing a plot allowing the user to explore body size measurements interactively
      # Drop-down menu to select the input for the y-axis variable using selectInput. This allows the user to plot the variable of interest to them
      # Scatterplot output using plotly, which creates interactive plots, allowing the user to select/de-select data, zoom, download an image of the plot, etc.
      tabPanel("Size Plots", h3(HTML("<b>Explore the penguins body size measurements</b>")), 
               selectInput("yaxis", "Select Y-Axis Variable:",
                           choices = yvars),
               tags$p(style = "font-weight:bold; color:black","Hover your mouse over the plot to see the data associated with each point."),
               verbatimTextOutput("info"),
               plotlyOutput("scatterplot")), 
      
      # FEATURE
      # Add a tab containing an interactive table using data table output (DTOutput)
      # The data table contains a search bar, number of entries per page, and each variable can be arranged by size or name
      # Add a drop-down menu with selectInput to allow the user to select a species of interest
      # Add check boxes with checkboxGroupInput to allow the user to select one or more islands of interest
      # All of these together provide the user with many options for customizing the data table to the variables they are interested in
      tabPanel("Data tables", h3(HTML("<b>Explore the penguins dataset</b>")), p("Choose a species and one or more islands to view the corresponding data table."),
               selectInput("penguinsp", "Species",  choices= unique(penguins$species)),
               checkboxGroupInput("islands", "Island",
                                  choices = unique(penguins$island), selected="Torgersen",
                                  inline = TRUE),
               DTOutput("selected"))
    )
  )
)


# Define server logic 
server <- function(input, output) {
  
  # Function to render images based on button clicks
  observeEvent(input$showImage1, {
    output$imageDisplay <- renderUI({
      image1 <-  tags$div(
        tags$figure(
        tags$img(src = "palmer_archipelago.png", width = "700"),
        tags$figcaption(style = "text-align: center; margin-top: 10px;",
          "Graphics by Julian Avila-Jimenez")
        ))
        image1
  })
})
  observeEvent(input$showImage2, {
    output$imageDisplay <- renderUI({
      image2 <- tags$div(
        tags$figure(
        tags$img(src = "p_archipelago_photo.png", width = "700", height = "300"),
        tags$figcaption(style = "text-align: center; margin-top: 10px;",
          "Photo from Holland America")
        ))
      image2
    })
  })
  
  
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
    
    # FEATURE
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
