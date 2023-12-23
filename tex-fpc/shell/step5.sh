cp lib/hypthen.tex TeXinputs/
cd tex
mv ../TeXformats .
mv ../TeXfonts .
mv ../TeXinputs .
../initex ../lib/plain \\dump
mv plain.fmt TeXformats
cd ..
