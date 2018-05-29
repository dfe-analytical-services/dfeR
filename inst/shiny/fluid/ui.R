# ============================================================================ #
# ui.R - user interface, the 'front-end' of your app
# ============================================================================ #

# This script provides the structure of your app. It uses the different inputs,
# outputs and tags from the shiny package to construct the HTML of your app.
# In this case, we're using a fluidPage. We could also use the dashboardPage from
# the shinydashboard package. The script needs to create a single object called ui.

# User Interface ----------------------------------------------------------

ui <- fluidPage(

  # Adding a title to your app is a good idea
  titlePanel(title = "New Shiny App"),

  # a sidebarLayout is a common layout for an app
  sidebarLayout(

    # It has two elements, the first is the sidebar - inputs often go here
    sidebarPanel = sidebarPanel(),

    # The second is the mainPanel - outputs generally go here
    mainPanel = mainPanel()

  )

)
