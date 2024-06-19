# UPDATE: 19 Jun 2024 (Display version)
library(shiny)
library(tidyverse)
library(utf8)
library(rclipboard)
library(htmltools)

# What version of WordleR?
version <- read.csv("version.csv")$date

# Initialize our word list
# select the top n words by frequency from Knuth's list
short_list.df.knuth <- readRDS("Knuth_Words.Rds") # Knuth's 5757 words, sorted by letter frequency score
short_list.df.wordle <- readRDS("Wordle_Words.Rds") # Official Wordle Words, sorted by letter frequency score

# # uggcf://zrqvhz.pbz/@bjralva/urer-yvrf-jbeqyr-2021-2027-shyy-nafjre-yvfg-52017rr99r86
# Get used words from: https://www.rockpapershotgun.com/wordle-past-answers
# used_words.df <- read.csv("used_words.csv")
# used_words.df$word <- tolower(used_words.df$word)
# saveRDS(used_words.df,"used_words.df.Rds")
# UPDATE (27 Apr 2024): used_words.R is a scraper utility to re-generate used_words.Rds
used_words.df <- readRDS("used_words.df.Rds")
# 
short_list.df.knuth <- anti_join(short_list.df.knuth, used_words.df, by="word")
short_list.df.wordle <- anti_join(short_list.df.wordle, used_words.df, by="word")
# saveRDS(short_list.df,"short_list.Rds")
# select the top n words by frequency from word list (Wordle or Knuth)
n.knuth <- nrow(short_list.df.knuth)
n.wordle <- nrow(short_list.df.wordle)

# Make it a vector
short_list.knuth <- short_list.df.knuth[1:n.knuth,]$word
short_list.wordle <- short_list.df.knuth[1:n.wordle,]$word

# We gratuitously display a subset of words
guess_length <- 50

# Set up the (simple) UI...
ui <- fluidPage(
  
  rclipboardSetup(),
  
  tags$head(tags$style(HTML("pre {white-space: pre-wrap; word-break: keep-all;}")),
            tags$style(HTML("td {vertical-align: top;text-align:center;}")),
            tags$style(HTML("img {float:none;}"))
            ),
  img(src='WordleR.png', align = "left"),
  titlePanel("An R-based WORDLE Helper"),
  tags$h3("1. Start by entering a great starter word into",  
          tags$a(href="https://www.nytimes.com/games/wordle/index.html","WORDLE"), ", like:", 
          tags$br(),
          tags$b("RECAP, FETUS, FLAKE, LYRIC, OVARY, SALVO, SLANG, or STORK")
  ),
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
             tags$tr(tags$td(actionButton("load_wordle", "Load Wordle word list",
                                          style="color: #fff; background-color: #337ab7; border-color: #2e6da4")),
                     tags$td(actionButton("load_knuth", "Load Knuth word list",
                                          style="color: #fff; background-color: #337ab7; border-color: #2e6da4"))
                     )
  ),
  tags$br(),
  tags$h3("5. Let WordleR generate your social media 'brag' post!"), 
  tags$table(
    tags$tr(
      tags$td(selectInput("wordle_brag",choices=c("genius","magnificent","impressive","splendid","great","phew"),label="Select your congrats text:"))
      ,tags$td(tags$br()),
      tags$td(textInput("wordle_paste",label="Paste your Wordle result here:", value = ""))),
    tags$tr(
      tags$td(htmlOutput("twitter_text"))
      ,tags$td(tags$br()),
      tags$td(uiOutput("twitter_clip"))
    )
  )
  ,
  tags$br(),
  tags$h4("Notes:"),
  tags$p("a. Based on the ", tags$a(href="https://bit.ly/32tqaWj","list of 2315 Wordle 'Magic Words'"),
         paste0(", with used words as of ",version," removed. "), 
         tags$a(href="https://www.rockpapershotgun.com/wordle-past-answers","See also here.")),
  tags$p("b. WordleR arranges the remaining possible words based on the frequencies of the letters of those words in the English language. 
         Words with reoccurring letters are de-emphasized."),
  # tags$p("c. IMPORTANT! Each day WordleR removes previously-used words from the 'Magic Words' list."),
  tags$p("c. WordleR's recommended 'starter' words are the top remaining starter words as evaluated by the WordleR Autoplayer notebook. See the figure below."),  
  tags$p("d. WordleR's list of 'possible' guesses is only a subset of", guess_length, "matching words."),
  tags$p("e. ",tags$a(href="https://gist.github.com/colmmacc/5783eb809f5714c30d8a8ee759e0af59","This page"),"contains some useful insights on letter and word frequency."),
  tags$p("f. WordleR is powered by R, the world's greatest data analytics language!"),
  tags$p("g. WordleR source code and a related R Notebook are available at:",
         tags$a(href="https://github.com/TheRensselaerIDEA/WordleR","https://github.com/TheRensselaerIDEA/WordleR")),
img(src='BestWordleRWords.png', align = "right",width="50%"),
tags$br(),
tags$i(paste0("WordleR version: ",version))
)

server <- function(input, output) {
  
word_list <- reactiveVal(short_list.wordle) # Initialize to Wordle words
short_list.df <- reactiveVal(short_list.wordle)

twitter_html <- reactiveVal() # with markup
twitter_raw <- reactiveVal() # for Mastodon et.al.

output$johnsguess <- renderText({
  word_list()[1]
})

  output$guess <- renderText({
    head(word_list(),guess_length)
    })

  output$possible_guesses <- renderText({
    length(word_list())
  })

  output$twitter_text <- renderUI({
    #browser()
    wordle_paste <- input$wordle_paste
    twitter_html(HTML(paste0('WordleR, the #Rstats-powered #Wordle Helper, was "',input$wordle_brag,'" today!<br/>'),
#    paste0(strsplit(input$wordle_paste,split = "")[[1]][1:15], collapse = ""),"<br/>",
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][1:17]), paste0(paste0(strsplit(wordle_paste,split = "")[[1]][1:17],  collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][18:23]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][18:23], collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][24:29]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][24:29], collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][30:35]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][30:35], collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][36:41]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][36:41], collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][42:47]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][42:47], collapse = ""),"<br/>"),""),
    ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][48:53]),paste0(paste0(strsplit(wordle_paste,split = "")[[1]][48:53], collapse = ""),"<br/>"),""),
    "http://bit.ly/WordleR"))
    
    twitter_raw(HTML(paste0('WordleR, the #Rstats-powered #Wordle Helper, was "',input$wordle_brag,'" today!\n'),
                      #    paste0(strsplit(input$wordle_paste,split = "")[[1]][1:15], collapse = ""),"<br/>",
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][1:17]), paste0("",paste0(strsplit(wordle_paste,split = "")[[1]][1:17],  collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][18:23]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][18:23], collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][24:29]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][24:29], collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][30:35]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][30:35], collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][36:41]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][36:41], collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][42:47]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][42:47], collapse = "")),""),
                      ifelse(!anyNA(strsplit(wordle_paste,split = "")[[1]][48:53]),paste0("\n",paste0(strsplit(wordle_paste,split = "")[[1]][48:53], collapse = "")),""),
                     "\n","http://bit.ly/WordleR"))
    
    twitter_html()
    
    
  })
    
  output$twitter_clip <- renderUI({
    rclipButton(
      inputId = "clipbtn", 
      label = "Copy", 
      clipText = twitter_raw(),
      icon = icon("clipboard"))
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

  observeEvent(input$load_wordle, {
    word_list(short_list.wordle)
  })

  observeEvent(input$load_knuth, {
    word_list(short_list.knuth)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
