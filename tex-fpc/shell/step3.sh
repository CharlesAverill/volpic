cd mf
../ch.ch/mkprod mf
tangle mf.web mf.ch
fpc -Fasysutils,baseunix,unix mf.p
cd ..
