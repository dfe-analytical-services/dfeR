# ============================================================================ #
# server.R - server instructions, the 'back-end' of your app
# ============================================================================ #

# This script gives the logic to your app, providing the 'wiring' between the
# different inputs and outputs you define. It is a function, and is broadly
# dividable into 3 sections: reactive values, outputs and observers.


# Server Function ---------------------------------------------------------

server <- function(input, output, session){

# Reactive Values ---------------------------------------------------------

  # This is the first section of server, and in it you create all your reactive
  # values, using calls to `reactive()` and `eventReactive()`. Reactive values
  # are things like dynamic subsets of your global data, depending on user input.


# Outputs -----------------------------------------------------------------

  # Outputs are defined with `output$id <- render*()`, using a render function
  # from the shiny package. The ids should correspond with those specified in
  # your ui.R script. These are the tables, plots, maps and so on which appear
  # as interactive widgets in your app.

# Observers ---------------------------------------------------------------

  # Observers add additional logic to your app, beyond the basic input -> reactive
  # -> output pipeline. They allow you to run extra bits of code when the user
  # does specific things, such as click a button. They are defined using calls to
  # `observe()` and `observeEvent()` from the shiny package.

}
