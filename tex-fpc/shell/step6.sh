cd tex
../ch.ch/mkprod tex
tangle tex.web tex.ch
fpc -Fasysutils,baseunix,unix tex.p
cd ..
