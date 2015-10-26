#!/bin/sh
set -e
rm -f fancysearch.zip
zip -r fancysearch.zip src docs/ImportFancySearch.hx demo bin haxelib.json build.hxml docs.hxml gendocs.sh gulpfile.js package.json README.md -x "*/\.*"
haxelib submit fancysearch.zip
