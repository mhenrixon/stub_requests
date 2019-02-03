#!/usr/bin/env bash

git checkout master
git pull --rebase

rake yard

git checkout gh-pages

shopt -s extglob
command="$(echo ./!(bin|_config.yml|_index.html))"
echo "Cleaning up current documentation: rm -rf ${command}"
rm -rf $command

echo "Copying new documentation"
mv doc/* ./

echo "Sending new documentation to github"
git add --all
git commit -a -m 'Update documentation'
git push

