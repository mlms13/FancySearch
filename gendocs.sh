#!/bin/sh

rm -rf ./docs/xml
rm -rf ./docs/pages
haxe docs.hxml
haxelib run dox -i docs/xml/fancy.xml -o docs/pages --title "Fancy Search" -in "fancy"
