#!/bin/sh

cd ~/repositories/fooforge.com
git pull

# Bootstrap fooforge.com.
bundle install
jekyll build --trace'
