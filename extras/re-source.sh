#!/bin/sh
me="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
RenameFiles() {
find . -name "*$1*" -print0 | while read -d $'\0' file
do
new=`echo $file | sed "s/$1/$2/g"`
echo -e "Renaming ${RED}$file${NC} \t into \t ${GREEN}$new${NC}"
mv "$file" "$new"
done
}
Replace() {
grep -rl "$1" . | grep -v $me | xargs -r sed -i s@"$1"@"$2"@g
}
Replace lynis flexy
Replace Lynis Flexy
Replace LYNIS FLEXY
Replace https://cisofy.com https://buzzworks.com
Replace "https://cisofy.com/flexy/" "https://buzzworks.com"
Replace "flexy-dev\@cisofy.com" "help\@flexydial.com"
Replace "support\@cisofy.com" "help\@flexydial.com"
Replace "https://github.com/CISOfy/flexy" "https://github.com/buzzworks"
Replace "CISOfy" "Buzzworks Business Services Pvt Ltd"
Replace "cisofy.com" "buzzworks.com"
Replace "Copyright 2007-2013, Michael Boelen" "Copyright 2012-2021, Ganapathi Chidambaram"
Replace "Michael Boelen" "Ganapathi Chidambaram"
Replace "michael.boelen\@buzzworks.com" "ganapathi.chidambaram\@flexydial.com"

RenameFiles "lynis" "flexy"