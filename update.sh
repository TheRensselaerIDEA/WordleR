#!/bin/bash
echo "Updating used_words"
R --slave --no-restore --file=used_words.R
echo "Updating version"
R --slave --no-restore --file=version.R

