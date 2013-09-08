#!/bin/bash
# AUTHOR:   fanzeyi
# CREATED:  11:19:16 15/08/2013
# MODIFIED: 11:19:16 15/08/2013

PACKAGED_PATH=`pwd`
SED_PATTERN="s/dist\/\(.*\).js/dist\/\1.min.js/"

rm -rf /tmp/`basename $PACKAGED_PATH`
cd /tmp
cp -r $PACKAGED_PATH .
cd `basename $PACKAGED_PATH`
grunt
rm -rf *.sketch
rm package.json
rm Gruntfile.js
rm -rf node_modules
rm -rf coffee
rm *.sh
rm -rf .git
rm .gitignore
cd coffee-dist
find . -not -name "*.min.js" -delete
cd ../plugins
echo `pwd`
rm *.c
rm *.o
rm *.h
rm Makefile
cd ../views
find . -name "*.html" -exec sed -i "" $SED_PATTERN {} \;
cd ../..
zip -r fmpackaged.zip `basename $PACKAGED_PATH`
