
git checkout -B gh-pages
git rebase docs-korean
touch .nojekyll
echo '!Doc/build/' >> .gitignore
cd Doc
make html
cd ..
git add . -A
git commit -m "build"
git push -f origin gh-pages
git reset --hard HEAD
git clean -f
git checkout docs-korean
