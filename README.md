![WordkeR](www/WordleR.png)
# WordleR: An R-based WORDLE Helper

Live app: https://olyerickson.shinyapps.io/wordler/

a. **WordleR** is based on Knuth's list of 5757 most comment five-letter words:
<br/>&nbsp;&nbsp;&nbsp;https://www-cs-faculty.stanford.edu/~knuth/sgb-words.txt

b. Knuth's list was narrowed to 3000 words based on this analysis of English word frequency:
<br/>&nbsp;&nbsp;&nbsp;https://www.kaggle.com/rtatman/english-word-frequency

c. According to news reports, Wordle is actually based on a list of [2315 five-letter words](https://www.reddit.com/r/wordle/comments/s4tcw8/a_note_on_wordles_word_list/).

d. Wordler's recommended starter words are the top four-vowel words in Knuth's list: AUDIO, BAYOU, ADIEU, OUIJA and YOUSE.

e. Wordler's list of 'possible' guesses is a subset of 50 matching words, in word frequency order. WordleR's current guess is the top remaining most-frequent word.

f. WordleR is powered by R, the world's greatest data analytics language!

g. WordleR source code available at: https://github.com/TheRensselaerIDEA/WordleR
