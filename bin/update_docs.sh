#!/usr/bin/env bash

git checkout master
git pull --rebase

rake yard

git checkout gh-pages

echo "Cleaning up current documentation"
find . ! -path '*/.git*' ! -path '*/bin/update_docs.sh*' ! -path '*/_config.yml*' ! -path '*/_index.html*' ! -path '.' | xargs rm -rf

echo "Copying new documentation"
mv doc/* ./

echo "Sending new documentation to github"
git add --all
git commit -a -m 'Update documentation'
git push

