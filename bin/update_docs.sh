#!/usr/bin/env bash

git checkout master

rake yard

git checkout gh-pages

shopt -s extglob
rm -rf "$(echo ./!(bin|_config.yml|_index.html))"

mv doc/* ./
git commit -a -m 'Update documentation'
git push

