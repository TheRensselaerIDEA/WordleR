
library(shiny)
library(tidyverse)

# Initialize our word list
# select the top n words by frequency from Knuth's list
#short_list.df <- readRDS("short_list.Rds") # Knuth's 5757 words, sorted by frequency
short_list.df <- readRDS("Wordle_Words.Rds") # Official Wordle Words, sorted by their word frequency score

# select the top n words by frequency from word list (Wordle or Knuth)
n <- nrow(short_list.df)

# Make it a vector
short_list <- short_list.df[1:n,]$word

# We gratuitously display a subset of words
guess_length <- 50

# Set up the (simple) UI...
ui <- fluidPage(
  tags$head(tags$style(HTML("pre {white-space: pre-wrap; word-break: keep-all;}")),
            tags$style(HTML("td {vertical-align: top;text-align:center;}")),
            tags$style(HTML("img {float:none;}"))
            ),
  img(src='WordleR.png', align = "left"),
  titlePanel("An R-based WORDLE Helper"),
#  tags$p("NOTE: WordleR may behave strangely on iOS devices. It works perfectly in desktop browsers..."),
  tags$h3("1. Start by entering a vowel-rich starter word into",  
          tags$a(href="https://www.powerlanguage.co.uk/wordle/","WORDLE"), ", like:", tags$br(),
          tags$b("BAYOU, ADIEU, YOUSE, AUDIO, ABOUT or OUIJA")),
#  tags$br(),
  tags$h3("2. Filter the list of possible words based on WORDLE's response:"),
  tags$table(
  tags$tr(
    tags$td(h4("Exclude letter:")),
    tags$td(selectInput("exclude",choices=letters,label=NULL, width="75px")),
    tags$td(actionButton("exclude_button", label="Exclude",
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
  ),
  tags$tr(
    tags$td(h4("Include letter:")),
    tags$td(selectInput("include",choices=letters,label=NULL,width="75px")),
    tags$td(actionButton("include_button", label="Include",
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
  ),
  tags$tr(
    tags$td(h4("Exclude letter in", tags$br(),"position (letter):")),
    tags$td(selectInput("pos_exclude",choices=letters,label=NULL,width="75px")),
    tags$td(h4("Exclude", tags$br(),"position:")),
    tags$td(selectInput("pos_exclude_position",label=NULL,choices=1:5, width = "75px")),
    tags$td(actionButton("pos_exclude_button", label="Exclude letter in position",
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
  ),
  tags$tr(
    tags$td(h4("Include letter in", tags$br(),"position (letter):")),
    tags$td(selectInput("pos_include",choices=letters,label=NULL,width="75px")),
    tags$td(h4("Include", tags$br(),"position:")),
    tags$td(selectInput("pos_include_position",label=NULL,choices=1:5, width = "75px")),
    tags$td(actionButton("pos_include_button", label="Include letter in position",
                         style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
  )
  ),
  tags$br(),
  tags$h3("3. WordleR's guess: ", tags$b(textOutput("johnsguess",inline = TRUE))),
#  tags$br(),
  tags$h3("4. Or try one of these words: (",textOutput("possible_guesses",inline = TRUE),"remaining possibilities)"),
  tags$table(width="50%",
             tags$tr(tags$td(verbatimTextOutput("guess"))),
             tags$tr(tags$td(actionButton("refresh", "Reload master word list",
                                          style="color: #fff; background-color: #337ab7; border-color: #2e6da4")))
  ),
  tags$br(),
  tags$h4("Notes:"),
  tags$p("a. Based on the list of", tags$a(href="https://bit.ly/32tqaWj","2315 Wordle 'Magic Words'. See also"), 
         tags$a(href="https://docs.google.com/spreadsheets/d/1-M0RIVVZqbeh0mZacdAsJyBrLuEmhKUhNaVAI-7pr2Y/edit#gid=0","here."),
  tags$p("b. WordleR arranges the remaining possible words based on the frequencies of the letters of thoses words in the English language. 
         Words with reoccurring letters are de-emphasized.")),
  tags$p("c. WordleR's recommended 'starter' words are the top",tags$i("four-vowel"), "words in Knuth's list"),  
  tags$p("d. WordleR's list of 'possible' guesses is only a subset of", guess_length, "matching words."),
  tags$p("e. ",tags$a(href="https://gist.github.com/colmmacc/5783eb809f5714c30d8a8ee759e0af59","This page"),"contains some useful insights on letter and word frequency."),
  tags$p("f. WordleR is powered by R, the world's greatest data analytics language!"),
  tags$p("g. WordleR source code and a related R Notebook are available at:",
         tags$a(href="https://github.com/TheRensselaerIDEA/WordleR","https://github.com/TheRensselaerIDEA/WordleR"))
)

server <- function(input, output) {
  
word_list <- reactiveVal(short_list)

output$johnsguess <- renderText({
  word_list()[1]
})

  output$guess <- renderText({
    head(word_list(),guess_length)
    })

  output$possible_guesses <- renderText({
    length(word_list())
  })
  
  observeEvent(input$exclude_button, {
    exclude_mask <- !grepl(input$exclude, word_list(), fixed = TRUE)
    word_list(word_list()[exclude_mask])
  })

  observeEvent(input$include_button, {
    include_mask <- grepl(input$include, word_list(), fixed = TRUE)
    word_list(word_list()[include_mask])
  })
  
  observeEvent(input$pos_exclude_button, {
    exclude_mask <- (str_sub(word_list(), input$pos_exclude_position, input$pos_exclude_position) != input$pos_exclude)
    word_list(word_list()[exclude_mask])
  })
  
  observeEvent(input$pos_include_button, {
    include_mask <- (str_sub(word_list(), input$pos_include_position, input$pos_include_position) == input$pos_include)
    word_list(word_list()[include_mask])
  })

  observeEvent(input$refresh, {
    word_list(short_list)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
