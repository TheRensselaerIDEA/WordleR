
library(shiny)
library(tidyverse)

# Initialize our word list
unigram_freq <- readRDS("unigram_freq.Rds") # From Kaggle
short_list.df <- readRDS("short_list.Rds") # Knuth's 5757 words
short_list.df <- data.frame(short_list.df)
colnames(short_list.df) <- c("word")

# select the top n words by frequency from Knuth's list
n <- 3000
short_list_freq <- left_join(short_list.df,unigram_freq,by="word")
short_list_freq <- short_list_freq %>% arrange(desc(count))
short_list <- short_list_freq[1:n,]$word

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
  tags$p("NOTE: WordleR may behave strangely on iOS devices. It works perfectly in desktop browsers..."),
  tags$h3("1. Start by entering a", 
          tags$a(href="https://www.gamespot.com/articles/wordle-best-first-words-to-use-and-other-tips/1100-6499460/",
                 "good starter word"), 
          "into",
          tags$a(href="https://www.powerlanguage.co.uk/wordle/","WORDLE"), "like", tags$b("SOARE"),"or",tags$b("ADIEU")),
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
  tags$br(),
  tags$h3("4. Or try one of these words: (",textOutput("possible_guesses",inline = TRUE),"remaining possibilities)"),
  tags$table(width="50%",
             tags$tr(tags$td(verbatimTextOutput("guess"))),
             tags$tr(tags$td(actionButton("refresh", "Reload master word list",
                                          style="color: #fff; background-color: #337ab7; border-color: #2e6da4")))
  ),
  tags$br(),
  tags$h3("Notes:"),
  tags$h4("a. Based on Knuth's list of 5757 most comment five-letter words:", tags$br(),
          tags$a(href="https://www-cs-faculty.stanford.edu/~knuth/sgb-words.txt","https://www-cs-faculty.stanford.edu/~knuth/sgb-words.txt")),
  tags$h4("b. Knuth's list was narrowed to 3000 words based on ",
          tags$a(href="https://www.kaggle.com/rtatman/english-word-frequency","this analysis of English word frequency.")),
  tags$h4("c. According to news reports, Wordle is actually based on a list of approx 2500 five-letter words."),
  tags$h4("d. The list of 'guess' words shown is only a subset of", guess_length, "matching words, in no particular order. We suggest simply chosing the first word!"),
  tags$h4("e. WordleR is powered by R, the world's greatest data analytics language!"),
  tags$h4("f. WordleR source code available at:",tags$a(href="TheRensselaerIDEA/WordleR","TheRensselaerIDEA/WordleR"))
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
