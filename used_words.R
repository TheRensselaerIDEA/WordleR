# Retrieves past words list and updates used_words.csv et.al.
# 27 Apr 2024

library(rvest)
pastwords_link <- "https://www.rockpapershotgun.com/wordle-past-answers"

pastwords_page <- read_html(pastwords_link)

# The class is "inline"
inline_css <- pastwords_page %>%
  html_elements(css = ".inline")

pastwords_inline_css <- html_text(summaries_css)

pastwords_inline_css.df <- data.frame(cbind(c(pastwords_inline_css)))

colnames(pastwords_inline_css.df) <- c("word")

pastwords_inline_css.df$word <- tolower(pastwords_inline_css.df$word)

used_words.df <- separate_longer_delim(pastwords_inline_css.df, word, "\n")

saveRDS(used_words.df, "used_words.df.Rds")

# Now do:
# commit to github
# re-deploy to shinyapps.io
