# ============================================================================ #
# ui.R - user interface, the 'front-end' of your app
# ============================================================================ #

# This script provides the structure of your app. It uses the different inputs,
# outputs and tags from the shiny package to construct the HTML of your app.
# In this case, we're using a dashboardPage, from the shinydashboard package.
# The script needs to create a single object called ui.

# User Interface ----------------------------------------------------------

# Note we've called `library(shinydashboard)` in global.R, so don't need it again

ui <- dashboardPage(

  # Give your app a title
  title = "New Shiny App",

  # `skin` is the colour of the dashboard - one of blue, black, green, purple, red or yellow
  skin = "blue",

  # the dashboardHeader can contain drop down menus of information
  header = dashboardHeader(),

  # the dashboardSideber should contain a menu, created with sidebarMenu
  sidebar = dashboardSidebar(

    sidebarMenu(
      id = "menu",
      menuItem(tabName = "page1", text = "Page 1"),
      menuItem(tabName = "page2", text = "Page 2"),
      menuItem(tabName = "page3", text = "Page 3")
    )

  ),

  # the dashboardBody should contain the main content of your app, using tabItems
  # to correspond to the items in your menu. You can also include your custom CSS
  # and any other resources (like other CSS, JS files etc) here.

  body = dashboardBody(

    # including your custom.css file
    includeCSS("custom.css"),

    # a tabItems list contains individual 'tabItem's, corresponding to the menu
    tabItems(

      # add the content of each tabItem after the tabName, separated  by commas
      # e.g. tabItem(tabName = "page1",
      #              box(width = 4, selectInput(inputId = "input1", ...)),
      #              ..., more content
      #              ..., more content
      #              ...)
      tabItem(tabName = "page1"),
      tabItem(tabName = "page2"),
      tabItem(tabName = "page3")
    )
  )

)
