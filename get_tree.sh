filename="${1%%.*}"
options=$2

fpc $2 -vp $1
rm $filename $filename.o
mv tree.log $filename.tree.log

