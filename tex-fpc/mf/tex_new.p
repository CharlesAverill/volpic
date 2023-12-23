{4:}{9:}{$MODE ISO}{$Q+}{$R+}{[$Q-][$R-]}{:9}

Program TEX(input,output);

Label {6:}1,9998,9999;{:6}

Const {11:}memmax = 30000;
  memmin = 0;
  bufsize = 500;
  errorline = 72;
  halferrorline = 42;
  maxprintline = 79;
  stacksize = 200;
  maxinopen = 6;
  fontmax = 75;
  fontmemsize = 20000;
  paramsize = 60;
  nestsize = 40;
  maxstrings = 3000;
  stringvacancies = 8000;
  poolsize = 32000;
  savesize = 600;
  triesize = 8000;
  trieopsize = 500;
  dvibufsize = 800;
  filenamesize = 40;
  poolname = 'TeXformats/tex.pool';{:11}

Type {18:}ASCIIcode = 0..255;
{:18}{25:}
  eightbits = 0..255;
  alphafile = text;
  bytefile = packed file Of eightbits;
  untypedfile = file;
{:25}{38:}
  poolpointer = 0..poolsize;
  strnumber = 0..maxstrings;
  packedASCIIcode = 0..255;{:38}{101:}
  scaled = integer;
  nonnegativeinteger = 0..2147483647;
  smallnumber = 0..63;
{:101}{109:}
  glueratio = single;{:109}{113:}
  quarterword = 0..255;
  halfword = 0..65535;
  twochoices = 1..2;
  fourchoices = 1..4;
  twohalves = packed Record
    rh: halfword;
    Case twochoices Of 
      1: (lh:halfword);
      2: (b0:quarterword;b1:quarterword);
  End;
  fourquarters = packed Record
    b0: quarterword;
    b1: quarterword;
    b2: quarterword;
    b3: quarterword;
  End;
  memoryword = Record
    Case fourchoices Of 
      1: (int:integer);
      2: (gr:glueratio);
      3: (hh:twohalves);
      4: (qqqq:fourquarters);
  End;
  wordfile = file Of memoryword;
{:113}{150:}
  glueord = 0..3;
{:150}{212:}
  liststaterecord = Record
    modefield: -203..203;
    headfield,tailfield: halfword;
    pgfield,mlfield: integer;
    auxfield: memoryword;
  End;{:212}{269:}
  groupcode = 0..16;
{:269}{300:}
  instaterecord = Record
    statefield,indexfield: quarterword;
    startfield,locfield,limitfield,namefield: halfword;
  End;
{:300}{548:}
  internalfontnumber = 0..fontmax;
  fontindex = 0..fontmemsize;
{:548}{594:}
  dviindex = 0..dvibufsize;{:594}{920:}
  triepointer = 0..triesize;
{:920}{925:}
  hyphpointer = 0..307;{:925}

Var {13:}bad: integer;
{:13}{20:}
  xord: array[char] Of ASCIIcode;
  xchr: array[ASCIIcode] Of char;
{:20}{26:}
  nameoffile: packed array[1..filenamesize] Of char;
  namelength: 0..filenamesize;
{:26}{30:}
  buffer: array[0..bufsize] Of ASCIIcode;
  first: 0..bufsize;
  last: 0..bufsize;
  maxbufstack: 0..bufsize;
{:30}{39:}
  strpool: packed array[poolpointer] Of packedASCIIcode;
  strstart: array[strnumber] Of poolpointer;
  poolptr: poolpointer;
  strptr: strnumber;
  initpoolptr: poolpointer;
  initstrptr: strnumber;
{:39}{50:}{poolfile:alphafile;}{:50}{54:}
  logfile: alphafile;
  selector: 0..21;
  dig: array[0..22] Of 0..15;
  tally: integer;
  termoffset: 0..maxprintline;
  fileoffset: 0..maxprintline;
  trickbuf: array[0..errorline] Of ASCIIcode;
  trickcount: integer;
  firstcount: integer;{:54}{73:}
  interaction: 0..3;
{:73}{76:}
  deletionsallowed: boolean;
  setboxallowed: boolean;
  history: 0..3;
  errorcount: -1..100;{:76}{79:}
  helpline: array[0..5] Of strnumber;
  helpptr: 0..6;
  useerrhelp: boolean;
  wantedit: boolean;
{:79}{96:}
  interrupt: integer;
  OKtointerrupt: boolean;
{:96}{104:}
  aritherror: boolean;
  remainder: scaled;
{:104}{115:}
  tempptr: halfword;
{:115}{116:}
  mem: array[memmin..memmax] Of memoryword;
  lomemmax: halfword;
  himemmin: halfword;{:116}{117:}
  varused,dynused: integer;
{:117}{118:}
  avail: halfword;
  memend: halfword;{:118}{124:}
  rover: halfword;
{:124}{165:}
{free:packed array[memmin..memmax]of boolean;
wasfree:packed array[memmin..memmax]of boolean;
wasmemend,waslomax,washimin:halfword;panicking:boolean;}
{:165}{173:}
  fontinshortdisplay: integer;
{:173}{181:}
  depththreshold: integer;
  breadthmax: integer;
{:181}{213:}
  nest: array[0..nestsize] Of liststaterecord;
  nestptr: 0..nestsize;
  maxneststack: 0..nestsize;
  curlist: liststaterecord;
  shownmode: -203..203;{:213}{246:}
  oldsetting: 0..21;
  systime,sysday,sysmonth,sysyear: integer;
{:246}{253:}
  eqtb: array[1..6106] Of memoryword;
  xeqlevel: array[5263..6106] Of quarterword;
{:253}{256:}
  hash: array[514..2880] Of twohalves;
  hashused: halfword;
  nonewcontrolsequence: boolean;
  cscount: integer;
{:256}{271:}
  savestack: array[0..savesize] Of memoryword;
  saveptr: 0..savesize;
  maxsavestack: 0..savesize;
  curlevel: quarterword;
  curgroup: groupcode;
  curboundary: 0..savesize;{:271}{286:}
  magset: integer;
{:286}{297:}
  curcmd: eightbits;
  curchr: halfword;
  curcs: halfword;
  curtok: halfword;
{:297}{301:}
  inputstack: array[0..stacksize] Of instaterecord;
  inputptr: 0..stacksize;
  maxinstack: 0..stacksize;
  curinput: instaterecord;
{:301}{304:}
  inopen: 0..maxinopen;
  openparens: 0..maxinopen;
  inputfile: array[1..maxinopen] Of alphafile;
  line: integer;
  linestack: array[1..maxinopen] Of integer;{:304}{305:}
  scannerstatus: 0..5;
  warningindex: halfword;
  defref: halfword;
{:305}{308:}
  paramstack: array[0..paramsize] Of halfword;
  paramptr: 0..paramsize;
  maxparamstack: integer;
{:308}{309:}
  alignstate: integer;{:309}{310:}
  baseptr: 0..stacksize;
{:310}{333:}
  parloc: halfword;
  partoken: halfword;
{:333}{361:}
  forceeof: boolean;{:361}{382:}
  curmark: array[0..4] Of halfword;
{:382}{387:}
  longstate: 111..114;
{:387}{388:}
  pstack: array[0..8] Of halfword;{:388}{410:}
  curval: integer;
  curvallevel: 0..5;{:410}{438:}
  radix: smallnumber;
{:438}{447:}
  curorder: glueord;
{:447}{480:}
  readfile: array[0..15] Of alphafile;
  readopen: array[0..16] Of 0..2;{:480}{489:}
  condptr: halfword;
  iflimit: 0..4;
  curif: smallnumber;
  ifline: integer;{:489}{493:}
  skipline: integer;
{:493}{512:}
  curname: strnumber;
  curarea: strnumber;
  curext: strnumber;
{:512}{513:}
  areadelimiter: poolpointer;
  extdelimiter: poolpointer;
{:513}{520:}
  TEXformatdefault: packed array[1..20] Of char;
{:520}{527:}
  nameinprogress: boolean;
  jobname: strnumber;
  logopened: boolean;
{:527}{532:}
  dvifile: bytefile;
  outputfilename: strnumber;
  logname: strnumber;
{:532}{539:}
  tfmfile: bytefile;
{:539}{549:}
  fontinfo: array[fontindex] Of memoryword;
  fmemptr: fontindex;
  fontptr: internalfontnumber;
  fontcheck: array[internalfontnumber] Of fourquarters;
  fontsize: array[internalfontnumber] Of scaled;
  fontdsize: array[internalfontnumber] Of scaled;
  fontparams: array[internalfontnumber] Of fontindex;
  fontname: array[internalfontnumber] Of strnumber;
  fontarea: array[internalfontnumber] Of strnumber;
  fontbc: array[internalfontnumber] Of eightbits;
  fontec: array[internalfontnumber] Of eightbits;
  fontglue: array[internalfontnumber] Of halfword;
  fontused: array[internalfontnumber] Of boolean;
  hyphenchar: array[internalfontnumber] Of integer;
  skewchar: array[internalfontnumber] Of integer;
  bcharlabel: array[internalfontnumber] Of fontindex;
  fontbchar: array[internalfontnumber] Of 0..256;
  fontfalsebchar: array[internalfontnumber] Of 0..256;
{:549}{550:}
  charbase: array[internalfontnumber] Of integer;
  widthbase: array[internalfontnumber] Of integer;
  heightbase: array[internalfontnumber] Of integer;
  depthbase: array[internalfontnumber] Of integer;
  italicbase: array[internalfontnumber] Of integer;
  ligkernbase: array[internalfontnumber] Of integer;
  kernbase: array[internalfontnumber] Of integer;
  extenbase: array[internalfontnumber] Of integer;
  parambase: array[internalfontnumber] Of integer;
{:550}{555:}
  nullcharacter: fourquarters;{:555}{592:}
  totalpages: integer;
  maxv: scaled;
  maxh: scaled;
  maxpush: integer;
  lastbop: integer;
  deadcycles: integer;
  doingleaders: boolean;
  c,f: quarterword;
  ruleht,ruledp,rulewd: scaled;
  g: halfword;
  lq,lr: integer;
{:592}{595:}
  dvibuf: array[dviindex] Of eightbits;
  halfbuf: dviindex;
  dvilimit: dviindex;
  dviptr: dviindex;
  dvioffset: integer;
  dvigone: integer;
{:595}{605:}
  downptr,rightptr: halfword;{:605}{616:}
  dvih,dviv: scaled;
  curh,curv: scaled;
  dvif: internalfontnumber;
  curs: integer;
{:616}{646:}
  totalstretch,totalshrink: array[glueord] Of scaled;
  lastbadness: integer;{:646}{647:}
  adjusttail: halfword;
{:647}{661:}
  packbeginline: integer;{:661}{684:}
  emptyfield: twohalves;
  nulldelimiter: fourquarters;{:684}{719:}
  curmlist: halfword;
  curstyle: smallnumber;
  cursize: smallnumber;
  curmu: scaled;
  mlistpenalties: boolean;{:719}{724:}
  curf: internalfontnumber;
  curc: quarterword;
  curi: fourquarters;{:724}{764:}
  magicoffset: integer;
{:764}{770:}
  curalign: halfword;
  curspan: halfword;
  curloop: halfword;
  alignptr: halfword;
  curhead,curtail: halfword;{:770}{814:}
  justbox: halfword;
{:814}{821:}
  passive: halfword;
  printednode: halfword;
  passnumber: halfword;
{:821}{823:}
  activewidth: array[1..6] Of scaled;
  curactivewidth: array[1..6] Of scaled;
  background: array[1..6] Of scaled;
  breakwidth: array[1..6] Of scaled;{:823}{825:}
  noshrinkerroryet: boolean;
{:825}{828:}
  curp: halfword;
  secondpass: boolean;
  finalpass: boolean;
  threshold: integer;{:828}{833:}
  minimaldemerits: array[0..3] Of integer;
  minimumdemerits: integer;
  bestplace: array[0..3] Of halfword;
  bestplline: array[0..3] Of halfword;{:833}{839:}
  discwidth: scaled;
{:839}{847:}
  easyline: halfword;
  lastspecialline: halfword;
  firstwidth: scaled;
  secondwidth: scaled;
  firstindent: scaled;
  secondindent: scaled;{:847}{872:}
  bestbet: halfword;
  fewestdemerits: integer;
  bestline: halfword;
  actuallooseness: integer;
  linediff: integer;
{:872}{892:}
  hc: array[0..65] Of 0..256;
  hn: 0..64;
  ha,hb: halfword;
  hf: internalfontnumber;
  hu: array[0..63] Of 0..256;
  hyfchar: integer;
  curlang,initcurlang: ASCIIcode;
  lhyf,rhyf,initlhyf,initrhyf: integer;
  hyfbchar: halfword;{:892}{900:}
  hyf: array[0..64] Of 0..9;
  initlist: halfword;
  initlig: boolean;
  initlft: boolean;{:900}{905:}
  hyphenpassed: smallnumber;
{:905}{907:}
  curl,curr: halfword;
  curq: halfword;
  ligstack: halfword;
  ligaturepresent: boolean;
  lfthit,rthit: boolean;
{:907}{921:}
  trie: array[triepointer] Of twohalves;
  hyfdistance: array[1..trieopsize] Of smallnumber;
  hyfnum: array[1..trieopsize] Of smallnumber;
  hyfnext: array[1..trieopsize] Of quarterword;
  opstart: array[ASCIIcode] Of 0..trieopsize;
{:921}{926:}
  hyphword: array[hyphpointer] Of strnumber;
  hyphlist: array[hyphpointer] Of halfword;
  hyphcount: hyphpointer;
{:926}{943:}
{trieophash:array[-trieopsize..trieopsize]of 0..trieopsize;
trieused:array[ASCIIcode]of quarterword;
trieoplang:array[1..trieopsize]of ASCIIcode;
trieopval:array[1..trieopsize]of quarterword;trieopptr:0..trieopsize;}
{:943}{947:}
{triec:packed array[triepointer]of packedASCIIcode;
trieo:packed array[triepointer]of quarterword;
triel:packed array[triepointer]of triepointer;
trier:packed array[triepointer]of triepointer;trieptr:triepointer;
triehash:packed array[triepointer]of triepointer;}
{:947}{950:}
{trietaken:packed array[1..triesize]of boolean;
triemin:array[ASCIIcode]of triepointer;triemax:triepointer;
trienotready:boolean;}
  {:950}{971:}
  bestheightplusdepth: scaled;
{:971}{980:}
  pagetail: halfword;
  pagecontents: 0..2;
  pagemaxdepth: scaled;
  bestpagebreak: halfword;
  leastpagecost: integer;
  bestsize: scaled;
{:980}{982:}
  pagesofar: array[0..7] Of scaled;
  lastglue: halfword;
  lastpenalty: integer;
  lastkern: scaled;
  insertpenalties: integer;
{:982}{989:}
  outputactive: boolean;{:989}{1032:}
  mainf: internalfontnumber;
  maini: fourquarters;
  mainj: fourquarters;
  maink: fontindex;
  mainp: halfword;
  mains: integer;
  bchar: halfword;
  falsebchar: halfword;
  cancelboundary: boolean;
  insdisc: boolean;{:1032}{1074:}
  curbox: halfword;
{:1074}{1266:}
  aftertoken: halfword;{:1266}{1281:}
  longhelpseen: boolean;
{:1281}{1299:}
  formatident: strnumber;{:1299}{1305:}
  fmtfile: wordfile;
{:1305}{1331:}
  readyalready: integer;
{:1331}{1342:}
  writefile: array[0..15] Of alphafile;
  writeopen: array[0..17] Of boolean;{:1342}{1345:}
  writeloc: halfword;
{:1345}
Procedure catchsignal(i:integer);
interrupt forward;
Procedure initialize;

Var {19:}i: integer;{:19}{163:}
  k: integer;
{:163}{927:}
  z: hyphpointer;{:927}
Begin{8:}{21:}
  xchr[32] := ' ';
  xchr[33] := '!';
  xchr[34] := '"';
  xchr[35] := '#';
  xchr[36] := '$';
  xchr[37] := '%';
  xchr[38] := '&';
  xchr[39] := '''';
  xchr[40] := '(';
  xchr[41] := ')';
  xchr[42] := '*';
  xchr[43] := '+';
  xchr[44] := ',';
  xchr[45] := '-';
  xchr[46] := '.';
  xchr[47] := '/';
  xchr[48] := '0';
  xchr[49] := '1';
  xchr[50] := '2';
  xchr[51] := '3';
  xchr[52] := '4';
  xchr[53] := '5';
  xchr[54] := '6';
  xchr[55] := '7';
  xchr[56] := '8';
  xchr[57] := '9';
  xchr[58] := ':';
  xchr[59] := ';';
  xchr[60] := '<';
  xchr[61] := '=';
  xchr[62] := '>';
  xchr[63] := '?';
  xchr[64] := '@';
  xchr[65] := 'A';
  xchr[66] := 'B';
  xchr[67] := 'C';
  xchr[68] := 'D';
  xchr[69] := 'E';
  xchr[70] := 'F';
  xchr[71] := 'G';
  xchr[72] := 'H';
  xchr[73] := 'I';
  xchr[74] := 'J';
  xchr[75] := 'K';
  xchr[76] := 'L';
  xchr[77] := 'M';
  xchr[78] := 'N';
  xchr[79] := 'O';
  xchr[80] := 'P';
  xchr[81] := 'Q';
  xchr[82] := 'R';
  xchr[83] := 'S';
  xchr[84] := 'T';
  xchr[85] := 'U';
  xchr[86] := 'V';
  xchr[87] := 'W';
  xchr[88] := 'X';
  xchr[89] := 'Y';
  xchr[90] := 'Z';
  xchr[91] := '[';
  xchr[92] := '\';
  xchr[93] := ']';
  xchr[94] := '^';
  xchr[95] := '_';
  xchr[96] := '`';
  xchr[97] := 'a';
  xchr[98] := 'b';
  xchr[99] := 'c';
  xchr[100] := 'd';
  xchr[101] := 'e';
  xchr[102] := 'f';
  xchr[103] := 'g';
  xchr[104] := 'h';
  xchr[105] := 'i';
  xchr[106] := 'j';
  xchr[107] := 'k';
  xchr[108] := 'l';
  xchr[109] := 'm';
  xchr[110] := 'n';
  xchr[111] := 'o';
  xchr[112] := 'p';
  xchr[113] := 'q';
  xchr[114] := 'r';
  xchr[115] := 's';
  xchr[116] := 't';
  xchr[117] := 'u';
  xchr[118] := 'v';
  xchr[119] := 'w';
  xchr[120] := 'x';
  xchr[121] := 'y';
  xchr[122] := 'z';
  xchr[123] := '{';
  xchr[124] := '|';
  xchr[125] := '}';
  xchr[126] := '~';{:21}{23:}
  For i:=0 To 31 Do
    xchr[i] := ' ';
  xchr[9] := chr(9);
  xchr[12] := chr(12);
  For i:=127 To 255 Do
    xchr[i] := ' ';
{:23}{24:}
  For i:=0 To 255 Do
    xord[chr(i)] := 127;
  For i:=128 To 255 Do
    xord[xchr[i]] := i;
  For i:=0 To 126 Do
    xord[xchr[i]] := i;{:24}{74:}
  interaction := 3;
{:74}{77:}
  deletionsallowed := true;
  setboxallowed := true;
  errorcount := 0;
{:77}{80:}
  helpptr := 0;
  useerrhelp := false;
  wantedit := false;
{:80}{97:}
  interrupt := 0;
  OKtointerrupt := true;
{:97}{166:}{wasmemend:=memmin;waslomax:=memmin;washimin:=memmax;
panicking:=false;}{:166}{215:}
  nestptr := 0;
  maxneststack := 0;
  curlist.modefield := 1;
  curlist.headfield := 29999;
  curlist.tailfield := 29999;
  curlist.auxfield.int := -65536000;
  curlist.mlfield := 0;
  curlist.pgfield := 0;
  shownmode := 0;{991:}
  pagecontents := 0;
  pagetail := 29998;
  mem[29998].hh.rh := 0;
  lastglue := 65535;
  lastpenalty := 0;
  lastkern := 0;
  pagesofar[7] := 0;
  pagemaxdepth := 0{:991};{:215}{254:}
  For k:=5263 To 6106 Do
    xeqlevel[k] := 1;
{:254}{257:}
  nonewcontrolsequence := true;
  hash[514].lh := 0;
  hash[514].rh := 0;
  For k:=515 To 2880 Do
    hash[k] := hash[514];{:257}{272:}
  saveptr := 0;
  curlevel := 1;
  curgroup := 0;
  curboundary := 0;
  maxsavestack := 0;
{:272}{287:}
  magset := 0;{:287}{383:}
  curmark[0] := 0;
  curmark[1] := 0;
  curmark[2] := 0;
  curmark[3] := 0;
  curmark[4] := 0;{:383}{439:}
  curval := 0;
  curvallevel := 0;
  radix := 0;
  curorder := 0;
{:439}{481:}
  For k:=0 To 16 Do
    readopen[k] := 2;{:481}{490:}
  condptr := 0;
  iflimit := 0;
  curif := 0;
  ifline := 0;
{:490}{521:}
  TEXformatdefault := 'TeXformats/plain.fmt';
{:521}{551:}
  For k:=0 To fontmax Do
    fontused[k] := false;
{:551}{556:}
  nullcharacter.b0 := 0;
  nullcharacter.b1 := 0;
  nullcharacter.b2 := 0;
  nullcharacter.b3 := 0;{:556}{593:}
  totalpages := 0;
  maxv := 0;
  maxh := 0;
  maxpush := 0;
  lastbop := -1;
  doingleaders := false;
  deadcycles := 0;
  curs := -1;
{:593}{596:}
  halfbuf := dvibufsize Div 2;
  dvilimit := dvibufsize;
  dviptr := 0;
  dvioffset := 0;
  dvigone := 0;{:596}{606:}
  downptr := 0;
  rightptr := 0;
{:606}{648:}
  adjusttail := 0;
  lastbadness := 0;{:648}{662:}
  packbeginline := 0;
{:662}{685:}
  emptyfield.rh := 0;
  emptyfield.lh := 0;
  nulldelimiter.b0 := 0;
  nulldelimiter.b1 := 0;
  nulldelimiter.b2 := 0;
  nulldelimiter.b3 := 0;
{:685}{771:}
  alignptr := 0;
  curalign := 0;
  curspan := 0;
  curloop := 0;
  curhead := 0;
  curtail := 0;{:771}{928:}
  For z:=0 To 307 Do
    Begin
      hyphword[z] := 0;
      hyphlist[z] := 0;
    End;
  hyphcount := 0;{:928}{990:}
  outputactive := false;
  insertpenalties := 0;{:990}{1033:}
  ligaturepresent := false;
  cancelboundary := false;
  lfthit := false;
  rthit := false;
  insdisc := false;
{:1033}{1267:}
  aftertoken := 0;{:1267}{1282:}
  longhelpseen := false;
{:1282}{1300:}
  formatident := 0;
{:1300}{1343:}
  For k:=0 To 17 Do
    writeopen[k] := false;
{:1343}{1381:}
  fpsignal(SIGINT,signalhandler(catchsignal));
  If fpgeterrno<>0 Then writeln('Could not install signal handler:',
                                fpgeterrno);{:1381}
{[164:]for k:=1 to 19 do mem[k].int:=0;k:=0;
while k<=19 do begin mem[k].hh.rh:=1;mem[k].hh.b0:=0;mem[k].hh.b1:=0;
k:=k+4;end;mem[6].int:=65536;mem[4].hh.b0:=1;mem[10].int:=65536;
mem[8].hh.b0:=2;mem[14].int:=65536;mem[12].hh.b0:=1;mem[15].int:=65536;
mem[12].hh.b1:=1;mem[18].int:=-65536;mem[16].hh.b0:=1;rover:=20;
mem[rover].hh.rh:=65535;mem[rover].hh.lh:=1000;
mem[rover+1].hh.lh:=rover;mem[rover+1].hh.rh:=rover;
lomemmax:=rover+1000;mem[lomemmax].hh.rh:=0;mem[lomemmax].hh.lh:=0;
for k:=29987 to 30000 do mem[k]:=mem[lomemmax];
[790:]mem[29990].hh.lh:=6714;[:790][797:]mem[29991].hh.rh:=256;
mem[29991].hh.lh:=0;[:797][820:]mem[29993].hh.b0:=1;
mem[29994].hh.lh:=65535;mem[29993].hh.b1:=0;
[:820][981:]mem[30000].hh.b1:=255;mem[30000].hh.b0:=1;
mem[30000].hh.rh:=30000;[:981][988:]mem[29998].hh.b0:=10;
mem[29998].hh.b1:=0;[:988];avail:=0;memend:=30000;himemmin:=29987;
varused:=20;dynused:=14;[:164][222:]eqtb[2881].hh.b0:=101;
eqtb[2881].hh.rh:=0;eqtb[2881].hh.b1:=0;
for k:=1 to 2880 do eqtb[k]:=eqtb[2881];[:222][228:]eqtb[2882].hh.rh:=0;
eqtb[2882].hh.b1:=1;eqtb[2882].hh.b0:=117;
for k:=2883 to 3411 do eqtb[k]:=eqtb[2882];
mem[0].hh.rh:=mem[0].hh.rh+530;[:228][232:]eqtb[3412].hh.rh:=0;
eqtb[3412].hh.b0:=118;eqtb[3412].hh.b1:=1;
for k:=3413 to 3677 do eqtb[k]:=eqtb[2881];eqtb[3678].hh.rh:=0;
eqtb[3678].hh.b0:=119;eqtb[3678].hh.b1:=1;
for k:=3679 to 3933 do eqtb[k]:=eqtb[3678];eqtb[3934].hh.rh:=0;
eqtb[3934].hh.b0:=120;eqtb[3934].hh.b1:=1;
for k:=3935 to 3982 do eqtb[k]:=eqtb[3934];eqtb[3983].hh.rh:=0;
eqtb[3983].hh.b0:=120;eqtb[3983].hh.b1:=1;
for k:=3984 to 5262 do eqtb[k]:=eqtb[3983];
for k:=0 to 255 do begin eqtb[3983+k].hh.rh:=12;eqtb[5007+k].hh.rh:=k;
eqtb[4751+k].hh.rh:=1000;end;eqtb[3996].hh.rh:=5;eqtb[4015].hh.rh:=10;
eqtb[4075].hh.rh:=0;eqtb[4020].hh.rh:=14;eqtb[4110].hh.rh:=15;
eqtb[3983].hh.rh:=9;for k:=48 to 57 do eqtb[5007+k].hh.rh:=k+28672;
for k:=65 to 90 do begin eqtb[3983+k].hh.rh:=11;
eqtb[3983+k+32].hh.rh:=11;eqtb[5007+k].hh.rh:=k+28928;
eqtb[5007+k+32].hh.rh:=k+28960;eqtb[4239+k].hh.rh:=k+32;
eqtb[4239+k+32].hh.rh:=k+32;eqtb[4495+k].hh.rh:=k;
eqtb[4495+k+32].hh.rh:=k;eqtb[4751+k].hh.rh:=999;end;
[:232][240:]for k:=5263 to 5573 do eqtb[k].int:=0;eqtb[5280].int:=1000;
eqtb[5264].int:=10000;eqtb[5304].int:=1;eqtb[5303].int:=25;
eqtb[5308].int:=92;eqtb[5311].int:=13;
for k:=0 to 255 do eqtb[5574+k].int:=-1;eqtb[5620].int:=0;
[:240][250:]for k:=5830 to 6106 do eqtb[k].int:=0;
[:250][258:]hashused:=2614;cscount:=0;eqtb[2623].hh.b0:=116;
hash[2623].rh:=502;[:258][552:]fontptr:=0;fmemptr:=7;fontname[0]:=802;
fontarea[0]:=338;hyphenchar[0]:=45;skewchar[0]:=-1;bcharlabel[0]:=0;
fontbchar[0]:=256;fontfalsebchar[0]:=256;fontbc[0]:=1;fontec[0]:=0;
fontsize[0]:=0;fontdsize[0]:=0;charbase[0]:=0;widthbase[0]:=0;
heightbase[0]:=0;depthbase[0]:=0;italicbase[0]:=0;ligkernbase[0]:=0;
kernbase[0]:=0;extenbase[0]:=0;fontglue[0]:=0;fontparams[0]:=7;
parambase[0]:=-1;for k:=0 to 6 do fontinfo[k].int:=0;
[:552][946:]for k:=-trieopsize to trieopsize do trieophash[k]:=0;
for k:=0 to 255 do trieused[k]:=0;trieopptr:=0;
[:946][951:]trienotready:=true;triel[0]:=0;triec[0]:=0;trieptr:=0;
[:951][1216:]hash[2614].rh:=1191;[:1216][1301:]formatident:=1258;
[:1301][1369:]hash[2622].rh:=1297;eqtb[2622].hh.b1:=1;
eqtb[2622].hh.b0:=113;eqtb[2622].hh.rh:=0;[:1369]}
  {:8}
End;
{57:}
Procedure println;
Begin
  Case selector Of 
    19:
        Begin
          writeln(output);
          writeln(logfile);
          termoffset := 0;
          fileoffset := 0;
        End;
    18:
        Begin
          writeln(logfile);
          fileoffset := 0;
        End;
    17:
        Begin
          writeln(output);
          termoffset := 0;
        End;
    16,20,21:;
    Else writeln(writefile[selector])
  End;
End;
{:57}{58:}
Procedure printchar(s:ASCIIcode);

Label 10;
Begin
  If {244:}s=eqtb[5312].int{:244}Then If selector<20 Then
                                        Begin
                                          println;
                                          goto 10;
                                        End;
  Case selector Of 
    19:
        Begin
          write(output,xchr[s]);
          write(logfile,xchr[s]);
          termoffset := termoffset+1;
          fileoffset := fileoffset+1;
          If termoffset=maxprintline Then
            Begin
              writeln(output);
              termoffset := 0;
            End;
          If fileoffset=maxprintline Then
            Begin
              writeln(logfile);
              fileoffset := 0;
            End;
        End;
    18:
        Begin
          write(logfile,xchr[s]);
          fileoffset := fileoffset+1;
          If fileoffset=maxprintline Then println;
        End;
    17:
        Begin
          write(output,xchr[s]);
          termoffset := termoffset+1;
          If termoffset=maxprintline Then println;
        End;
    16:;
    20: If tally<trickcount Then trickbuf[tally mod errorline] := s;
    21:
        Begin
          If poolptr<poolsize Then
            Begin
              strpool[poolptr] := s;
              poolptr := poolptr+1;
            End;
        End;
    Else write(writefile[selector],xchr[s])
  End;
  tally := tally+1;
  10:
End;{:58}{59:}
Procedure print(s:integer);

Label 10;

Var j: poolpointer;
  nl: integer;
Begin
  If s>=strptr Then s := 259
  Else If s<256 Then If s<0 Then s := 259
  Else
    Begin
      If selector>20 Then
        Begin
          printchar(s);
          goto 10;
        End;
      If ({244:}s=eqtb[5312].int{:244})Then If selector<20 Then
                                              Begin
                                                println;
                                                goto 10;
                                              End;
      nl := eqtb[5312].int;
      eqtb[5312].int := -1;
      j := strstart[s];
      While j<strstart[s+1] Do
        Begin
          printchar(strpool[j]);
          j := j+1;
        End;
      eqtb[5312].int := nl;
      goto 10;
    End;
  j := strstart[s];
  While j<strstart[s+1] Do
    Begin
      printchar(strpool[j]);
      j := j+1;
    End;
  10:
End;
{:59}{60:}
Procedure slowprint(s:integer);

Var j: poolpointer;
Begin
  If (s>=strptr)Or(s<256)Then print(s)
  Else
    Begin
      j := strstart[s];
      While j<strstart[s+1] Do
        Begin
          print(strpool[j]);
          j := j+1;
        End;
    End;
End;
{:60}{62:}
Procedure printnl(s:strnumber);
Begin
  If ((termoffset>0)And(odd(selector)))Or((fileoffset>0)And(selector
     >=18))Then println;
  print(s);
End;
{:62}{63:}
Procedure printesc(s:strnumber);

Var c: integer;
Begin{243:}
  c := eqtb[5308].int{:243};
  If c>=0 Then If c<256 Then print(c);
  slowprint(s);
End;{:63}{64:}
Procedure printthedigs(k:eightbits);
Begin
  While k>0 Do
    Begin
      k := k-1;
      If dig[k]<10 Then printchar(48+dig[k])
      Else printchar(55+dig[k]);
    End;
End;
{:64}{65:}
Procedure printint(n:integer);

Var k: 0..23;
  m: integer;
Begin
  k := 0;
  If n<0 Then
    Begin
      printchar(45);
      If n>-100000000 Then n := -n
      Else
        Begin
          m := -1-n;
          n := m Div 10;
          m := (m Mod 10)+1;
          k := 1;
          If m<10 Then dig[0] := m
          Else
            Begin
              dig[0] := 0;
              n := n+1;
            End;
        End;
    End;
  Repeat
    dig[k] := n Mod 10;
    n := n Div 10;
    k := k+1;
  Until n=0;
  printthedigs(k);
End;{:65}{262:}
Procedure printcs(p:integer);
Begin
  If p<514 Then If p>=257 Then If p=513 Then
                                 Begin
                                   printesc(504);
                                   printesc(505);
                                   printchar(32);
                                 End
  Else
    Begin
      printesc(p-257);
      If eqtb[3983+p-257].hh.rh=11 Then printchar(32);
    End
  Else If p<1 Then printesc(506)
  Else print(p-1)
  Else If p>=2881 Then
         printesc(506)
  Else If (hash[p].rh<0)Or(hash[p].rh>=strptr)Then printesc(
                                                            507)
  Else
    Begin
      printesc(hash[p].rh);
      printchar(32);
    End;
End;
{:262}{263:}
Procedure sprintcs(p:halfword);
Begin
  If p<514 Then If p<257 Then print(p-1)
  Else If p<513 Then printesc(
                              p-257)
  Else
    Begin
      printesc(504);
      printesc(505);
    End
  Else printesc(hash[p].rh);
End;
{:263}{518:}
Procedure printfilename(n,a,e:integer);
Begin
  slowprint(a);
  slowprint(n);
  slowprint(e);
End;
{:518}{699:}
Procedure printsize(s:integer);
Begin
  If s=0 Then printesc(412)
  Else If s=16 Then printesc(413)
  Else
    printesc(414);
End;{:699}{1355:}
Procedure printwritewhatsit(s:strnumber;
                            p:halfword);
Begin
  printesc(s);
  If mem[p+1].hh.lh<16 Then printint(mem[p+1].hh.lh)
  Else If mem[p+1].hh.lh
          =16 Then printchar(42)
  Else printchar(45);
End;
{:1355}{78:}
Procedure normalizeselector;
forward;
Procedure gettoken;
forward;
Procedure terminput;
forward;
Procedure showcontext;
forward;
Procedure beginfilereading;
forward;
Procedure openlogfile;
forward;
Procedure closefilesandterminate;
forward;
Procedure clearforerrorprompt;
forward;
Procedure giveerrhelp;
forward;{procedure debughelp;forward;}
{:78}{81:}
Procedure jumpout;
Begin
  goto 9998;
End;
{:81}{82:}
Procedure error;

Label 22,10;

Var c: ASCIIcode;
  s1,s2,s3,s4: integer;
Begin
  If history<2 Then history := 2;
  printchar(46);
  showcontext;
  If interaction=3 Then{83:}While true Do
                              Begin
                                22: If interaction<>3 Then
                                      goto 10;
                                clearforerrorprompt;
                                Begin;
                                  print(264);
                                  terminput;
                                End;
                                If last=first Then goto 10;
                                c := buffer[first];
                                If c>=97 Then c := c-32;
{84:}
                                Case c Of 
                                  48,49,50,51,52,53,54,55,56,57: If deletionsallowed Then
{88:}
                                                                   Begin
                                                                     s1 := curtok;
                                                                     s2 := curcmd;
                                                                     s3 := curchr;
                                                                     s4 := alignstate;
                                                                     alignstate := 1000000;
                                                                     OKtointerrupt := false;
                                                                     If (last>first+1)And(buffer[
                                                                        first+1]>=48)And(buffer[
                                                                        first+1]<=57)Then c := 
                                                                                               c*10+
                                                                                              buffer
                                                                                               [
                                                                                               first
                                                                                               +1]-
                                                                                               48*11
                                                                     Else c := c-48;
                                                                     While c>0 Do
                                                                       Begin
                                                                         gettoken;
                                                                         c := c-1;
                                                                       End;
                                                                     curtok := s1;
                                                                     curcmd := s2;
                                                                     curchr := s3;
                                                                     alignstate := s4;
                                                                     OKtointerrupt := true;
                                                                     Begin
                                                                       helpptr := 2;
                                                                       helpline[1] := 279;
                                                                       helpline[0] := 280;
                                                                     End;
                                                                     showcontext;
                                                                     goto 22;
                                                                   End{:88};
                                  {68:begin debughelp;goto 22;end;}
                                  69: If baseptr>0 Then If inputstack[baseptr].namefield>=256 Then
                                                          Begin
                                                            printnl(265);
                                                            slowprint(inputstack[baseptr].namefield)
                                                            ;
                                                            print(266);
                                                            printint(line);
                                                            interaction := 2;
                                                            wantedit := true;
                                                            jumpout;
                                                          End;
                                  72:{89:}
                                      Begin
                                        If useerrhelp Then
                                          Begin
                                            giveerrhelp;
                                            useerrhelp := false;
                                          End
                                        Else
                                          Begin
                                            If helpptr=0 Then
                                              Begin
                                                helpptr := 2;
                                                helpline[1] := 281;
                                                helpline[0] := 282;
                                              End;
                                            Repeat
                                              helpptr := helpptr-1;
                                              print(helpline[helpptr]);
                                              println;
                                            Until helpptr=0;
                                          End;
                                        Begin
                                          helpptr := 4;
                                          helpline[3] := 283;
                                          helpline[2] := 282;
                                          helpline[1] := 284;
                                          helpline[0] := 285;
                                        End;
                                        goto 22;
                                      End{:89};
                                  73:{87:}
                                      Begin
                                        beginfilereading;
                                        If last>first+1 Then
                                          Begin
                                            curinput.locfield := first+1;
                                            buffer[first] := 32;
                                          End
                                        Else
                                          Begin
                                            Begin;
                                              print(278);
                                              terminput;
                                            End;
                                            curinput.locfield := first;
                                          End;
                                        first := last;
                                        curinput.limitfield := last-1;
                                        goto 10;
                                      End{:87};
                                  81,82,83:{86:}
                                            Begin
                                              errorcount := 0;
                                              interaction := 0+c-81;
                                              print(273);
                                              Case c Of 
                                                81: printesc(274);
                                                82: printesc(275);
                                                83: printesc(276);
                                              End;
                                              print(277);
                                              println;
                                              flush(output);
                                              If c=81 Then selector := selector-1;
                                              goto 10;
                                            End{:86};
                                  88:
                                      Begin
                                        interaction := 2;
                                        jumpout;
                                      End;
                                  Else
                                End;
{85:}
                                Begin
                                  print(267);
                                  printnl(268);
                                  printnl(269);
                                  If baseptr>0 Then If inputstack[baseptr].namefield>=256 Then print
                                                      (270);
                                  If deletionsallowed Then printnl(271);
                                  printnl(272);
                                End{:85}{:84};
                              End{:83};
  errorcount := errorcount+1;
  If errorcount=100 Then
    Begin
      printnl(263);
      history := 3;
      jumpout;
    End;
{90:}
  If interaction>0 Then selector := selector-1;
  If useerrhelp Then
    Begin
      println;
      giveerrhelp;
    End
  Else While helpptr>0 Do
         Begin
           helpptr := helpptr-1;
           printnl(helpline[helpptr]);
         End;
  println;
  If interaction>0 Then selector := selector+1;
  println{:90};
  10:
End;
{:82}{93:}
Procedure fatalerror(s:strnumber);
Begin
  normalizeselector;
  Begin
    If interaction=3 Then;
    printnl(262);
    print(287);
  End;
  Begin
    helpptr := 1;
    helpline[0] := s;
  End;
  Begin
    If interaction=3 Then interaction := 2;
    If logopened Then error;
{if interaction>0 then debughelp;}
    history := 3;
    jumpout;
  End;
End;
{:93}{94:}
Procedure overflow(s:strnumber;n:integer);
Begin
  normalizeselector;
  Begin
    If interaction=3 Then;
    printnl(262);
    print(288);
  End;
  print(s);
  printchar(61);
  printint(n);
  printchar(93);
  Begin
    helpptr := 2;
    helpline[1] := 289;
    helpline[0] := 290;
  End;
  Begin
    If interaction=3 Then interaction := 2;
    If logopened Then error;
{if interaction>0 then debughelp;}
    history := 3;
    jumpout;
  End;
End;
{:94}{95:}
Procedure confusion(s:strnumber);
Begin
  normalizeselector;
  If history<2 Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(291);
      End;
      print(s);
      printchar(41);
      Begin
        helpptr := 1;
        helpline[0] := 292;
      End;
    End
  Else
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(293);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 294;
        helpline[0] := 295;
      End;
    End;
  Begin
    If interaction=3 Then interaction := 2;
    If logopened Then error;
{if interaction>0 then debughelp;}
    history := 3;
    jumpout;
  End;
End;
{:95}{1382:}
Procedure catchsignal;
interrupt;
Begin
  interrupt := i;
End;
{:1382}{:4}{27:}{$I-}
Function aopenin(Var f:alphafile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  reset(f);
  aopenin := ioresult=0;
End;
Function aopenout(Var f:alphafile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  rewrite(f);
  aopenout := ioresult=0;
End;
Function bopenin(Var f:bytefile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  reset(f);
  bopenin := ioresult=0;
End;
Function bopenout(Var f:bytefile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  rewrite(f);
  bopenout := ioresult=0;
End;
Function wopenin(Var f:wordfile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  reset(f);
  wopenin := ioresult=0;
End;
Function wopenout(Var f:wordfile): boolean;
Begin
  If ioresult=0 Then;
  assign(f,nameoffile);
  rewrite(f);
  wopenout := ioresult=0;
End;{$I+}
{:27}{28:}
Procedure aclose(Var f:alphafile);
Begin
  close(f);
End;
Procedure bclose(Var f:bytefile);
Begin
  close(f);
End;
Procedure wclose(Var f:wordfile);
Begin
  close(f);
End;
{:28}{31:}
Function inputln(Var f:alphafile;bypasseoln:boolean): boolean;

Var lastnonblank: 0..bufsize;
Begin
  last := first;
  If eof(f)Then inputln := false
  Else
    Begin
      lastnonblank := first;
      While Not eoln(f) Do
        Begin
          If last>=maxbufstack Then
            Begin
              maxbufstack := 
                             last+1;
              If maxbufstack=bufsize Then{35:}If formatident=0 Then
                                                Begin
                                                  writeln(
                                                          output,'Buffer size exceeded!');
                                                  goto 9999;
                                                End
              Else
                Begin
                  curinput.locfield := first;
                  curinput.limitfield := last-1;
                  overflow(256,bufsize);
                End{:35};
            End;
          buffer[last] := xord[f^];
          get(f);
          last := last+1;
          If buffer[last-1]<>32 Then lastnonblank := last;
        End;
      last := lastnonblank;
      inputln := true;
      readln(f);
    End;
End;
{:31}{36:}
Procedure inputcommandln;

Var argc: integer;
  arg: shortstring;
  cc: integer;
Begin
  last := first;
  argc := 1;
  While argc<=paramcount Do
    Begin
      cc := 1;
      arg := paramstr(argc);
      argc := argc+1;
      While cc<=length(arg) Do
        Begin
          If last+1>=bufsize Then{35:}If formatident
                                         =0 Then
                                        Begin
                                          writeln(output,'Buffer size exceeded!');
                                          goto 9999;
                                        End
          Else
            Begin
              curinput.locfield := first;
              curinput.limitfield := last-1;
              overflow(256,bufsize);
            End{:35};
          If xord[arg[cc]]<>127 Then buffer[last] := xord[arg[cc]];
          last := last+1;
          cc := cc+1
        End;
      If (argc<=paramcount)Then
        Begin
          buffer[last] := 32;
          last := last+1
        End
    End
End;{:36}{37:}
Function initterminal: boolean;

Label 10;
Begin;
  inputcommandln;
  curinput.locfield := first;
  If curinput.locfield<last Then
    Begin
      initterminal := true;
      goto 10;
    End;
  While true Do
    Begin
      write(output,'**');
      If Not inputln(input,true)Then
        Begin
          writeln(output);
          initterminal := false;
          goto 10;
        End;
      curinput.locfield := first;
      While (curinput.locfield<last)And(buffer[curinput.locfield]=32) Do
        curinput.locfield := curinput.locfield+1;
      If curinput.locfield<last Then
        Begin
          initterminal := true;
          goto 10;
        End;
      writeln(output,'Please type the name of your input file or Control-D.');
    End;
  10:
End;{:37}{43:}
Function makestring: strnumber;
Begin
  If strptr=maxstrings Then overflow(258,maxstrings-initstrptr);
  strptr := strptr+1;
  strstart[strptr] := poolptr;
  makestring := strptr-1;
End;
{:43}{45:}
Function streqbuf(s:strnumber;k:integer): boolean;

Label 45;

Var j: poolpointer;
  result: boolean;
Begin
  j := strstart[s];
  While j<strstart[s+1] Do
    Begin
      If strpool[j]<>buffer[k]Then
        Begin
          result 
          := false;
          goto 45;
        End;
      j := j+1;
      k := k+1;
    End;
  result := true;
  45: streqbuf := result;
End;{:45}{46:}
Function streqstr(s,t:strnumber): boolean;

Label 45;

Var j,k: poolpointer;
  result: boolean;
Begin
  result := false;
  If (strstart[s+1]-strstart[s])<>(strstart[t+1]-strstart[t])Then goto 45;
  j := strstart[s];
  k := strstart[t];
  While j<strstart[s+1] Do
    Begin
      If strpool[j]<>strpool[k]Then goto 45;
      j := j+1;
      k := k+1;
    End;
  result := true;
  45: streqstr := result;
End;
{:46}{47:}
{function getstringsstarted:boolean;label 30,10;
var k,l:0..255;m,n:char;g:strnumber;a:integer;c:boolean;
begin poolptr:=0;strptr:=0;strstart[0]:=0;
[48:]for k:=0 to 255 do begin if([49:](k<32)or(k>126)[:49])then begin
begin strpool[poolptr]:=94;poolptr:=poolptr+1;end;
begin strpool[poolptr]:=94;poolptr:=poolptr+1;end;
if k<64 then begin strpool[poolptr]:=k+64;poolptr:=poolptr+1;
end else if k<128 then begin strpool[poolptr]:=k-64;poolptr:=poolptr+1;
end else begin l:=k div 16;if l<10 then begin strpool[poolptr]:=l+48;
poolptr:=poolptr+1;end else begin strpool[poolptr]:=l+87;
poolptr:=poolptr+1;end;l:=k mod 16;
if l<10 then begin strpool[poolptr]:=l+48;poolptr:=poolptr+1;
end else begin strpool[poolptr]:=l+87;poolptr:=poolptr+1;end;end;
end else begin strpool[poolptr]:=k;poolptr:=poolptr+1;end;g:=makestring;
end[:48];[51:]nameoffile:=poolname;
if aopenin(poolfile)then begin c:=false;
repeat[52:]begin if eof(poolfile)then begin;
writeln(output,'! TEX.POOL has no check sum.');getstringsstarted:=false;
goto 10;end;read(poolfile,m,n);if m='*'then[53:]begin a:=0;k:=1;
while true do begin if(xord[n]<48)or(xord[n]>57)then begin;
writeln(output,'! TEX.POOL check sum doesn''t have nine digits.');
getstringsstarted:=false;goto 10;end;a:=10*a+xord[n]-48;
if k=9 then goto 30;k:=k+1;read(poolfile,n);end;
30:if a<>305924274 then begin;
writeln(output,'! TeXformats/tex.pool doesn''t match. Not installed?');
getstringsstarted:=false;goto 10;end;c:=true;
end[:53]else begin if(xord[m]<48)or(xord[m]>57)or(xord[n]<48)or(xord[n]>
57)then begin;
writeln(output,'! TEX.POOL line doesn''t begin with two digits.');
getstringsstarted:=false;goto 10;end;l:=xord[m]*10+xord[n]-48*11;
if poolptr+l+stringvacancies>poolsize then begin;
writeln(output,'! You have to increase POOLSIZE.');
getstringsstarted:=false;goto 10;end;
for k:=1 to l do begin if eoln(poolfile)then m:=' 'else read(poolfile,m)
;begin strpool[poolptr]:=xord[m];poolptr:=poolptr+1;end;end;
readln(poolfile);g:=makestring;end;end[:52];until c;aclose(poolfile);
getstringsstarted:=true;end else begin;
writeln(output,'! I can''t read TeXformats/tex.pool.');
getstringsstarted:=false;goto 10;end[:51];10:end;}
{:47}{66:}
Procedure printtwo(n:integer);
Begin
  n := abs(n)Mod 100;
  printchar(48+(n Div 10));
  printchar(48+(n Mod 10));
End;
{:66}{67:}
Procedure printhex(n:integer);

Var k: 0..22;
Begin
  k := 0;
  printchar(34);
  Repeat
    dig[k] := n Mod 16;
    n := n Div 16;
    k := k+1;
  Until n=0;
  printthedigs(k);
End;{:67}{69:}
Procedure printromanint(n:integer);

Label 10;

Var j,k: poolpointer;
  u,v: nonnegativeinteger;
Begin
  j := strstart[260];
  v := 1000;
  While true Do
    Begin
      While n>=v Do
        Begin
          printchar(strpool[j]);
          n := n-v;
        End;
      If n<=0 Then goto 10;
      k := j+2;
      u := v Div(strpool[k-1]-48);
      If strpool[k-1]=50 Then
        Begin
          k := k+2;
          u := u Div(strpool[k-1]-48);
        End;
      If n+u>=v Then
        Begin
          printchar(strpool[k]);
          n := n+u;
        End
      Else
        Begin
          j := j+2;
          v := v Div(strpool[j-1]-48);
        End;
    End;
  10:
End;
{:69}{70:}
Procedure printcurrentstring;

Var j: poolpointer;
Begin
  j := strstart[strptr];
  While j<poolptr Do
    Begin
      printchar(strpool[j]);
      j := j+1;
    End;
End;
{:70}{71:}
Procedure terminput;

Var k: 0..bufsize;
Begin
  flush(output);
  If Not inputln(input,true)Then fatalerror(261);
  termoffset := 0;
  selector := selector-1;
  If last<>first Then For k:=first To last-1 Do
                        print(buffer[k]);
  println;
  selector := selector+1;
End;{:71}{91:}
Procedure interror(n:integer);
Begin
  print(286);
  printint(n);
  printchar(41);
  error;
End;
{:91}{92:}
Procedure normalizeselector;
Begin
  If logopened Then selector := 19
  Else selector := 17;
  If jobname=0 Then openlogfile;
  If interaction=0 Then selector := selector-1;
End;
{:92}{98:}
Procedure pauseforinstructions;
Begin
  If OKtointerrupt Then
    Begin
      interaction := 3;
      If (selector=18)Or(selector=16)Then selector := selector+1;
      Begin
        If interaction=3 Then;
        printnl(262);
        print(296);
      End;
      Begin
        helpptr := 3;
        helpline[2] := 297;
        helpline[1] := 298;
        helpline[0] := 299;
      End;
      deletionsallowed := false;
      error;
      deletionsallowed := true;
      interrupt := 0;
    End;
End;{:98}{100:}
Function half(x:integer): integer;
Begin
  If odd(x)Then half := (x+1)Div 2
  Else half := x Div 2;
End;
{:100}{102:}
Function rounddecimals(k:smallnumber): scaled;

Var a: integer;
Begin
  a := 0;
  While k>0 Do
    Begin
      k := k-1;
      a := (a+dig[k]*131072)Div 10;
    End;
  rounddecimals := (a+1)Div 2;
End;
{:102}{103:}
Procedure printscaled(s:scaled);

Var delta: scaled;
Begin
  If s<0 Then
    Begin
      printchar(45);
      s := -s;
    End;
  printint(s Div 65536);
  printchar(46);
  s := 10*(s Mod 65536)+5;
  delta := 10;
  Repeat
    If delta>65536 Then s := s-17232;
    printchar(48+(s Div 65536));
    s := 10*(s Mod 65536);
    delta := delta*10;
  Until s<=delta;
End;
{:103}{105:}
Function multandadd(n:integer;x,y,maxanswer:scaled): scaled;
Begin
  If n<0 Then
    Begin
      x := -x;
      n := -n;
    End;
  If n=0 Then multandadd := y
  Else If ((x<=(maxanswer-y)Div n)And(-x<=(
          maxanswer+y)Div n))Then multandadd := n*x+y
  Else
    Begin
      aritherror := true;
      multandadd := 0;
    End;
End;{:105}{106:}
Function xovern(x:scaled;
                n:integer): scaled;

Var negative: boolean;
Begin
  negative := false;
  If n=0 Then
    Begin
      aritherror := true;
      xovern := 0;
      remainder := x;
    End
  Else
    Begin
      If n<0 Then
        Begin
          x := -x;
          n := -n;
          negative := true;
        End;
      If x>=0 Then
        Begin
          xovern := x Div n;
          remainder := x Mod n;
        End
      Else
        Begin
          xovern := -((-x)Div n);
          remainder := -((-x)Mod n);
        End;
    End;
  If negative Then remainder := -remainder;
End;
{:106}{107:}
Function xnoverd(x:scaled;n,d:integer): scaled;

Var positive: boolean;
  t,u,v: nonnegativeinteger;
Begin
  If x>=0 Then positive := true
  Else
    Begin
      x := -x;
      positive := false;
    End;
  t := (x Mod 32768)*n;
  u := (x Div 32768)*n+(t Div 32768);
  v := (u Mod d)*32768+(t Mod 32768);
  If u Div d>=32768 Then aritherror := true
  Else u := 32768*(u Div d)+(v Div d
            );
  If positive Then
    Begin
      xnoverd := u;
      remainder := v Mod d;
    End
  Else
    Begin
      xnoverd := -u;
      remainder := -(v Mod d);
    End;
End;
{:107}{108:}
Function badness(t,s:scaled): halfword;

Var r: integer;
Begin
  If t=0 Then badness := 0
  Else If s<=0 Then badness := 10000
  Else
    Begin
      If t<=7230584 Then r := (t*297)Div s
      Else If s>=1663497 Then r := t Div(s
                                   Div 297)
      Else r := t;
      If r>1290 Then badness := 10000
      Else badness := (r*r*r+131072)Div 262144;
    End;
End;{:108}{114:}
{procedure printword(w:memoryword);
begin printint(w.int);printchar(32);printscaled(w.int);printchar(32);
printscaled(round(65536*w.gr));println;printint(w.hh.lh);printchar(61);
printint(w.hh.b0);printchar(58);printint(w.hh.b1);printchar(59);
printint(w.hh.rh);printchar(32);printint(w.qqqq.b0);printchar(58);
printint(w.qqqq.b1);printchar(58);printint(w.qqqq.b2);printchar(58);
printint(w.qqqq.b3);end;}
{:114}{119:}{292:}
Procedure showtokenlist(p,q:integer;l:integer);

Label 10;

Var m,c: integer;
  matchchr: ASCIIcode;
  n: ASCIIcode;
Begin
  matchchr := 35;
  n := 48;
  tally := 0;
  While (p<>0)And(tally<l) Do
    Begin
      If p=q Then{320:}
        Begin
          firstcount := tally
          ;
          trickcount := tally+1+errorline-halferrorline;
          If trickcount<errorline Then trickcount := errorline;
        End{:320};
{293:}
      If (p<himemmin)Or(p>memend)Then
        Begin
          printesc(309);
          goto 10;
        End;
      If mem[p].hh.lh>=4095 Then printcs(mem[p].hh.lh-4095)
      Else
        Begin
          m := mem[p
               ].hh.lh Div 256;
          c := mem[p].hh.lh Mod 256;
          If mem[p].hh.lh<0 Then printesc(555)
          Else{294:}Case m Of 
                      1,2,3,4,7,8,10,
                      11,12: print(c);
                      6:
                         Begin
                           print(c);
                           print(c);
                         End;
                      5:
                         Begin
                           print(matchchr);
                           If c<=9 Then printchar(c+48)
                           Else
                             Begin
                               printchar(33);
                               goto 10;
                             End;
                         End;
                      13:
                          Begin
                            matchchr := c;
                            print(c);
                            n := n+1;
                            printchar(n);
                            If n>57 Then goto 10;
                          End;
                      14: print(556);
                      Else printesc(555)
            End{:294};
        End{:293};
      p := mem[p].hh.rh;
    End;
  If p<>0 Then printesc(554);
  10:
End;{:292}{306:}
Procedure runaway;

Var p: halfword;
Begin
  If scannerstatus>1 Then
    Begin
      printnl(569);
      Case scannerstatus Of 
        2:
           Begin
             print(570);
             p := defref;
           End;
        3:
           Begin
             print(571);
             p := 29997;
           End;
        4:
           Begin
             print(572);
             p := 29996;
           End;
        5:
           Begin
             print(573);
             p := defref;
           End;
      End;
      printchar(63);
      println;
      showtokenlist(mem[p].hh.rh,0,errorline-10);
    End;
End;
{:306}{:119}{120:}
Function getavail: halfword;

Var p: halfword;
Begin
  p := avail;
  If p<>0 Then avail := mem[avail].hh.rh
  Else If memend<memmax Then
         Begin
           memend := memend+1;
           p := memend;
         End
  Else
    Begin
      himemmin := himemmin-1;
      p := himemmin;
      If himemmin<=lomemmax Then
        Begin
          runaway;
          overflow(300,memmax+1-memmin);
        End;
    End;
  mem[p].hh.rh := 0;
  dynused := dynused+1;
  getavail := p;
End;
{:120}{123:}
Procedure flushlist(p:halfword);

Var q,r: halfword;
Begin
  If p<>0 Then
    Begin
      r := p;
      Repeat
        q := r;
        r := mem[r].hh.rh;
        dynused := dynused-1;
      Until r=0;
      mem[q].hh.rh := avail;
      avail := p;
    End;
End;
{:123}{125:}
Function getnode(s:integer): halfword;

Label 40,10,20;

Var p: halfword;
  q: halfword;
  r: integer;
  t: integer;
Begin
  20: p := rover;
  Repeat{127:}
    q := p+mem[p].hh.lh;
    While (mem[q].hh.rh=65535) Do
      Begin
        t := mem[q+1].hh.rh;
        If q=rover Then rover := t;
        mem[t+1].hh.lh := mem[q+1].hh.lh;
        mem[mem[q+1].hh.lh+1].hh.rh := t;
        q := q+mem[q].hh.lh;
      End;
    r := q-s;
    If r>p+1 Then{128:}
      Begin
        mem[p].hh.lh := r-p;
        rover := p;
        goto 40;
      End{:128};
    If r=p Then If mem[p+1].hh.rh<>p Then{129:}
                  Begin
                    rover := mem[p+1].hh.rh;
                    t := mem[p+1].hh.lh;
                    mem[rover+1].hh.lh := t;
                    mem[t+1].hh.rh := rover;
                    goto 40;
                  End{:129};
    mem[p].hh.lh := q-p{:127};
    p := mem[p+1].hh.rh;
  Until p=rover;
  If s=1073741824 Then
    Begin
      getnode := 65535;
      goto 10;
    End;
  If lomemmax+2<himemmin Then If lomemmax+2<=65535 Then{126:}
                                Begin
                                  If 
                                     himemmin-lomemmax>=1998 Then t := lomemmax+1000
                                  Else t := lomemmax+1+(
                                            himemmin-lomemmax)Div 2;
                                  p := mem[rover+1].hh.lh;
                                  q := lomemmax;
                                  mem[p+1].hh.rh := q;
                                  mem[rover+1].hh.lh := q;
                                  If t>65535 Then t := 65535;
                                  mem[q+1].hh.rh := rover;
                                  mem[q+1].hh.lh := p;
                                  mem[q].hh.rh := 65535;
                                  mem[q].hh.lh := t-lomemmax;
                                  lomemmax := t;
                                  mem[lomemmax].hh.rh := 0;
                                  mem[lomemmax].hh.lh := 0;
                                  rover := q;
                                  goto 20;
                                End{:126};
  overflow(300,memmax+1-memmin);
  40: mem[r].hh.rh := 0;
  varused := varused+s;
  getnode := r;
  10:
End;{:125}{130:}
Procedure freenode(p:halfword;s:halfword);

Var q: halfword;
Begin
  mem[p].hh.lh := s;
  mem[p].hh.rh := 65535;
  q := mem[rover+1].hh.lh;
  mem[p+1].hh.lh := q;
  mem[p+1].hh.rh := rover;
  mem[rover+1].hh.lh := p;
  mem[q+1].hh.rh := p;
  varused := varused-s;
End;
{:130}{131:}
{procedure sortavail;var p,q,r:halfword;oldrover:halfword;
begin p:=getnode(1073741824);p:=mem[rover+1].hh.rh;
mem[rover+1].hh.rh:=65535;oldrover:=rover;
while p<>oldrover do[132:]if p<rover then begin q:=p;p:=mem[q+1].hh.rh;
mem[q+1].hh.rh:=rover;rover:=q;end else begin q:=rover;
while mem[q+1].hh.rh<p do q:=mem[q+1].hh.rh;r:=mem[p+1].hh.rh;
mem[p+1].hh.rh:=mem[q+1].hh.rh;mem[q+1].hh.rh:=p;p:=r;end[:132];
p:=rover;
while mem[p+1].hh.rh<>65535 do begin mem[mem[p+1].hh.rh+1].hh.lh:=p;
p:=mem[p+1].hh.rh;end;mem[p+1].hh.rh:=rover;mem[rover+1].hh.lh:=p;end;}
{:131}{136:}
Function newnullbox: halfword;

Var p: halfword;
Begin
  p := getnode(7);
  mem[p].hh.b0 := 0;
  mem[p].hh.b1 := 0;
  mem[p+1].int := 0;
  mem[p+2].int := 0;
  mem[p+3].int := 0;
  mem[p+4].int := 0;
  mem[p+5].hh.rh := 0;
  mem[p+5].hh.b0 := 0;
  mem[p+5].hh.b1 := 0;
  mem[p+6].gr := 0.0;
  newnullbox := p;
End;
{:136}{139:}
Function newrule: halfword;

Var p: halfword;
Begin
  p := getnode(4);
  mem[p].hh.b0 := 2;
  mem[p].hh.b1 := 0;
  mem[p+1].int := -1073741824;
  mem[p+2].int := -1073741824;
  mem[p+3].int := -1073741824;
  newrule := p;
End;
{:139}{144:}
Function newligature(f,c:quarterword;q:halfword): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 6;
  mem[p+1].hh.b0 := f;
  mem[p+1].hh.b1 := c;
  mem[p+1].hh.rh := q;
  mem[p].hh.b1 := 0;
  newligature := p;
End;
Function newligitem(c:quarterword): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b1 := c;
  mem[p+1].hh.rh := 0;
  newligitem := p;
End;
{:144}{145:}
Function newdisc: halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 7;
  mem[p].hh.b1 := 0;
  mem[p+1].hh.lh := 0;
  mem[p+1].hh.rh := 0;
  newdisc := p;
End;{:145}{147:}
Function newmath(w:scaled;
                 s:smallnumber): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 9;
  mem[p].hh.b1 := s;
  mem[p+1].int := w;
  newmath := p;
End;
{:147}{151:}
Function newspec(p:halfword): halfword;

Var q: halfword;
Begin
  q := getnode(4);
  mem[q] := mem[p];
  mem[q].hh.rh := 0;
  mem[q+1].int := mem[p+1].int;
  mem[q+2].int := mem[p+2].int;
  mem[q+3].int := mem[p+3].int;
  newspec := q;
End;
{:151}{152:}
Function newparamglue(n:smallnumber): halfword;

Var p: halfword;
  q: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 10;
  mem[p].hh.b1 := n+1;
  mem[p+1].hh.rh := 0;
  q := {224:}eqtb[2882+n].hh.rh{:224};
  mem[p+1].hh.lh := q;
  mem[q].hh.rh := mem[q].hh.rh+1;
  newparamglue := p;
End;
{:152}{153:}
Function newglue(q:halfword): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 10;
  mem[p].hh.b1 := 0;
  mem[p+1].hh.rh := 0;
  mem[p+1].hh.lh := q;
  mem[q].hh.rh := mem[q].hh.rh+1;
  newglue := p;
End;
{:153}{154:}
Function newskipparam(n:smallnumber): halfword;

Var p: halfword;
Begin
  tempptr := newspec({224:}eqtb[2882+n].hh.rh{:224});
  p := newglue(tempptr);
  mem[tempptr].hh.rh := 0;
  mem[p].hh.b1 := n+1;
  newskipparam := p;
End;{:154}{156:}
Function newkern(w:scaled): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 11;
  mem[p].hh.b1 := 0;
  mem[p+1].int := w;
  newkern := p;
End;
{:156}{158:}
Function newpenalty(m:integer): halfword;

Var p: halfword;
Begin
  p := getnode(2);
  mem[p].hh.b0 := 12;
  mem[p].hh.b1 := 0;
  mem[p+1].int := m;
  newpenalty := p;
End;{:158}{167:}
{procedure checkmem(printlocs:boolean);
label 31,32;var p,q:halfword;clobbered:boolean;
begin for p:=memmin to lomemmax do free[p]:=false;
for p:=himemmin to memend do free[p]:=false;[168:]p:=avail;q:=0;
clobbered:=false;
while p<>0 do begin if(p>memend)or(p<himemmin)then clobbered:=true else
if free[p]then clobbered:=true;if clobbered then begin printnl(301);
printint(q);goto 31;end;free[p]:=true;q:=p;p:=mem[q].hh.rh;end;
31:[:168];[169:]p:=rover;q:=0;clobbered:=false;
repeat if(p>=lomemmax)or(p<memmin)then clobbered:=true else if(mem[p+1].
hh.rh>=lomemmax)or(mem[p+1].hh.rh<memmin)then clobbered:=true else if
not((mem[p].hh.rh=65535))or(mem[p].hh.lh<2)or(p+mem[p].hh.lh>lomemmax)or
(mem[mem[p+1].hh.rh+1].hh.lh<>p)then clobbered:=true;
if clobbered then begin printnl(302);printint(q);goto 32;end;
for q:=p to p+mem[p].hh.lh-1 do begin if free[q]then begin printnl(303);
printint(q);goto 32;end;free[q]:=true;end;q:=p;p:=mem[p+1].hh.rh;
until p=rover;32:[:169];[170:]p:=memmin;
while p<=lomemmax do begin if(mem[p].hh.rh=65535)then begin printnl(304)
;printint(p);end;while(p<=lomemmax)and not free[p]do p:=p+1;
while(p<=lomemmax)and free[p]do p:=p+1;end[:170];
if printlocs then[171:]begin printnl(305);
for p:=memmin to lomemmax do if not free[p]and((p>waslomax)or wasfree[p]
)then begin printchar(32);printint(p);end;
for p:=himemmin to memend do if not free[p]and((p<washimin)or(p>
wasmemend)or wasfree[p])then begin printchar(32);printint(p);end;
end[:171];for p:=memmin to lomemmax do wasfree[p]:=free[p];
for p:=himemmin to memend do wasfree[p]:=free[p];wasmemend:=memend;
waslomax:=lomemmax;washimin:=himemmin;end;}
{:167}{172:}
{procedure searchmem(p:halfword);var q:integer;
begin for q:=memmin to lomemmax do begin if mem[q].hh.rh=p then begin
printnl(306);printint(q);printchar(41);end;
if mem[q].hh.lh=p then begin printnl(307);printint(q);printchar(41);end;
end;
for q:=himemmin to memend do begin if mem[q].hh.rh=p then begin printnl(
306);printint(q);printchar(41);end;
if mem[q].hh.lh=p then begin printnl(307);printint(q);printchar(41);end;
end;
[255:]for q:=1 to 3933 do begin if eqtb[q].hh.rh=p then begin printnl(
501);printint(q);printchar(41);end;end[:255];
[285:]if saveptr>0 then for q:=0 to saveptr-1 do begin if savestack[q].
hh.rh=p then begin printnl(546);printint(q);printchar(41);end;end[:285];
[933:]for q:=0 to 307 do begin if hyphlist[q]=p then begin printnl(941);
printint(q);printchar(41);end;end[:933];end;}
{:172}{174:}
Procedure shortdisplay(p:integer);

Var n: integer;
Begin
  While p>memmin Do
    Begin
      If (p>=himemmin)Then
        Begin
          If p<=memend
            Then
            Begin
              If mem[p].hh.b0<>fontinshortdisplay Then
                Begin
                  If (mem[p].hh.
                     b0<0)Or(mem[p].hh.b0>fontmax)Then printchar(42)
                  Else{267:}printesc(hash[
                                     2624+mem[p].hh.b0].rh){:267};
                  printchar(32);
                  fontinshortdisplay := mem[p].hh.b0;
                End;
              print(mem[p].hh.b1);
            End;
        End
      Else{175:}Case mem[p].hh.b0 Of 
                  0,1,3,8,4,5,13: print(308);
                  2: printchar(124);
                  10: If mem[p+1].hh.lh<>0 Then printchar(32);
                  9: printchar(36);
                  6: shortdisplay(mem[p+1].hh.rh);
                  7:
                     Begin
                       shortdisplay(mem[p+1].hh.lh);
                       shortdisplay(mem[p+1].hh.rh);
                       n := mem[p].hh.b1;
                       While n>0 Do
                         Begin
                           If mem[p].hh.rh<>0 Then p := mem[p].hh.rh;
                           n := n-1;
                         End;
                     End;
                  Else
        End{:175};
      p := mem[p].hh.rh;
    End;
End;
{:174}{176:}
Procedure printfontandchar(p:integer);
Begin
  If p>memend Then printesc(309)
  Else
    Begin
      If (mem[p].hh.b0<0)Or(mem[
         p].hh.b0>fontmax)Then printchar(42)
      Else{267:}printesc(hash[2624+mem[p].
                         hh.b0].rh){:267};
      printchar(32);
      print(mem[p].hh.b1);
    End;
End;
Procedure printmark(p:integer);
Begin
  printchar(123);
  If (p<himemmin)Or(p>memend)Then printesc(309)
  Else showtokenlist(mem[p].hh
                     .rh,0,maxprintline-10);
  printchar(125);
End;
Procedure printruledimen(d:scaled);
Begin
  If (d=-1073741824)Then printchar(42)
  Else printscaled(d);
End;
{:176}{177:}
Procedure printglue(d:scaled;order:integer;s:strnumber);
Begin
  printscaled(d);
  If (order<0)Or(order>3)Then print(310)
  Else If order>0 Then
         Begin
           print(
                 311);
           While order>1 Do
             Begin
               printchar(108);
               order := order-1;
             End;
         End
  Else If s<>0 Then print(s);
End;
{:177}{178:}
Procedure printspec(p:integer;s:strnumber);
Begin
  If (p<memmin)Or(p>=lomemmax)Then printchar(42)
  Else
    Begin
      printscaled(mem[p+1].int);
      If s<>0 Then print(s);
      If mem[p+2].int<>0 Then
        Begin
          print(312);
          printglue(mem[p+2].int,mem[p].hh.b0,s);
        End;
      If mem[p+3].int<>0 Then
        Begin
          print(313);
          printglue(mem[p+3].int,mem[p].hh.b1,s);
        End;
    End;
End;
{:178}{179:}{691:}
Procedure printfamandchar(p:halfword);
Begin
  printesc(464);
  printint(mem[p].hh.b0);
  printchar(32);
  print(mem[p].hh.b1);
End;
Procedure printdelimiter(p:halfword);

Var a: integer;
Begin
  a := mem[p].qqqq.b0*256+mem[p].qqqq.b1;
  a := a*4096+mem[p].qqqq.b2*256+mem[p].qqqq.b3;
  If a<0 Then printint(a)
  Else printhex(a);
End;
{:691}{692:}
Procedure showinfo;
forward;
Procedure printsubsidiarydata(p:halfword;c:ASCIIcode);
Begin
  If (poolptr-strstart[strptr])>=depththreshold Then
    Begin
      If mem[p].
         hh.rh<>0 Then print(314);
    End
  Else
    Begin
      Begin
        strpool[poolptr] := c;
        poolptr := poolptr+1;
      End;
      tempptr := p;
      Case mem[p].hh.rh Of 
        1:
           Begin
             println;
             printcurrentstring;
             printfamandchar(p);
           End;
        2: showinfo;
        3: If mem[p].hh.lh=0 Then
             Begin
               println;
               printcurrentstring;
               print(861);
             End
           Else showinfo;
        Else
      End;
      poolptr := poolptr-1;
    End;
End;
{:692}{694:}
Procedure printstyle(c:integer);
Begin
  Case c Div 2 Of 
    0: printesc(862);
    1: printesc(863);
    2: printesc(864);
    3: printesc(865);
    Else print(866)
  End;
End;
{:694}{225:}
Procedure printskipparam(n:integer);
Begin
  Case n Of 
    0: printesc(376);
    1: printesc(377);
    2: printesc(378);
    3: printesc(379);
    4: printesc(380);
    5: printesc(381);
    6: printesc(382);
    7: printesc(383);
    8: printesc(384);
    9: printesc(385);
    10: printesc(386);
    11: printesc(387);
    12: printesc(388);
    13: printesc(389);
    14: printesc(390);
    15: printesc(391);
    16: printesc(392);
    17: printesc(393);
    Else print(394)
  End;
End;{:225}{:179}{182:}
Procedure shownodelist(p:integer);

Label 10;

Var n: integer;
  g: real;
Begin
  If (poolptr-strstart[strptr])>depththreshold Then
    Begin
      If p>0 Then
        print(314);
      goto 10;
    End;
  n := 0;
  While p>memmin Do
    Begin
      println;
      printcurrentstring;
      If p>memend Then
        Begin
          print(315);
          goto 10;
        End;
      n := n+1;
      If n>breadthmax Then
        Begin
          print(316);
          goto 10;
        End;
{183:}
      If (p>=himemmin)Then printfontandchar(p)
      Else Case mem[p].hh.b0 Of 
             0
             ,1,13:{184:}
                    Begin
                      If mem[p].hh.b0=0 Then printesc(104)
                      Else If mem[p].hh.
                              b0=1 Then printesc(118)
                      Else printesc(318);
                      print(319);
                      printscaled(mem[p+3].int);
                      printchar(43);
                      printscaled(mem[p+2].int);
                      print(320);
                      printscaled(mem[p+1].int);
                      If mem[p].hh.b0=13 Then{185:}
                        Begin
                          If mem[p].hh.b1<>0 Then
                            Begin
                              print(
                                    286);
                              printint(mem[p].hh.b1+1);
                              print(322);
                            End;
                          If mem[p+6].int<>0 Then
                            Begin
                              print(323);
                              printglue(mem[p+6].int,mem[p+5].hh.b1,0);
                            End;
                          If mem[p+4].int<>0 Then
                            Begin
                              print(324);
                              printglue(mem[p+4].int,mem[p+5].hh.b0,0);
                            End;
                        End{:185}
                      Else
                        Begin{186:}
                          g := mem[p+6].gr;
                          If (g<>0.0)And(mem[p+5].hh.b0<>0)Then
                            Begin
                              print(325);
                              If mem[p+5].hh.b0=2 Then print(326);
                              If abs(mem[p+6].int)<1048576 Then print(327)
                              Else If abs(g)>20000.0 Then
                                     Begin
                                       If g>0.0 Then printchar(62)
                                       Else print(328);
                                       printglue(20000*65536,mem[p+5].hh.b1,0);
                                     End
                              Else printglue(round(65536*g),mem[p+5].hh.b1,0);
                            End{:186};
                          If mem[p+4].int<>0 Then
                            Begin
                              print(321);
                              printscaled(mem[p+4].int);
                            End;
                        End;
                      Begin
                        Begin
                          strpool[poolptr] := 46;
                          poolptr := poolptr+1;
                        End;
                        shownodelist(mem[p+5].hh.rh);
                        poolptr := poolptr-1;
                      End;
                    End{:184};
             2:{187:}
                Begin
                  printesc(329);
                  printruledimen(mem[p+3].int);
                  printchar(43);
                  printruledimen(mem[p+2].int);
                  print(320);
                  printruledimen(mem[p+1].int);
                End{:187};
             3:{188:}
                Begin
                  printesc(330);
                  printint(mem[p].hh.b1);
                  print(331);
                  printscaled(mem[p+3].int);
                  print(332);
                  printspec(mem[p+4].hh.rh,0);
                  printchar(44);
                  printscaled(mem[p+2].int);
                  print(333);
                  printint(mem[p+1].int);
                  Begin
                    Begin
                      strpool[poolptr] := 46;
                      poolptr := poolptr+1;
                    End;
                    shownodelist(mem[p+4].hh.lh);
                    poolptr := poolptr-1;
                  End;
                End{:188};
             8:{1356:}Case mem[p].hh.b1 Of 
                        0:
                           Begin
                             printwritewhatsit(1286,p);
                             printchar(61);
                             printfilename(mem[p+1].hh.rh,mem[p+2].hh.lh,mem[p+2].hh.rh);
                           End;
                        1:
                           Begin
                             printwritewhatsit(594,p);
                             printmark(mem[p+1].hh.rh);
                           End;
                        2: printwritewhatsit(1287,p);
                        3:
                           Begin
                             printesc(1288);
                             printmark(mem[p+1].hh.rh);
                           End;
                        4:
                           Begin
                             printesc(1290);
                             printint(mem[p+1].hh.rh);
                             print(1293);
                             printint(mem[p+1].hh.b0);
                             printchar(44);
                             printint(mem[p+1].hh.b1);
                             printchar(41);
                           End;
                        Else print(1294)
                End{:1356};
             10:{189:}If mem[p].hh.b1>=100 Then{190:}
                        Begin
                          printesc(338);
                          If mem[p].hh.b1=101 Then printchar(99)
                          Else If mem[p].hh.b1=102 Then
                                 printchar(120);
                          print(339);
                          printspec(mem[p+1].hh.lh,0);
                          Begin
                            Begin
                              strpool[poolptr] := 46;
                              poolptr := poolptr+1;
                            End;
                            shownodelist(mem[p+1].hh.rh);
                            poolptr := poolptr-1;
                          End;
                        End{:190}
                 Else
                   Begin
                     printesc(334);
                     If mem[p].hh.b1<>0 Then
                       Begin
                         printchar(40);
                         If mem[p].hh.b1<98 Then printskipparam(mem[p].hh.b1-1)
                         Else If mem[p].hh.
                                 b1=98 Then printesc(335)
                         Else printesc(336);
                         printchar(41);
                       End;
                     If mem[p].hh.b1<>98 Then
                       Begin
                         printchar(32);
                         If mem[p].hh.b1<98 Then printspec(mem[p+1].hh.lh,0)
                         Else printspec(mem[p
                                        +1].hh.lh,337);
                       End;
                   End{:189};
             11:{191:}If mem[p].hh.b1<>99 Then
                        Begin
                          printesc(340);
                          If mem[p].hh.b1<>0 Then printchar(32);
                          printscaled(mem[p+1].int);
                          If mem[p].hh.b1=2 Then print(341);
                        End
                 Else
                   Begin
                     printesc(342);
                     printscaled(mem[p+1].int);
                     print(337);
                   End{:191};
             9:{192:}
                Begin
                  printesc(343);
                  If mem[p].hh.b1=0 Then print(344)
                  Else print(345);
                  If mem[p+1].int<>0 Then
                    Begin
                      print(346);
                      printscaled(mem[p+1].int);
                    End;
                End{:192};
             6:{193:}
                Begin
                  printfontandchar(p+1);
                  print(347);
                  If mem[p].hh.b1>1 Then printchar(124);
                  fontinshortdisplay := mem[p+1].hh.b0;
                  shortdisplay(mem[p+1].hh.rh);
                  If odd(mem[p].hh.b1)Then printchar(124);
                  printchar(41);
                End{:193};
             12:{194:}
                 Begin
                   printesc(348);
                   printint(mem[p+1].int);
                 End{:194};
             7:{195:}
                Begin
                  printesc(349);
                  If mem[p].hh.b1>0 Then
                    Begin
                      print(350);
                      printint(mem[p].hh.b1);
                    End;
                  Begin
                    Begin
                      strpool[poolptr] := 46;
                      poolptr := poolptr+1;
                    End;
                    shownodelist(mem[p+1].hh.lh);
                    poolptr := poolptr-1;
                  End;
                  Begin
                    strpool[poolptr] := 124;
                    poolptr := poolptr+1;
                  End;
                  shownodelist(mem[p+1].hh.rh);
                  poolptr := poolptr-1;
                End{:195};
             4:{196:}
                Begin
                  printesc(351);
                  printmark(mem[p+1].int);
                End{:196};
             5:{197:}
                Begin
                  printesc(352);
                  Begin
                    Begin
                      strpool[poolptr] := 46;
                      poolptr := poolptr+1;
                    End;
                    shownodelist(mem[p+1].int);
                    poolptr := poolptr-1;
                  End;
                End{:197};{690:}
             14: printstyle(mem[p].hh.b1);
             15:{695:}
                 Begin
                   printesc(525);
                   Begin
                     strpool[poolptr] := 68;
                     poolptr := poolptr+1;
                   End;
                   shownodelist(mem[p+1].hh.lh);
                   poolptr := poolptr-1;
                   Begin
                     strpool[poolptr] := 84;
                     poolptr := poolptr+1;
                   End;
                   shownodelist(mem[p+1].hh.rh);
                   poolptr := poolptr-1;
                   Begin
                     strpool[poolptr] := 83;
                     poolptr := poolptr+1;
                   End;
                   shownodelist(mem[p+2].hh.lh);
                   poolptr := poolptr-1;
                   Begin
                     strpool[poolptr] := 115;
                     poolptr := poolptr+1;
                   End;
                   shownodelist(mem[p+2].hh.rh);
                   poolptr := poolptr-1;
                 End{:695};
             16,17,18,19,20,21,22,23,24,27,26,29,28,30,31:{696:}
                                                           Begin
                                                             Case mem[p].hh.
                                                                  b0 Of 
                                                               16: printesc(867);
                                                               17: printesc(868);
                                                               18: printesc(869);
                                                               19: printesc(870);
                                                               20: printesc(871);
                                                               21: printesc(872);
                                                               22: printesc(873);
                                                               23: printesc(874);
                                                               27: printesc(875);
                                                               26: printesc(876);
                                                               29: printesc(539);
                                                               24:
                                                                   Begin
                                                                     printesc(533);
                                                                     printdelimiter(p+4);
                                                                   End;
                                                               28:
                                                                   Begin
                                                                     printesc(508);
                                                                     printfamandchar(p+4);
                                                                   End;
                                                               30:
                                                                   Begin
                                                                     printesc(877);
                                                                     printdelimiter(p+1);
                                                                   End;
                                                               31:
                                                                   Begin
                                                                     printesc(878);
                                                                     printdelimiter(p+1);
                                                                   End;
                                                             End;
                                                             If mem[p].hh.b1<>0 Then If mem[p].hh.b1
                                                                                        =1 Then
                                                                                       printesc(879)
                                                             Else
                                                               printesc(880);
                                                             If mem[p].hh.b0<30 Then
                                                               printsubsidiarydata(p+1,46);
                                                             printsubsidiarydata(p+2,94);
                                                             printsubsidiarydata(p+3,95);
                                                           End{:696};
             25:{697:}
                 Begin
                   printesc(881);
                   If mem[p+1].int=1073741824 Then print(882)
                   Else printscaled(mem[p+1].int)
                   ;
                   If (mem[p+4].qqqq.b0<>0)Or(mem[p+4].qqqq.b1<>0)Or(mem[p+4].qqqq.b2<>0)Or(
                      mem[p+4].qqqq.b3<>0)Then
                     Begin
                       print(883);
                       printdelimiter(p+4);
                     End;
                   If (mem[p+5].qqqq.b0<>0)Or(mem[p+5].qqqq.b1<>0)Or(mem[p+5].qqqq.b2<>0)Or(
                      mem[p+5].qqqq.b3<>0)Then
                     Begin
                       print(884);
                       printdelimiter(p+5);
                     End;
                   printsubsidiarydata(p+2,92);
                   printsubsidiarydata(p+3,47);
                 End{:697};
{:690}
             Else print(317)
        End{:183};
      p := mem[p].hh.rh;
    End;
  10:
End;
{:182}{198:}
Procedure showbox(p:halfword);
Begin{236:}
  depththreshold := eqtb[5288].int;
  breadthmax := eqtb[5287].int{:236};
  If breadthmax<=0 Then breadthmax := 5;
  If poolptr+depththreshold>=poolsize Then depththreshold := poolsize-
                                                             poolptr-1;
  shownodelist(p);
  println;
End;
{:198}{200:}
Procedure deletetokenref(p:halfword);
Begin
  If mem[p].hh.lh=0 Then flushlist(p)
  Else mem[p].hh.lh := mem[p].hh.lh
                       -1;
End;{:200}{201:}
Procedure deleteglueref(p:halfword);
Begin
  If mem[p].hh.rh=0 Then freenode(p,4)
  Else mem[p].hh.rh := mem[p].hh.
                       rh-1;
End;{:201}{202:}
Procedure flushnodelist(p:halfword);

Label 30;

Var q: halfword;
Begin
  While p<>0 Do
    Begin
      q := mem[p].hh.rh;
      If (p>=himemmin)Then
        Begin
          mem[p].hh.rh := avail;
          avail := p;
          dynused := dynused-1;
        End
      Else
        Begin
          Case mem[p].hh.b0 Of 
            0,1,13:
                    Begin
                      flushnodelist(mem[p+5].
                                    hh.rh);
                      freenode(p,7);
                      goto 30;
                    End;
            2:
               Begin
                 freenode(p,4);
                 goto 30;
               End;
            3:
               Begin
                 flushnodelist(mem[p+4].hh.lh);
                 deleteglueref(mem[p+4].hh.rh);
                 freenode(p,5);
                 goto 30;
               End;
            8:{1358:}
               Begin
                 Case mem[p].hh.b1 Of 
                   0: freenode(p,3);
                   1,3:
                        Begin
                          deletetokenref(mem[p+1].hh.rh);
                          freenode(p,2);
                          goto 30;
                        End;
                   2,4: freenode(p,2);
                   Else confusion(1296)
                 End;
                 goto 30;
               End{:1358};
            10:
                Begin
                  Begin
                    If mem[mem[p+1].hh.lh].hh.rh=0 Then freenode(mem[p+1].hh.
                                                                 lh,4)
                    Else mem[mem[p+1].hh.lh].hh.rh := mem[mem[p+1].hh.lh].hh.rh-1;
                  End;
                  If mem[p+1].hh.rh<>0 Then flushnodelist(mem[p+1].hh.rh);
                End;
            11,9,12:;
            6: flushnodelist(mem[p+1].hh.rh);
            4: deletetokenref(mem[p+1].int);
            7:
               Begin
                 flushnodelist(mem[p+1].hh.lh);
                 flushnodelist(mem[p+1].hh.rh);
               End;
            5: flushnodelist(mem[p+1].int);{698:}
            14:
                Begin
                  freenode(p,3);
                  goto 30;
                End;
            15:
                Begin
                  flushnodelist(mem[p+1].hh.lh);
                  flushnodelist(mem[p+1].hh.rh);
                  flushnodelist(mem[p+2].hh.lh);
                  flushnodelist(mem[p+2].hh.rh);
                  freenode(p,3);
                  goto 30;
                End;
            16,17,18,19,20,21,22,23,24,27,26,29,28:
                                                    Begin
                                                      If mem[p+1].hh.rh>=2 Then
                                                        flushnodelist(mem[p+1].hh.lh);
                                                      If mem[p+2].hh.rh>=2 Then flushnodelist(mem[p+
                                                                                              2].hh.
                                                                                              lh);
                                                      If mem[p+3].hh.rh>=2 Then flushnodelist(mem[p+
                                                                                              3].hh.
                                                                                              lh);
                                                      If mem[p].hh.b0=24 Then freenode(p,5)
                                                      Else If mem[p].hh.b0=28 Then
                                                             freenode(p,5)
                                                      Else freenode(p,4);
                                                      goto 30;
                                                    End;
            30,31:
                   Begin
                     freenode(p,4);
                     goto 30;
                   End;
            25:
                Begin
                  flushnodelist(mem[p+2].hh.lh);
                  flushnodelist(mem[p+3].hh.lh);
                  freenode(p,6);
                  goto 30;
                End;
{:698}
            Else confusion(353)
          End;
          freenode(p,2);
          30:
        End;
      p := q;
    End;
End;
{:202}{204:}
Function copynodelist(p:halfword): halfword;

Var h: halfword;
  q: halfword;
  r: halfword;
  words: 0..5;
Begin
  h := getavail;
  q := h;
  While p<>0 Do
    Begin{205:}
      words := 1;
      If (p>=himemmin)Then r := getavail
      Else{206:}Case mem[p].hh.b0 Of 
                  0,1,13:
                          Begin
                            r := getnode(7);
                            mem[r+6] := mem[p+6];
                            mem[r+5] := mem[p+5];
                            mem[r+5].hh.rh := copynodelist(mem[p+5].hh.rh);
                            words := 5;
                          End;
                  2:
                     Begin
                       r := getnode(4);
                       words := 4;
                     End;
                  3:
                     Begin
                       r := getnode(5);
                       mem[r+4] := mem[p+4];
                       mem[mem[p+4].hh.rh].hh.rh := mem[mem[p+4].hh.rh].hh.rh+1;
                       mem[r+4].hh.lh := copynodelist(mem[p+4].hh.lh);
                       words := 4;
                     End;
                  8:{1357:}Case mem[p].hh.b1 Of 
                             0:
                                Begin
                                  r := getnode(3);
                                  words := 3;
                                End;
                             1,3:
                                  Begin
                                    r := getnode(2);
                                    mem[mem[p+1].hh.rh].hh.lh := mem[mem[p+1].hh.rh].hh.lh+1;
                                    words := 2;
                                  End;
                             2,4:
                                  Begin
                                    r := getnode(2);
                                    words := 2;
                                  End;
                             Else confusion(1295)
                     End{:1357};
                  10:
                      Begin
                        r := getnode(2);
                        mem[mem[p+1].hh.lh].hh.rh := mem[mem[p+1].hh.lh].hh.rh+1;
                        mem[r+1].hh.lh := mem[p+1].hh.lh;
                        mem[r+1].hh.rh := copynodelist(mem[p+1].hh.rh);
                      End;
                  11,9,12:
                           Begin
                             r := getnode(2);
                             words := 2;
                           End;
                  6:
                     Begin
                       r := getnode(2);
                       mem[r+1] := mem[p+1];
                       mem[r+1].hh.rh := copynodelist(mem[p+1].hh.rh);
                     End;
                  7:
                     Begin
                       r := getnode(2);
                       mem[r+1].hh.lh := copynodelist(mem[p+1].hh.lh);
                       mem[r+1].hh.rh := copynodelist(mem[p+1].hh.rh);
                     End;
                  4:
                     Begin
                       r := getnode(2);
                       mem[mem[p+1].int].hh.lh := mem[mem[p+1].int].hh.lh+1;
                       words := 2;
                     End;
                  5:
                     Begin
                       r := getnode(2);
                       mem[r+1].int := copynodelist(mem[p+1].int);
                     End;
                  Else confusion(354)
        End{:206};
      While words>0 Do
        Begin
          words := words-1;
          mem[r+words] := mem[p+words];
        End{:205};
      mem[q].hh.rh := r;
      q := r;
      p := mem[p].hh.rh;
    End;
  mem[q].hh.rh := 0;
  q := mem[h].hh.rh;
  Begin
    mem[h].hh.rh := avail;
    avail := h;
    dynused := dynused-1;
  End;
  copynodelist := q;
End;{:204}{211:}
Procedure printmode(m:integer);
Begin
  If m>0 Then Case m Div(101) Of 
                0: print(355);
                1: print(356);
                2: print(357);
    End
  Else If m=0 Then print(358)
  Else Case (-m)Div(101) Of 
         0: print(359);
         1: print(360);
         2: print(343);
    End;
  print(361);
End;
{:211}{216:}
Procedure pushnest;
Begin
  If nestptr>maxneststack Then
    Begin
      maxneststack := nestptr;
      If nestptr=nestsize Then overflow(362,nestsize);
    End;
  nest[nestptr] := curlist;
  nestptr := nestptr+1;
  curlist.headfield := getavail;
  curlist.tailfield := curlist.headfield;
  curlist.pgfield := 0;
  curlist.mlfield := line;
End;{:216}{217:}
Procedure popnest;
Begin
  Begin
    mem[curlist.headfield].hh.rh := avail;
    avail := curlist.headfield;
    dynused := dynused-1;
  End;
  nestptr := nestptr-1;
  curlist := nest[nestptr];
End;{:217}{218:}
Procedure printtotals;
forward;
Procedure showactivities;

Var p: 0..nestsize;
  m: -203..203;
  a: memoryword;
  q,r: halfword;
  t: integer;
Begin
  nest[nestptr] := curlist;
  printnl(338);
  println;
  For p:=nestptr Downto 0 Do
    Begin
      m := nest[p].modefield;
      a := nest[p].auxfield;
      printnl(363);
      printmode(m);
      print(364);
      printint(abs(nest[p].mlfield));
      If m=102 Then If nest[p].pgfield<>8585216 Then
                      Begin
                        print(365);
                        printint(nest[p].pgfield Mod 65536);
                        print(366);
                        printint(nest[p].pgfield Div 4194304);
                        printchar(44);
                        printint((nest[p].pgfield Div 65536)mod 64);
                        printchar(41);
                      End;
      If nest[p].mlfield<0 Then print(367);
      If p=0 Then
        Begin{986:}
          If 29998<>pagetail Then
            Begin
              printnl(981);
              If outputactive Then print(982);
              showbox(mem[29998].hh.rh);
              If pagecontents>0 Then
                Begin
                  printnl(983);
                  printtotals;
                  printnl(984);
                  printscaled(pagesofar[0]);
                  r := mem[30000].hh.rh;
                  While r<>30000 Do
                    Begin
                      println;
                      printesc(330);
                      t := mem[r].hh.b1;
                      printint(t);
                      print(985);
                      If eqtb[5318+t].int=1000 Then t := mem[r+3].int
                      Else t := xovern(mem[r+3].
                                int,1000)*eqtb[5318+t].int;
                      printscaled(t);
                      If mem[r].hh.b0=1 Then
                        Begin
                          q := 29998;
                          t := 0;
                          Repeat
                            q := mem[q].hh.rh;
                            If (mem[q].hh.b0=3)And(mem[q].hh.b1=mem[r].hh.b1)Then t := t+1;
                          Until q=mem[r+1].hh.lh;
                          print(986);
                          printint(t);
                          print(987);
                        End;
                      r := mem[r].hh.rh;
                    End;
                End;
            End{:986};
          If mem[29999].hh.rh<>0 Then printnl(368);
        End;
      showbox(mem[nest[p].headfield].hh.rh);
{219:}
      Case abs(m)Div(101) Of 
        0:
           Begin
             printnl(369);
             If a.int<=-65536000 Then print(370)
             Else printscaled(a.int);
             If nest[p].pgfield<>0 Then
               Begin
                 print(371);
                 printint(nest[p].pgfield);
                 print(372);
                 If nest[p].pgfield<>1 Then printchar(115);
               End;
           End;
        1:
           Begin
             printnl(373);
             printint(a.hh.lh);
             If m>0 Then If a.hh.rh>0 Then
                           Begin
                             print(374);
                             printint(a.hh.rh);
                           End;
           End;
        2: If a.int<>0 Then
             Begin
               print(375);
               showbox(a.int);
             End;
      End{:219};
    End;
End;{:218}{237:}
Procedure printparam(n:integer);
Begin
  Case n Of 
    0: printesc(420);
    1: printesc(421);
    2: printesc(422);
    3: printesc(423);
    4: printesc(424);
    5: printesc(425);
    6: printesc(426);
    7: printesc(427);
    8: printesc(428);
    9: printesc(429);
    10: printesc(430);
    11: printesc(431);
    12: printesc(432);
    13: printesc(433);
    14: printesc(434);
    15: printesc(435);
    16: printesc(436);
    17: printesc(437);
    18: printesc(438);
    19: printesc(439);
    20: printesc(440);
    21: printesc(441);
    22: printesc(442);
    23: printesc(443);
    24: printesc(444);
    25: printesc(445);
    26: printesc(446);
    27: printesc(447);
    28: printesc(448);
    29: printesc(449);
    30: printesc(450);
    31: printesc(451);
    32: printesc(452);
    33: printesc(453);
    34: printesc(454);
    35: printesc(455);
    36: printesc(456);
    37: printesc(457);
    38: printesc(458);
    39: printesc(459);
    40: printesc(460);
    41: printesc(461);
    42: printesc(462);
    43: printesc(463);
    44: printesc(464);
    45: printesc(465);
    46: printesc(466);
    47: printesc(467);
    48: printesc(468);
    49: printesc(469);
    50: printesc(470);
    51: printesc(471);
    52: printesc(472);
    53: printesc(473);
    54: printesc(474);
    Else print(475)
  End;
End;{:237}{241:}
Procedure fixdateandtime;

Var yy,mm,dd: word;
  hh,ss,ms: word;
Begin
  decodedate(now,yy,mm,dd);
  sysday := dd;
  eqtb[5284].int := sysday;
  sysmonth := mm;
  eqtb[5285].int := sysmonth;
  sysyear := yy;
  eqtb[5286].int := sysyear;
  decodetime(now,hh,mm,ss,ms);
  systime := hh*60+mm;
  eqtb[5283].int := systime;
End;
{:241}{245:}
Procedure begindiagnostic;
Begin
  oldsetting := selector;
  If (eqtb[5292].int<=0)And(selector=19)Then
    Begin
      selector := selector-1;
      If history=0 Then history := 1;
    End;
End;
Procedure enddiagnostic(blankline:boolean);
Begin
  printnl(338);
  If blankline Then println;
  selector := oldsetting;
End;
{:245}{247:}
Procedure printlengthparam(n:integer);
Begin
  Case n Of 
    0: printesc(478);
    1: printesc(479);
    2: printesc(480);
    3: printesc(481);
    4: printesc(482);
    5: printesc(483);
    6: printesc(484);
    7: printesc(485);
    8: printesc(486);
    9: printesc(487);
    10: printesc(488);
    11: printesc(489);
    12: printesc(490);
    13: printesc(491);
    14: printesc(492);
    15: printesc(493);
    16: printesc(494);
    17: printesc(495);
    18: printesc(496);
    19: printesc(497);
    20: printesc(498);
    Else print(499)
  End;
End;
{:247}{252:}{298:}
Procedure printcmdchr(cmd:quarterword;
                      chrcode:halfword);
Begin
  Case cmd Of 
    1:
       Begin
         print(557);
         print(chrcode);
       End;
    2:
       Begin
         print(558);
         print(chrcode);
       End;
    3:
       Begin
         print(559);
         print(chrcode);
       End;
    6:
       Begin
         print(560);
         print(chrcode);
       End;
    7:
       Begin
         print(561);
         print(chrcode);
       End;
    8:
       Begin
         print(562);
         print(chrcode);
       End;
    9: print(563);
    10:
        Begin
          print(564);
          print(chrcode);
        End;
    11:
        Begin
          print(565);
          print(chrcode);
        End;
    12:
        Begin
          print(566);
          print(chrcode);
        End;
{227:}
    75,76: If chrcode<2900 Then printskipparam(chrcode-2882)
           Else If 
                   chrcode<3156 Then
                  Begin
                    printesc(395);
                    printint(chrcode-2900);
                  End
           Else
             Begin
               printesc(396);
               printint(chrcode-3156);
             End;
{:227}{231:}
    72: If chrcode>=3422 Then
          Begin
            printesc(407);
            printint(chrcode-3422);
          End
        Else Case chrcode Of 
               3413: printesc(398);
               3414: printesc(399);
               3415: printesc(400);
               3416: printesc(401);
               3417: printesc(402);
               3418: printesc(403);
               3419: printesc(404);
               3420: printesc(405);
               Else printesc(406)
          End;
{:231}{239:}
    73: If chrcode<5318 Then printparam(chrcode-5263)
        Else
          Begin
            printesc(476);
            printint(chrcode-5318);
          End;
{:239}{249:}
    74: If chrcode<5851 Then printlengthparam(chrcode-5830)
        Else
          Begin
            printesc(500);
            printint(chrcode-5851);
          End;
{:249}{266:}
    45: printesc(508);
    90: printesc(509);
    40: printesc(510);
    41: printesc(511);
    77: printesc(519);
    61: printesc(512);
    42: printesc(531);
    16: printesc(513);
    107: printesc(504);
    88: printesc(518);
    15: printesc(514);
    92: printesc(515);
    67: printesc(505);
    62: printesc(516);
    64: printesc(32);
    102: printesc(517);
    32: printesc(520);
    36: printesc(521);
    39: printesc(522);
    37: printesc(330);
    44: printesc(47);
    18: printesc(351);
    46: printesc(523);
    17: printesc(524);
    54: printesc(525);
    91: printesc(526);
    34: printesc(527);
    65: printesc(528);
    103: printesc(529);
    55: printesc(335);
    63: printesc(530);
    66: printesc(533);
    96: printesc(534);
    0: printesc(535);
    98: printesc(536);
    80: printesc(532);
    84: printesc(408);
    109: printesc(537);
    71: printesc(407);
    38: printesc(352);
    33: printesc(538);
    56: printesc(539);
    35: printesc(540);
{:266}{335:}
    13: printesc(597);
{:335}{377:}
    104: If chrcode=0 Then printesc(629)
         Else printesc(630);
{:377}{385:}
    110: Case chrcode Of 
           1: printesc(632);
           2: printesc(633);
           3: printesc(634);
           4: printesc(635);
           Else printesc(631)
         End;
{:385}{412:}
    89: If chrcode=0 Then printesc(476)
        Else If chrcode=1 Then
               printesc(500)
        Else If chrcode=2 Then printesc(395)
        Else printesc(396);
{:412}{417:}
    79: If chrcode=1 Then printesc(669)
        Else printesc(668);
    82: If chrcode=0 Then printesc(670)
        Else printesc(671);
    83: If chrcode=1 Then printesc(672)
        Else If chrcode=3 Then printesc(673)
        Else printesc(674);
    70: Case chrcode Of 
          0: printesc(675);
          1: printesc(676);
          2: printesc(677);
          3: printesc(678);
          Else printesc(679)
        End;
{:417}{469:}
    108: Case chrcode Of 
           0: printesc(735);
           1: printesc(736);
           2: printesc(737);
           3: printesc(738);
           4: printesc(739);
           Else printesc(740)
         End;
{:469}{488:}
    105: Case chrcode Of 
           1: printesc(758);
           2: printesc(759);
           3: printesc(760);
           4: printesc(761);
           5: printesc(762);
           6: printesc(763);
           7: printesc(764);
           8: printesc(765);
           9: printesc(766);
           10: printesc(767);
           11: printesc(768);
           12: printesc(769);
           13: printesc(770);
           14: printesc(771);
           15: printesc(772);
           16: printesc(773);
           Else printesc(757)
         End;
{:488}{492:}
    106: If chrcode=2 Then printesc(774)
         Else If chrcode=4 Then
                printesc(775)
         Else printesc(776);
{:492}{781:}
    4: If chrcode=256 Then printesc(899)
       Else
         Begin
           print(903);
           print(chrcode);
         End;
    5: If chrcode=257 Then printesc(900)
       Else printesc(901);
{:781}{984:}
    81: Case chrcode Of 
          0: printesc(971);
          1: printesc(972);
          2: printesc(973);
          3: printesc(974);
          4: printesc(975);
          5: printesc(976);
          6: printesc(977);
          Else printesc(978)
        End;
{:984}{1053:}
    14: If chrcode=1 Then printesc(1027)
        Else printesc(1026);
{:1053}{1059:}
    26: Case chrcode Of 
          4: printesc(1028);
          0: printesc(1029);
          1: printesc(1030);
          2: printesc(1031);
          Else printesc(1032)
        End;
    27: Case chrcode Of 
          4: printesc(1033);
          0: printesc(1034);
          1: printesc(1035);
          2: printesc(1036);
          Else printesc(1037)
        End;
    28: printesc(336);
    29: printesc(340);
    30: printesc(342);
{:1059}{1072:}
    21: If chrcode=1 Then printesc(1055)
        Else printesc(1056);
    22: If chrcode=1 Then printesc(1057)
        Else printesc(1058);
    20: Case chrcode Of 
          0: printesc(409);
          1: printesc(1059);
          2: printesc(1060);
          3: printesc(966);
          4: printesc(1061);
          5: printesc(968);
          Else printesc(1062)
        End;
    31: If chrcode=100 Then printesc(1064)
        Else If chrcode=101 Then printesc(
                                          1065)
        Else If chrcode=102 Then printesc(1066)
        Else printesc(1063);
{:1072}{1089:}
    43: If chrcode=0 Then printesc(1082)
        Else printesc(1081);
{:1089}{1108:}
    25: If chrcode=10 Then printesc(1093)
        Else If chrcode=11
               Then printesc(1092)
        Else printesc(1091);
    23: If chrcode=1 Then printesc(1095)
        Else printesc(1094);
    24: If chrcode=1 Then printesc(1097)
        Else printesc(1096);
{:1108}{1115:}
    47: If chrcode=1 Then printesc(45)
        Else printesc(349);
{:1115}{1143:}
    48: If chrcode=1 Then printesc(1129)
        Else printesc(1128);
{:1143}{1157:}
    50: Case chrcode Of 
          16: printesc(867);
          17: printesc(868);
          18: printesc(869);
          19: printesc(870);
          20: printesc(871);
          21: printesc(872);
          22: printesc(873);
          23: printesc(874);
          26: printesc(876);
          Else printesc(875)
        End;
    51: If chrcode=1 Then printesc(879)
        Else If chrcode=2 Then printesc(880)
        Else printesc(1130);{:1157}{1170:}
    53: printstyle(chrcode);
{:1170}{1179:}
    52: Case chrcode Of 
          1: printesc(1149);
          2: printesc(1150);
          3: printesc(1151);
          4: printesc(1152);
          5: printesc(1153);
          Else printesc(1148)
        End;
{:1179}{1189:}
    49: If chrcode=30 Then printesc(877)
        Else printesc(878);
{:1189}{1209:}
    93: If chrcode=1 Then printesc(1172)
        Else If chrcode=2 Then
               printesc(1173)
        Else printesc(1174);
    97: If chrcode=0 Then printesc(1175)
        Else If chrcode=1 Then printesc(1176)
        Else If chrcode=2 Then printesc(1177)
        Else printesc(1178);
{:1209}{1220:}
    94: If chrcode<>0 Then printesc(1193)
        Else printesc(1192);
{:1220}{1223:}
    95: Case chrcode Of 
          0: printesc(1194);
          1: printesc(1195);
          2: printesc(1196);
          3: printesc(1197);
          4: printesc(1198);
          5: printesc(1199);
          Else printesc(1200)
        End;
    68:
        Begin
          printesc(513);
          printhex(chrcode);
        End;
    69:
        Begin
          printesc(524);
          printhex(chrcode);
        End;
{:1223}{1231:}
    85: If chrcode=3983 Then printesc(415)
        Else If chrcode=5007
               Then printesc(419)
        Else If chrcode=4239 Then printesc(416)
        Else If chrcode
                =4495 Then printesc(417)
        Else If chrcode=4751 Then printesc(418)
        Else
          printesc(477);
    86: printsize(chrcode-3935);
{:1231}{1251:}
    99: If chrcode=1 Then printesc(954)
        Else printesc(942);
{:1251}{1255:}
    78: If chrcode=0 Then printesc(1218)
        Else printesc(1219);
{:1255}{1261:}
    87:
        Begin
          print(1227);
          slowprint(fontname[chrcode]);
          If fontsize[chrcode]<>fontdsize[chrcode]Then
            Begin
              print(741);
              printscaled(fontsize[chrcode]);
              print(397);
            End;
        End;
{:1261}{1263:}
    100: Case chrcode Of 
           0: printesc(274);
           1: printesc(275);
           2: printesc(276);
           Else printesc(1228)
         End;
{:1263}{1273:}
    60: If chrcode=0 Then printesc(1230)
        Else printesc(1229);
{:1273}{1278:}
    58: If chrcode=0 Then printesc(1231)
        Else printesc(1232);
{:1278}{1287:}
    57: If chrcode=4239 Then printesc(1238)
        Else printesc(1239);
{:1287}{1292:}
    19: Case chrcode Of 
          1: printesc(1241);
          2: printesc(1242);
          3: printesc(1243);
          Else printesc(1240)
        End;{:1292}{1295:}
    101: print(1250);
    111: print(1251);
    112: printesc(1252);
    113: printesc(1253);
    114:
         Begin
           printesc(1172);
           printesc(1253);
         End;
    115: printesc(1254);
{:1295}{1346:}
    59: Case chrcode Of 
          0: printesc(1286);
          1: printesc(594);
          2: printesc(1287);
          3: printesc(1288);
          4: printesc(1289);
          5: printesc(1290);
          Else print(1291)
        End;{:1346}
    Else print(567)
  End;
End;
{:298}
Procedure showeqtb(n:halfword);
Begin
  If n<1 Then printchar(63)
  Else If n<2882 Then{223:}
         Begin
           sprintcs(n
           );
           printchar(61);
           printcmdchr(eqtb[n].hh.b0,eqtb[n].hh.rh);
           If eqtb[n].hh.b0>=111 Then
             Begin
               printchar(58);
               showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);
             End;
         End{:223}
  Else If n<3412 Then{229:}If n<2900 Then
                             Begin
                               printskipparam(n
                                              -2882);
                               printchar(61);
                               If n<2897 Then printspec(eqtb[n].hh.rh,397)
                               Else printspec(eqtb[n].hh.rh,
                                              337);
                             End
  Else If n<3156 Then
         Begin
           printesc(395);
           printint(n-2900);
           printchar(61);
           printspec(eqtb[n].hh.rh,397);
         End
  Else
    Begin
      printesc(396);
      printint(n-3156);
      printchar(61);
      printspec(eqtb[n].hh.rh,337);
    End{:229}
  Else If n<5263 Then{233:}If n=3412 Then
                             Begin
                               printesc(408);
                               printchar(61);
                               If eqtb[3412].hh.rh=0 Then printchar(48)
                               Else printint(mem[eqtb[3412].hh.
                                             rh].hh.lh);
                             End
  Else If n<3422 Then
         Begin
           printcmdchr(72,n);
           printchar(61);
           If eqtb[n].hh.rh<>0 Then showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);
         End
  Else If n<3678 Then
         Begin
           printesc(407);
           printint(n-3422);
           printchar(61);
           If eqtb[n].hh.rh<>0 Then showtokenlist(mem[eqtb[n].hh.rh].hh.rh,0,32);
         End
  Else If n<3934 Then
         Begin
           printesc(409);
           printint(n-3678);
           printchar(61);
           If eqtb[n].hh.rh=0 Then print(410)
           Else
             Begin
               depththreshold := 0;
               breadthmax := 1;
               shownodelist(eqtb[n].hh.rh);
             End;
         End
  Else If n<3983 Then{234:}
         Begin
           If n=3934 Then print(411)
           Else If n<
                   3951 Then
                  Begin
                    printesc(412);
                    printint(n-3935);
                  End
           Else If n<3967 Then
                  Begin
                    printesc(413);
                    printint(n-3951);
                  End
           Else
             Begin
               printesc(414);
               printint(n-3967);
             End;
           printchar(61);
           printesc(hash[2624+eqtb[n].hh.rh].rh);
         End{:234}
  Else{235:}If n<5007 Then
              Begin
                If n<4239 Then
                  Begin
                    printesc(
                             415);
                    printint(n-3983);
                  End
                Else If n<4495 Then
                       Begin
                         printesc(416);
                         printint(n-4239);
                       End
                Else If n<4751 Then
                       Begin
                         printesc(417);
                         printint(n-4495);
                       End
                Else
                  Begin
                    printesc(418);
                    printint(n-4751);
                  End;
                printchar(61);
                printint(eqtb[n].hh.rh);
              End
  Else
    Begin
      printesc(419);
      printint(n-5007);
      printchar(61);
      printint(eqtb[n].hh.rh);
    End{:235}{:233}
  Else If n<5830 Then{242:}
         Begin
           If n<5318 Then printparam(
                                     n-5263)
           Else If n<5574 Then
                  Begin
                    printesc(476);
                    printint(n-5318);
                  End
           Else
             Begin
               printesc(477);
               printint(n-5574);
             End;
           printchar(61);
           printint(eqtb[n].int);
         End{:242}
  Else If n<=6106 Then{251:}
         Begin
           If n<5851 Then printlengthparam
             (n-5830)
           Else
             Begin
               printesc(500);
               printint(n-5851);
             End;
           printchar(61);
           printscaled(eqtb[n].int);
           print(397);
         End{:251}
  Else printchar(63);
End;
{:252}{259:}
Function idlookup(j,l:integer): halfword;

Label 40;

Var h: integer;
  d: integer;
  p: halfword;
  k: halfword;
Begin{261:}
  h := buffer[j];
  For k:=j+1 To j+l-1 Do
    Begin
      h := h+h+buffer[k];
      While h>=1777 Do
        h := h-1777;
    End{:261};
  p := h+514;
  While true Do
    Begin
      If hash[p].rh>0 Then If (strstart[hash[p].rh+1]-
                              strstart[hash[p].rh])=l Then If streqbuf(hash[p].rh,j)Then goto 40;
      If hash[p].lh=0 Then
        Begin
          If nonewcontrolsequence Then p := 2881
          Else
{260:}
            Begin
              If hash[p].rh>0 Then
                Begin
                  Repeat
                    If (hashused=514)Then
                      overflow(503,2100);
                    hashused := hashused-1;
                  Until hash[hashused].rh=0;
                  hash[p].lh := hashused;
                  p := hashused;
                End;
              Begin
                If poolptr+l>poolsize Then overflow(257,poolsize-initpoolptr);
              End;
              d := (poolptr-strstart[strptr]);
              While poolptr>strstart[strptr] Do
                Begin
                  poolptr := poolptr-1;
                  strpool[poolptr+l] := strpool[poolptr];
                End;
              For k:=j To j+l-1 Do
                Begin
                  strpool[poolptr] := buffer[k];
                  poolptr := poolptr+1;
                End;
              hash[p].rh := makestring;
              poolptr := poolptr+d;
              cscount := cscount+1;
            End{:260};
          goto 40;
        End;
      p := hash[p].lh;
    End;
  40: idlookup := p;
End;{:259}{264:}
{procedure primitive(s:strnumber;
c:quarterword;o:halfword);var k:poolpointer;j:smallnumber;l:smallnumber;
begin if s<256 then curval:=s+257 else begin k:=strstart[s];
l:=strstart[s+1]-k;for j:=0 to l-1 do buffer[j]:=strpool[k+j];
curval:=idlookup(0,l);begin strptr:=strptr-1;poolptr:=strstart[strptr];
end;hash[curval].rh:=s;end;eqtb[curval].hh.b1:=1;eqtb[curval].hh.b0:=c;
eqtb[curval].hh.rh:=o;end;}
{:264}{274:}
Procedure newsavelevel(c:groupcode);
Begin
  If saveptr>maxsavestack Then
    Begin
      maxsavestack := saveptr;
      If maxsavestack>savesize-6 Then overflow(541,savesize);
    End;
  savestack[saveptr].hh.b0 := 3;
  savestack[saveptr].hh.b1 := curgroup;
  savestack[saveptr].hh.rh := curboundary;
  If curlevel=255 Then overflow(542,255);
  curboundary := saveptr;
  curlevel := curlevel+1;
  saveptr := saveptr+1;
  curgroup := c;
End;
{:274}{275:}
Procedure eqdestroy(w:memoryword);

Var q: halfword;
Begin
  Case w.hh.b0 Of 
    111,112,113,114: deletetokenref(w.hh.rh);
    117: deleteglueref(w.hh.rh);
    118:
         Begin
           q := w.hh.rh;
           If q<>0 Then freenode(q,mem[q].hh.lh+mem[q].hh.lh+1);
         End;
    119: flushnodelist(w.hh.rh);
    Else
  End;
End;
{:275}{276:}
Procedure eqsave(p:halfword;l:quarterword);
Begin
  If saveptr>maxsavestack Then
    Begin
      maxsavestack := saveptr;
      If maxsavestack>savesize-6 Then overflow(541,savesize);
    End;
  If l=0 Then savestack[saveptr].hh.b0 := 1
  Else
    Begin
      savestack[saveptr] := 
                            eqtb[p];
      saveptr := saveptr+1;
      savestack[saveptr].hh.b0 := 0;
    End;
  savestack[saveptr].hh.b1 := l;
  savestack[saveptr].hh.rh := p;
  saveptr := saveptr+1;
End;{:276}{277:}
Procedure eqdefine(p:halfword;
                   t:quarterword;e:halfword);
Begin
  If eqtb[p].hh.b1=curlevel Then eqdestroy(eqtb[p])
  Else If curlevel>
          1 Then eqsave(p,eqtb[p].hh.b1);
  eqtb[p].hh.b1 := curlevel;
  eqtb[p].hh.b0 := t;
  eqtb[p].hh.rh := e;
End;{:277}{278:}
Procedure eqworddefine(p:halfword;
                       w:integer);
Begin
  If xeqlevel[p]<>curlevel Then
    Begin
      eqsave(p,xeqlevel[p]);
      xeqlevel[p] := curlevel;
    End;
  eqtb[p].int := w;
End;
{:278}{279:}
Procedure geqdefine(p:halfword;t:quarterword;e:halfword);
Begin
  eqdestroy(eqtb[p]);
  eqtb[p].hh.b1 := 1;
  eqtb[p].hh.b0 := t;
  eqtb[p].hh.rh := e;
End;
Procedure geqworddefine(p:halfword;w:integer);
Begin
  eqtb[p].int := w;
  xeqlevel[p] := 1;
End;
{:279}{280:}
Procedure saveforafter(t:halfword);
Begin
  If curlevel>1 Then
    Begin
      If saveptr>maxsavestack Then
        Begin
          maxsavestack := saveptr;
          If maxsavestack>savesize-6 Then overflow(541,savesize);
        End;
      savestack[saveptr].hh.b0 := 2;
      savestack[saveptr].hh.b1 := 0;
      savestack[saveptr].hh.rh := t;
      saveptr := saveptr+1;
    End;
End;
{:280}{281:}{284:}
Procedure restoretrace(p:halfword;s:strnumber);
Begin
  begindiagnostic;
  printchar(123);
  print(s);
  printchar(32);
  showeqtb(p);
  printchar(125);
  enddiagnostic(false);
End;{:284}
Procedure backinput;
forward;
Procedure unsave;

Label 30;

Var p: halfword;
  l: quarterword;
  t: halfword;
Begin
  If curlevel>1 Then
    Begin
      curlevel := curlevel-1;
{282:}
      While true Do
        Begin
          saveptr := saveptr-1;
          If savestack[saveptr].hh.b0=3 Then goto 30;
          p := savestack[saveptr].hh.rh;
          If savestack[saveptr].hh.b0=2 Then{326:}
            Begin
              t := curtok;
              curtok := p;
              backinput;
              curtok := t;
            End{:326}
          Else
            Begin
              If savestack[saveptr].hh.b0=0 Then
                Begin
                  l := 
                       savestack[saveptr].hh.b1;
                  saveptr := saveptr-1;
                End
              Else savestack[saveptr] := eqtb[2881];
{283:}
              If p<5263 Then If eqtb[p].hh.b1=1 Then
                               Begin
                                 eqdestroy(savestack[
                                           saveptr]);
                                 If eqtb[5300].int>0 Then restoretrace(p,544);
                               End
              Else
                Begin
                  eqdestroy(eqtb[p]);
                  eqtb[p] := savestack[saveptr];
                  If eqtb[5300].int>0 Then restoretrace(p,545);
                End
              Else If xeqlevel[p]<>1 Then
                     Begin
                       eqtb[p] := savestack[saveptr];
                       xeqlevel[p] := l;
                       If eqtb[5300].int>0 Then restoretrace(p,545);
                     End
              Else
                Begin
                  If eqtb[5300].int>0 Then restoretrace(p,544);
                End{:283};
            End;
        End;
      30: curgroup := savestack[saveptr].hh.b1;
      curboundary := savestack[saveptr].hh.rh{:282};
    End
  Else confusion(543);
End;
{:281}{288:}
Procedure preparemag;
Begin
  If (magset>0)And(eqtb[5280].int<>magset)Then
    Begin
      Begin
        If 
           interaction=3 Then;
        printnl(262);
        print(547);
      End;
      printint(eqtb[5280].int);
      print(548);
      printnl(549);
      Begin
        helpptr := 2;
        helpline[1] := 550;
        helpline[0] := 551;
      End;
      interror(magset);
      geqworddefine(5280,magset);
    End;
  If (eqtb[5280].int<=0)Or(eqtb[5280].int>32768)Then
    Begin
      Begin
        If 
           interaction=3 Then;
        printnl(262);
        print(552);
      End;
      Begin
        helpptr := 1;
        helpline[0] := 553;
      End;
      interror(eqtb[5280].int);
      geqworddefine(5280,1000);
    End;
  magset := eqtb[5280].int;
End;
{:288}{295:}
Procedure tokenshow(p:halfword);
Begin
  If p<>0 Then showtokenlist(mem[p].hh.rh,0,10000000);
End;
{:295}{296:}
Procedure printmeaning;
Begin
  printcmdchr(curcmd,curchr);
  If curcmd>=111 Then
    Begin
      printchar(58);
      println;
      tokenshow(curchr);
    End
  Else If curcmd=110 Then
         Begin
           printchar(58);
           println;
           tokenshow(curmark[curchr]);
         End;
End;{:296}{299:}
Procedure showcurcmdchr;
Begin
  begindiagnostic;
  printnl(123);
  If curlist.modefield<>shownmode Then
    Begin
      printmode(curlist.modefield);
      print(568);
      shownmode := curlist.modefield;
    End;
  printcmdchr(curcmd,curchr);
  printchar(125);
  enddiagnostic(false);
End;
{:299}{311:}
Procedure showcontext;

Label 30;

Var oldsetting: 0..21;
  nn: integer;
  bottomline: boolean;{315:}
  i: 0..bufsize;
  j: 0..bufsize;
  l: 0..halferrorline;
  m: integer;
  n: 0..errorline;
  p: integer;
  q: integer;
{:315}
Begin
  baseptr := inputptr;
  inputstack[baseptr] := curinput;
  nn := -1;
  bottomline := false;
  While true Do
    Begin
      curinput := inputstack[baseptr];
      If (curinput.statefield<>0)Then If (curinput.namefield>17)Or(baseptr=0)
                                        Then bottomline := true;
      If (baseptr=inputptr)Or bottomline Or(nn<eqtb[5317].int)Then{312:}
        Begin
          If (baseptr=inputptr)Or(curinput.statefield<>0)Or(curinput.indexfield<>3)
             Or(curinput.locfield<>0)Then
            Begin
              tally := 0;
              oldsetting := selector;
              If curinput.statefield<>0 Then
                Begin{313:}
                  If curinput.namefield<=17 Then
                    If (curinput.namefield=0)Then If baseptr=0 Then printnl(574)
                  Else printnl(
                               575)
                  Else
                    Begin
                      printnl(576);
                      If curinput.namefield=17 Then printchar(42)
                      Else printint(curinput.
                                    namefield-1);
                      printchar(62);
                    End
                  Else
                    Begin
                      printnl(577);
                      printint(line);
                    End;
                  printchar(32){:313};{318:}
                  Begin
                    l := tally;
                    tally := 0;
                    selector := 20;
                    trickcount := 1000000;
                  End;
                  If buffer[curinput.limitfield]=eqtb[5311].int Then j := curinput.
                                                                          limitfield
                  Else j := curinput.limitfield+1;
                  If j>0 Then For i:=curinput.startfield To j-1 Do
                                Begin
                                  If i=curinput.
                                     locfield Then
                                    Begin
                                      firstcount := tally;
                                      trickcount := tally+1+errorline-halferrorline;
                                      If trickcount<errorline Then trickcount := errorline;
                                    End;
                                  print(buffer[i]);
                                End{:318};
                End
              Else
                Begin{314:}
                  Case curinput.indexfield Of 
                    0: printnl(578);
                    1,2: printnl(579);
                    3: If curinput.locfield=0 Then printnl(580)
                       Else printnl(581);
                    4: printnl(582);
                    5:
                       Begin
                         println;
                         printcs(curinput.namefield);
                       End;
                    6: printnl(583);
                    7: printnl(584);
                    8: printnl(585);
                    9: printnl(586);
                    10: printnl(587);
                    11: printnl(588);
                    12: printnl(589);
                    13: printnl(590);
                    14: printnl(591);
                    15: printnl(592);
                    Else printnl(63)
                  End{:314};
{319:}
                  Begin
                    l := tally;
                    tally := 0;
                    selector := 20;
                    trickcount := 1000000;
                  End;
                  If curinput.indexfield<5 Then showtokenlist(curinput.startfield,curinput
                                                              .locfield,100000)
                  Else showtokenlist(mem[curinput.startfield].hh.rh,
                                     curinput.locfield,100000){:319};
                End;
              selector := oldsetting;
{317:}
              If trickcount=1000000 Then
                Begin
                  firstcount := tally;
                  trickcount := tally+1+errorline-halferrorline;
                  If trickcount<errorline Then trickcount := errorline;
                End;
              If tally<trickcount Then m := tally-firstcount
              Else m := trickcount-
                        firstcount;
              If l+firstcount<=halferrorline Then
                Begin
                  p := 0;
                  n := l+firstcount;
                End
              Else
                Begin
                  print(277);
                  p := l+firstcount-halferrorline+3;
                  n := halferrorline;
                End;
              For q:=p To firstcount-1 Do
                printchar(trickbuf[q Mod errorline]);
              println;
              For q:=1 To n Do
                printchar(32);
              If m+n<=errorline Then p := firstcount+m
              Else p := firstcount+(errorline-n-3
                        );
              For q:=firstcount To p-1 Do
                printchar(trickbuf[q Mod errorline]);
              If m+n>errorline Then print(277){:317};
              nn := nn+1;
            End;
        End{:312}
      Else If nn=eqtb[5317].int Then
             Begin
               printnl(277);
               nn := nn+1;
             End;
      If bottomline Then goto 30;
      baseptr := baseptr-1;
    End;
  30: curinput := inputstack[inputptr];
End;
{:311}{323:}
Procedure begintokenlist(p:halfword;t:quarterword);
Begin
  Begin
    If inputptr>maxinstack Then
      Begin
        maxinstack := inputptr;
        If inputptr=stacksize Then overflow(593,stacksize);
      End;
    inputstack[inputptr] := curinput;
    inputptr := inputptr+1;
  End;
  curinput.statefield := 0;
  curinput.startfield := p;
  curinput.indexfield := t;
  If t>=5 Then
    Begin
      mem[p].hh.lh := mem[p].hh.lh+1;
      If t=5 Then curinput.limitfield := paramptr
      Else
        Begin
          curinput.locfield := 
                               mem[p].hh.rh;
          If eqtb[5293].int>1 Then
            Begin
              begindiagnostic;
              printnl(338);
              Case t Of 
                14: printesc(351);
                15: printesc(594);
                Else printcmdchr(72,t+3407)
              End;
              print(556);
              tokenshow(p);
              enddiagnostic(false);
            End;
        End;
    End
  Else curinput.locfield := p;
End;
{:323}{324:}
Procedure endtokenlist;
Begin
  If curinput.indexfield>=3 Then
    Begin
      If curinput.indexfield<=4
        Then flushlist(curinput.startfield)
      Else
        Begin
          deletetokenref(curinput.
                         startfield);
          If curinput.indexfield=5 Then While paramptr>curinput.limitfield Do
                                          Begin
                                            paramptr := paramptr-1;
                                            flushlist(paramstack[paramptr]);
                                          End;
        End;
    End
  Else If curinput.indexfield=1 Then If alignstate>500000 Then
                                       alignstate := 0
  Else fatalerror(595);
  Begin
    inputptr := inputptr-1;
    curinput := inputstack[inputptr];
  End;
  Begin
    If interrupt<>0 Then pauseforinstructions;
  End;
End;
{:324}{325:}
Procedure backinput;

Var p: halfword;
Begin
  While (curinput.statefield=0)And(curinput.locfield=0)And(curinput.
        indexfield<>2) Do
    endtokenlist;
  p := getavail;
  mem[p].hh.lh := curtok;
  If curtok<768 Then If curtok<512 Then alignstate := alignstate-1
  Else
    alignstate := alignstate+1;
  Begin
    If inputptr>maxinstack Then
      Begin
        maxinstack := inputptr;
        If inputptr=stacksize Then overflow(593,stacksize);
      End;
    inputstack[inputptr] := curinput;
    inputptr := inputptr+1;
  End;
  curinput.statefield := 0;
  curinput.startfield := p;
  curinput.indexfield := 3;
  curinput.locfield := p;
End;{:325}{327:}
Procedure backerror;
Begin
  OKtointerrupt := false;
  backinput;
  OKtointerrupt := true;
  error;
End;
Procedure inserror;
Begin
  OKtointerrupt := false;
  backinput;
  curinput.indexfield := 4;
  OKtointerrupt := true;
  error;
End;
{:327}{328:}
Procedure beginfilereading;
Begin
  If inopen=maxinopen Then overflow(596,maxinopen);
  If first=bufsize Then overflow(256,bufsize);
  inopen := inopen+1;
  Begin
    If inputptr>maxinstack Then
      Begin
        maxinstack := inputptr;
        If inputptr=stacksize Then overflow(593,stacksize);
      End;
    inputstack[inputptr] := curinput;
    inputptr := inputptr+1;
  End;
  curinput.indexfield := inopen;
  linestack[curinput.indexfield] := line;
  curinput.startfield := first;
  curinput.statefield := 1;
  curinput.namefield := 0;
End;{:328}{329:}
Procedure endfilereading;
Begin
  first := curinput.startfield;
  line := linestack[curinput.indexfield];
  If curinput.namefield>17 Then aclose(inputfile[curinput.indexfield]);
  Begin
    inputptr := inputptr-1;
    curinput := inputstack[inputptr];
  End;
  inopen := inopen-1;
End;{:329}{330:}
Procedure clearforerrorprompt;
Begin
  While (curinput.statefield<>0)And(curinput.namefield=0)And(inputptr
        >0)And(curinput.locfield>curinput.limitfield) Do
    endfilereading;
  println;;
End;{:330}{336:}
Procedure checkoutervalidity;

Var p: halfword;
  q: halfword;
Begin
  If scannerstatus<>0 Then
    Begin
      deletionsallowed := false;
{337:}
      If curcs<>0 Then
        Begin
          If (curinput.statefield=0)Or(curinput.
             namefield<1)Or(curinput.namefield>17)Then
            Begin
              p := getavail;
              mem[p].hh.lh := 4095+curcs;
              begintokenlist(p,3);
            End;
          curcmd := 10;
          curchr := 32;
        End{:337};
      If scannerstatus>1 Then{338:}
        Begin
          runaway;
          If curcs=0 Then
            Begin
              If interaction=3 Then;
              printnl(262);
              print(604);
            End
          Else
            Begin
              curcs := 0;
              Begin
                If interaction=3 Then;
                printnl(262);
                print(605);
              End;
            End;
          print(606);{339:}
          p := getavail;
          Case scannerstatus Of 
            2:
               Begin
                 print(570);
                 mem[p].hh.lh := 637;
               End;
            3:
               Begin
                 print(612);
                 mem[p].hh.lh := partoken;
                 longstate := 113;
               End;
            4:
               Begin
                 print(572);
                 mem[p].hh.lh := 637;
                 q := p;
                 p := getavail;
                 mem[p].hh.rh := q;
                 mem[p].hh.lh := 6710;
                 alignstate := -1000000;
               End;
            5:
               Begin
                 print(573);
                 mem[p].hh.lh := 637;
               End;
          End;
          begintokenlist(p,4){:339};
          print(607);
          sprintcs(warningindex);
          Begin
            helpptr := 4;
            helpline[3] := 608;
            helpline[2] := 609;
            helpline[1] := 610;
            helpline[0] := 611;
          End;
          error;
        End{:338}
      Else
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(598);
          End;
          printcmdchr(105,curif);
          print(599);
          printint(skipline);
          Begin
            helpptr := 3;
            helpline[2] := 600;
            helpline[1] := 601;
            helpline[0] := 602;
          End;
          If curcs<>0 Then curcs := 0
          Else helpline[2] := 603;
          curtok := 6713;
          inserror;
        End;
      deletionsallowed := true;
    End;
End;{:336}{340:}
Procedure firmuptheline;
forward;{:340}{341:}
Procedure getnext;

Label 20,25,21,26,40,10;

Var k: 0..bufsize;
  t: halfword;
  cat: 0..15;
  c,cc: ASCIIcode;
  d: 2..3;
Begin
  20: curcs := 0;
  If curinput.statefield<>0 Then{343:}
    Begin
      25: If curinput.locfield<=
             curinput.limitfield Then
            Begin
              curchr := buffer[curinput.locfield];
              curinput.locfield := curinput.locfield+1;
              21: curcmd := eqtb[3983+curchr].hh.rh;
{344:}
              Case curinput.statefield+curcmd Of {345:}
                10,26,42,27,43{:345}: goto
                                      25;
                1,17,33:{354:}
                         Begin
                           If curinput.locfield>curinput.limitfield Then curcs 
                             := 513
                           Else
                             Begin
                               26: k := curinput.locfield;
                               curchr := buffer[k];
                               cat := eqtb[3983+curchr].hh.rh;
                               k := k+1;
                               If cat=11 Then curinput.statefield := 17
                               Else If cat=10 Then curinput.
                                      statefield := 17
                               Else curinput.statefield := 1;
                               If (cat=11)And(k<=curinput.limitfield)Then{356:}
                                 Begin
                                   Repeat
                                     curchr := 
                                               buffer[k];
                                     cat := eqtb[3983+curchr].hh.rh;
                                     k := k+1;
                                   Until (cat<>11)Or(k>curinput.limitfield);
{355:}
                                   Begin
                                     If buffer[k]=curchr Then If cat=7 Then If k<curinput.
                                                                               limitfield Then
                                                                              Begin
                                                                                c := buffer[k+1];
                                                                                If c<128 Then
                                                                                  Begin
                                                                                    d := 2;
                                                                                    If (((c>=48)And(
                                                                                       c<=57))Or((c
                                                                                       >=97)And(c<=
                                                                                       102)))Then If
                                                                                                   k
                                                                                                   +
                                                                                                   2
                                                                                                  <=
                                                                                            curinput
                                                                                                   .

                                                                                          limitfield
                                                                                                Then

                                                                                               Begin

                                                                                                  cc
                                                                                                  :=
                                                                                              buffer
                                                                                                   [
                                                                                                   k
                                                                                                   +
                                                                                                   2
                                                                                                   ]
                                                                                                   ;

                                                                                                  If
                                                                                                   (
                                                                                                   (
                                                                                                   (
                                                                                                  cc
                                                                                                  >=
                                                                                                  48
                                                                                                   )
                                                                                                 And
                                                                                                   (
                                                                                                  cc
                                                                                                  <=
                                                                                                  57
                                                                                                   )
                                                                                                   )
                                                                                                  Or
                                                                                                   (
                                                                                                   (
                                                                                                  cc
                                                                                                  >=
                                                                                                  97
                                                                                                   )
                                                                                                 And
                                                                                                   (
                                                                                                  cc
                                                                                                  <=
                                                                                                 102
                                                                                                   )
                                                                                                   )
                                                                                                   )
                                                                                                Then
                                                                                                   d
                                                                                                  :=
                                                                                                   d
                                                                                                   +
                                                                                                   1
                                                                                                   ;

                                                                                                 End
                                                                                    ;
                                                                                    If d>2 Then
                                                                                      Begin
                                                                                        If c<=57
                                                                                          Then
                                                                                          curchr := 
                                                                                                   c
                                                                                                   -
                                                                                                  48
                                                                                        Else curchr 
                                                                                          := c-87;
                                                                                        If cc<=57
                                                                                          Then
                                                                                          curchr := 
                                                                                                  16
                                                                                                   *
                                                                                              curchr
                                                                                                   +
                                                                                                  cc
                                                                                                   -
                                                                                                  48
                                                                                        Else curchr 
                                                                                          := 16*
                                                                                             curchr+
                                                                                             cc-87;
                                                                                        buffer[k-1] 
                                                                                        := curchr;
                                                                                      End
                                                                                    Else If c<64
                                                                                           Then
                                                                                           buffer[k-
                                                                                           1] := c+
                                                                                                 64
                                                                                    Else buffer[k-1]
                                                                                      := c-64;
                                                                                    curinput.
                                                                                    limitfield := 
                                                                                            curinput
                                                                                                  .
                                                                                          limitfield
                                                                                                  -d
                                                                                    ;
                                                                                    first := first-d
                                                                                    ;
                                                                                    While k<=
                                                                                          curinput.
                                                                                          limitfield
                                                                                      Do
                                                                                      Begin
                                                                                        buffer[k] :=
                                                                                              buffer
                                                                                                   [
                                                                                                   k
                                                                                                   +
                                                                                                   d
                                                                                                   ]
                                                                                        ;
                                                                                        k := k+1;
                                                                                      End;
                                                                                    goto 26;
                                                                                  End;
                                                                              End;
                                   End{:355};
                                   If cat<>11 Then k := k-1;
                                   If k>curinput.locfield+1 Then
                                     Begin
                                       curcs := idlookup(curinput.locfield,k-
                                                curinput.locfield);
                                       curinput.locfield := k;
                                       goto 40;
                                     End;
                                 End{:356}
                               Else{355:}
                                 Begin
                                   If buffer[k]=curchr Then If cat=7 Then If k<
                                                                             curinput.limitfield
                                                                            Then
                                                                            Begin
                                                                              c := buffer[k+1];
                                                                              If c<128 Then
                                                                                Begin
                                                                                  d := 2;
                                                                                  If (((c>=48)And(c
                                                                                     <=57))Or((c>=97
                                                                                     )And(c<=102)))
                                                                                    Then If k+2<=
                                                                                            curinput
                                                                                            .

                                                                                          limitfield
                                                                                           Then
                                                                                           Begin
                                                                                             cc := 
                                                                                              buffer
                                                                                                   [
                                                                                                   k
                                                                                                   +
                                                                                                   2
                                                                                                   ]
                                                                                             ;
                                                                                             If (((
                                                                                                cc>=
                                                                                                48)
                                                                                                And(
                                                                                                cc<=
                                                                                                57))
                                                                                                Or((
                                                                                                cc>=
                                                                                                97)
                                                                                                And(
                                                                                                cc<=
                                                                                                102)
                                                                                                ))
                                                                                               Then
                                                                                               d := 
                                                                                                   d
                                                                                                   +
                                                                                                   1
                                                                                             ;
                                                                                           End;
                                                                                  If d>2 Then
                                                                                    Begin
                                                                                      If c<=57 Then
                                                                                        curchr := c-
                                                                                                  48
                                                                                      Else curchr :=
                                                                                                   c
                                                                                                   -
                                                                                                  87
                                                                                      ;
                                                                                      If cc<=57 Then
                                                                                        curchr := 16
                                                                                                  *
                                                                                              curchr
                                                                                                  +
                                                                                                  cc
                                                                                                  -
                                                                                                  48
                                                                                      Else curchr :=
                                                                                                  16
                                                                                                   *
                                                                                              curchr
                                                                                                   +
                                                                                                  cc
                                                                                                   -
                                                                                                  87
                                                                                      ;
                                                                                      buffer[k-1] :=
                                                                                              curchr
                                                                                      ;
                                                                                    End
                                                                                  Else If c<64 Then
                                                                                         buffer[k-1]
                                                                                         := c+64
                                                                                  Else buffer[k-1] 
                                                                                    := c-64;
                                                                                  curinput.
                                                                                  limitfield := 
                                                                                            curinput
                                                                                                .
                                                                                          limitfield
                                                                                                -d;
                                                                                  first := first-d;
                                                                                  While k<=curinput.
                                                                                        limitfield 
                                                                                    Do
                                                                                    Begin
                                                                                      buffer[k] := 
                                                                                              buffer
                                                                                                   [
                                                                                                   k
                                                                                                   +
                                                                                                   d
                                                                                                   ]
                                                                                      ;
                                                                                      k := k+1;
                                                                                    End;
                                                                                  goto 26;
                                                                                End;
                                                                            End;
                                 End{:355};
                               curcs := 257+buffer[curinput.locfield];
                               curinput.locfield := curinput.locfield+1;
                             End;
                           40: curcmd := eqtb[curcs].hh.b0;
                           curchr := eqtb[curcs].hh.rh;
                           If curcmd>=113 Then checkoutervalidity;
                         End{:354};
                14,30,46:{353:}
                          Begin
                            curcs := curchr+1;
                            curcmd := eqtb[curcs].hh.b0;
                            curchr := eqtb[curcs].hh.rh;
                            curinput.statefield := 1;
                            If curcmd>=113 Then checkoutervalidity;
                          End{:353};
                8,24,40:{352:}
                         Begin
                           If curchr=buffer[curinput.locfield]Then If curinput.
                                                                      locfield<curinput.limitfield
                                                                     Then
                                                                     Begin
                                                                       c := buffer[curinput.locfield
                                                                            +1];
                                                                       If c<128 Then
                                                                         Begin
                                                                           curinput.locfield := 
                                                                                            curinput
                                                                                                .
                                                                                            locfield
                                                                                                +2;
                                                                           If (((c>=48)And(c<=57))Or
                                                                              ((c>=97)And(c<=102)))
                                                                             Then If curinput.
                                                                                     locfield<=
                                                                                     curinput.
                                                                                     limitfield Then
                                                                                    Begin
                                                                                      cc := buffer[
                                                                                            curinput
                                                                                            .
                                                                                            locfield
                                                                                            ];
                                                                                      If (((cc>=48)
                                                                                         And(cc<=57)
                                                                                         )Or((cc>=97
                                                                                         )And(cc<=
                                                                                         102)))Then
                                                                                        Begin
                                                                                          curinput.
                                                                                          locfield 
                                                                                          := 
                                                                                            curinput
                                                                                             .
                                                                                            locfield
                                                                                             +1;
                                                                                          If c<=57
                                                                                            Then
                                                                                            curchr 
                                                                                            := c-48
                                                                                          Else
                                                                                            curchr 
                                                                                            := c-87;
                                                                                          If cc<=57
                                                                                            Then
                                                                                            curchr 
                                                                                            := 16*
                                                                                              curchr
                                                                                               +cc-
                                                                                               48
                                                                                          Else
                                                                                            curchr 
                                                                                            := 16*
                                                                                              curchr
                                                                                               +cc-
                                                                                               87;
                                                                                          goto 21;
                                                                                        End;
                                                                                    End;
                                                                           If c<64 Then curchr := c+
                                                                                                  64
                                                                           Else curchr := c-64;
                                                                           goto 21;
                                                                         End;
                                                                     End;
                           curinput.statefield := 1;
                         End{:352};
                16,32,48:{346:}
                          Begin
                            Begin
                              If interaction=3 Then;
                              printnl(262);
                              print(613);
                            End;
                            Begin
                              helpptr := 2;
                              helpline[1] := 614;
                              helpline[0] := 615;
                            End;
                            deletionsallowed := false;
                            error;
                            deletionsallowed := true;
                            goto 20;
                          End{:346};
{347:}
                11:{349:}
                    Begin
                      curinput.statefield := 17;
                      curchr := 32;
                    End{:349};
                6:{348:}
                   Begin
                     curinput.locfield := curinput.limitfield+1;
                     curcmd := 10;
                     curchr := 32;
                   End{:348};
                22,15,31,47:{350:}
                             Begin
                               curinput.locfield := curinput.limitfield+1;
                               goto 25;
                             End{:350};
                38:{351:}
                    Begin
                      curinput.locfield := curinput.limitfield+1;
                      curcs := parloc;
                      curcmd := eqtb[curcs].hh.b0;
                      curchr := eqtb[curcs].hh.rh;
                      If curcmd>=113 Then checkoutervalidity;
                    End{:351};
                2: alignstate := alignstate+1;
                18,34:
                       Begin
                         curinput.statefield := 1;
                         alignstate := alignstate+1;
                       End;
                3: alignstate := alignstate-1;
                19,35:
                       Begin
                         curinput.statefield := 1;
                         alignstate := alignstate-1;
                       End;
                20,21,23,25,28,29,36,37,39,41,44,45: curinput.statefield := 1;
{:347}
                Else
              End{:344};
            End
          Else
            Begin
              curinput.statefield := 33;
{360:}
              If curinput.namefield>17 Then{362:}
                Begin
                  line := line+1;
                  first := curinput.startfield;
                  If Not forceeof Then
                    Begin
                      If inputln(inputfile[curinput.indexfield],
                         true)Then firmuptheline
                      Else forceeof := true;
                    End;
                  If forceeof Then
                    Begin
                      printchar(41);
                      openparens := openparens-1;
                      flush(output);
                      forceeof := false;
                      endfilereading;
                      checkoutervalidity;
                      goto 20;
                    End;
                  If (eqtb[5311].int<0)Or(eqtb[5311].int>255)Then curinput.limitfield := 
                                                                                         curinput.
                                                                                         limitfield-
                                                                                         1
                  Else buffer[curinput.limitfield] := eqtb[5311].int;
                  first := curinput.limitfield+1;
                  curinput.locfield := curinput.startfield;
                End{:362}
              Else
                Begin
                  If Not(curinput.namefield=0)Then
                    Begin
                      curcmd := 0;
                      curchr := 0;
                      goto 10;
                    End;
                  If inputptr>0 Then
                    Begin
                      endfilereading;
                      goto 20;
                    End;
                  If selector<18 Then openlogfile;
                  If interaction>1 Then
                    Begin
                      If (eqtb[5311].int<0)Or(eqtb[5311].int>255)
                        Then curinput.limitfield := curinput.limitfield+1;
                      If curinput.limitfield=-1 Then printnl(616);
                      printnl(338);
                      first := curinput.startfield;
                      Begin;
                        print(42);
                        terminput;
                      End;
                      curinput.limitfield := last;
                      If (eqtb[5311].int<0)Or(eqtb[5311].int>255)Then curinput.limitfield := 

                                                                                            curinput
                                                                                             .
                                                                                          limitfield
                                                                                             -1
                      Else buffer[curinput.limitfield] := eqtb[5311].int;
                      first := curinput.limitfield+1;
                      curinput.locfield := curinput.startfield;
                    End
                  Else fatalerror(617);
                End{:360};
              Begin
                If interrupt<>0 Then pauseforinstructions;
              End;
              goto 25;
            End;
    End{:343}
  Else{357:}If curinput.locfield<>0 Then
              Begin
                t := mem[curinput.
                     locfield].hh.lh;
                curinput.locfield := mem[curinput.locfield].hh.rh;
                If t>=4095 Then
                  Begin
                    curcs := t-4095;
                    curcmd := eqtb[curcs].hh.b0;
                    curchr := eqtb[curcs].hh.rh;
                    If curcmd>=113 Then If curcmd=116 Then{358:}
                                          Begin
                                            curcs := mem[curinput.
                                                     locfield].hh.lh-4095;
                                            curinput.locfield := 0;
                                            curcmd := eqtb[curcs].hh.b0;
                                            curchr := eqtb[curcs].hh.rh;
                                            If curcmd>100 Then
                                              Begin
                                                curcmd := 0;
                                                curchr := 257;
                                              End;
                                          End{:358}
                    Else checkoutervalidity;
                  End
                Else
                  Begin
                    curcmd := t Div 256;
                    curchr := t Mod 256;
                    Case curcmd Of 
                      1: alignstate := alignstate+1;
                      2: alignstate := alignstate-1;
                      5:{359:}
                         Begin
                           begintokenlist(paramstack[curinput.limitfield+curchr-1],0)
                           ;
                           goto 20;
                         End{:359};
                      Else
                    End;
                  End;
              End
  Else
    Begin
      endtokenlist;
      goto 20;
    End{:357};
{342:}
  If curcmd<=5 Then If curcmd>=4 Then If alignstate=0 Then{789:}
                                        Begin
                                          If (scannerstatus=4)Or(curalign=0)Then fatalerror(595);
                                          curcmd := mem[curalign+5].hh.lh;
                                          mem[curalign+5].hh.lh := curchr;
                                          If curcmd=63 Then begintokenlist(29990,2)
                                          Else begintokenlist(mem[
                                                              curalign+2].int,2);
                                          alignstate := 1000000;
                                          goto 20;
                                        End{:789}{:342};
  10:
End;
{:341}{363:}
Procedure firmuptheline;

Var k: 0..bufsize;
Begin
  curinput.limitfield := last;
  If eqtb[5291].int>0 Then If interaction>1 Then
                             Begin;
                               println;
                               If curinput.startfield<curinput.limitfield Then For k:=curinput.
                                                                                   startfield To
                                                                                   curinput.
                                                                                   limitfield-1 Do
                                                                                 print(buffer[k]);
                               first := curinput.limitfield;
                               Begin;
                                 print(618);
                                 terminput;
                               End;
                               If last>first Then
                                 Begin
                                   For k:=first To last-1 Do
                                     buffer[k+curinput.
                                     startfield-first] := buffer[k];
                                   curinput.limitfield := curinput.startfield+last-first;
                                 End;
                             End;
End;
{:363}{365:}
Procedure gettoken;
Begin
  nonewcontrolsequence := false;
  getnext;
  nonewcontrolsequence := true;
  If curcs=0 Then curtok := (curcmd*256)+curchr
  Else curtok := 4095+curcs;
End;
{:365}{366:}{389:}
Procedure macrocall;

Label 10,22,30,31,40;

Var r: halfword;
  p: halfword;
  q: halfword;
  s: halfword;
  t: halfword;
  u,v: halfword;
  rbraceptr: halfword;
  n: smallnumber;
  unbalance: halfword;
  m: halfword;
  refcount: halfword;
  savescannerstatus: smallnumber;
  savewarningindex: halfword;
  matchchr: ASCIIcode;
Begin
  savescannerstatus := scannerstatus;
  savewarningindex := warningindex;
  warningindex := curcs;
  refcount := curchr;
  r := mem[refcount].hh.rh;
  n := 0;
  If eqtb[5293].int>0 Then{401:}
    Begin
      begindiagnostic;
      println;
      printcs(warningindex);
      tokenshow(refcount);
      enddiagnostic(false);
    End{:401};
  If mem[r].hh.lh<>3584 Then{391:}
    Begin
      scannerstatus := 3;
      unbalance := 0;
      longstate := eqtb[curcs].hh.b0;
      If longstate>=113 Then longstate := longstate-2;
      Repeat
        mem[29997].hh.rh := 0;
        If (mem[r].hh.lh>3583)Or(mem[r].hh.lh<3328)Then s := 0
        Else
          Begin
            matchchr 
            := mem[r].hh.lh-3328;
            s := mem[r].hh.rh;
            r := s;
            p := 29997;
            m := 0;
          End;
{392:}
        22: gettoken;
        If curtok=mem[r].hh.lh Then{394:}
          Begin
            r := mem[r].hh.rh;
            If (mem[r].hh.lh>=3328)And(mem[r].hh.lh<=3584)Then
              Begin
                If curtok<512
                  Then alignstate := alignstate-1;
                goto 40;
              End
            Else goto 22;
          End{:394};
{397:}
        If s<>r Then If s=0 Then{398:}
                       Begin
                         Begin
                           If interaction=3 Then;
                           printnl(262);
                           print(650);
                         End;
                         sprintcs(warningindex);
                         print(651);
                         Begin
                           helpptr := 4;
                           helpline[3] := 652;
                           helpline[2] := 653;
                           helpline[1] := 654;
                           helpline[0] := 655;
                         End;
                         error;
                         goto 10;
                       End{:398}
        Else
          Begin
            t := s;
            Repeat
              Begin
                q := getavail;
                mem[p].hh.rh := q;
                mem[q].hh.lh := mem[t].hh.lh;
                p := q;
              End;
              m := m+1;
              u := mem[t].hh.rh;
              v := s;
              While true Do
                Begin
                  If u=r Then If curtok<>mem[v].hh.lh Then goto 30
                  Else
                    Begin
                      r := mem[v].hh.rh;
                      goto 22;
                    End;
                  If mem[u].hh.lh<>mem[v].hh.lh Then goto 30;
                  u := mem[u].hh.rh;
                  v := mem[v].hh.rh;
                End;
              30: t := mem[t].hh.rh;
            Until t=r;
            r := s;
          End{:397};
        If curtok=partoken Then If longstate<>112 Then{396:}
                                  Begin
                                    If longstate=
                                       111 Then
                                      Begin
                                        runaway;
                                        Begin
                                          If interaction=3 Then;
                                          printnl(262);
                                          print(645);
                                        End;
                                        sprintcs(warningindex);
                                        print(646);
                                        Begin
                                          helpptr := 3;
                                          helpline[2] := 647;
                                          helpline[1] := 648;
                                          helpline[0] := 649;
                                        End;
                                        backerror;
                                      End;
                                    pstack[n] := mem[29997].hh.rh;
                                    alignstate := alignstate-unbalance;
                                    For m:=0 To n Do
                                      flushlist(pstack[m]);
                                    goto 10;
                                  End{:396};
        If curtok<768 Then If curtok<512 Then{399:}
                             Begin
                               unbalance := 1;
                               While true Do
                                 Begin
                                   Begin
                                     Begin
                                       q := avail;
                                       If q=0 Then q := getavail
                                       Else
                                         Begin
                                           avail := mem[q].hh.rh;
                                           mem[q].hh.rh := 0;
                                           dynused := dynused+1;
                                         End;
                                     End;
                                     mem[p].hh.rh := q;
                                     mem[q].hh.lh := curtok;
                                     p := q;
                                   End;
                                   gettoken;
                                   If curtok=partoken Then If longstate<>112 Then{396:}
                                                             Begin
                                                               If longstate=
                                                                  111 Then
                                                                 Begin
                                                                   runaway;
                                                                   Begin
                                                                     If interaction=3 Then;
                                                                     printnl(262);
                                                                     print(645);
                                                                   End;
                                                                   sprintcs(warningindex);
                                                                   print(646);
                                                                   Begin
                                                                     helpptr := 3;
                                                                     helpline[2] := 647;
                                                                     helpline[1] := 648;
                                                                     helpline[0] := 649;
                                                                   End;
                                                                   backerror;
                                                                 End;
                                                               pstack[n] := mem[29997].hh.rh;
                                                               alignstate := alignstate-unbalance;
                                                               For m:=0 To n Do
                                                                 flushlist(pstack[m]);
                                                               goto 10;
                                                             End{:396};
                                   If curtok<768 Then If curtok<512 Then unbalance := unbalance+1
                                   Else
                                     Begin
                                       unbalance := unbalance-1;
                                       If unbalance=0 Then goto 31;
                                     End;
                                 End;
                               31: rbraceptr := p;
                               Begin
                                 q := getavail;
                                 mem[p].hh.rh := q;
                                 mem[q].hh.lh := curtok;
                                 p := q;
                               End;
                             End{:399}
        Else{395:}
          Begin
            backinput;
            Begin
              If interaction=3 Then;
              printnl(262);
              print(637);
            End;
            sprintcs(warningindex);
            print(638);
            Begin
              helpptr := 6;
              helpline[5] := 639;
              helpline[4] := 640;
              helpline[3] := 641;
              helpline[2] := 642;
              helpline[1] := 643;
              helpline[0] := 644;
            End;
            alignstate := alignstate+1;
            longstate := 111;
            curtok := partoken;
            inserror;
            goto 22;
          End{:395}
        Else{393:}
          Begin
            If curtok=2592 Then If mem[r].hh.lh<=3584 Then
                                  If mem[r].hh.lh>=3328 Then goto 22;
            Begin
              q := getavail;
              mem[p].hh.rh := q;
              mem[q].hh.lh := curtok;
              p := q;
            End;
          End{:393};
        m := m+1;
        If mem[r].hh.lh>3584 Then goto 22;
        If mem[r].hh.lh<3328 Then goto 22;
        40: If s<>0 Then{400:}
              Begin
                If (m=1)And(mem[p].hh.lh<768)Then
                  Begin
                    mem[
                    rbraceptr].hh.rh := 0;
                    Begin
                      mem[p].hh.rh := avail;
                      avail := p;
                      dynused := dynused-1;
                    End;
                    p := mem[29997].hh.rh;
                    pstack[n] := mem[p].hh.rh;
                    Begin
                      mem[p].hh.rh := avail;
                      avail := p;
                      dynused := dynused-1;
                    End;
                  End
                Else pstack[n] := mem[29997].hh.rh;
                n := n+1;
                If eqtb[5293].int>0 Then
                  Begin
                    begindiagnostic;
                    printnl(matchchr);
                    printint(n);
                    print(656);
                    showtokenlist(pstack[n-1],0,1000);
                    enddiagnostic(false);
                  End;
              End{:400}{:392};
      Until mem[r].hh.lh=3584;
    End{:391};
{390:}
  While (curinput.statefield=0)And(curinput.locfield=0)And(curinput.
        indexfield<>2) Do
    endtokenlist;
  begintokenlist(refcount,5);
  curinput.namefield := warningindex;
  curinput.locfield := mem[r].hh.rh;
  If n>0 Then
    Begin
      If paramptr+n>maxparamstack Then
        Begin
          maxparamstack := 
                           paramptr+n;
          If maxparamstack>paramsize Then overflow(636,paramsize);
        End;
      For m:=0 To n-1 Do
        paramstack[paramptr+m] := pstack[m];
      paramptr := paramptr+n;
    End{:390};
  10: scannerstatus := savescannerstatus;
  warningindex := savewarningindex;
End;{:389}{379:}
Procedure insertrelax;
Begin
  curtok := 4095+curcs;
  backinput;
  curtok := 6716;
  backinput;
  curinput.indexfield := 4;
End;{:379}
Procedure passtext;
forward;
Procedure startinput;
forward;
Procedure conditional;
forward;
Procedure getxtoken;
forward;
Procedure convtoks;
forward;
Procedure insthetoks;
forward;
Procedure expand;

Var t: halfword;
  p,q,r: halfword;
  j: 0..bufsize;
  cvbackup: integer;
  cvlbackup,radixbackup,cobackup: smallnumber;
  backupbackup: halfword;
  savescannerstatus: smallnumber;
Begin
  cvbackup := curval;
  cvlbackup := curvallevel;
  radixbackup := radix;
  cobackup := curorder;
  backupbackup := mem[29987].hh.rh;
  If curcmd<111 Then{367:}
    Begin
      If eqtb[5299].int>1 Then showcurcmdchr;
      Case curcmd Of 
        110:{386:}
             Begin
               If curmark[curchr]<>0 Then begintokenlist
                 (curmark[curchr],14);
             End{:386};
        102:{368:}
             Begin
               gettoken;
               t := curtok;
               gettoken;
               If curcmd>100 Then expand
               Else backinput;
               curtok := t;
               backinput;
             End{:368};
        103:{369:}
             Begin
               savescannerstatus := scannerstatus;
               scannerstatus := 0;
               gettoken;
               scannerstatus := savescannerstatus;
               t := curtok;
               backinput;
               If t>=4095 Then
                 Begin
                   p := getavail;
                   mem[p].hh.lh := 6718;
                   mem[p].hh.rh := curinput.locfield;
                   curinput.startfield := p;
                   curinput.locfield := p;
                 End;
             End{:369};
        107:{372:}
             Begin
               r := getavail;
               p := r;
               Repeat
                 getxtoken;
                 If curcs=0 Then
                   Begin
                     q := getavail;
                     mem[p].hh.rh := q;
                     mem[q].hh.lh := curtok;
                     p := q;
                   End;
               Until curcs<>0;
               If curcmd<>67 Then{373:}
                 Begin
                   Begin
                     If interaction=3 Then;
                     printnl(262);
                     print(625);
                   End;
                   printesc(505);
                   print(626);
                   Begin
                     helpptr := 2;
                     helpline[1] := 627;
                     helpline[0] := 628;
                   End;
                   backerror;
                 End{:373};
{374:}
               j := first;
               p := mem[r].hh.rh;
               While p<>0 Do
                 Begin
                   If j>=maxbufstack Then
                     Begin
                       maxbufstack := j+1;
                       If maxbufstack=bufsize Then overflow(256,bufsize);
                     End;
                   buffer[j] := mem[p].hh.lh Mod 256;
                   j := j+1;
                   p := mem[p].hh.rh;
                 End;
               If j>first+1 Then
                 Begin
                   nonewcontrolsequence := false;
                   curcs := idlookup(first,j-first);
                   nonewcontrolsequence := true;
                 End
               Else If j=first Then curcs := 513
               Else curcs := 257+buffer[first]{:374};
               flushlist(r);
               If eqtb[curcs].hh.b0=101 Then
                 Begin
                   eqdefine(curcs,0,256);
                 End;
               curtok := curcs+4095;
               backinput;
             End{:372};
        108: convtoks;
        109: insthetoks;
        105: conditional;
        106:{510:}If curchr>iflimit Then If iflimit=1 Then insertrelax
             Else
               Begin
                 Begin
                   If interaction=3 Then;
                   printnl(262);
                   print(777);
                 End;
                 printcmdchr(106,curchr);
                 Begin
                   helpptr := 1;
                   helpline[0] := 778;
                 End;
                 error;
               End
             Else
               Begin
                 While curchr<>2 Do
                   passtext;{496:}
                 Begin
                   p := condptr;
                   ifline := mem[p+1].int;
                   curif := mem[p].hh.b1;
                   iflimit := mem[p].hh.b0;
                   condptr := mem[p].hh.rh;
                   freenode(p,2);
                 End{:496};
               End{:510};
        104:{378:}If curchr>0 Then forceeof := true
             Else If nameinprogress Then
                    insertrelax
             Else startinput{:378};
        Else{370:}
          Begin
            Begin
              If interaction=3 Then;
              printnl(262);
              print(619);
            End;
            Begin
              helpptr := 5;
              helpline[4] := 620;
              helpline[3] := 621;
              helpline[2] := 622;
              helpline[1] := 623;
              helpline[0] := 624;
            End;
            error;
          End{:370}
      End;
    End{:367}
  Else If curcmd<115 Then macrocall
  Else{375:}
    Begin
      curtok := 6715;
      backinput;
    End{:375};
  curval := cvbackup;
  curvallevel := cvlbackup;
  radix := radixbackup;
  curorder := cobackup;
  mem[29987].hh.rh := backupbackup;
End;{:366}{380:}
Procedure getxtoken;

Label 20,30;
Begin
  20: getnext;
  If curcmd<=100 Then goto 30;
  If curcmd>=111 Then If curcmd<115 Then macrocall
  Else
    Begin
      curcs := 2620;
      curcmd := 9;
      goto 30;
    End
  Else expand;
  goto 20;
  30: If curcs=0 Then curtok := (curcmd*256)+curchr
      Else curtok := 4095+curcs;
End;{:380}{381:}
Procedure xtoken;
Begin
  While curcmd>100 Do
    Begin
      expand;
      getnext;
    End;
  If curcs=0 Then curtok := (curcmd*256)+curchr
  Else curtok := 4095+curcs;
End;
{:381}{403:}
Procedure scanleftbrace;
Begin{404:}
  Repeat
    getxtoken;
  Until (curcmd<>10)And(curcmd<>0){:404};
  If curcmd<>1 Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(657);
      End;
      Begin
        helpptr := 4;
        helpline[3] := 658;
        helpline[2] := 659;
        helpline[1] := 660;
        helpline[0] := 661;
      End;
      backerror;
      curtok := 379;
      curcmd := 1;
      curchr := 123;
      alignstate := alignstate+1;
    End;
End;
{:403}{405:}
Procedure scanoptionalequals;
Begin{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  If curtok<>3133 Then backinput;
End;
{:405}{407:}
Function scankeyword(s:strnumber): boolean;

Label 10;

Var p: halfword;
  q: halfword;
  k: poolpointer;
Begin
  p := 29987;
  mem[p].hh.rh := 0;
  k := strstart[s];
  While k<strstart[s+1] Do
    Begin
      getxtoken;
      If (curcs=0)And((curchr=strpool[k])Or(curchr=strpool[k]-32))Then
        Begin
          Begin
            q := getavail;
            mem[p].hh.rh := q;
            mem[q].hh.lh := curtok;
            p := q;
          End;
          k := k+1;
        End
      Else If (curcmd<>10)Or(p<>29987)Then
             Begin
               backinput;
               If p<>29987 Then begintokenlist(mem[29987].hh.rh,3);
               scankeyword := false;
               goto 10;
             End;
    End;
  flushlist(mem[29987].hh.rh);
  scankeyword := true;
  10:
End;
{:407}{408:}
Procedure muerror;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(662);
  End;
  Begin
    helpptr := 1;
    helpline[0] := 663;
  End;
  error;
End;{:408}{409:}
Procedure scanint;
forward;
{433:}
Procedure scaneightbitint;
Begin
  scanint;
  If (curval<0)Or(curval>255)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(687);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 688;
        helpline[0] := 689;
      End;
      interror(curval);
      curval := 0;
    End;
End;
{:433}{434:}
Procedure scancharnum;
Begin
  scanint;
  If (curval<0)Or(curval>255)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(690);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 691;
        helpline[0] := 689;
      End;
      interror(curval);
      curval := 0;
    End;
End;
{:434}{435:}
Procedure scanfourbitint;
Begin
  scanint;
  If (curval<0)Or(curval>15)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(692);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 693;
        helpline[0] := 689;
      End;
      interror(curval);
      curval := 0;
    End;
End;
{:435}{436:}
Procedure scanfifteenbitint;
Begin
  scanint;
  If (curval<0)Or(curval>32767)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(694);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 695;
        helpline[0] := 689;
      End;
      interror(curval);
      curval := 0;
    End;
End;
{:436}{437:}
Procedure scantwentysevenbitint;
Begin
  scanint;
  If (curval<0)Or(curval>134217727)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(696);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 697;
        helpline[0] := 689;
      End;
      interror(curval);
      curval := 0;
    End;
End;
{:437}{577:}
Procedure scanfontident;

Var f: internalfontnumber;
  m: halfword;
Begin{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  If curcmd=88 Then f := eqtb[3934].hh.rh
  Else If curcmd=87 Then f := curchr
  Else If curcmd=86 Then
         Begin
           m := curchr;
           scanfourbitint;
           f := eqtb[m+curval].hh.rh;
         End
  Else
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(818);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 819;
        helpline[0] := 820;
      End;
      backerror;
      f := 0;
    End;
  curval := f;
End;
{:577}{578:}
Procedure findfontdimen(writing:boolean);

Var f: internalfontnumber;
  n: integer;
Begin
  scanint;
  n := curval;
  scanfontident;
  f := curval;
  If n<=0 Then curval := fmemptr
  Else
    Begin
      If writing And(n<=4)And(n>=2)And
         (fontglue[f]<>0)Then
        Begin
          deleteglueref(fontglue[f]);
          fontglue[f] := 0;
        End;
      If n>fontparams[f]Then If f<fontptr Then curval := fmemptr
      Else{580:}
        Begin
          Repeat
            If fmemptr=fontmemsize Then overflow(825,fontmemsize);
            fontinfo[fmemptr].int := 0;
            fmemptr := fmemptr+1;
            fontparams[f] := fontparams[f]+1;
          Until n=fontparams[f];
          curval := fmemptr-1;
        End{:580}
      Else curval := n+parambase[f];
    End;
{579:}
  If curval=fmemptr Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(803);
      End;
      printesc(hash[2624+f].rh);
      print(821);
      printint(fontparams[f]);
      print(822);
      Begin
        helpptr := 2;
        helpline[1] := 823;
        helpline[0] := 824;
      End;
      error;
    End{:579};
End;
{:578}{:409}{413:}
Procedure scansomethinginternal(level:smallnumber;
                                negative:boolean);

Var m: halfword;
  p: 0..nestsize;
Begin
  m := curchr;
  Case curcmd Of 
    85:{414:}
        Begin
          scancharnum;
          If m=5007 Then
            Begin
              curval := eqtb[5007+curval].hh.rh;
              curvallevel := 0;
            End
          Else If m<5007 Then
                 Begin
                   curval := eqtb[m+curval].hh.rh;
                   curvallevel := 0;
                 End
          Else
            Begin
              curval := eqtb[m+curval].int;
              curvallevel := 0;
            End;
        End{:414};
    71,72,86,87,88:{415:}If level<>5 Then
                           Begin
                             Begin
                               If interaction=3 Then;
                               printnl(262);
                               print(664);
                             End;
                             Begin
                               helpptr := 3;
                               helpline[2] := 665;
                               helpline[1] := 666;
                               helpline[0] := 667;
                             End;
                             backerror;
                             Begin
                               curval := 0;
                               curvallevel := 1;
                             End;
                           End
                    Else If curcmd<=72 Then
                           Begin
                             If curcmd<72 Then
                               Begin
                                 scaneightbitint;
                                 m := 3422+curval;
                               End;
                             Begin
                               curval := eqtb[m].hh.rh;
                               curvallevel := 5;
                             End;
                           End
                    Else
                      Begin
                        backinput;
                        scanfontident;
                        Begin
                          curval := 2624+curval;
                          curvallevel := 4;
                        End;
                      End{:415};
    73:
        Begin
          curval := eqtb[m].int;
          curvallevel := 0;
        End;
    74:
        Begin
          curval := eqtb[m].int;
          curvallevel := 1;
        End;
    75:
        Begin
          curval := eqtb[m].hh.rh;
          curvallevel := 2;
        End;
    76:
        Begin
          curval := eqtb[m].hh.rh;
          curvallevel := 3;
        End;
    79:{418:}If abs(curlist.modefield)<>m Then
               Begin
                 Begin
                   If interaction=3
                     Then;
                   printnl(262);
                   print(680);
                 End;
                 printcmdchr(79,m);
                 Begin
                   helpptr := 4;
                   helpline[3] := 681;
                   helpline[2] := 682;
                   helpline[1] := 683;
                   helpline[0] := 684;
                 End;
                 error;
                 If level<>5 Then
                   Begin
                     curval := 0;
                     curvallevel := 1;
                   End
                 Else
                   Begin
                     curval := 0;
                     curvallevel := 0;
                   End;
               End
        Else If m=1 Then
               Begin
                 curval := curlist.auxfield.int;
                 curvallevel := 1;
               End
        Else
          Begin
            curval := curlist.auxfield.hh.lh;
            curvallevel := 0;
          End{:418};
    80:{422:}If curlist.modefield=0 Then
               Begin
                 curval := 0;
                 curvallevel := 0;
               End
        Else
          Begin
            nest[nestptr] := curlist;
            p := nestptr;
            While abs(nest[p].modefield)<>1 Do
              p := p-1;
            Begin
              curval := nest[p].pgfield;
              curvallevel := 0;
            End;
          End{:422};
    82:{419:}
        Begin
          If m=0 Then curval := deadcycles
          Else curval := 
                         insertpenalties;
          curvallevel := 0;
        End{:419};
    81:{421:}
        Begin
          If (pagecontents=0)And(Not outputactive)Then If m=0 Then
                                                         curval := 1073741823
          Else curval := 0
          Else curval := pagesofar[m];
          curvallevel := 1;
        End{:421};
    84:{423:}
        Begin
          If eqtb[3412].hh.rh=0 Then curval := 0
          Else curval := mem[
                         eqtb[3412].hh.rh].hh.lh;
          curvallevel := 0;
        End{:423};
    83:{420:}
        Begin
          scaneightbitint;
          If eqtb[3678+curval].hh.rh=0 Then curval := 0
          Else curval := mem[eqtb[3678+
                         curval].hh.rh+m].int;
          curvallevel := 1;
        End{:420};
    68,69:
           Begin
             curval := curchr;
             curvallevel := 0;
           End;
    77:{425:}
        Begin
          findfontdimen(false);
          fontinfo[fmemptr].int := 0;
          Begin
            curval := fontinfo[curval].int;
            curvallevel := 1;
          End;
        End{:425};
    78:{426:}
        Begin
          scanfontident;
          If m=0 Then
            Begin
              curval := hyphenchar[curval];
              curvallevel := 0;
            End
          Else
            Begin
              curval := skewchar[curval];
              curvallevel := 0;
            End;
        End{:426};
    89:{427:}
        Begin
          scaneightbitint;
          Case m Of 
            0: curval := eqtb[5318+curval].int;
            1: curval := eqtb[5851+curval].int;
            2: curval := eqtb[2900+curval].hh.rh;
            3: curval := eqtb[3156+curval].hh.rh;
          End;
          curvallevel := m;
        End{:427};
    70:{424:}If curchr>2 Then
               Begin
                 If curchr=3 Then curval := line
                 Else
                   curval := lastbadness;
                 curvallevel := 0;
               End
        Else
          Begin
            If curchr=2 Then curval := 0
            Else curval := 0;
            curvallevel := curchr;
            If Not(curlist.tailfield>=himemmin)And(curlist.modefield<>0)Then Case 
                                                                                  curchr Of 
                                                                               0: If mem[curlist.
                                                                                     tailfield].hh.
                                                                                     b0=12 Then
                                                                                    curval := mem[
                                                                                             curlist
                                                                                              .

                                                                                           tailfield
                                                                                              +1].
                                                                                              int;
                                                                               1: If mem[curlist.
                                                                                     tailfield].hh.
                                                                                     b0=11 Then
                                                                                    curval := mem[
                                                                                             curlist
                                                                                              .
                                                                                           tailfield
                                                                                              +1].
                                                                                              int;
                                                                               2: If mem[curlist.
                                                                                     tailfield].hh.
                                                                                     b0=10 Then
                                                                                    Begin
                                                                                      curval := mem[
                                                                                             curlist
                                                                                                .

                                                                                           tailfield
                                                                                                +1].
                                                                                                hh.
                                                                                                lh;
                                                                                      If mem[curlist
                                                                                         .tailfield]
                                                                                         .hh.b1=99
                                                                                        Then
                                                                                        curvallevel 
                                                                                        := 3;
                                                                                    End;
              End
            Else If (curlist.modefield=1)And(curlist.tailfield=curlist.headfield)
                   Then Case curchr Of 
                          0: curval := lastpenalty;
                          1: curval := lastkern;
                          2: If lastglue<>65535 Then curval := lastglue;
                   End;
          End{:424};
    Else{428:}
      Begin
        Begin
          If interaction=3 Then;
          printnl(262);
          print(685);
        End;
        printcmdchr(curcmd,curchr);
        print(686);
        printesc(537);
        Begin
          helpptr := 1;
          helpline[0] := 684;
        End;
        error;
        If level<>5 Then
          Begin
            curval := 0;
            curvallevel := 1;
          End
        Else
          Begin
            curval := 0;
            curvallevel := 0;
          End;
      End{:428}
  End;
  While curvallevel>level Do{429:}
    Begin
      If curvallevel=2 Then curval := mem[
                                      curval+1].int
      Else If curvallevel=3 Then muerror;
      curvallevel := curvallevel-1;
    End{:429};
{430:}
  If negative Then If curvallevel>=2 Then
                     Begin
                       curval := newspec(
                                 curval);{431:}
                       Begin
                         mem[curval+1].int := -mem[curval+1].int;
                         mem[curval+2].int := -mem[curval+2].int;
                         mem[curval+3].int := -mem[curval+3].int;
                       End{:431};
                     End
  Else curval := -curval
  Else If (curvallevel>=2)And(curvallevel<=3)Then
         mem[curval].hh.rh := mem[curval].hh.rh+1{:430};
End;
{:413}{440:}
Procedure scanint;

Label 30;

Var negative: boolean;
  m: integer;
  d: smallnumber;
  vacuous: boolean;
  OKsofar: boolean;
Begin
  radix := 0;
  OKsofar := true;{441:}
  negative := false;
  Repeat{406:}
    Repeat
      getxtoken;
    Until curcmd<>10{:406};
    If curtok=3117 Then
      Begin
        negative := Not negative;
        curtok := 3115;
      End;
  Until curtok<>3115{:441};
  If curtok=3168 Then{442:}
    Begin
      gettoken;
      If curtok<4095 Then
        Begin
          curval := curchr;
          If curcmd<=2 Then If curcmd=2 Then alignstate := alignstate+1
          Else
            alignstate := alignstate-1;
        End
      Else If curtok<4352 Then curval := curtok-4096
      Else curval := curtok
                     -4352;
      If curval>255 Then
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(698);
          End;
          Begin
            helpptr := 2;
            helpline[1] := 699;
            helpline[0] := 700;
          End;
          curval := 48;
          backerror;
        End
      Else{443:}
        Begin
          getxtoken;
          If curcmd<>10 Then backinput;
        End{:443};
    End{:442}
  Else If (curcmd>=68)And(curcmd<=89)Then scansomethinginternal(0,
                                                                false)
  Else{444:}
    Begin
      radix := 10;
      m := 214748364;
      If curtok=3111 Then
        Begin
          radix := 8;
          m := 268435456;
          getxtoken;
        End
      Else If curtok=3106 Then
             Begin
               radix := 16;
               m := 134217728;
               getxtoken;
             End;
      vacuous := true;
      curval := 0;
{445:}
      While true Do
        Begin
          If (curtok<3120+radix)And(curtok>=3120)And(
             curtok<=3129)Then d := curtok-3120
          Else If radix=16 Then If (curtok<=2886)
                                   And(curtok>=2881)Then d := curtok-2871
          Else If (curtok<=3142)And(curtok>=
                  3137)Then d := curtok-3127
          Else goto 30
          Else goto 30;
          vacuous := false;
          If (curval>=m)And((curval>m)Or(d>7)Or(radix<>10))Then
            Begin
              If OKsofar
                Then
                Begin
                  Begin
                    If interaction=3 Then;
                    printnl(262);
                    print(701);
                  End;
                  Begin
                    helpptr := 2;
                    helpline[1] := 702;
                    helpline[0] := 703;
                  End;
                  error;
                  curval := 2147483647;
                  OKsofar := false;
                End;
            End
          Else curval := curval*radix+d;
          getxtoken;
        End;
      30:{:445};
      If vacuous Then{446:}
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(664);
          End;
          Begin
            helpptr := 3;
            helpline[2] := 665;
            helpline[1] := 666;
            helpline[0] := 667;
          End;
          backerror;
        End{:446}
      Else If curcmd<>10 Then backinput;
    End{:444};
  If negative Then curval := -curval;
End;
{:440}{448:}
Procedure scandimen(mu,inf,shortcut:boolean);

Label 30,31,32,40,45,88,89;

Var negative: boolean;
  f: integer;
{450:}
  num,denom: 1..65536;
  k,kk: smallnumber;
  p,q: halfword;
  v: scaled;
  savecurval: integer;{:450}
Begin
  f := 0;
  aritherror := false;
  curorder := 0;
  negative := false;
  If Not shortcut Then
    Begin{441:}
      negative := false;
      Repeat{406:}
        Repeat
          getxtoken;
        Until curcmd<>10{:406};
        If curtok=3117 Then
          Begin
            negative := Not negative;
            curtok := 3115;
          End;
      Until curtok<>3115{:441};
      If (curcmd>=68)And(curcmd<=89)Then{449:}If mu Then
                                                Begin
                                                  scansomethinginternal(3,false);
{451:}
                                                  If curvallevel>=2 Then
                                                    Begin
                                                      v := mem[curval+1].int;
                                                      deleteglueref(curval);
                                                      curval := v;
                                                    End{:451};
                                                  If curvallevel=3 Then goto 89;
                                                  If curvallevel<>0 Then muerror;
                                                End
      Else
        Begin
          scansomethinginternal(1,false);
          If curvallevel=1 Then goto 89;
        End{:449}
      Else
        Begin
          backinput;
          If curtok=3116 Then curtok := 3118;
          If curtok<>3118 Then scanint
          Else
            Begin
              radix := 10;
              curval := 0;
            End;
          If curtok=3116 Then curtok := 3118;
          If (radix=10)And(curtok=3118)Then{452:}
            Begin
              k := 0;
              p := 0;
              gettoken;
              While true Do
                Begin
                  getxtoken;
                  If (curtok>3129)Or(curtok<3120)Then goto 31;
                  If k<17 Then
                    Begin
                      q := getavail;
                      mem[q].hh.rh := p;
                      mem[q].hh.lh := curtok-3120;
                      p := q;
                      k := k+1;
                    End;
                End;
              31: For kk:=k Downto 1 Do
                    Begin
                      dig[kk-1] := mem[p].hh.lh;
                      q := p;
                      p := mem[p].hh.rh;
                      Begin
                        mem[q].hh.rh := avail;
                        avail := q;
                        dynused := dynused-1;
                      End;
                    End;
              f := rounddecimals(k);
              If curcmd<>10 Then backinput;
            End{:452};
        End;
    End;
  If curval<0 Then
    Begin
      negative := Not negative;
      curval := -curval;
    End;
{453:}
  If inf Then{454:}If scankeyword(311)Then
                     Begin
                       curorder := 1;
                       While scankeyword(108) Do
                         Begin
                           If curorder=3 Then
                             Begin
                               Begin
                                 If 
                                    interaction=3 Then;
                                 printnl(262);
                                 print(705);
                               End;
                               print(706);
                               Begin
                                 helpptr := 1;
                                 helpline[0] := 707;
                               End;
                               error;
                             End
                           Else curorder := curorder+1;
                         End;
                       goto 88;
                     End{:454};
{455:}
  savecurval := curval;{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  If (curcmd<68)Or(curcmd>89)Then backinput
  Else
    Begin
      If mu Then
        Begin
          scansomethinginternal(3,false);
{451:}
          If curvallevel>=2 Then
            Begin
              v := mem[curval+1].int;
              deleteglueref(curval);
              curval := v;
            End{:451};
          If curvallevel<>3 Then muerror;
        End
      Else scansomethinginternal(1,false);
      v := curval;
      goto 40;
    End;
  If mu Then goto 45;
  If scankeyword(708)Then v := ({558:}fontinfo[6+parambase[eqtb[3934].hh.rh]
                               ].int{:558})
  Else If scankeyword(709)Then v := ({559:}fontinfo[5+parambase[
                                    eqtb[3934].hh.rh]].int{:559})
  Else goto 45;{443:}
  Begin
    getxtoken;
    If curcmd<>10 Then backinput;
  End{:443};
  40: curval := multandadd(savecurval,v,xnoverd(v,f,65536),1073741823);
  goto 89;
  45:{:455};
  If mu Then{456:}If scankeyword(337)Then goto 88
  Else
    Begin
      Begin
        If 
           interaction=3 Then;
        printnl(262);
        print(705);
      End;
      print(710);
      Begin
        helpptr := 4;
        helpline[3] := 711;
        helpline[2] := 712;
        helpline[1] := 713;
        helpline[0] := 714;
      End;
      error;
      goto 88;
    End{:456};
  If scankeyword(704)Then{457:}
    Begin
      preparemag;
      If eqtb[5280].int<>1000 Then
        Begin
          curval := xnoverd(curval,1000,eqtb[5280
                    ].int);
          f := (1000*f+65536*remainder)Div eqtb[5280].int;
          curval := curval+(f Div 65536);
          f := f Mod 65536;
        End;
    End{:457};
  If scankeyword(397)Then goto 88;
{458:}
  If scankeyword(715)Then
    Begin
      num := 7227;
      denom := 100;
    End
  Else If scankeyword(716)Then
         Begin
           num := 12;
           denom := 1;
         End
  Else If scankeyword(717)Then
         Begin
           num := 7227;
           denom := 254;
         End
  Else If scankeyword(718)Then
         Begin
           num := 7227;
           denom := 2540;
         End
  Else If scankeyword(719)Then
         Begin
           num := 7227;
           denom := 7200;
         End
  Else If scankeyword(720)Then
         Begin
           num := 1238;
           denom := 1157;
         End
  Else If scankeyword(721)Then
         Begin
           num := 14856;
           denom := 1157;
         End
  Else If scankeyword(722)Then goto 30
  Else{459:}
    Begin
      Begin
        If 
           interaction=3 Then;
        printnl(262);
        print(705);
      End;
      print(723);
      Begin
        helpptr := 6;
        helpline[5] := 724;
        helpline[4] := 725;
        helpline[3] := 726;
        helpline[2] := 712;
        helpline[1] := 713;
        helpline[0] := 714;
      End;
      error;
      goto 32;
    End{:459};
  curval := xnoverd(curval,num,denom);
  f := (num*f+65536*remainder)Div denom;
  curval := curval+(f Div 65536);
  f := f Mod 65536;
  32:{:458};
  88: If curval>=16384 Then aritherror := true
      Else curval := curval*65536+f;
  30:{:453};{443:}
  Begin
    getxtoken;
    If curcmd<>10 Then backinput;
  End{:443};
  89: If aritherror Or(abs(curval)>=1073741824)Then{460:}
        Begin
          Begin
            If 
               interaction=3 Then;
            printnl(262);
            print(727);
          End;
          Begin
            helpptr := 2;
            helpline[1] := 728;
            helpline[0] := 729;
          End;
          error;
          curval := 1073741823;
          aritherror := false;
        End{:460};
  If negative Then curval := -curval;
End;
{:448}{461:}
Procedure scanglue(level:smallnumber);

Label 10;

Var negative: boolean;
  q: halfword;
  mu: boolean;
Begin
  mu := (level=3);
{441:}
  negative := false;
  Repeat{406:}
    Repeat
      getxtoken;
    Until curcmd<>10{:406};
    If curtok=3117 Then
      Begin
        negative := Not negative;
        curtok := 3115;
      End;
  Until curtok<>3115{:441};
  If (curcmd>=68)And(curcmd<=89)Then
    Begin
      scansomethinginternal(level,
                            negative);
      If curvallevel>=2 Then
        Begin
          If curvallevel<>level Then muerror;
          goto 10;
        End;
      If curvallevel=0 Then scandimen(mu,false,true)
      Else If level=3 Then
             muerror;
    End
  Else
    Begin
      backinput;
      scandimen(mu,false,false);
      If negative Then curval := -curval;
    End;{462:}
  q := newspec(0);
  mem[q+1].int := curval;
  If scankeyword(730)Then
    Begin
      scandimen(mu,true,false);
      mem[q+2].int := curval;
      mem[q].hh.b0 := curorder;
    End;
  If scankeyword(731)Then
    Begin
      scandimen(mu,true,false);
      mem[q+3].int := curval;
      mem[q].hh.b1 := curorder;
    End;
  curval := q{:462};
  10:
End;
{:461}{463:}
Function scanrulespec: halfword;

Label 21;

Var q: halfword;
Begin
  q := newrule;
  If curcmd=35 Then mem[q+1].int := 26214
  Else
    Begin
      mem[q+3].int := 26214;
      mem[q+2].int := 0;
    End;
  21: If scankeyword(732)Then
        Begin
          scandimen(false,false,false);
          mem[q+1].int := curval;
          goto 21;
        End;
  If scankeyword(733)Then
    Begin
      scandimen(false,false,false);
      mem[q+3].int := curval;
      goto 21;
    End;
  If scankeyword(734)Then
    Begin
      scandimen(false,false,false);
      mem[q+2].int := curval;
      goto 21;
    End;
  scanrulespec := q;
End;
{:463}{464:}
Function strtoks(b:poolpointer): halfword;

Var p: halfword;
  q: halfword;
  t: halfword;
  k: poolpointer;
Begin
  Begin
    If poolptr+1>poolsize Then overflow(257,poolsize-initpoolptr
      );
  End;
  p := 29997;
  mem[p].hh.rh := 0;
  k := b;
  While k<poolptr Do
    Begin
      t := strpool[k];
      If t=32 Then t := 2592
      Else t := 3072+t;
      Begin
        Begin
          q := avail;
          If q=0 Then q := getavail
          Else
            Begin
              avail := mem[q].hh.rh;
              mem[q].hh.rh := 0;
              dynused := dynused+1;
            End;
        End;
        mem[p].hh.rh := q;
        mem[q].hh.lh := t;
        p := q;
      End;
      k := k+1;
    End;
  poolptr := b;
  strtoks := p;
End;
{:464}{465:}
Function thetoks: halfword;

Var oldsetting: 0..21;
  p,q,r: halfword;
  b: poolpointer;
Begin
  getxtoken;
  scansomethinginternal(5,false);
  If curvallevel>=4 Then{466:}
    Begin
      p := 29997;
      mem[p].hh.rh := 0;
      If curvallevel=4 Then
        Begin
          q := getavail;
          mem[p].hh.rh := q;
          mem[q].hh.lh := 4095+curval;
          p := q;
        End
      Else If curval<>0 Then
             Begin
               r := mem[curval].hh.rh;
               While r<>0 Do
                 Begin
                   Begin
                     Begin
                       q := avail;
                       If q=0 Then q := getavail
                       Else
                         Begin
                           avail := mem[q].hh.rh;
                           mem[q].hh.rh := 0;
                           dynused := dynused+1;
                         End;
                     End;
                     mem[p].hh.rh := q;
                     mem[q].hh.lh := mem[r].hh.lh;
                     p := q;
                   End;
                   r := mem[r].hh.rh;
                 End;
             End;
      thetoks := p;
    End{:466}
  Else
    Begin
      oldsetting := selector;
      selector := 21;
      b := poolptr;
      Case curvallevel Of 
        0: printint(curval);
        1:
           Begin
             printscaled(curval);
             print(397);
           End;
        2:
           Begin
             printspec(curval,397);
             deleteglueref(curval);
           End;
        3:
           Begin
             printspec(curval,337);
             deleteglueref(curval);
           End;
      End;
      selector := oldsetting;
      thetoks := strtoks(b);
    End;
End;
{:465}{467:}
Procedure insthetoks;
Begin
  mem[29988].hh.rh := thetoks;
  begintokenlist(mem[29997].hh.rh,4);
End;{:467}{470:}
Procedure convtoks;

Var oldsetting: 0..21;
  c: 0..5;
  savescannerstatus: smallnumber;
  b: poolpointer;
Begin
  c := curchr;{471:}
  Case c Of 
    0,1: scanint;
    2,3:
         Begin
           savescannerstatus := scannerstatus;
           scannerstatus := 0;
           gettoken;
           scannerstatus := savescannerstatus;
         End;
    4: scanfontident;
    5: If jobname=0 Then openlogfile;
  End{:471};
  oldsetting := selector;
  selector := 21;
  b := poolptr;{472:}
  Case c Of 
    0: printint(curval);
    1: printromanint(curval);
    2: If curcs<>0 Then sprintcs(curcs)
       Else printchar(curchr);
    3: printmeaning;
    4:
       Begin
         print(fontname[curval]);
         If fontsize[curval]<>fontdsize[curval]Then
           Begin
             print(741);
             printscaled(fontsize[curval]);
             print(397);
           End;
       End;
    5: print(jobname);
  End{:472};
  selector := oldsetting;
  mem[29988].hh.rh := strtoks(b);
  begintokenlist(mem[29997].hh.rh,4);
End;
{:470}{473:}
Function scantoks(macrodef,xpand:boolean): halfword;

Label 40,22,30,31,32;

Var t: halfword;
  s: halfword;
  p: halfword;
  q: halfword;
  unbalance: halfword;
  hashbrace: halfword;
Begin
  If macrodef Then scannerstatus := 2
  Else scannerstatus := 5;
  warningindex := curcs;
  defref := getavail;
  mem[defref].hh.lh := 0;
  p := defref;
  hashbrace := 0;
  t := 3120;
  If macrodef Then{474:}
    Begin
      While true Do
        Begin
          22: gettoken;
          If curtok<768 Then goto 31;
          If curcmd=6 Then{476:}
            Begin
              s := 3328+curchr;
              gettoken;
              If curtok<512 Then
                Begin
                  hashbrace := curtok;
                  Begin
                    q := getavail;
                    mem[p].hh.rh := q;
                    mem[q].hh.lh := curtok;
                    p := q;
                  End;
                  Begin
                    q := getavail;
                    mem[p].hh.rh := q;
                    mem[q].hh.lh := 3584;
                    p := q;
                  End;
                  goto 30;
                End;
              If t=3129 Then
                Begin
                  Begin
                    If interaction=3 Then;
                    printnl(262);
                    print(744);
                  End;
                  Begin
                    helpptr := 2;
                    helpline[1] := 745;
                    helpline[0] := 746;
                  End;
                  error;
                  goto 22;
                End
              Else
                Begin
                  t := t+1;
                  If curtok<>t Then
                    Begin
                      Begin
                        If interaction=3 Then;
                        printnl(262);
                        print(747);
                      End;
                      Begin
                        helpptr := 2;
                        helpline[1] := 748;
                        helpline[0] := 749;
                      End;
                      backerror;
                    End;
                  curtok := s;
                End;
            End{:476};
          Begin
            q := getavail;
            mem[p].hh.rh := q;
            mem[q].hh.lh := curtok;
            p := q;
          End;
        End;
      31:
          Begin
            q := getavail;
            mem[p].hh.rh := q;
            mem[q].hh.lh := 3584;
            p := q;
          End;
      If curcmd=2 Then{475:}
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(657);
          End;
          alignstate := alignstate+1;
          Begin
            helpptr := 2;
            helpline[1] := 742;
            helpline[0] := 743;
          End;
          error;
          goto 40;
        End{:475};
      30:
    End{:474}
  Else scanleftbrace;{477:}
  unbalance := 1;
  While true Do
    Begin
      If xpand Then{478:}
        Begin
          While true Do
            Begin
              getnext
              ;
              If curcmd<=100 Then goto 32;
              If curcmd<>109 Then expand
              Else
                Begin
                  q := thetoks;
                  If mem[29997].hh.rh<>0 Then
                    Begin
                      mem[p].hh.rh := mem[29997].hh.rh;
                      p := q;
                    End;
                End;
            End;
          32: xtoken
        End{:478}
      Else gettoken;
      If curtok<768 Then If curcmd<2 Then unbalance := unbalance+1
      Else
        Begin
          unbalance := unbalance-1;
          If unbalance=0 Then goto 40;
        End
      Else If curcmd=6 Then If macrodef Then{479:}
                              Begin
                                s := curtok;
                                If xpand Then getxtoken
                                Else gettoken;
                                If curcmd<>6 Then If (curtok<=3120)Or(curtok>t)Then
                                                    Begin
                                                      Begin
                                                        If 
                                                           interaction=3 Then;
                                                        printnl(262);
                                                        print(750);
                                                      End;
                                                      sprintcs(warningindex);
                                                      Begin
                                                        helpptr := 3;
                                                        helpline[2] := 751;
                                                        helpline[1] := 752;
                                                        helpline[0] := 753;
                                                      End;
                                                      backerror;
                                                      curtok := s;
                                                    End
                                Else curtok := 1232+curchr;
                              End{:479};
      Begin
        q := getavail;
        mem[p].hh.rh := q;
        mem[q].hh.lh := curtok;
        p := q;
      End;
    End{:477};
  40: scannerstatus := 0;
  If hashbrace<>0 Then
    Begin
      q := getavail;
      mem[p].hh.rh := q;
      mem[q].hh.lh := hashbrace;
      p := q;
    End;
  scantoks := p;
End;
{:473}{482:}
Procedure readtoks(n:integer;r:halfword);

Label 30;

Var p: halfword;
  q: halfword;
  s: integer;
  m: smallnumber;
Begin
  scannerstatus := 2;
  warningindex := r;
  defref := getavail;
  mem[defref].hh.lh := 0;
  p := defref;
  Begin
    q := getavail;
    mem[p].hh.rh := q;
    mem[q].hh.lh := 3584;
    p := q;
  End;
  If (n<0)Or(n>15)Then m := 16
  Else m := n;
  s := alignstate;
  alignstate := 1000000;
  Repeat{483:}
    beginfilereading;
    curinput.namefield := m+1;
    If readopen[m]=2 Then{484:}If interaction>1 Then If n<0 Then
                                                       Begin;
                                                         print(338);
                                                         terminput;
                                                       End
    Else
      Begin;
        println;
        sprintcs(r);
        Begin;
          print(61);
          terminput;
        End;
        n := -1;
      End
    Else fatalerror(754){:484}
    Else If readopen[m]=1 Then{485:}If inputln
                                       (readfile[m],false)Then readopen[m] := 0
    Else
      Begin
        aclose(readfile[m]);
        readopen[m] := 2;
      End{:485}
    Else{486:}
      Begin
        If Not inputln(readfile[m],true)Then
          Begin
            aclose(readfile[m]);
            readopen[m] := 2;
            If alignstate<>1000000 Then
              Begin
                runaway;
                Begin
                  If interaction=3 Then;
                  printnl(262);
                  print(755);
                End;
                printesc(534);
                Begin
                  helpptr := 1;
                  helpline[0] := 756;
                End;
                alignstate := 1000000;
                curinput.limitfield := 0;
                error;
              End;
          End;
      End{:486};
    curinput.limitfield := last;
    If (eqtb[5311].int<0)Or(eqtb[5311].int>255)Then curinput.limitfield := 
                                                                           curinput.limitfield-1
    Else buffer[curinput.limitfield] := eqtb[5311].int;
    first := curinput.limitfield+1;
    curinput.locfield := curinput.startfield;
    curinput.statefield := 33;
    While true Do
      Begin
        gettoken;
        If curtok=0 Then goto 30;
        If alignstate<1000000 Then
          Begin
            Repeat
              gettoken;
            Until curtok=0;
            alignstate := 1000000;
            goto 30;
          End;
        Begin
          q := getavail;
          mem[p].hh.rh := q;
          mem[q].hh.lh := curtok;
          p := q;
        End;
      End;
    30: endfilereading{:483};
  Until alignstate=1000000;
  curval := defref;
  scannerstatus := 0;
  alignstate := s;
End;{:482}{494:}
Procedure passtext;

Label 30;

Var l: integer;
  savescannerstatus: smallnumber;
Begin
  savescannerstatus := scannerstatus;
  scannerstatus := 1;
  l := 0;
  skipline := line;
  While true Do
    Begin
      getnext;
      If curcmd=106 Then
        Begin
          If l=0 Then goto 30;
          If curchr=2 Then l := l-1;
        End
      Else If curcmd=105 Then l := l+1;
    End;
  30: scannerstatus := savescannerstatus;
End;
{:494}{497:}
Procedure changeiflimit(l:smallnumber;p:halfword);

Label 10;

Var q: halfword;
Begin
  If p=condptr Then iflimit := l
  Else
    Begin
      q := condptr;
      While true Do
        Begin
          If q=0 Then confusion(757);
          If mem[q].hh.rh=p Then
            Begin
              mem[q].hh.b0 := l;
              goto 10;
            End;
          q := mem[q].hh.rh;
        End;
    End;
  10:
End;{:497}{498:}
Procedure conditional;

Label 10,50;

Var b: boolean;
  r: 60..62;
  m,n: integer;
  p,q: halfword;
  savescannerstatus: smallnumber;
  savecondptr: halfword;
  thisif: smallnumber;
Begin{495:}
  Begin
    p := getnode(2);
    mem[p].hh.rh := condptr;
    mem[p].hh.b0 := iflimit;
    mem[p].hh.b1 := curif;
    mem[p+1].int := ifline;
    condptr := p;
    curif := curchr;
    iflimit := 1;
    ifline := line;
  End{:495};
  savecondptr := condptr;
  thisif := curchr;
{501:}
  Case thisif Of 
    0,1:{506:}
         Begin
           Begin
             getxtoken;
             If curcmd=0 Then If curchr=257 Then
                                Begin
                                  curcmd := 13;
                                  curchr := curtok-4096;
                                End;
           End;
           If (curcmd>13)Or(curchr>255)Then
             Begin
               m := 0;
               n := 256;
             End
           Else
             Begin
               m := curcmd;
               n := curchr;
             End;
           Begin
             getxtoken;
             If curcmd=0 Then If curchr=257 Then
                                Begin
                                  curcmd := 13;
                                  curchr := curtok-4096;
                                End;
           End;
           If (curcmd>13)Or(curchr>255)Then
             Begin
               curcmd := 0;
               curchr := 256;
             End;
           If thisif=0 Then b := (n=curchr)
           Else b := (m=curcmd);
         End{:506};
    2,3:{503:}
         Begin
           If thisif=2 Then scanint
           Else scandimen(false,false,
                          false);
           n := curval;{406:}
           Repeat
             getxtoken;
           Until curcmd<>10{:406};
           If (curtok>=3132)And(curtok<=3134)Then r := curtok-3072
           Else
             Begin
               Begin
                 If 
                    interaction=3 Then;
                 printnl(262);
                 print(781);
               End;
               printcmdchr(105,thisif);
               Begin
                 helpptr := 1;
                 helpline[0] := 782;
               End;
               backerror;
               r := 61;
             End;
           If thisif=2 Then scanint
           Else scandimen(false,false,false);
           Case r Of 
             60: b := (n<curval);
             61: b := (n=curval);
             62: b := (n>curval);
           End;
         End{:503};
    4:{504:}
       Begin
         scanint;
         b := odd(curval);
       End{:504};
    5: b := (abs(curlist.modefield)=1);
    6: b := (abs(curlist.modefield)=102);
    7: b := (abs(curlist.modefield)=203);
    8: b := (curlist.modefield<0);
    9,10,11:{505:}
             Begin
               scaneightbitint;
               p := eqtb[3678+curval].hh.rh;
               If thisif=9 Then b := (p=0)
               Else If p=0 Then b := false
               Else If thisif=10
                      Then b := (mem[p].hh.b0=0)
               Else b := (mem[p].hh.b0=1);
             End{:505};
    12:{507:}
        Begin
          savescannerstatus := scannerstatus;
          scannerstatus := 0;
          getnext;
          n := curcs;
          p := curcmd;
          q := curchr;
          getnext;
          If curcmd<>p Then b := false
          Else If curcmd<111 Then b := (curchr=q)
          Else
{508:}
            Begin
              p := mem[curchr].hh.rh;
              q := mem[eqtb[n].hh.rh].hh.rh;
              If p=q Then b := true
              Else
                Begin
                  While (p<>0)And(q<>0) Do
                    If mem[p].hh.lh<>
                       mem[q].hh.lh Then p := 0
                    Else
                      Begin
                        p := mem[p].hh.rh;
                        q := mem[q].hh.rh;
                      End;
                  b := ((p=0)And(q=0));
                End;
            End{:508};
          scannerstatus := savescannerstatus;
        End{:507};
    13:
        Begin
          scanfourbitint;
          b := (readopen[curval]=2);
        End;
    14: b := true;
    15: b := false;
    16:{509:}
        Begin
          scanint;
          n := curval;
          If eqtb[5299].int>1 Then
            Begin
              begindiagnostic;
              print(783);
              printint(n);
              printchar(125);
              enddiagnostic(false);
            End;
          While n<>0 Do
            Begin
              passtext;
              If condptr=savecondptr Then If curchr=4 Then n := n-1
              Else goto 50
              Else If 
                      curchr=2 Then{496:}
                     Begin
                       p := condptr;
                       ifline := mem[p+1].int;
                       curif := mem[p].hh.b1;
                       iflimit := mem[p].hh.b0;
                       condptr := mem[p].hh.rh;
                       freenode(p,2);
                     End{:496};
            End;
          changeiflimit(4,savecondptr);
          goto 10;
        End{:509};
  End{:501};
  If eqtb[5299].int>1 Then{502:}
    Begin
      begindiagnostic;
      If b Then print(779)
      Else print(780);
      enddiagnostic(false);
    End{:502};
  If b Then
    Begin
      changeiflimit(3,savecondptr);
      goto 10;
    End;
{500:}
  While true Do
    Begin
      passtext;
      If condptr=savecondptr Then
        Begin
          If curchr<>4 Then goto 50;
          Begin
            If interaction=3 Then;
            printnl(262);
            print(777);
          End;
          printesc(775);
          Begin
            helpptr := 1;
            helpline[0] := 778;
          End;
          error;
        End
      Else If curchr=2 Then{496:}
             Begin
               p := condptr;
               ifline := mem[p+1].int;
               curif := mem[p].hh.b1;
               iflimit := mem[p].hh.b0;
               condptr := mem[p].hh.rh;
               freenode(p,2);
             End{:496};
    End{:500};
  50: If curchr=2 Then{496:}
        Begin
          p := condptr;
          ifline := mem[p+1].int;
          curif := mem[p].hh.b1;
          iflimit := mem[p].hh.b0;
          condptr := mem[p].hh.rh;
          freenode(p,2);
        End{:496}
      Else iflimit := 2;
  10:
End;
{:498}{515:}
Procedure beginname;
Begin
  areadelimiter := 0;
  extdelimiter := 0;
End;{:515}{516:}
Function morename(c:ASCIIcode): boolean;
Begin
  If c=32 Then morename := false
  Else
    Begin
      Begin
        If poolptr+1>
           poolsize Then overflow(257,poolsize-initpoolptr);
      End;
      Begin
        strpool[poolptr] := c;
        poolptr := poolptr+1;
      End;
      If c=47 Then
        Begin
          areadelimiter := (poolptr-strstart[strptr]);
          extdelimiter := 0;
        End
      Else If (c=46)And(extdelimiter=0)Then extdelimiter := (poolptr-strstart
                                                            [strptr]);
      morename := true;
    End;
End;{:516}{517:}
Procedure endname;
Begin
  If strptr+3>maxstrings Then overflow(258,maxstrings-initstrptr);
  If areadelimiter=0 Then curarea := 338
  Else
    Begin
      curarea := strptr;
      strstart[strptr+1] := strstart[strptr]+areadelimiter;
      strptr := strptr+1;
    End;
  If extdelimiter=0 Then
    Begin
      curext := 338;
      curname := makestring;
    End
  Else
    Begin
      curname := strptr;
      strstart[strptr+1] := strstart[strptr]+extdelimiter-areadelimiter-1;
      strptr := strptr+1;
      curext := makestring;
    End;
End;
{:517}{519:}
Procedure packfilename(n,a,e:strnumber);

Var k: integer;
  c: ASCIIcode;
  j: poolpointer;
Begin
  k := 0;
  For j:=strstart[a]To strstart[a+1]-1 Do
    Begin
      c := strpool[j];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  For j:=strstart[n]To strstart[n+1]-1 Do
    Begin
      c := strpool[j];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  For j:=strstart[e]To strstart[e+1]-1 Do
    Begin
      c := strpool[j];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  If k<=filenamesize Then namelength := k
  Else namelength := filenamesize;
  For k:=namelength+1 To filenamesize Do
    nameoffile[k] := chr(0);
End;
{:519}{523:}
Procedure packbufferedname(n:smallnumber;a,b:integer);

Var k: integer;
  c: ASCIIcode;
  j: integer;
Begin
  If n+b-a+5>filenamesize Then b := a+filenamesize-n-5;
  k := 0;
  For j:=1 To n Do
    Begin
      c := xord[TEXformatdefault[j]];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  For j:=a To b Do
    Begin
      c := buffer[j];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  For j:=17 To 20 Do
    Begin
      c := xord[TEXformatdefault[j]];
      k := k+1;
      If k<=filenamesize Then nameoffile[k] := xchr[c];
    End;
  If k<=filenamesize Then namelength := k
  Else namelength := filenamesize;
  For k:=namelength+1 To filenamesize Do
    nameoffile[k] := chr(0);
End;
{:523}{525:}
Function makenamestring: strnumber;

Var k: 1..filenamesize;
Begin
  If (poolptr+namelength>poolsize)Or(strptr=maxstrings)Or((poolptr-
     strstart[strptr])>0)Then makenamestring := 63
  Else
    Begin
      For k:=1 To
          namelength Do
        Begin
          strpool[poolptr] := xord[nameoffile[k]];
          poolptr := poolptr+1;
        End;
      makenamestring := makestring;
    End;
End;
Function amakenamestring(Var f:alphafile): strnumber;
Begin
  amakenamestring := makenamestring;
End;
Function bmakenamestring(Var f:bytefile): strnumber;
Begin
  bmakenamestring := makenamestring;
End;
Function wmakenamestring(Var f:wordfile): strnumber;
Begin
  wmakenamestring := makenamestring;
End;
{:525}{526:}
Procedure scanfilename;

Label 30;
Begin
  nameinprogress := true;
  beginname;{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  While true Do
    Begin
      If (curcmd>12)Or(curchr>255)Then
        Begin
          backinput;
          goto 30;
        End;
      If Not morename(curchr)Then goto 30;
      getxtoken;
    End;
  30: endname;
  nameinprogress := false;
End;
{:526}{529:}
Procedure packjobname(s:strnumber);
Begin
  curarea := 338;
  curext := s;
  curname := jobname;
  packfilename(curname,curarea,curext);
End;
{:529}{530:}
Procedure promptfilename(s,e:strnumber);

Label 30;

Var k: 0..bufsize;
Begin
  If interaction=2 Then;
  If s=787 Then
    Begin
      If interaction=3 Then;
      printnl(262);
      print(788);
    End
  Else
    Begin
      If interaction=3 Then;
      printnl(262);
      print(789);
    End;
  printfilename(curname,curarea,curext);
  print(790);
  If e=791 Then showcontext;
  printnl(792);
  print(s);
  print(793);
  If interaction<2 Then fatalerror(794);;
  Begin;
    print(568);
    terminput;
  End;
{531:}
  Begin
    beginname;
    k := first;
    While (buffer[k]=32)And(k<last) Do
      k := k+1;
    While true Do
      Begin
        If k=last Then goto 30;
        If Not morename(buffer[k])Then goto 30;
        k := k+1;
      End;
    30: endname;
  End{:531};
  If curext=338 Then curext := e;
  packfilename(curname,curarea,curext);
End;
{:530}{534:}
Procedure openlogfile;

Var oldsetting: 0..21;
  k: 0..bufsize;
  l: 0..bufsize;
  months: packed array[1..36] Of char;
Begin
  oldsetting := selector;
  If jobname=0 Then jobname := 797;
  packjobname(798);
  While Not aopenout(logfile) Do{535:}
    Begin
      selector := 17;
      promptfilename(800,798);
    End{:535};
  logname := amakenamestring(logfile);
  selector := 18;
  logopened := true;
{536:}
  Begin
    write(logfile,'This is TeX-FPC, 4th ed.');
    slowprint(formatident);
    print(801);
    printint(sysday);
    printchar(32);
    months := 'JANFEBMARAPRMAYJUNJULAUGSEPOCTNOVDEC';
    For k:=3*sysmonth-2 To 3*sysmonth Do
      write(logfile,months[k]);
    printchar(32);
    printint(sysyear);
    printchar(32);
    printtwo(systime Div 60);
    printchar(58);
    printtwo(systime Mod 60);
  End{:536};
  inputstack[inputptr] := curinput;
  printnl(799);
  l := inputstack[0].limitfield;
  If buffer[l]=eqtb[5311].int Then l := l-1;
  For k:=1 To l Do
    print(buffer[k]);
  println;
  selector := oldsetting+2;
End;
{:534}{537:}
Procedure startinput;

Label 30;
Begin
  scanfilename;
  If curext=338 Then curext := 791;
  packfilename(curname,curarea,curext);
  While true Do
    Begin
      beginfilereading;
      If aopenin(inputfile[curinput.indexfield])Then goto 30;
      If curarea=338 Then
        Begin
          packfilename(curname,784,curext);
          If aopenin(inputfile[curinput.indexfield])Then goto 30;
        End;
      endfilereading;
      promptfilename(787,791);
    End;
  30: curinput.namefield := amakenamestring(inputfile[curinput.indexfield]);
  If jobname=0 Then
    Begin
      jobname := curname;
      openlogfile;
    End;
  If termoffset+(strstart[curinput.namefield+1]-strstart[curinput.
     namefield])>maxprintline-2 Then println
  Else If (termoffset>0)Or(
          fileoffset>0)Then printchar(32);
  printchar(40);
  openparens := openparens+1;
  slowprint(curinput.namefield);
  flush(output);
  curinput.statefield := 33;
{538:}
  Begin
    line := 1;
    If inputln(inputfile[curinput.indexfield],false)Then;
    firmuptheline;
    If (eqtb[5311].int<0)Or(eqtb[5311].int>255)Then curinput.limitfield := 
                                                                           curinput.limitfield-1
    Else buffer[curinput.limitfield] := eqtb[5311].int;
    first := curinput.limitfield+1;
    curinput.locfield := curinput.startfield;
  End{:538};
End;{:537}{560:}
Function readfontinfo(u:halfword;
                      nom,aire:strnumber;s:scaled): internalfontnumber;

Label 30,11,45;

Var k: fontindex;
  fileopened: boolean;
  lf,lh,bc,ec,nw,nh,nd,ni,nl,nk,ne,np: halfword;
  f: internalfontnumber;
  g: internalfontnumber;
  a,b,c,d: eightbits;
  qw: fourquarters;
  sw: scaled;
  bchlabel: integer;
  bchar: 0..256;
  z: scaled;
  alpha: integer;
  beta: 1..16;
Begin
  g := 0;{562:}{563:}
  fileopened := false;
  If aire=338 Then packfilename(nom,785,812)
  Else packfilename(nom,aire,812
    );
  If Not bopenin(tfmfile)Then goto 11;
  fileopened := true{:563};
{565:}
  Begin
    Begin
      lf := tfmfile^;
      If lf>127 Then goto 11;
      get(tfmfile);
      lf := lf*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      lh := tfmfile^;
      If lh>127 Then goto 11;
      get(tfmfile);
      lh := lh*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      bc := tfmfile^;
      If bc>127 Then goto 11;
      get(tfmfile);
      bc := bc*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      ec := tfmfile^;
      If ec>127 Then goto 11;
      get(tfmfile);
      ec := ec*256+tfmfile^;
    End;
    If (bc>ec+1)Or(ec>255)Then goto 11;
    If bc>255 Then
      Begin
        bc := 1;
        ec := 0;
      End;
    get(tfmfile);
    Begin
      nw := tfmfile^;
      If nw>127 Then goto 11;
      get(tfmfile);
      nw := nw*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      nh := tfmfile^;
      If nh>127 Then goto 11;
      get(tfmfile);
      nh := nh*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      nd := tfmfile^;
      If nd>127 Then goto 11;
      get(tfmfile);
      nd := nd*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      ni := tfmfile^;
      If ni>127 Then goto 11;
      get(tfmfile);
      ni := ni*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      nl := tfmfile^;
      If nl>127 Then goto 11;
      get(tfmfile);
      nl := nl*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      nk := tfmfile^;
      If nk>127 Then goto 11;
      get(tfmfile);
      nk := nk*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      ne := tfmfile^;
      If ne>127 Then goto 11;
      get(tfmfile);
      ne := ne*256+tfmfile^;
    End;
    get(tfmfile);
    Begin
      np := tfmfile^;
      If np>127 Then goto 11;
      get(tfmfile);
      np := np*256+tfmfile^;
    End;
    If lf<>6+lh+(ec-bc+1)+nw+nh+nd+ni+nl+nk+ne+np Then goto 11;
    If (nw=0)Or(nh=0)Or(nd=0)Or(ni=0)Then goto 11;
  End{:565};
{566:}
  lf := lf-6-lh;
  If np<7 Then lf := lf+7-np;
  If (fontptr=fontmax)Or(fmemptr+lf>fontmemsize)Then{567:}
    Begin
      Begin
        If 
           interaction=3 Then;
        printnl(262);
        print(803);
      End;
      sprintcs(u);
      printchar(61);
      printfilename(nom,aire,338);
      If s>=0 Then
        Begin
          print(741);
          printscaled(s);
          print(397);
        End
      Else If s<>-1000 Then
             Begin
               print(804);
               printint(-s);
             End;
      print(813);
      Begin
        helpptr := 4;
        helpline[3] := 814;
        helpline[2] := 815;
        helpline[1] := 816;
        helpline[0] := 817;
      End;
      error;
      goto 30;
    End{:567};
  f := fontptr+1;
  charbase[f] := fmemptr-bc;
  widthbase[f] := charbase[f]+ec+1;
  heightbase[f] := widthbase[f]+nw;
  depthbase[f] := heightbase[f]+nh;
  italicbase[f] := depthbase[f]+nd;
  ligkernbase[f] := italicbase[f]+ni;
  kernbase[f] := ligkernbase[f]+nl-256*(128);
  extenbase[f] := kernbase[f]+256*(128)+nk;
  parambase[f] := extenbase[f]+ne{:566};{568:}
  Begin
    If lh<2 Then goto 11;
    Begin
      get(tfmfile);
      a := tfmfile^;
      qw.b0 := a;
      get(tfmfile);
      b := tfmfile^;
      qw.b1 := b;
      get(tfmfile);
      c := tfmfile^;
      qw.b2 := c;
      get(tfmfile);
      d := tfmfile^;
      qw.b3 := d;
      fontcheck[f] := qw;
    End;
    get(tfmfile);
    Begin
      z := tfmfile^;
      If z>127 Then goto 11;
      get(tfmfile);
      z := z*256+tfmfile^;
    End;
    get(tfmfile);
    z := z*256+tfmfile^;
    get(tfmfile);
    z := (z*16)+(tfmfile^Div 16);
    If z<65536 Then goto 11;
    While lh>2 Do
      Begin
        get(tfmfile);
        get(tfmfile);
        get(tfmfile);
        get(tfmfile);
        lh := lh-1;
      End;
    fontdsize[f] := z;
    If s<>-1000 Then If s>=0 Then z := s
    Else z := xnoverd(z,-s,1000);
    fontsize[f] := z;
  End{:568};
{569:}
  For k:=fmemptr To widthbase[f]-1 Do
    Begin
      Begin
        get(tfmfile);
        a := tfmfile^;
        qw.b0 := a;
        get(tfmfile);
        b := tfmfile^;
        qw.b1 := b;
        get(tfmfile);
        c := tfmfile^;
        qw.b2 := c;
        get(tfmfile);
        d := tfmfile^;
        qw.b3 := d;
        fontinfo[k].qqqq := qw;
      End;
      If (a>=nw)Or(b Div 16>=nh)Or(b Mod 16>=nd)Or(c Div 4>=ni)Then goto 11;
      Case c Mod 4 Of 
        1: If d>=nl Then goto 11;
        3: If d>=ne Then goto 11;
        2:{570:}
           Begin
             Begin
               If (d<bc)Or(d>ec)Then goto 11
             End;
             While d<k+bc-fmemptr Do
               Begin
                 qw := fontinfo[charbase[f]+d].qqqq;
                 If ((qw.b2)Mod 4)<>2 Then goto 45;
                 d := qw.b3;
               End;
             If d=k+bc-fmemptr Then goto 11;
             45:
           End{:570};
        Else
      End;
    End{:569};
{571:}
  Begin{572:}
    Begin
      alpha := 16;
      While z>=8388608 Do
        Begin
          z := z Div 2;
          alpha := alpha+alpha;
        End;
      beta := 256 Div alpha;
      alpha := alpha*z;
    End{:572};
    For k:=widthbase[f]To ligkernbase[f]-1 Do
      Begin
        get(tfmfile);
        a := tfmfile^;
        get(tfmfile);
        b := tfmfile^;
        get(tfmfile);
        c := tfmfile^;
        get(tfmfile);
        d := tfmfile^;
        sw := (((((d*z)Div 256)+(c*z))Div 256)+(b*z))Div beta;
        If a=0 Then fontinfo[k].int := sw
        Else If a=255 Then fontinfo[k].int := sw-
                                              alpha
        Else goto 11;
      End;
    If fontinfo[widthbase[f]].int<>0 Then goto 11;
    If fontinfo[heightbase[f]].int<>0 Then goto 11;
    If fontinfo[depthbase[f]].int<>0 Then goto 11;
    If fontinfo[italicbase[f]].int<>0 Then goto 11;
  End{:571};
{573:}
  bchlabel := 32767;
  bchar := 256;
  If nl>0 Then
    Begin
      For k:=ligkernbase[f]To kernbase[f]+256*(128)-1 Do
        Begin
          Begin
            get(tfmfile);
            a := tfmfile^;
            qw.b0 := a;
            get(tfmfile);
            b := tfmfile^;
            qw.b1 := b;
            get(tfmfile);
            c := tfmfile^;
            qw.b2 := c;
            get(tfmfile);
            d := tfmfile^;
            qw.b3 := d;
            fontinfo[k].qqqq := qw;
          End;
          If a>128 Then
            Begin
              If 256*c+d>=nl Then goto 11;
              If a=255 Then If k=ligkernbase[f]Then bchar := b;
            End
          Else
            Begin
              If b<>bchar Then
                Begin
                  Begin
                    If (b<bc)Or(b>ec)Then goto 11
                  End;
                  qw := fontinfo[charbase[f]+b].qqqq;
                  If Not(qw.b0>0)Then goto 11;
                End;
              If c<128 Then
                Begin
                  Begin
                    If (d<bc)Or(d>ec)Then goto 11
                  End;
                  qw := fontinfo[charbase[f]+d].qqqq;
                  If Not(qw.b0>0)Then goto 11;
                End
              Else If 256*(c-128)+d>=nk Then goto 11;
              If a<128 Then If k-ligkernbase[f]+a+1>=nl Then goto 11;
            End;
        End;
      If a=255 Then bchlabel := 256*c+d;
    End;
  For k:=kernbase[f]+256*(128)To extenbase[f]-1 Do
    Begin
      get(tfmfile);
      a := tfmfile^;
      get(tfmfile);
      b := tfmfile^;
      get(tfmfile);
      c := tfmfile^;
      get(tfmfile);
      d := tfmfile^;
      sw := (((((d*z)Div 256)+(c*z))Div 256)+(b*z))Div beta;
      If a=0 Then fontinfo[k].int := sw
      Else If a=255 Then fontinfo[k].int := sw-
                                            alpha
      Else goto 11;
    End;{:573};
{574:}
  For k:=extenbase[f]To parambase[f]-1 Do
    Begin
      Begin
        get(tfmfile);
        a := tfmfile^;
        qw.b0 := a;
        get(tfmfile);
        b := tfmfile^;
        qw.b1 := b;
        get(tfmfile);
        c := tfmfile^;
        qw.b2 := c;
        get(tfmfile);
        d := tfmfile^;
        qw.b3 := d;
        fontinfo[k].qqqq := qw;
      End;
      If a<>0 Then
        Begin
          Begin
            If (a<bc)Or(a>ec)Then goto 11
          End;
          qw := fontinfo[charbase[f]+a].qqqq;
          If Not(qw.b0>0)Then goto 11;
        End;
      If b<>0 Then
        Begin
          Begin
            If (b<bc)Or(b>ec)Then goto 11
          End;
          qw := fontinfo[charbase[f]+b].qqqq;
          If Not(qw.b0>0)Then goto 11;
        End;
      If c<>0 Then
        Begin
          Begin
            If (c<bc)Or(c>ec)Then goto 11
          End;
          qw := fontinfo[charbase[f]+c].qqqq;
          If Not(qw.b0>0)Then goto 11;
        End;
      Begin
        Begin
          If (d<bc)Or(d>ec)Then goto 11
        End;
        qw := fontinfo[charbase[f]+d].qqqq;
        If Not(qw.b0>0)Then goto 11;
      End;
    End{:574};{575:}
  Begin
    For k:=1 To np Do
      If k=1 Then
        Begin
          get(tfmfile);
          sw := tfmfile^;
          If sw>127 Then sw := sw-256;
          get(tfmfile);
          sw := sw*256+tfmfile^;
          get(tfmfile);
          sw := sw*256+tfmfile^;
          get(tfmfile);
          fontinfo[parambase[f]].int := (sw*16)+(tfmfile^Div 16);
        End
      Else
        Begin
          get(tfmfile);
          a := tfmfile^;
          get(tfmfile);
          b := tfmfile^;
          get(tfmfile);
          c := tfmfile^;
          get(tfmfile);
          d := tfmfile^;
          sw := (((((d*z)Div 256)+(c*z))Div 256)+(b*z))Div beta;
          If a=0 Then fontinfo[parambase[f]+k-1].int := sw
          Else If a=255 Then
                 fontinfo[parambase[f]+k-1].int := sw-alpha
          Else goto 11;
        End;
    For k:=np+1 To 7 Do
      fontinfo[parambase[f]+k-1].int := 0;
  End{:575};
{576:}
  If np>=7 Then fontparams[f] := np
  Else fontparams[f] := 7;
  hyphenchar[f] := eqtb[5309].int;
  skewchar[f] := eqtb[5310].int;
  If bchlabel<nl Then bcharlabel[f] := bchlabel+ligkernbase[f]
  Else
    bcharlabel[f] := 0;
  fontbchar[f] := bchar;
  fontfalsebchar[f] := bchar;
  If bchar<=ec Then If bchar>=bc Then
                      Begin
                        qw := fontinfo[charbase[f]+bchar
                              ].qqqq;
                        If (qw.b0>0)Then fontfalsebchar[f] := 256;
                      End;
  fontname[f] := nom;
  fontarea[f] := aire;
  fontbc[f] := bc;
  fontec[f] := ec;
  fontglue[f] := 0;
  charbase[f] := charbase[f];
  widthbase[f] := widthbase[f];
  ligkernbase[f] := ligkernbase[f];
  kernbase[f] := kernbase[f];
  extenbase[f] := extenbase[f];
  parambase[f] := parambase[f]-1;
  fmemptr := fmemptr+lf;
  fontptr := f;
  g := f;
  goto 30{:576}{:562};
  11:{561:}
      Begin
        If interaction=3 Then;
        printnl(262);
        print(803);
      End;
  sprintcs(u);
  printchar(61);
  printfilename(nom,aire,338);
  If s>=0 Then
    Begin
      print(741);
      printscaled(s);
      print(397);
    End
  Else If s<>-1000 Then
         Begin
           print(804);
           printint(-s);
         End;
  If fileopened Then print(805)
  Else print(806);
  Begin
    helpptr := 5;
    helpline[4] := 807;
    helpline[3] := 808;
    helpline[2] := 809;
    helpline[1] := 810;
    helpline[0] := 811;
  End;
  error{:561};
  30: If fileopened Then bclose(tfmfile);
  readfontinfo := g;
End;
{:560}{581:}
Procedure charwarning(f:internalfontnumber;c:eightbits);
Begin
  If eqtb[5298].int>0 Then
    Begin
      begindiagnostic;
      printnl(826);
      print(c);
      print(827);
      slowprint(fontname[f]);
      printchar(33);
      enddiagnostic(false);
    End;
End;
{:581}{582:}
Function newcharacter(f:internalfontnumber;
                      c:eightbits): halfword;

Label 10;

Var p: halfword;
Begin
  If fontbc[f]<=c Then If fontec[f]>=c Then If (fontinfo[charbase[f]+
                                               c].qqqq.b0>0)Then
                                              Begin
                                                p := getavail;
                                                mem[p].hh.b0 := f;
                                                mem[p].hh.b1 := c;
                                                newcharacter := p;
                                                goto 10;
                                              End;
  charwarning(f,c);
  newcharacter := 0;
  10:
End;
{:582}{597:}
Procedure writedvi(a,b:dviindex);
Begin
  blockwrite(dvifile,dvibuf[a],b-a+1);
End;
{:597}{598:}
Procedure dviswap;
Begin
  If dvilimit=dvibufsize Then
    Begin
      writedvi(0,halfbuf-1);
      dvilimit := halfbuf;
      dvioffset := dvioffset+dvibufsize;
      dviptr := 0;
    End
  Else
    Begin
      writedvi(halfbuf,dvibufsize-1);
      dvilimit := dvibufsize;
    End;
  dvigone := dvigone+halfbuf;
End;{:598}{600:}
Procedure dvifour(x:integer);
Begin
  If x>=0 Then
    Begin
      dvibuf[dviptr] := x Div 16777216;
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End
  Else
    Begin
      x := x+1073741824;
      x := x+1073741824;
      Begin
        dvibuf[dviptr] := (x Div 16777216)+128;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
    End;
  x := x Mod 16777216;
  Begin
    dvibuf[dviptr] := x Div 65536;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  x := x Mod 65536;
  Begin
    dvibuf[dviptr] := x Div 256;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := x Mod 256;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
End;
{:600}{601:}
Procedure dvipop(l:integer);
Begin
  If (l=dvioffset+dviptr)And(dviptr>0)Then dviptr := dviptr-1
  Else
    Begin
      dvibuf[dviptr] := 142;
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End;
End;
{:601}{602:}
Procedure dvifontdef(f:internalfontnumber);

Var k: poolpointer;
Begin
  Begin
    dvibuf[dviptr] := 243;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := f-1;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := fontcheck[f].b0;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := fontcheck[f].b1;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := fontcheck[f].b2;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := fontcheck[f].b3;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  dvifour(fontsize[f]);
  dvifour(fontdsize[f]);
  Begin
    dvibuf[dviptr] := (strstart[fontarea[f]+1]-strstart[fontarea[f]]);
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  Begin
    dvibuf[dviptr] := (strstart[fontname[f]+1]-strstart[fontname[f]]);
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
{603:}
  For k:=strstart[fontarea[f]]To strstart[fontarea[f]+1]-1 Do
    Begin
      dvibuf[dviptr] := strpool[k];
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End;
  For k:=strstart[fontname[f]]To strstart[fontname[f]+1]-1 Do
    Begin
      dvibuf
      [dviptr] := strpool[k];
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End{:603};
End;{:602}{607:}
Procedure movement(w:scaled;o:eightbits);

Label 10,40,45,2,1;

Var mstate: smallnumber;
  p,q: halfword;
  k: integer;
Begin
  q := getnode(3);
  mem[q+1].int := w;
  mem[q+2].int := dvioffset+dviptr;
  If o=157 Then
    Begin
      mem[q].hh.rh := downptr;
      downptr := q;
    End
  Else
    Begin
      mem[q].hh.rh := rightptr;
      rightptr := q;
    End;
{611:}
  p := mem[q].hh.rh;
  mstate := 0;
  While p<>0 Do
    Begin
      If mem[p+1].int=w Then{612:}Case mstate+mem[p].hh.lh 
                                    Of 
                                    3,4,15,16: If mem[p+2].int<dvigone Then goto 45
                                               Else{613:}
                                                 Begin
                                                   k := mem
                                                        [p+2].int-dvioffset;
                                                   If k<0 Then k := k+dvibufsize;
                                                   dvibuf[k] := dvibuf[k]+5;
                                                   mem[p].hh.lh := 1;
                                                   goto 40;
                                                 End{:613};
                                    5,9,11: If mem[p+2].int<dvigone Then goto 45
                                            Else{614:}
                                              Begin
                                                k := mem[p+2].
                                                     int-dvioffset;
                                                If k<0 Then k := k+dvibufsize;
                                                dvibuf[k] := dvibuf[k]+10;
                                                mem[p].hh.lh := 2;
                                                goto 40;
                                              End{:614};
                                    1,2,8,13: goto 40;
                                    Else
        End{:612}
      Else Case mstate+mem[p].hh.lh Of 
             1: mstate := 6;
             2: mstate := 12;
             8,13: goto 45;
             Else
        End;
      p := mem[p].hh.rh;
    End;
  45:{:611};
{610:}
  mem[q].hh.lh := 3;
  If abs(w)>=8388608 Then
    Begin
      Begin
        dvibuf[dviptr] := o+3;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      dvifour(w);
      goto 10;
    End;
  If abs(w)>=32768 Then
    Begin
      Begin
        dvibuf[dviptr] := o+2;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      If w<0 Then w := w+16777216;
      Begin
        dvibuf[dviptr] := w Div 65536;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      w := w Mod 65536;
      goto 2;
    End;
  If abs(w)>=128 Then
    Begin
      Begin
        dvibuf[dviptr] := o+1;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      If w<0 Then w := w+65536;
      goto 2;
    End;
  Begin
    dvibuf[dviptr] := o;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  If w<0 Then w := w+256;
  goto 1;
  2:
     Begin
       dvibuf[dviptr] := w Div 256;
       dviptr := dviptr+1;
       If dviptr=dvilimit Then dviswap;
     End;
  1:
     Begin
       dvibuf[dviptr] := w Mod 256;
       dviptr := dviptr+1;
       If dviptr=dvilimit Then dviswap;
     End;
  goto 10{:610};
  40:{609:}mem[q].hh.lh := mem[p].hh.lh;
  If mem[q].hh.lh=1 Then
    Begin
      Begin
        dvibuf[dviptr] := o+4;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      While mem[q].hh.rh<>p Do
        Begin
          q := mem[q].hh.rh;
          Case mem[q].hh.lh Of 
            3: mem[q].hh.lh := 5;
            4: mem[q].hh.lh := 6;
            Else
          End;
        End;
    End
  Else
    Begin
      Begin
        dvibuf[dviptr] := o+9;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      While mem[q].hh.rh<>p Do
        Begin
          q := mem[q].hh.rh;
          Case mem[q].hh.lh Of 
            3: mem[q].hh.lh := 4;
            5: mem[q].hh.lh := 6;
            Else
          End;
        End;
    End{:609};
  10:
End;{:607}{615:}
Procedure prunemovements(l:integer);

Label 30,10;

Var p: halfword;
Begin
  While downptr<>0 Do
    Begin
      If mem[downptr+2].int<l Then goto 30;
      p := downptr;
      downptr := mem[p].hh.rh;
      freenode(p,3);
    End;
  30: While rightptr<>0 Do
        Begin
          If mem[rightptr+2].int<l Then goto 10;
          p := rightptr;
          rightptr := mem[p].hh.rh;
          freenode(p,3);
        End;
  10:
End;
{:615}{618:}
Procedure vlistout;
forward;
{:618}{619:}{1368:}
Procedure specialout(p:halfword);

Var oldsetting: 0..21;
  k: poolpointer;
Begin
  If curh<>dvih Then
    Begin
      movement(curh-dvih,143);
      dvih := curh;
    End;
  If curv<>dviv Then
    Begin
      movement(curv-dviv,157);
      dviv := curv;
    End;
  oldsetting := selector;
  selector := 21;
  showtokenlist(mem[mem[p+1].hh.rh].hh.rh,0,poolsize-poolptr);
  selector := oldsetting;
  Begin
    If poolptr+1>poolsize Then overflow(257,poolsize-initpoolptr);
  End;
  If (poolptr-strstart[strptr])<256 Then
    Begin
      Begin
        dvibuf[dviptr] := 239;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      Begin
        dvibuf[dviptr] := (poolptr-strstart[strptr]);
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
    End
  Else
    Begin
      Begin
        dvibuf[dviptr] := 242;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      dvifour((poolptr-strstart[strptr]));
    End;
  For k:=strstart[strptr]To poolptr-1 Do
    Begin
      dvibuf[dviptr] := strpool[k];
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End;
  poolptr := strstart[strptr];
End;
{:1368}{1370:}
Procedure writeout(p:halfword);

Var oldsetting: 0..21;
  oldmode: integer;
  j: smallnumber;
  q,r: halfword;
Begin{1371:}
  q := getavail;
  mem[q].hh.lh := 637;
  r := getavail;
  mem[q].hh.rh := r;
  mem[r].hh.lh := 6717;
  begintokenlist(q,4);
  begintokenlist(mem[p+1].hh.rh,15);
  q := getavail;
  mem[q].hh.lh := 379;
  begintokenlist(q,4);
  oldmode := curlist.modefield;
  curlist.modefield := 0;
  curcs := writeloc;
  q := scantoks(false,true);
  gettoken;
  If curtok<>6717 Then{1372:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1298);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 1299;
        helpline[0] := 1013;
      End;
      error;
      Repeat
        gettoken;
      Until curtok=6717;
    End{:1372};
  curlist.modefield := oldmode;
  endtokenlist{:1371};
  oldsetting := selector;
  j := mem[p+1].hh.lh;
  If writeopen[j]Then selector := j
  Else
    Begin
      If (j=17)And(selector=19)Then
        selector := 18;
      printnl(338);
    End;
  tokenshow(defref);
  println;
  flushlist(defref);
  selector := oldsetting;
End;
{:1370}{1373:}
Procedure outwhat(p:halfword);

Var j: smallnumber;
Begin
  Case mem[p].hh.b1 Of 
    0,1,2:{1374:}If Not doingleaders Then
                   Begin
                     j 
                     := mem[p+1].hh.lh;
                     If mem[p].hh.b1=1 Then writeout(p)
                     Else
                       Begin
                         If writeopen[j]Then aclose(
                                                    writefile[j]);
                         If mem[p].hh.b1=2 Then writeopen[j] := false
                         Else If j<16 Then
                                Begin
                                  curname := mem[p+1].hh.rh;
                                  curarea := mem[p+2].hh.lh;
                                  curext := mem[p+2].hh.rh;
                                  If curext=338 Then curext := 791;
                                  packfilename(curname,curarea,curext);
                                  While Not aopenout(writefile[j]) Do
                                    promptfilename(1301,791);
                                  writeopen[j] := true;
                                End;
                       End;
                   End{:1374};
    3: specialout(p);
    4:;
    Else confusion(1300)
  End;
End;{:1373}
Procedure hlistout;

Label 21,13,14,15;

Var baseline: scaled;
  leftedge: scaled;
  saveh,savev: scaled;
  thisbox: halfword;
  gorder: glueord;
  gsign: 0..2;
  p: halfword;
  saveloc: integer;
  leaderbox: halfword;
  leaderwd: scaled;
  lx: scaled;
  outerdoingleaders: boolean;
  edge: scaled;
  gluetemp: real;
  curglue: real;
  curg: scaled;
Begin
  curg := 0;
  curglue := 0.0;
  thisbox := tempptr;
  gorder := mem[thisbox+5].hh.b1;
  gsign := mem[thisbox+5].hh.b0;
  p := mem[thisbox+5].hh.rh;
  curs := curs+1;
  If curs>0 Then
    Begin
      dvibuf[dviptr] := 141;
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End;
  If curs>maxpush Then maxpush := curs;
  saveloc := dvioffset+dviptr;
  baseline := curv;
  leftedge := curh;
  While p<>0 Do{620:}
    21: If (p>=himemmin)Then
          Begin
            If curh<>dvih Then
              Begin
                movement(curh-dvih,143);
                dvih := curh;
              End;
            If curv<>dviv Then
              Begin
                movement(curv-dviv,157);
                dviv := curv;
              End;
            Repeat
              f := mem[p].hh.b0;
              c := mem[p].hh.b1;
              If f<>dvif Then{621:}
                Begin
                  If Not fontused[f]Then
                    Begin
                      dvifontdef(f);
                      fontused[f] := true;
                    End;
                  If f<=64 Then
                    Begin
                      dvibuf[dviptr] := f+170;
                      dviptr := dviptr+1;
                      If dviptr=dvilimit Then dviswap;
                    End
                  Else
                    Begin
                      Begin
                        dvibuf[dviptr] := 235;
                        dviptr := dviptr+1;
                        If dviptr=dvilimit Then dviswap;
                      End;
                      Begin
                        dvibuf[dviptr] := f-1;
                        dviptr := dviptr+1;
                        If dviptr=dvilimit Then dviswap;
                      End;
                    End;
                  dvif := f;
                End{:621};
              If c>=128 Then
                Begin
                  dvibuf[dviptr] := 128;
                  dviptr := dviptr+1;
                  If dviptr=dvilimit Then dviswap;
                End;
              Begin
                dvibuf[dviptr] := c;
                dviptr := dviptr+1;
                If dviptr=dvilimit Then dviswap;
              End;
              curh := curh+fontinfo[widthbase[f]+fontinfo[charbase[f]+c].qqqq.b0].int;
              p := mem[p].hh.rh;
            Until Not(p>=himemmin);
            dvih := curh;
          End
        Else{622:}
          Begin
            Case mem[p].hh.b0 Of 
              0,1:{623:}If mem[p+5].hh.rh=0
                          Then curh := curh+mem[p+1].int
                   Else
                     Begin
                       saveh := dvih;
                       savev := dviv;
                       curv := baseline+mem[p+4].int;
                       tempptr := p;
                       edge := curh;
                       If mem[p].hh.b0=1 Then vlistout
                       Else hlistout;
                       dvih := saveh;
                       dviv := savev;
                       curh := edge+mem[p+1].int;
                       curv := baseline;
                     End{:623};
              2:
                 Begin
                   ruleht := mem[p+3].int;
                   ruledp := mem[p+2].int;
                   rulewd := mem[p+1].int;
                   goto 14;
                 End;
              8:{1367:}outwhat(p){:1367};
              10:{625:}
                  Begin
                    g := mem[p+1].hh.lh;
                    rulewd := mem[g+1].int-curg;
                    If gsign<>0 Then
                      Begin
                        If gsign=1 Then
                          Begin
                            If mem[g].hh.b0=gorder Then
                              Begin
                                curglue := curglue+mem[g+2].int;
                                gluetemp := mem[thisbox+6].gr*curglue;
                                If gluetemp>1000000000.0 Then gluetemp := 1000000000.0
                                Else If gluetemp<
                                        -1000000000.0 Then gluetemp := -1000000000.0;
                                curg := round(gluetemp);
                              End;
                          End
                        Else If mem[g].hh.b1=gorder Then
                               Begin
                                 curglue := curglue-mem[g+3].int
                                 ;
                                 gluetemp := mem[thisbox+6].gr*curglue;
                                 If gluetemp>1000000000.0 Then gluetemp := 1000000000.0
                                 Else If gluetemp<
                                         -1000000000.0 Then gluetemp := -1000000000.0;
                                 curg := round(gluetemp);
                               End;
                      End;
                    rulewd := rulewd+curg;
                    If mem[p].hh.b1>=100 Then{626:}
                      Begin
                        leaderbox := mem[p+1].hh.rh;
                        If mem[leaderbox].hh.b0=2 Then
                          Begin
                            ruleht := mem[leaderbox+3].int;
                            ruledp := mem[leaderbox+2].int;
                            goto 14;
                          End;
                        leaderwd := mem[leaderbox+1].int;
                        If (leaderwd>0)And(rulewd>0)Then
                          Begin
                            rulewd := rulewd+10;
                            edge := curh+rulewd;
                            lx := 0;
{627:}
                            If mem[p].hh.b1=100 Then
                              Begin
                                saveh := curh;
                                curh := leftedge+leaderwd*((curh-leftedge)Div leaderwd);
                                If curh<saveh Then curh := curh+leaderwd;
                              End
                            Else
                              Begin
                                lq := rulewd Div leaderwd;
                                lr := rulewd Mod leaderwd;
                                If mem[p].hh.b1=101 Then curh := curh+(lr Div 2)
                                Else
                                  Begin
                                    lx := lr Div(lq+1
                                          );
                                    curh := curh+((lr-(lq-1)*lx)Div 2);
                                  End;
                              End{:627};
                            While curh+leaderwd<=edge Do{628:}
                              Begin
                                curv := baseline+mem[leaderbox+4].
                                        int;
                                If curv<>dviv Then
                                  Begin
                                    movement(curv-dviv,157);
                                    dviv := curv;
                                  End;
                                savev := dviv;
                                If curh<>dvih Then
                                  Begin
                                    movement(curh-dvih,143);
                                    dvih := curh;
                                  End;
                                saveh := dvih;
                                tempptr := leaderbox;
                                outerdoingleaders := doingleaders;
                                doingleaders := true;
                                If mem[leaderbox].hh.b0=1 Then vlistout
                                Else hlistout;
                                doingleaders := outerdoingleaders;
                                dviv := savev;
                                dvih := saveh;
                                curv := baseline;
                                curh := saveh+leaderwd+lx;
                              End{:628};
                            curh := edge-10;
                            goto 15;
                          End;
                      End{:626};
                    goto 13;
                  End{:625};
              11,9: curh := curh+mem[p+1].int;
              6:{652:}
                 Begin
                   mem[29988] := mem[p+1];
                   mem[29988].hh.rh := mem[p].hh.rh;
                   p := 29988;
                   goto 21;
                 End{:652};
              Else
            End;
            goto 15;
            14:{624:}If (ruleht=-1073741824)Then ruleht := mem[thisbox+3].int;
            If (ruledp=-1073741824)Then ruledp := mem[thisbox+2].int;
            ruleht := ruleht+ruledp;
            If (ruleht>0)And(rulewd>0)Then
              Begin
                If curh<>dvih Then
                  Begin
                    movement(
                             curh-dvih,143);
                    dvih := curh;
                  End;
                curv := baseline+ruledp;
                If curv<>dviv Then
                  Begin
                    movement(curv-dviv,157);
                    dviv := curv;
                  End;
                Begin
                  dvibuf[dviptr] := 132;
                  dviptr := dviptr+1;
                  If dviptr=dvilimit Then dviswap;
                End;
                dvifour(ruleht);
                dvifour(rulewd);
                curv := baseline;
                dvih := dvih+rulewd;
              End{:624};
            13: curh := curh+rulewd;
            15: p := mem[p].hh.rh;
          End{:622}{:620};
  prunemovements(saveloc);
  If curs>0 Then dvipop(saveloc);
  curs := curs-1;
End;
{:619}{629:}
Procedure vlistout;

Label 13,14,15;

Var leftedge: scaled;
  topedge: scaled;
  saveh,savev: scaled;
  thisbox: halfword;
  gorder: glueord;
  gsign: 0..2;
  p: halfword;
  saveloc: integer;
  leaderbox: halfword;
  leaderht: scaled;
  lx: scaled;
  outerdoingleaders: boolean;
  edge: scaled;
  gluetemp: real;
  curglue: real;
  curg: scaled;
Begin
  curg := 0;
  curglue := 0.0;
  thisbox := tempptr;
  gorder := mem[thisbox+5].hh.b1;
  gsign := mem[thisbox+5].hh.b0;
  p := mem[thisbox+5].hh.rh;
  curs := curs+1;
  If curs>0 Then
    Begin
      dvibuf[dviptr] := 141;
      dviptr := dviptr+1;
      If dviptr=dvilimit Then dviswap;
    End;
  If curs>maxpush Then maxpush := curs;
  saveloc := dvioffset+dviptr;
  leftedge := curh;
  curv := curv-mem[thisbox+3].int;
  topedge := curv;
  While p<>0 Do{630:}
    Begin
      If (p>=himemmin)Then confusion(829)
      Else{631:}
        Begin
          Case mem[p].hh.b0 Of 
            0,1:{632:}If mem[p+5].hh.rh=0 Then curv := curv
                                                       +mem[p+3].int+mem[p+2].int
                 Else
                   Begin
                     curv := curv+mem[p+3].int;
                     If curv<>dviv Then
                       Begin
                         movement(curv-dviv,157);
                         dviv := curv;
                       End;
                     saveh := dvih;
                     savev := dviv;
                     curh := leftedge+mem[p+4].int;
                     tempptr := p;
                     If mem[p].hh.b0=1 Then vlistout
                     Else hlistout;
                     dvih := saveh;
                     dviv := savev;
                     curv := savev+mem[p+2].int;
                     curh := leftedge;
                   End{:632};
            2:
               Begin
                 ruleht := mem[p+3].int;
                 ruledp := mem[p+2].int;
                 rulewd := mem[p+1].int;
                 goto 14;
               End;
            8:{1366:}outwhat(p){:1366};
            10:{634:}
                Begin
                  g := mem[p+1].hh.lh;
                  ruleht := mem[g+1].int-curg;
                  If gsign<>0 Then
                    Begin
                      If gsign=1 Then
                        Begin
                          If mem[g].hh.b0=gorder Then
                            Begin
                              curglue := curglue+mem[g+2].int;
                              gluetemp := mem[thisbox+6].gr*curglue;
                              If gluetemp>1000000000.0 Then gluetemp := 1000000000.0
                              Else If gluetemp<
                                      -1000000000.0 Then gluetemp := -1000000000.0;
                              curg := round(gluetemp);
                            End;
                        End
                      Else If mem[g].hh.b1=gorder Then
                             Begin
                               curglue := curglue-mem[g+3].int
                               ;
                               gluetemp := mem[thisbox+6].gr*curglue;
                               If gluetemp>1000000000.0 Then gluetemp := 1000000000.0
                               Else If gluetemp<
                                       -1000000000.0 Then gluetemp := -1000000000.0;
                               curg := round(gluetemp);
                             End;
                    End;
                  ruleht := ruleht+curg;
                  If mem[p].hh.b1>=100 Then{635:}
                    Begin
                      leaderbox := mem[p+1].hh.rh;
                      If mem[leaderbox].hh.b0=2 Then
                        Begin
                          rulewd := mem[leaderbox+1].int;
                          ruledp := 0;
                          goto 14;
                        End;
                      leaderht := mem[leaderbox+3].int+mem[leaderbox+2].int;
                      If (leaderht>0)And(ruleht>0)Then
                        Begin
                          ruleht := ruleht+10;
                          edge := curv+ruleht;
                          lx := 0;
{636:}
                          If mem[p].hh.b1=100 Then
                            Begin
                              savev := curv;
                              curv := topedge+leaderht*((curv-topedge)Div leaderht);
                              If curv<savev Then curv := curv+leaderht;
                            End
                          Else
                            Begin
                              lq := ruleht Div leaderht;
                              lr := ruleht Mod leaderht;
                              If mem[p].hh.b1=101 Then curv := curv+(lr Div 2)
                              Else
                                Begin
                                  lx := lr Div(lq+1
                                        );
                                  curv := curv+((lr-(lq-1)*lx)Div 2);
                                End;
                            End{:636};
                          While curv+leaderht<=edge Do{637:}
                            Begin
                              curh := leftedge+mem[leaderbox+4].
                                      int;
                              If curh<>dvih Then
                                Begin
                                  movement(curh-dvih,143);
                                  dvih := curh;
                                End;
                              saveh := dvih;
                              curv := curv+mem[leaderbox+3].int;
                              If curv<>dviv Then
                                Begin
                                  movement(curv-dviv,157);
                                  dviv := curv;
                                End;
                              savev := dviv;
                              tempptr := leaderbox;
                              outerdoingleaders := doingleaders;
                              doingleaders := true;
                              If mem[leaderbox].hh.b0=1 Then vlistout
                              Else hlistout;
                              doingleaders := outerdoingleaders;
                              dviv := savev;
                              dvih := saveh;
                              curh := leftedge;
                              curv := savev-mem[leaderbox+3].int+leaderht+lx;
                            End{:637};
                          curv := edge-10;
                          goto 15;
                        End;
                    End{:635};
                  goto 13;
                End{:634};
            11: curv := curv+mem[p+1].int;
            Else
          End;
          goto 15;
          14:{633:}If (rulewd=-1073741824)Then rulewd := mem[thisbox+1].int;
          ruleht := ruleht+ruledp;
          curv := curv+ruleht;
          If (ruleht>0)And(rulewd>0)Then
            Begin
              If curh<>dvih Then
                Begin
                  movement(
                           curh-dvih,143);
                  dvih := curh;
                End;
              If curv<>dviv Then
                Begin
                  movement(curv-dviv,157);
                  dviv := curv;
                End;
              Begin
                dvibuf[dviptr] := 137;
                dviptr := dviptr+1;
                If dviptr=dvilimit Then dviswap;
              End;
              dvifour(ruleht);
              dvifour(rulewd);
            End;
          goto 15{:633};
          13: curv := curv+ruleht;
        End{:631};
      15: p := mem[p].hh.rh;
    End{:630};
  prunemovements(saveloc);
  If curs>0 Then dvipop(saveloc);
  curs := curs-1;
End;{:629}{638:}
Procedure shipout(p:halfword);

Label 30;

Var pageloc: integer;
  j,k: 0..9;
  s: poolpointer;
  oldsetting: 0..21;
Begin
  If eqtb[5297].int>0 Then
    Begin
      printnl(338);
      println;
      print(830);
    End;
  If termoffset>maxprintline-9 Then println
  Else If (termoffset>0)Or(
          fileoffset>0)Then printchar(32);
  printchar(91);
  j := 9;
  While (eqtb[5318+j].int=0)And(j>0) Do
    j := j-1;
  For k:=0 To j Do
    Begin
      printint(eqtb[5318+k].int);
      If k<j Then printchar(46);
    End;
  flush(output);
  If eqtb[5297].int>0 Then
    Begin
      printchar(93);
      begindiagnostic;
      showbox(p);
      enddiagnostic(true);
    End;
{640:}{641:}
  If (mem[p+3].int>1073741823)Or(mem[p+2].int>1073741823)Or(mem
     [p+3].int+mem[p+2].int+eqtb[5849].int>1073741823)Or(mem[p+1].int+eqtb[
     5848].int>1073741823)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(834);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 835;
        helpline[0] := 836;
      End;
      error;
      If eqtb[5297].int<=0 Then
        Begin
          begindiagnostic;
          printnl(837);
          showbox(p);
          enddiagnostic(true);
        End;
      goto 30;
    End;
  If mem[p+3].int+mem[p+2].int+eqtb[5849].int>maxv Then maxv := mem[p+3].int
                                                                +mem[p+2].int+eqtb[5849].int;
  If mem[p+1].int+eqtb[5848].int>maxh Then maxh := mem[p+1].int+eqtb[5848].
                                                   int{:641};{617:}
  dvih := 0;
  dviv := 0;
  curh := eqtb[5848].int;
  dvif := 0;
  If outputfilename=0 Then
    Begin
      If jobname=0 Then openlogfile;
      packjobname(795);
      While Not bopenout(dvifile) Do
        promptfilename(796,795);
      outputfilename := bmakenamestring(dvifile);
    End;
  If totalpages=0 Then
    Begin
      Begin
        dvibuf[dviptr] := 247;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      Begin
        dvibuf[dviptr] := 2;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      dvifour(25400000);
      dvifour(473628672);
      preparemag;
      dvifour(eqtb[5280].int);
      oldsetting := selector;
      selector := 21;
      print(828);
      printint(eqtb[5286].int);
      printchar(46);
      printtwo(eqtb[5285].int);
      printchar(46);
      printtwo(eqtb[5284].int);
      printchar(58);
      printtwo(eqtb[5283].int Div 60);
      printtwo(eqtb[5283].int Mod 60);
      selector := oldsetting;
      Begin
        dvibuf[dviptr] := (poolptr-strstart[strptr]);
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      For s:=strstart[strptr]To poolptr-1 Do
        Begin
          dvibuf[dviptr] := strpool[s];
          dviptr := dviptr+1;
          If dviptr=dvilimit Then dviswap;
        End;
      poolptr := strstart[strptr];
    End{:617};
  pageloc := dvioffset+dviptr;
  Begin
    dvibuf[dviptr] := 139;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  For k:=0 To 9 Do
    dvifour(eqtb[5318+k].int);
  dvifour(lastbop);
  lastbop := pageloc;
  curv := mem[p+3].int+eqtb[5849].int;
  tempptr := p;
  If mem[p].hh.b0=1 Then vlistout
  Else hlistout;
  Begin
    dvibuf[dviptr] := 140;
    dviptr := dviptr+1;
    If dviptr=dvilimit Then dviswap;
  End;
  totalpages := totalpages+1;
  curs := -1;
  30:{:640};
  If eqtb[5297].int<=0 Then printchar(93);
  deadcycles := 0;
  flush(output);
{639:}
  If eqtb[5294].int>1 Then
    Begin
      printnl(831);
      printint(varused);
      printchar(38);
      printint(dynused);
      printchar(59);
    End;
  flushnodelist(p);
  If eqtb[5294].int>1 Then
    Begin
      print(832);
      printint(varused);
      printchar(38);
      printint(dynused);
      print(833);
      printint(himemmin-lomemmax-1);
      println;
    End;{:639};
End;
{:638}{645:}
Procedure scanspec(c:groupcode;threecodes:boolean);

Label 40;

Var s: integer;
  speccode: 0..1;
Begin
  If threecodes Then s := savestack[saveptr+0].int;
  If scankeyword(843)Then speccode := 0
  Else If scankeyword(844)Then
         speccode := 1
  Else
    Begin
      speccode := 1;
      curval := 0;
      goto 40;
    End;
  scandimen(false,false,false);
  40: If threecodes Then
        Begin
          savestack[saveptr+0].int := s;
          saveptr := saveptr+1;
        End;
  savestack[saveptr+0].int := speccode;
  savestack[saveptr+1].int := curval;
  saveptr := saveptr+2;
  newsavelevel(c);
  scanleftbrace;
End;{:645}{649:}
Function hpack(p:halfword;w:scaled;
               m:smallnumber): halfword;

Label 21,50,10;

Var r: halfword;
  q: halfword;
  h,d,x: scaled;
  s: scaled;
  g: halfword;
  o: glueord;
  f: internalfontnumber;
  i: fourquarters;
  hd: eightbits;
Begin
  lastbadness := 0;
  r := getnode(7);
  mem[r].hh.b0 := 0;
  mem[r].hh.b1 := 0;
  mem[r+4].int := 0;
  q := r+5;
  mem[q].hh.rh := p;
  h := 0;{650:}
  d := 0;
  x := 0;
  totalstretch[0] := 0;
  totalshrink[0] := 0;
  totalstretch[1] := 0;
  totalshrink[1] := 0;
  totalstretch[2] := 0;
  totalshrink[2] := 0;
  totalstretch[3] := 0;
  totalshrink[3] := 0{:650};
  While p<>0 Do{651:}
    Begin
      21: While (p>=himemmin) Do{654:}
            Begin
              f := mem[p].hh
                   .b0;
              i := fontinfo[charbase[f]+mem[p].hh.b1].qqqq;
              hd := i.b1;
              x := x+fontinfo[widthbase[f]+i.b0].int;
              s := fontinfo[heightbase[f]+(hd)Div 16].int;
              If s>h Then h := s;
              s := fontinfo[depthbase[f]+(hd)Mod 16].int;
              If s>d Then d := s;
              p := mem[p].hh.rh;
            End{:654};
      If p<>0 Then
        Begin
          Case mem[p].hh.b0 Of 
            0,1,2,13:{653:}
                      Begin
                        x := x+mem[p
                             +1].int;
                        If mem[p].hh.b0>=2 Then s := 0
                        Else s := mem[p+4].int;
                        If mem[p+3].int-s>h Then h := mem[p+3].int-s;
                        If mem[p+2].int+s>d Then d := mem[p+2].int+s;
                      End{:653};
            3,4,5: If adjusttail<>0 Then{655:}
                     Begin
                       While mem[q].hh.rh<>p Do
                         q := mem[q
                              ].hh.rh;
                       If mem[p].hh.b0=5 Then
                         Begin
                           mem[adjusttail].hh.rh := mem[p+1].int;
                           While mem[adjusttail].hh.rh<>0 Do
                             adjusttail := mem[adjusttail].hh.rh;
                           p := mem[p].hh.rh;
                           freenode(mem[q].hh.rh,2);
                         End
                       Else
                         Begin
                           mem[adjusttail].hh.rh := p;
                           adjusttail := p;
                           p := mem[p].hh.rh;
                         End;
                       mem[q].hh.rh := p;
                       p := q;
                     End{:655};
            8:{1360:}{:1360};
            10:{656:}
                Begin
                  g := mem[p+1].hh.lh;
                  x := x+mem[g+1].int;
                  o := mem[g].hh.b0;
                  totalstretch[o] := totalstretch[o]+mem[g+2].int;
                  o := mem[g].hh.b1;
                  totalshrink[o] := totalshrink[o]+mem[g+3].int;
                  If mem[p].hh.b1>=100 Then
                    Begin
                      g := mem[p+1].hh.rh;
                      If mem[g+3].int>h Then h := mem[g+3].int;
                      If mem[g+2].int>d Then d := mem[g+2].int;
                    End;
                End{:656};
            11,9: x := x+mem[p+1].int;
            6:{652:}
               Begin
                 mem[29988] := mem[p+1];
                 mem[29988].hh.rh := mem[p].hh.rh;
                 p := 29988;
                 goto 21;
               End{:652};
            Else
          End;
          p := mem[p].hh.rh;
        End;
    End{:651};
  If adjusttail<>0 Then mem[adjusttail].hh.rh := 0;
  mem[r+3].int := h;
  mem[r+2].int := d;{657:}
  If m=1 Then w := x+w;
  mem[r+1].int := w;
  x := w-x;
  If x=0 Then
    Begin
      mem[r+5].hh.b0 := 0;
      mem[r+5].hh.b1 := 0;
      mem[r+6].gr := 0.0;
      goto 10;
    End
  Else If x>0 Then{658:}
         Begin{659:}
           If totalstretch[3]<>0 Then o := 3
           Else If totalstretch[2]<>0 Then o := 2
           Else If totalstretch[1]<>0 Then o := 
                                                1
           Else o := 0{:659};
           mem[r+5].hh.b1 := o;
           mem[r+5].hh.b0 := 1;
           If totalstretch[o]<>0 Then mem[r+6].gr := x/totalstretch[o]
           Else
             Begin
               mem[
               r+5].hh.b0 := 0;
               mem[r+6].gr := 0.0;
             End;
           If o=0 Then If mem[r+5].hh.rh<>0 Then{660:}
                         Begin
                           lastbadness := badness(x,
                                          totalstretch[0]);
                           If lastbadness>eqtb[5289].int Then
                             Begin
                               println;
                               If lastbadness>100 Then printnl(845)
                               Else printnl(846);
                               print(847);
                               printint(lastbadness);
                               goto 50;
                             End;
                         End{:660};
           goto 10;
         End{:658}
  Else{664:}
    Begin{665:}
      If totalshrink[3]<>0 Then o := 3
      Else If 
              totalshrink[2]<>0 Then o := 2
      Else If totalshrink[1]<>0 Then o := 1
      Else o := 
                0{:665};
      mem[r+5].hh.b1 := o;
      mem[r+5].hh.b0 := 2;
      If totalshrink[o]<>0 Then mem[r+6].gr := (-x)/totalshrink[o]
      Else
        Begin
          mem
          [r+5].hh.b0 := 0;
          mem[r+6].gr := 0.0;
        End;
      If (totalshrink[o]<-x)And(o=0)And(mem[r+5].hh.rh<>0)Then
        Begin
          lastbadness := 1000000;
          mem[r+6].gr := 1.0;
{666:}
          If (-x-totalshrink[0]>eqtb[5838].int)Or(eqtb[5289].int<100)Then
            Begin
              If (eqtb[5846].int>0)And(-x-totalshrink[0]>eqtb[5838].int)Then
                Begin
                  While mem[q].hh.rh<>0 Do
                    q := mem[q].hh.rh;
                  mem[q].hh.rh := newrule;
                  mem[mem[q].hh.rh+1].int := eqtb[5846].int;
                End;
              println;
              printnl(853);
              printscaled(-x-totalshrink[0]);
              print(854);
              goto 50;
            End{:666};
        End
      Else If o=0 Then If mem[r+5].hh.rh<>0 Then{667:}
                         Begin
                           lastbadness := 
                                          badness(-x,totalshrink[0]);
                           If lastbadness>eqtb[5289].int Then
                             Begin
                               println;
                               printnl(855);
                               printint(lastbadness);
                               goto 50;
                             End;
                         End{:667};
      goto 10;
    End{:664}{:657};
  50:{663:}If outputactive Then print(848)
      Else
        Begin
          If packbeginline<>0
            Then
            Begin
              If packbeginline>0 Then print(849)
              Else print(850);
              printint(abs(packbeginline));
              print(851);
            End
          Else print(852);
          printint(line);
        End;
  println;
  fontinshortdisplay := 0;
  shortdisplay(mem[r+5].hh.rh);
  println;
  begindiagnostic;
  showbox(r);
  enddiagnostic(true){:663};
  10: hpack := r;
End;
{:649}{668:}
Function vpackage(p:halfword;h:scaled;m:smallnumber;
                  l:scaled): halfword;

Label 50,10;

Var r: halfword;
  w,d,x: scaled;
  s: scaled;
  g: halfword;
  o: glueord;
Begin
  lastbadness := 0;
  r := getnode(7);
  mem[r].hh.b0 := 1;
  mem[r].hh.b1 := 0;
  mem[r+4].int := 0;
  mem[r+5].hh.rh := p;
  w := 0;{650:}
  d := 0;
  x := 0;
  totalstretch[0] := 0;
  totalshrink[0] := 0;
  totalstretch[1] := 0;
  totalshrink[1] := 0;
  totalstretch[2] := 0;
  totalshrink[2] := 0;
  totalstretch[3] := 0;
  totalshrink[3] := 0{:650};
  While p<>0 Do{669:}
    Begin
      If (p>=himemmin)Then confusion(856)
      Else Case mem
                [p].hh.b0 Of 
             0,1,2,13:{670:}
                       Begin
                         x := x+d+mem[p+3].int;
                         d := mem[p+2].int;
                         If mem[p].hh.b0>=2 Then s := 0
                         Else s := mem[p+4].int;
                         If mem[p+1].int+s>w Then w := mem[p+1].int+s;
                       End{:670};
             8:{1359:}{:1359};
             10:{671:}
                 Begin
                   x := x+d;
                   d := 0;
                   g := mem[p+1].hh.lh;
                   x := x+mem[g+1].int;
                   o := mem[g].hh.b0;
                   totalstretch[o] := totalstretch[o]+mem[g+2].int;
                   o := mem[g].hh.b1;
                   totalshrink[o] := totalshrink[o]+mem[g+3].int;
                   If mem[p].hh.b1>=100 Then
                     Begin
                       g := mem[p+1].hh.rh;
                       If mem[g+1].int>w Then w := mem[g+1].int;
                     End;
                 End{:671};
             11:
                 Begin
                   x := x+d+mem[p+1].int;
                   d := 0;
                 End;
             Else
        End;
      p := mem[p].hh.rh;
    End{:669};
  mem[r+1].int := w;
  If d>l Then
    Begin
      x := x+d-l;
      mem[r+2].int := l;
    End
  Else mem[r+2].int := d;{672:}
  If m=1 Then h := x+h;
  mem[r+3].int := h;
  x := h-x;
  If x=0 Then
    Begin
      mem[r+5].hh.b0 := 0;
      mem[r+5].hh.b1 := 0;
      mem[r+6].gr := 0.0;
      goto 10;
    End
  Else If x>0 Then{673:}
         Begin{659:}
           If totalstretch[3]<>0 Then o := 3
           Else If totalstretch[2]<>0 Then o := 2
           Else If totalstretch[1]<>0 Then o := 
                                                1
           Else o := 0{:659};
           mem[r+5].hh.b1 := o;
           mem[r+5].hh.b0 := 1;
           If totalstretch[o]<>0 Then mem[r+6].gr := x/totalstretch[o]
           Else
             Begin
               mem[
               r+5].hh.b0 := 0;
               mem[r+6].gr := 0.0;
             End;
           If o=0 Then If mem[r+5].hh.rh<>0 Then{674:}
                         Begin
                           lastbadness := badness(x,
                                          totalstretch[0]);
                           If lastbadness>eqtb[5290].int Then
                             Begin
                               println;
                               If lastbadness>100 Then printnl(845)
                               Else printnl(846);
                               print(857);
                               printint(lastbadness);
                               goto 50;
                             End;
                         End{:674};
           goto 10;
         End{:673}
  Else{676:}
    Begin{665:}
      If totalshrink[3]<>0 Then o := 3
      Else If 
              totalshrink[2]<>0 Then o := 2
      Else If totalshrink[1]<>0 Then o := 1
      Else o := 
                0{:665};
      mem[r+5].hh.b1 := o;
      mem[r+5].hh.b0 := 2;
      If totalshrink[o]<>0 Then mem[r+6].gr := (-x)/totalshrink[o]
      Else
        Begin
          mem
          [r+5].hh.b0 := 0;
          mem[r+6].gr := 0.0;
        End;
      If (totalshrink[o]<-x)And(o=0)And(mem[r+5].hh.rh<>0)Then
        Begin
          lastbadness := 1000000;
          mem[r+6].gr := 1.0;
{677:}
          If (-x-totalshrink[0]>eqtb[5839].int)Or(eqtb[5290].int<100)Then
            Begin
              println;
              printnl(858);
              printscaled(-x-totalshrink[0]);
              print(859);
              goto 50;
            End{:677};
        End
      Else If o=0 Then If mem[r+5].hh.rh<>0 Then{678:}
                         Begin
                           lastbadness := 
                                          badness(-x,totalshrink[0]);
                           If lastbadness>eqtb[5290].int Then
                             Begin
                               println;
                               printnl(860);
                               printint(lastbadness);
                               goto 50;
                             End;
                         End{:678};
      goto 10;
    End{:676}{:672};
  50:{675:}If outputactive Then print(848)
      Else
        Begin
          If packbeginline<>0
            Then
            Begin
              print(850);
              printint(abs(packbeginline));
              print(851);
            End
          Else print(852);
          printint(line);
          println;
        End;
  begindiagnostic;
  showbox(r);
  enddiagnostic(true){:675};
  10: vpackage := r;
End;
{:668}{679:}
Procedure appendtovlist(b:halfword);

Var d: scaled;
  p: halfword;
Begin
  If curlist.auxfield.int>-65536000 Then
    Begin
      d := mem[eqtb[2883].hh.
           rh+1].int-curlist.auxfield.int-mem[b+3].int;
      If d<eqtb[5832].int Then p := newparamglue(0)
      Else
        Begin
          p := newskipparam(1)
          ;
          mem[tempptr+1].int := d;
        End;
      mem[curlist.tailfield].hh.rh := p;
      curlist.tailfield := p;
    End;
  mem[curlist.tailfield].hh.rh := b;
  curlist.tailfield := b;
  curlist.auxfield.int := mem[b+2].int;
End;
{:679}{686:}
Function newnoad: halfword;

Var p: halfword;
Begin
  p := getnode(4);
  mem[p].hh.b0 := 16;
  mem[p].hh.b1 := 0;
  mem[p+1].hh := emptyfield;
  mem[p+3].hh := emptyfield;
  mem[p+2].hh := emptyfield;
  newnoad := p;
End;{:686}{688:}
Function newstyle(s:smallnumber): halfword;

Var p: halfword;
Begin
  p := getnode(3);
  mem[p].hh.b0 := 14;
  mem[p].hh.b1 := s;
  mem[p+1].int := 0;
  mem[p+2].int := 0;
  newstyle := p;
End;
{:688}{689:}
Function newchoice: halfword;

Var p: halfword;
Begin
  p := getnode(3);
  mem[p].hh.b0 := 15;
  mem[p].hh.b1 := 0;
  mem[p+1].hh.lh := 0;
  mem[p+1].hh.rh := 0;
  mem[p+2].hh.lh := 0;
  mem[p+2].hh.rh := 0;
  newchoice := p;
End;
{:689}{693:}
Procedure showinfo;
Begin
  shownodelist(mem[tempptr].hh.lh);
End;{:693}{704:}
Function fractionrule(t:scaled): halfword;

Var p: halfword;
Begin
  p := newrule;
  mem[p+3].int := t;
  mem[p+2].int := 0;
  fractionrule := p;
End;
{:704}{705:}
Function overbar(b:halfword;k,t:scaled): halfword;

Var p,q: halfword;
Begin
  p := newkern(k);
  mem[p].hh.rh := b;
  q := fractionrule(t);
  mem[q].hh.rh := p;
  p := newkern(t);
  mem[p].hh.rh := q;
  overbar := vpackage(p,0,1,1073741823);
End;
{:705}{706:}{709:}
Function charbox(f:internalfontnumber;
                 c:quarterword): halfword;

Var q: fourquarters;
  hd: eightbits;
  b,p: halfword;
Begin
  q := fontinfo[charbase[f]+c].qqqq;
  hd := q.b1;
  b := newnullbox;
  mem[b+1].int := fontinfo[widthbase[f]+q.b0].int+fontinfo[italicbase[f]+(q.
                  b2)Div 4].int;
  mem[b+3].int := fontinfo[heightbase[f]+(hd)Div 16].int;
  mem[b+2].int := fontinfo[depthbase[f]+(hd)Mod 16].int;
  p := getavail;
  mem[p].hh.b1 := c;
  mem[p].hh.b0 := f;
  mem[b+5].hh.rh := p;
  charbox := b;
End;
{:709}{711:}
Procedure stackintobox(b:halfword;f:internalfontnumber;
                       c:quarterword);

Var p: halfword;
Begin
  p := charbox(f,c);
  mem[p].hh.rh := mem[b+5].hh.rh;
  mem[b+5].hh.rh := p;
  mem[b+3].int := mem[p+3].int;
End;
{:711}{712:}
Function heightplusdepth(f:internalfontnumber;
                         c:quarterword): scaled;

Var q: fourquarters;
  hd: eightbits;
Begin
  q := fontinfo[charbase[f]+c].qqqq;
  hd := q.b1;
  heightplusdepth := fontinfo[heightbase[f]+(hd)Div 16].int+fontinfo[
                     depthbase[f]+(hd)Mod 16].int;
End;{:712}
Function vardelimiter(d:halfword;
                      s:smallnumber;v:scaled): halfword;

Label 40,22;

Var b: halfword;
  f,g: internalfontnumber;
  c,x,y: quarterword;
  m,n: integer;
  u: scaled;
  w: scaled;
  q: fourquarters;
  hd: eightbits;
  r: fourquarters;
  z: smallnumber;
  largeattempt: boolean;
Begin
  f := 0;
  w := 0;
  largeattempt := false;
  z := mem[d].qqqq.b0;
  x := mem[d].qqqq.b1;
  While true Do
    Begin{707:}
      If (z<>0)Or(x<>0)Then
        Begin
          z := z+s+16;
          Repeat
            z := z-16;
            g := eqtb[3935+z].hh.rh;
            If g<>0 Then{708:}
              Begin
                y := x;
                If (y>=fontbc[g])And(y<=fontec[g])Then
                  Begin
                    22: q := fontinfo[charbase[g]+y
                             ].qqqq;
                    If (q.b0>0)Then
                      Begin
                        If ((q.b2)Mod 4)=3 Then
                          Begin
                            f := g;
                            c := y;
                            goto 40;
                          End;
                        hd := q.b1;
                        u := fontinfo[heightbase[g]+(hd)Div 16].int+fontinfo[depthbase[g]+(hd)Mod
                             16].int;
                        If u>w Then
                          Begin
                            f := g;
                            c := y;
                            w := u;
                            If u>=v Then goto 40;
                          End;
                        If ((q.b2)Mod 4)=2 Then
                          Begin
                            y := q.b3;
                            goto 22;
                          End;
                      End;
                  End;
              End{:708};
          Until z<16;
        End{:707};
      If largeattempt Then goto 40;
      largeattempt := true;
      z := mem[d].qqqq.b2;
      x := mem[d].qqqq.b3;
    End;
  40: If f<>0 Then{710:}If ((q.b2)Mod 4)=3 Then{713:}
                          Begin
                            b := newnullbox;
                            mem[b].hh.b0 := 1;
                            r := fontinfo[extenbase[f]+q.b3].qqqq;{714:}
                            c := r.b3;
                            u := heightplusdepth(f,c);
                            w := 0;
                            q := fontinfo[charbase[f]+c].qqqq;
                            mem[b+1].int := fontinfo[widthbase[f]+q.b0].int+fontinfo[italicbase[f]+(
                                            q.
                                            b2)Div 4].int;
                            c := r.b2;
                            If c<>0 Then w := w+heightplusdepth(f,c);
                            c := r.b1;
                            If c<>0 Then w := w+heightplusdepth(f,c);
                            c := r.b0;
                            If c<>0 Then w := w+heightplusdepth(f,c);
                            n := 0;
                            If u>0 Then While w<v Do
                                          Begin
                                            w := w+u;
                                            n := n+1;
                                            If r.b1<>0 Then w := w+u;
                                          End{:714};
                            c := r.b2;
                            If c<>0 Then stackintobox(b,f,c);
                            c := r.b3;
                            For m:=1 To n Do
                              stackintobox(b,f,c);
                            c := r.b1;
                            If c<>0 Then
                              Begin
                                stackintobox(b,f,c);
                                c := r.b3;
                                For m:=1 To n Do
                                  stackintobox(b,f,c);
                              End;
                            c := r.b0;
                            If c<>0 Then stackintobox(b,f,c);
                            mem[b+2].int := w-mem[b+3].int;
                          End{:713}
      Else b := charbox(f,c){:710}
      Else
        Begin
          b := newnullbox;
          mem[b+1].int := eqtb[5841].int;
        End;
  mem[b+4].int := half(mem[b+3].int-mem[b+2].int)-fontinfo[22+parambase[eqtb
                  [3937+s].hh.rh]].int;
  vardelimiter := b;
End;
{:706}{715:}
Function rebox(b:halfword;w:scaled): halfword;

Var p: halfword;
  f: internalfontnumber;
  v: scaled;
Begin
  If (mem[b+1].int<>w)And(mem[b+5].hh.rh<>0)Then
    Begin
      If mem[b].hh.
         b0=1 Then b := hpack(b,0,1);
      p := mem[b+5].hh.rh;
      If ((p>=himemmin))And(mem[p].hh.rh=0)Then
        Begin
          f := mem[p].hh.b0;
          v := fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
          ;
          If v<>mem[b+1].int Then mem[p].hh.rh := newkern(mem[b+1].int-v);
        End;
      freenode(b,7);
      b := newglue(12);
      mem[b].hh.rh := p;
      While mem[p].hh.rh<>0 Do
        p := mem[p].hh.rh;
      mem[p].hh.rh := newglue(12);
      rebox := hpack(b,w,0);
    End
  Else
    Begin
      mem[b+1].int := w;
      rebox := b;
    End;
End;
{:715}{716:}
Function mathglue(g:halfword;m:scaled): halfword;

Var p: halfword;
  n: integer;
  f: scaled;
Begin
  n := xovern(m,65536);
  f := remainder;
  If f<0 Then
    Begin
      n := n-1;
      f := f+65536;
    End;
  p := getnode(4);
  mem[p+1].int := multandadd(n,mem[g+1].int,xnoverd(mem[g+1].int,f,65536),
                  1073741823);
  mem[p].hh.b0 := mem[g].hh.b0;
  If mem[p].hh.b0=0 Then mem[p+2].int := multandadd(n,mem[g+2].int,xnoverd(
                                         mem[g+2].int,f,65536),1073741823)
  Else mem[p+2].int := mem[g+2].int;
  mem[p].hh.b1 := mem[g].hh.b1;
  If mem[p].hh.b1=0 Then mem[p+3].int := multandadd(n,mem[g+3].int,xnoverd(
                                         mem[g+3].int,f,65536),1073741823)
  Else mem[p+3].int := mem[g+3].int;
  mathglue := p;
End;{:716}{717:}
Procedure mathkern(p:halfword;m:scaled);

Var n: integer;
  f: scaled;
Begin
  If mem[p].hh.b1=99 Then
    Begin
      n := xovern(m,65536);
      f := remainder;
      If f<0 Then
        Begin
          n := n-1;
          f := f+65536;
        End;
      mem[p+1].int := multandadd(n,mem[p+1].int,xnoverd(mem[p+1].int,f,65536),
                      1073741823);
      mem[p].hh.b1 := 1;
    End;
End;{:717}{718:}
Procedure flushmath;
Begin
  flushnodelist(mem[curlist.headfield].hh.rh);
  flushnodelist(curlist.auxfield.int);
  mem[curlist.headfield].hh.rh := 0;
  curlist.tailfield := curlist.headfield;
  curlist.auxfield.int := 0;
End;
{:718}{720:}
Procedure mlisttohlist;
forward;
Function cleanbox(p:halfword;
                  s:smallnumber): halfword;

Label 40;

Var q: halfword;
  savestyle: smallnumber;
  x: halfword;
  r: halfword;
Begin
  Case mem[p].hh.rh Of 
    1:
       Begin
         curmlist := newnoad;
         mem[curmlist+1] := mem[p];
       End;
    2:
       Begin
         q := mem[p].hh.lh;
         goto 40;
       End;
    3: curmlist := mem[p].hh.lh;
    Else
      Begin
        q := newnullbox;
        goto 40;
      End
  End;
  savestyle := curstyle;
  curstyle := s;
  mlistpenalties := false;
  mlisttohlist;
  q := mem[29997].hh.rh;
  curstyle := savestyle;
{703:}
  Begin
    If curstyle<4 Then cursize := 0
    Else cursize := 16*((curstyle-2)
                    Div 2);
    curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
  End{:703};
  40: If (q>=himemmin)Or(q=0)Then x := hpack(q,0,1)
      Else If (mem[q].hh.rh=0)And(
              mem[q].hh.b0<=1)And(mem[q+4].int=0)Then x := q
      Else x := hpack(q,0,1);
{721:}
  q := mem[x+5].hh.rh;
  If (q>=himemmin)Then
    Begin
      r := mem[q].hh.rh;
      If r<>0 Then If mem[r].hh.rh=0 Then If Not(r>=himemmin)Then If mem[r].hh
                                                                     .b0=11 Then
                                                                    Begin
                                                                      freenode(r,2);
                                                                      mem[q].hh.rh := 0;
                                                                    End;
    End{:721};
  cleanbox := x;
End;{:720}{722:}
Procedure fetch(a:halfword);
Begin
  curc := mem[a].hh.b1;
  curf := eqtb[3935+mem[a].hh.b0+cursize].hh.rh;
  If curf=0 Then{723:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(338);
      End;
      printsize(cursize);
      printchar(32);
      printint(mem[a].hh.b0);
      print(885);
      print(curc);
      printchar(41);
      Begin
        helpptr := 4;
        helpline[3] := 886;
        helpline[2] := 887;
        helpline[1] := 888;
        helpline[0] := 889;
      End;
      error;
      curi := nullcharacter;
      mem[a].hh.rh := 0;
    End{:723}
  Else
    Begin
      If (curc>=fontbc[curf])And(curc<=fontec[curf])Then
        curi := fontinfo[charbase[curf]+curc].qqqq
      Else curi := nullcharacter;
      If Not((curi.b0>0))Then
        Begin
          charwarning(curf,curc);
          mem[a].hh.rh := 0;
          curi := nullcharacter;
        End;
    End;
End;
{:722}{726:}{734:}
Procedure makeover(q:halfword);
Begin
  mem[q+1].hh.lh := overbar(cleanbox(q+1,2*(curstyle Div 2)+1),3*
                    fontinfo[8+parambase[eqtb[3938+cursize].hh.rh]].int,fontinfo[8+parambase
                    [eqtb[3938+cursize].hh.rh]].int);
  mem[q+1].hh.rh := 2;
End;
{:734}{735:}
Procedure makeunder(q:halfword);

Var p,x,y: halfword;
  delta: scaled;
Begin
  x := cleanbox(q+1,curstyle);
  p := newkern(3*fontinfo[8+parambase[eqtb[3938+cursize].hh.rh]].int);
  mem[x].hh.rh := p;
  mem[p].hh.rh := fractionrule(fontinfo[8+parambase[eqtb[3938+cursize].hh.rh
                  ]].int);
  y := vpackage(x,0,1,1073741823);
  delta := mem[y+3].int+mem[y+2].int+fontinfo[8+parambase[eqtb[3938+cursize]
           .hh.rh]].int;
  mem[y+3].int := mem[x+3].int;
  mem[y+2].int := delta-mem[y+3].int;
  mem[q+1].hh.lh := y;
  mem[q+1].hh.rh := 2;
End;{:735}{736:}
Procedure makevcenter(q:halfword);

Var v: halfword;
  delta: scaled;
Begin
  v := mem[q+1].hh.lh;
  If mem[v].hh.b0<>1 Then confusion(539);
  delta := mem[v+3].int+mem[v+2].int;
  mem[v+3].int := fontinfo[22+parambase[eqtb[3937+cursize].hh.rh]].int+half(
                  delta);
  mem[v+2].int := delta-mem[v+3].int;
End;
{:736}{737:}
Procedure makeradical(q:halfword);

Var x,y: halfword;
  delta,clr: scaled;
Begin
  x := cleanbox(q+1,2*(curstyle Div 2)+1);
  If curstyle<2 Then clr := fontinfo[8+parambase[eqtb[3938+cursize].hh.rh]].
                            int+(abs(fontinfo[5+parambase[eqtb[3937+cursize].hh.rh]].int)Div 4)
  Else
    Begin
      clr := fontinfo[8+parambase[eqtb[3938+cursize].hh.rh]].int;
      clr := clr+(abs(clr)Div 4);
    End;
  y := vardelimiter(q+4,cursize,mem[x+3].int+mem[x+2].int+clr+fontinfo[8+
       parambase[eqtb[3938+cursize].hh.rh]].int);
  delta := mem[y+2].int-(mem[x+3].int+mem[x+2].int+clr);
  If delta>0 Then clr := clr+half(delta);
  mem[y+4].int := -(mem[x+3].int+clr);
  mem[y].hh.rh := overbar(x,clr,mem[y+3].int);
  mem[q+1].hh.lh := hpack(y,0,1);
  mem[q+1].hh.rh := 2;
End;{:737}{738:}
Procedure makemathaccent(q:halfword);

Label 30,31;

Var p,x,y: halfword;
  a: integer;
  c: quarterword;
  f: internalfontnumber;
  i: fourquarters;
  s: scaled;
  h: scaled;
  delta: scaled;
  w: scaled;
Begin
  fetch(q+4);
  If (curi.b0>0)Then
    Begin
      i := curi;
      c := curc;
      f := curf;{741:}
      s := 0;
      If mem[q+1].hh.rh=1 Then
        Begin
          fetch(q+1);
          If ((curi.b2)Mod 4)=1 Then
            Begin
              a := ligkernbase[curf]+curi.b3;
              curi := fontinfo[a].qqqq;
              If curi.b0>128 Then
                Begin
                  a := ligkernbase[curf]+256*curi.b2+curi.b3
                       +32768-256*(128);
                  curi := fontinfo[a].qqqq;
                End;
              While true Do
                Begin
                  If curi.b1=skewchar[curf]Then
                    Begin
                      If curi.b2>=128
                        Then If curi.b0<=128 Then s := fontinfo[kernbase[curf]+256*curi.b2+curi.b3
                                                       ].int;
                      goto 31;
                    End;
                  If curi.b0>=128 Then goto 31;
                  a := a+curi.b0+1;
                  curi := fontinfo[a].qqqq;
                End;
            End;
        End;
      31:{:741};
      x := cleanbox(q+1,2*(curstyle Div 2)+1);
      w := mem[x+1].int;
      h := mem[x+3].int;
{740:}
      While true Do
        Begin
          If ((i.b2)Mod 4)<>2 Then goto 30;
          y := i.b3;
          i := fontinfo[charbase[f]+y].qqqq;
          If Not(i.b0>0)Then goto 30;
          If fontinfo[widthbase[f]+i.b0].int>w Then goto 30;
          c := y;
        End;
      30:{:740};
      If h<fontinfo[5+parambase[f]].int Then delta := h
      Else delta := fontinfo[5+
                    parambase[f]].int;
      If (mem[q+2].hh.rh<>0)Or(mem[q+3].hh.rh<>0)Then If mem[q+1].hh.rh=1 Then
{742:}
                                                        Begin
                                                          flushnodelist(x);
                                                          x := newnoad;
                                                          mem[x+1] := mem[q+1];
                                                          mem[x+2] := mem[q+2];
                                                          mem[x+3] := mem[q+3];
                                                          mem[q+2].hh := emptyfield;
                                                          mem[q+3].hh := emptyfield;
                                                          mem[q+1].hh.rh := 3;
                                                          mem[q+1].hh.lh := x;
                                                          x := cleanbox(q+1,curstyle);
                                                          delta := delta+mem[x+3].int-h;
                                                          h := mem[x+3].int;
                                                        End{:742};
      y := charbox(f,c);
      mem[y+4].int := s+half(w-mem[y+1].int);
      mem[y+1].int := 0;
      p := newkern(-delta);
      mem[p].hh.rh := x;
      mem[y].hh.rh := p;
      y := vpackage(y,0,1,1073741823);
      mem[y+1].int := mem[x+1].int;
      If mem[y+3].int<h Then{739:}
        Begin
          p := newkern(h-mem[y+3].int);
          mem[p].hh.rh := mem[y+5].hh.rh;
          mem[y+5].hh.rh := p;
          mem[y+3].int := h;
        End{:739};
      mem[q+1].hh.lh := y;
      mem[q+1].hh.rh := 2;
    End;
End;
{:738}{743:}
Procedure makefraction(q:halfword);

Var p,v,x,y,z: halfword;
  delta,delta1,delta2,shiftup,shiftdown,clr: scaled;
Begin
  If mem[q+1].int=1073741824 Then mem[q+1].int := fontinfo[8+parambase
                                                  [eqtb[3938+cursize].hh.rh]].int;
{744:}
  x := cleanbox(q+2,curstyle+2-2*(curstyle Div 6));
  z := cleanbox(q+3,2*(curstyle Div 2)+3-2*(curstyle Div 6));
  If mem[x+1].int<mem[z+1].int Then x := rebox(x,mem[z+1].int)
  Else z := rebox(
            z,mem[x+1].int);
  If curstyle<2 Then
    Begin
      shiftup := fontinfo[8+parambase[eqtb[3937+cursize
                 ].hh.rh]].int;
      shiftdown := fontinfo[11+parambase[eqtb[3937+cursize].hh.rh]].int;
    End
  Else
    Begin
      shiftdown := fontinfo[12+parambase[eqtb[3937+cursize].hh.rh
                   ]].int;
      If mem[q+1].int<>0 Then shiftup := fontinfo[9+parambase[eqtb[3937+cursize]
                                         .hh.rh]].int
      Else shiftup := fontinfo[10+parambase[eqtb[3937+cursize].hh.
                      rh]].int;
    End{:744};
  If mem[q+1].int=0 Then{745:}
    Begin
      If curstyle<2 Then clr := 7*fontinfo[8+
                                parambase[eqtb[3938+cursize].hh.rh]].int
      Else clr := 3*fontinfo[8+
                  parambase[eqtb[3938+cursize].hh.rh]].int;
      delta := half(clr-((shiftup-mem[x+2].int)-(mem[z+3].int-shiftdown)));
      If delta>0 Then
        Begin
          shiftup := shiftup+delta;
          shiftdown := shiftdown+delta;
        End;
    End{:745}
  Else{746:}
    Begin
      If curstyle<2 Then clr := 3*mem[q+1].int
      Else clr 
        := mem[q+1].int;
      delta := half(mem[q+1].int);
      delta1 := clr-((shiftup-mem[x+2].int)-(fontinfo[22+parambase[eqtb[3937+
                cursize].hh.rh]].int+delta));
      delta2 := clr-((fontinfo[22+parambase[eqtb[3937+cursize].hh.rh]].int-delta
                )-(mem[z+3].int-shiftdown));
      If delta1>0 Then shiftup := shiftup+delta1;
      If delta2>0 Then shiftdown := shiftdown+delta2;
    End{:746};
{747:}
  v := newnullbox;
  mem[v].hh.b0 := 1;
  mem[v+3].int := shiftup+mem[x+3].int;
  mem[v+2].int := mem[z+2].int+shiftdown;
  mem[v+1].int := mem[x+1].int;
  If mem[q+1].int=0 Then
    Begin
      p := newkern((shiftup-mem[x+2].int)-(mem[z+3]
           .int-shiftdown));
      mem[p].hh.rh := z;
    End
  Else
    Begin
      y := fractionrule(mem[q+1].int);
      p := newkern((fontinfo[22+parambase[eqtb[3937+cursize].hh.rh]].int-delta)-
           (mem[z+3].int-shiftdown));
      mem[y].hh.rh := p;
      mem[p].hh.rh := z;
      p := newkern((shiftup-mem[x+2].int)-(fontinfo[22+parambase[eqtb[3937+
           cursize].hh.rh]].int+delta));
      mem[p].hh.rh := y;
    End;
  mem[x].hh.rh := p;
  mem[v+5].hh.rh := x{:747};
{748:}
  If curstyle<2 Then delta := fontinfo[20+parambase[eqtb[3937+cursize]
                              .hh.rh]].int
  Else delta := fontinfo[21+parambase[eqtb[3937+cursize].hh.rh]
                ].int;
  x := vardelimiter(q+4,cursize,delta);
  mem[x].hh.rh := v;
  z := vardelimiter(q+5,cursize,delta);
  mem[v].hh.rh := z;
  mem[q+1].int := hpack(x,0,1){:748};
End;
{:743}{749:}
Function makeop(q:halfword): scaled;

Var delta: scaled;
  p,v,x,y,z: halfword;
  c: quarterword;
  i: fourquarters;
  shiftup,shiftdown: scaled;
Begin
  If (mem[q].hh.b1=0)And(curstyle<2)Then mem[q].hh.b1 := 1;
  If mem[q+1].hh.rh=1 Then
    Begin
      fetch(q+1);
      If (curstyle<2)And(((curi.b2)Mod 4)=2)Then
        Begin
          c := curi.b3;
          i := fontinfo[charbase[curf]+c].qqqq;
          If (i.b0>0)Then
            Begin
              curc := c;
              curi := i;
              mem[q+1].hh.b1 := c;
            End;
        End;
      delta := fontinfo[italicbase[curf]+(curi.b2)Div 4].int;
      x := cleanbox(q+1,curstyle);
      If (mem[q+3].hh.rh<>0)And(mem[q].hh.b1<>1)Then mem[x+1].int := mem[x+1].int
                                                                     -delta;
      mem[x+4].int := half(mem[x+3].int-mem[x+2].int)-fontinfo[22+parambase[eqtb
                      [3937+cursize].hh.rh]].int;
      mem[q+1].hh.rh := 2;
      mem[q+1].hh.lh := x;
    End
  Else delta := 0;
  If mem[q].hh.b1=1 Then{750:}
    Begin
      x := cleanbox(q+2,2*(curstyle Div 4)+4+(
           curstyle Mod 2));
      y := cleanbox(q+1,curstyle);
      z := cleanbox(q+3,2*(curstyle Div 4)+5);
      v := newnullbox;
      mem[v].hh.b0 := 1;
      mem[v+1].int := mem[y+1].int;
      If mem[x+1].int>mem[v+1].int Then mem[v+1].int := mem[x+1].int;
      If mem[z+1].int>mem[v+1].int Then mem[v+1].int := mem[z+1].int;
      x := rebox(x,mem[v+1].int);
      y := rebox(y,mem[v+1].int);
      z := rebox(z,mem[v+1].int);
      mem[x+4].int := half(delta);
      mem[z+4].int := -mem[x+4].int;
      mem[v+3].int := mem[y+3].int;
      mem[v+2].int := mem[y+2].int;
{751:}
      If mem[q+2].hh.rh=0 Then
        Begin
          freenode(x,7);
          mem[v+5].hh.rh := y;
        End
      Else
        Begin
          shiftup := fontinfo[11+parambase[eqtb[3938+cursize].hh.rh]]
                     .int-mem[x+2].int;
          If shiftup<fontinfo[9+parambase[eqtb[3938+cursize].hh.rh]].int Then
            shiftup := fontinfo[9+parambase[eqtb[3938+cursize].hh.rh]].int;
          p := newkern(shiftup);
          mem[p].hh.rh := y;
          mem[x].hh.rh := p;
          p := newkern(fontinfo[13+parambase[eqtb[3938+cursize].hh.rh]].int);
          mem[p].hh.rh := x;
          mem[v+5].hh.rh := p;
          mem[v+3].int := mem[v+3].int+fontinfo[13+parambase[eqtb[3938+cursize].hh.
                          rh]].int+mem[x+3].int+mem[x+2].int+shiftup;
        End;
      If mem[q+3].hh.rh=0 Then freenode(z,7)
      Else
        Begin
          shiftdown := fontinfo[12+
                       parambase[eqtb[3938+cursize].hh.rh]].int-mem[z+3].int;
          If shiftdown<fontinfo[10+parambase[eqtb[3938+cursize].hh.rh]].int Then
            shiftdown := fontinfo[10+parambase[eqtb[3938+cursize].hh.rh]].int;
          p := newkern(shiftdown);
          mem[y].hh.rh := p;
          mem[p].hh.rh := z;
          p := newkern(fontinfo[13+parambase[eqtb[3938+cursize].hh.rh]].int);
          mem[z].hh.rh := p;
          mem[v+2].int := mem[v+2].int+fontinfo[13+parambase[eqtb[3938+cursize].hh.
                          rh]].int+mem[z+3].int+mem[z+2].int+shiftdown;
        End{:751};
      mem[q+1].int := v;
    End{:750};
  makeop := delta;
End;{:749}{752:}
Procedure makeord(q:halfword);

Label 20,10;

Var a: integer;
  p,r: halfword;
Begin
  20: If mem[q+3].hh.rh=0 Then If mem[q+2].hh.rh=0 Then If mem[q+1].
                                                           hh.rh=1 Then
                                                          Begin
                                                            p := mem[q].hh.rh;
                                                            If p<>0 Then If (mem[p].hh.b0>=16)And(
                                                                            mem[p].hh.b0<=22)Then If
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .

                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                   =
                                                                                                   1
                                                                                                Then
                                                                                                  If
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b0
                                                                                                   =
                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b0
                                                                                                Then

                                                                                               Begin

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh

                                                                                                  :=
                                                                                                   4
                                                                                                   ;

                                                                                               fetch
                                                                                                   (
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   )
                                                                                                   ;

                                                                                                  If
                                                                                                   (
                                                                                                   (
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                   )
                                                                                                 Mod
                                                                                                   4
                                                                                                   )
                                                                                                   =
                                                                                                   1
                                                                                                Then

                                                                                               Begin

                                                                                                   a
                                                                                                  :=
                                                                                         ligkernbase
                                                                                                   [
                                                                                                curf
                                                                                                   ]
                                                                                                   +
                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ;

                                                                                                curc
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b1
                                                                                                   ;

                                                                                                curi
                                                                                                  :=
                                                                                            fontinfo
                                                                                                   [
                                                                                                   a
                                                                                                   ]
                                                                                                   .
                                                                                                qqqq
                                                                                                   ;

                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b0
                                                                                                   >
                                                                                                 128
                                                                                                Then

                                                                                               Begin

                                                                                                   a
                                                                                                  :=
                                                                                         ligkernbase
                                                                                                   [
                                                                                                curf
                                                                                                   ]
                                                                                                   +
                                                                                                 256
                                                                                                   *
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                   +
                                                                                                curi
                                                                                                   .
                                                                                                  b3

                                                                                                   +
                                                                                               32768
                                                                                                   -
                                                                                                 256
                                                                                                   *
                                                                                                   (
                                                                                                 128
                                                                                                   )
                                                                                                   ;

                                                                                                curi
                                                                                                  :=
                                                                                            fontinfo
                                                                                                   [
                                                                                                   a
                                                                                                   ]
                                                                                                   .
                                                                                                qqqq
                                                                                                   ;

                                                                                                 End
                                                                                                   ;

                                                                                               While
                                                                                                true
                                                                                                  Do

                                                                                               Begin
                                                                                              {753:}

                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b1
                                                                                                   =
                                                                                                curc
                                                                                                Then
                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b0
                                                                                                  <=
                                                                                                 128
                                                                                                Then
                                                                                                  If

                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                  >=
                                                                                                 128
                                                                                                Then

                                                                                               Begin

                                                                                                   p
                                                                                                  :=
                                                                                             newkern
                                                                                                   (
                                                                                            fontinfo
                                                                                                   [
                                                                                            kernbase
                                                                                                   [
                                                                                                curf
                                                                                                   ]
                                                                                                   +
                                                                                                 256
                                                                                                   *
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                   +

                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ]
                                                                                                   .
                                                                                                 int
                                                                                                   )
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   p
                                                                                                   ;

                                                                                                goto
                                                                                                  10
                                                                                                   ;

                                                                                                 End

                                                                                                Else

                                                                                               Begin

                                                                                               Begin

                                                                                                  If
                                                                                           interrupt
                                                                                                  <>
                                                                                                   0
                                                                                                Then
                                                                                pauseforinstructions
                                                                                                   ;

                                                                                                 End
                                                                                                   ;

                                                                                                Case
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                  Of

                                                                                                   1
                                                                                                   ,
                                                                                                   5
                                                                                                   :
                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b1
                                                                                                  :=
                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ;

                                                                                                   2
                                                                                                   ,
                                                                                                   6
                                                                                                   :
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b1
                                                                                                  :=
                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ;

                                                                                                   3
                                                                                                   ,
                                                                                                   7
                                                                                                   ,
                                                                                                  11
                                                                                                   :

                                                                                               Begin

                                                                                                   r
                                                                                                  :=
                                                                                             newnoad
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   r
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b1
                                                                                                  :=
                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   r
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b0
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b0
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   r
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   r
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   p
                                                                                                   ;

                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                   <
                                                                                                  11
                                                                                                Then
                                                                                                 mem
                                                                                                   [
                                                                                                   r
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   1

                                                                                                Else
                                                                                                 mem
                                                                                                   [
                                                                                                   r
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   4
                                                                                                   ;

                                                                                                 End
                                                                                                   ;

                                                                                                Else

                                                                                               Begin

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  b1
                                                                                                  :=
                                                                                                curi
                                                                                                   .
                                                                                                  b3
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   3
                                                                                                   ]
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   3
                                                                                                   ]
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   2
                                                                                                   ]
                                                                                                  :=
                                                                                                 mem
                                                                                                   [
                                                                                                   p
                                                                                                   +
                                                                                                   2
                                                                                                   ]
                                                                                                   ;

                                                                                            freenode
                                                                                                   (
                                                                                                   p
                                                                                                   ,
                                                                                                   4
                                                                                                   )
                                                                                                   ;

                                                                                                 End

                                                                                                 End
                                                                                                   ;

                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b2
                                                                                                   >
                                                                                                   3
                                                                                                Then
                                                                                                goto
                                                                                                  10
                                                                                                   ;

                                                                                                 mem
                                                                                                   [
                                                                                                   q
                                                                                                   +
                                                                                                   1
                                                                                                   ]
                                                                                                   .
                                                                                                  hh
                                                                                                   .
                                                                                                  rh
                                                                                                  :=
                                                                                                   1
                                                                                                   ;

                                                                                                goto
                                                                                                  20
                                                                                                   ;

                                                                                                 End
                                                                                              {:753}
                                                                                                   ;

                                                                                                  If
                                                                                                curi
                                                                                                   .
                                                                                                  b0
                                                                                                  >=
                                                                                                 128
                                                                                                Then
                                                                                                goto
                                                                                                  10
                                                                                                   ;

                                                                                                   a
                                                                                                  :=
                                                                                                   a
                                                                                                   +
                                                                                                curi
                                                                                                   .
                                                                                                  b0
                                                                                                   +
                                                                                                   1
                                                                                                   ;

                                                                                                curi
                                                                                                  :=
                                                                                            fontinfo
                                                                                                   [
                                                                                                   a
                                                                                                   ]
                                                                                                   .
                                                                                                qqqq
                                                                                                   ;

                                                                                                 End
                                                                                                   ;

                                                                                                 End
                                                                                                   ;

                                                                                                 End
                                                            ;
                                                          End;
  10:
End;{:752}{756:}
Procedure makescripts(q:halfword;
                      delta:scaled);

Var p,x,y,z: halfword;
  shiftup,shiftdown,clr: scaled;
  t: smallnumber;
Begin
  p := mem[q+1].int;
  If (p>=himemmin)Then
    Begin
      shiftup := 0;
      shiftdown := 0;
    End
  Else
    Begin
      z := hpack(p,0,1);
      If curstyle<4 Then t := 16
      Else t := 32;
      shiftup := mem[z+3].int-fontinfo[18+parambase[eqtb[3937+t].hh.rh]].int;
      shiftdown := mem[z+2].int+fontinfo[19+parambase[eqtb[3937+t].hh.rh]].int;
      freenode(z,7);
    End;
  If mem[q+2].hh.rh=0 Then{757:}
    Begin
      x := cleanbox(q+3,2*(curstyle Div 4)+5
           );
      mem[x+1].int := mem[x+1].int+eqtb[5842].int;
      If shiftdown<fontinfo[16+parambase[eqtb[3937+cursize].hh.rh]].int Then
        shiftdown := fontinfo[16+parambase[eqtb[3937+cursize].hh.rh]].int;
      clr := mem[x+3].int-(abs(fontinfo[5+parambase[eqtb[3937+cursize].hh.rh]].
             int*4)Div 5);
      If shiftdown<clr Then shiftdown := clr;
      mem[x+4].int := shiftdown;
    End{:757}
  Else
    Begin{758:}
      Begin
        x := cleanbox(q+2,2*(curstyle Div 4)+4+(
             curstyle Mod 2));
        mem[x+1].int := mem[x+1].int+eqtb[5842].int;
        If odd(curstyle)Then clr := fontinfo[15+parambase[eqtb[3937+cursize].hh.rh
                                    ]].int
        Else If curstyle<2 Then clr := fontinfo[13+parambase[eqtb[3937+
                                       cursize].hh.rh]].int
        Else clr := fontinfo[14+parambase[eqtb[3937+cursize].
                    hh.rh]].int;
        If shiftup<clr Then shiftup := clr;
        clr := mem[x+2].int+(abs(fontinfo[5+parambase[eqtb[3937+cursize].hh.rh]].
               int)Div 4);
        If shiftup<clr Then shiftup := clr;
      End{:758};
      If mem[q+3].hh.rh=0 Then mem[x+4].int := -shiftup
      Else{759:}
        Begin
          y := 
               cleanbox(q+3,2*(curstyle Div 4)+5);
          mem[y+1].int := mem[y+1].int+eqtb[5842].int;
          If shiftdown<fontinfo[17+parambase[eqtb[3937+cursize].hh.rh]].int Then
            shiftdown := fontinfo[17+parambase[eqtb[3937+cursize].hh.rh]].int;
          clr := 4*fontinfo[8+parambase[eqtb[3938+cursize].hh.rh]].int-((shiftup-mem
                 [x+2].int)-(mem[y+3].int-shiftdown));
          If clr>0 Then
            Begin
              shiftdown := shiftdown+clr;
              clr := (abs(fontinfo[5+parambase[eqtb[3937+cursize].hh.rh]].int*4)Div 5)-(
                     shiftup-mem[x+2].int);
              If clr>0 Then
                Begin
                  shiftup := shiftup+clr;
                  shiftdown := shiftdown-clr;
                End;
            End;
          mem[x+4].int := delta;
          p := newkern((shiftup-mem[x+2].int)-(mem[y+3].int-shiftdown));
          mem[x].hh.rh := p;
          mem[p].hh.rh := y;
          x := vpackage(x,0,1,1073741823);
          mem[x+4].int := shiftdown;
        End{:759};
    End;
  If mem[q+1].int=0 Then mem[q+1].int := x
  Else
    Begin
      p := mem[q+1].int;
      While mem[p].hh.rh<>0 Do
        p := mem[p].hh.rh;
      mem[p].hh.rh := x;
    End;
End;
{:756}{762:}
Function makeleftright(q:halfword;style:smallnumber;
                       maxd,maxh:scaled): smallnumber;

Var delta,delta1,delta2: scaled;
Begin
  If style<4 Then cursize := 0
  Else cursize := 16*((style-2)Div 2);
  delta2 := maxd+fontinfo[22+parambase[eqtb[3937+cursize].hh.rh]].int;
  delta1 := maxh+maxd-delta2;
  If delta2>delta1 Then delta1 := delta2;
  delta := (delta1 Div 500)*eqtb[5281].int;
  delta2 := delta1+delta1-eqtb[5840].int;
  If delta<delta2 Then delta := delta2;
  mem[q+1].int := vardelimiter(q+1,cursize,delta);
  makeleftright := mem[q].hh.b0-(10);
End;{:762}
Procedure mlisttohlist;

Label 21,82,80,81,83,30;

Var mlist: halfword;
  penalties: boolean;
  style: smallnumber;
  savestyle: smallnumber;
  q: halfword;
  r: halfword;
  rtype: smallnumber;
  t: smallnumber;
  p,x,y,z: halfword;
  pen: integer;
  s: smallnumber;
  maxh,maxd: scaled;
  delta: scaled;
Begin
  mlist := curmlist;
  penalties := mlistpenalties;
  style := curstyle;
  q := mlist;
  r := 0;
  rtype := 17;
  maxh := 0;
  maxd := 0;
{703:}
  Begin
    If curstyle<4 Then cursize := 0
    Else cursize := 16*((curstyle-2)
                    Div 2);
    curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
  End{:703};
  While q<>0 Do{727:}
    Begin{728:}
      21: delta := 0;
      Case mem[q].hh.b0 Of 
        18: Case rtype Of 
              18,17,19,20,22,30:
                                 Begin
                                   mem[q].hh.
                                   b0 := 16;
                                   goto 21;
                                 End;
              Else
            End;
        19,21,22,31:
                     Begin{729:}
                       If rtype=18 Then mem[r].hh.b0 := 16{:729};
                       If mem[q].hh.b0=31 Then goto 80;
                     End;{733:}
        30: goto 80;
        25:
            Begin
              makefraction(q);
              goto 82;
            End;
        17:
            Begin
              delta := makeop(q);
              If mem[q].hh.b1=1 Then goto 82;
            End;
        16: makeord(q);
        20,23:;
        24: makeradical(q);
        27: makeover(q);
        26: makeunder(q);
        28: makemathaccent(q);
        29: makevcenter(q);{:733}{730:}
        14:
            Begin
              curstyle := mem[q].hh.b1;
{703:}
              Begin
                If curstyle<4 Then cursize := 0
                Else cursize := 16*((curstyle-2)
                                Div 2);
                curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
              End{:703};
              goto 81;
            End;
        15:{731:}
            Begin
              Case curstyle Div 2 Of 
                0:
                   Begin
                     p := mem[q+1].hh.lh;
                     mem[q+1].hh.lh := 0;
                   End;
                1:
                   Begin
                     p := mem[q+1].hh.rh;
                     mem[q+1].hh.rh := 0;
                   End;
                2:
                   Begin
                     p := mem[q+2].hh.lh;
                     mem[q+2].hh.lh := 0;
                   End;
                3:
                   Begin
                     p := mem[q+2].hh.rh;
                     mem[q+2].hh.rh := 0;
                   End;
              End;
              flushnodelist(mem[q+1].hh.lh);
              flushnodelist(mem[q+1].hh.rh);
              flushnodelist(mem[q+2].hh.lh);
              flushnodelist(mem[q+2].hh.rh);
              mem[q].hh.b0 := 14;
              mem[q].hh.b1 := curstyle;
              mem[q+1].int := 0;
              mem[q+2].int := 0;
              If p<>0 Then
                Begin
                  z := mem[q].hh.rh;
                  mem[q].hh.rh := p;
                  While mem[p].hh.rh<>0 Do
                    p := mem[p].hh.rh;
                  mem[p].hh.rh := z;
                End;
              goto 81;
            End{:731};
        3,4,5,8,12,7: goto 81;
        2:
           Begin
             If mem[q+3].int>maxh Then maxh := mem[q+3].int;
             If mem[q+2].int>maxd Then maxd := mem[q+2].int;
             goto 81;
           End;
        10:
            Begin{732:}
              If mem[q].hh.b1=99 Then
                Begin
                  x := mem[q+1].hh.lh;
                  y := mathglue(x,curmu);
                  deleteglueref(x);
                  mem[q+1].hh.lh := y;
                  mem[q].hh.b1 := 0;
                End
              Else If (cursize<>0)And(mem[q].hh.b1=98)Then
                     Begin
                       p := mem[q].hh.rh;
                       If p<>0 Then If (mem[p].hh.b0=10)Or(mem[p].hh.b0=11)Then
                                      Begin
                                        mem[q].hh.
                                        rh := mem[p].hh.rh;
                                        mem[p].hh.rh := 0;
                                        flushnodelist(p);
                                      End;
                     End{:732};
              goto 81;
            End;
        11:
            Begin
              mathkern(q,curmu);
              goto 81;
            End;{:730}
        Else confusion(890)
      End;
{754:}
      Case mem[q+1].hh.rh Of 
        1,4:{755:}
             Begin
               fetch(q+1);
               If (curi.b0>0)Then
                 Begin
                   delta := fontinfo[italicbase[curf]+(curi.b2)Div 4]
                            .int;
                   p := newcharacter(curf,curc);
                   If (mem[q+1].hh.rh=4)And(fontinfo[2+parambase[curf]].int<>0)Then delta := 0
                   ;
                   If (mem[q+3].hh.rh=0)And(delta<>0)Then
                     Begin
                       mem[p].hh.rh := newkern(delta)
                       ;
                       delta := 0;
                     End;
                 End
               Else p := 0;
             End{:755};
        0: p := 0;
        2: p := mem[q+1].hh.lh;
        3:
           Begin
             curmlist := mem[q+1].hh.lh;
             savestyle := curstyle;
             mlistpenalties := false;
             mlisttohlist;
             curstyle := savestyle;
{703:}
             Begin
               If curstyle<4 Then cursize := 0
               Else cursize := 16*((curstyle-2)
                               Div 2);
               curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
             End{:703};
             p := hpack(mem[29997].hh.rh,0,1);
           End;
        Else confusion(891)
      End;
      mem[q+1].int := p;
      If (mem[q+3].hh.rh=0)And(mem[q+2].hh.rh=0)Then goto 82;
      makescripts(q,delta){:754}{:728};
      82: z := hpack(mem[q+1].int,0,1);
      If mem[z+3].int>maxh Then maxh := mem[z+3].int;
      If mem[z+2].int>maxd Then maxd := mem[z+2].int;
      freenode(z,7);
      80: r := q;
      rtype := mem[r].hh.b0;
      81: q := mem[q].hh.rh;
    End{:727};
{729:}
  If rtype=18 Then mem[r].hh.b0 := 16{:729};{760:}
  p := 29997;
  mem[p].hh.rh := 0;
  q := mlist;
  rtype := 0;
  curstyle := style;
{703:}
  Begin
    If curstyle<4 Then cursize := 0
    Else cursize := 16*((curstyle-2)
                    Div 2);
    curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
  End{:703};
  While q<>0 Do
    Begin{761:}
      t := 16;
      s := 4;
      pen := 10000;
      Case mem[q].hh.b0 Of 
        17,20,21,22,23: t := mem[q].hh.b0;
        18:
            Begin
              t := 18;
              pen := eqtb[5272].int;
            End;
        19:
            Begin
              t := 19;
              pen := eqtb[5273].int;
            End;
        16,29,27,26:;
        24: s := 5;
        28: s := 5;
        25: s := 6;
        30,31: t := makeleftright(q,style,maxd,maxh);
        14:{763:}
            Begin
              curstyle := mem[q].hh.b1;
              s := 3;
{703:}
              Begin
                If curstyle<4 Then cursize := 0
                Else cursize := 16*((curstyle-2)
                                Div 2);
                curmu := xovern(fontinfo[6+parambase[eqtb[3937+cursize].hh.rh]].int,18);
              End{:703};
              goto 83;
            End{:763};
        8,12,2,7,5,3,4,10,11:
                              Begin
                                mem[p].hh.rh := q;
                                p := q;
                                q := mem[q].hh.rh;
                                mem[p].hh.rh := 0;
                                goto 30;
                              End;
        Else confusion(892)
      End{:761};
{766:}
      If rtype>0 Then
        Begin
          Case strpool[rtype*8+t+magicoffset] Of 
            48: x := 
                     0;
            49: If curstyle<4 Then x := 15
                Else x := 0;
            50: x := 15;
            51: If curstyle<4 Then x := 16
                Else x := 0;
            52: If curstyle<4 Then x := 17
                Else x := 0;
            Else confusion(894)
          End;
          If x<>0 Then
            Begin
              y := mathglue(eqtb[2882+x].hh.rh,curmu);
              z := newglue(y);
              mem[y].hh.rh := 0;
              mem[p].hh.rh := z;
              p := z;
              mem[z].hh.b1 := x+1;
            End;
        End{:766};
{767:}
      If mem[q+1].int<>0 Then
        Begin
          mem[p].hh.rh := mem[q+1].int;
          Repeat
            p := mem[p].hh.rh;
          Until mem[p].hh.rh=0;
        End;
      If penalties Then If mem[q].hh.rh<>0 Then If pen<10000 Then
                                                  Begin
                                                    rtype 
                                                    := mem[mem[q].hh.rh].hh.b0;
                                                    If rtype<>12 Then If rtype<>19 Then
                                                                        Begin
                                                                          z := newpenalty(pen);
                                                                          mem[p].hh.rh := z;
                                                                          p := z;
                                                                        End;
                                                  End{:767};
      rtype := t;
      83: r := q;
      q := mem[q].hh.rh;
      freenode(r,s);
      30:
    End{:760};
End;{:726}{772:}
Procedure pushalignment;

Var p: halfword;
Begin
  p := getnode(5);
  mem[p].hh.rh := alignptr;
  mem[p].hh.lh := curalign;
  mem[p+1].hh.lh := mem[29992].hh.rh;
  mem[p+1].hh.rh := curspan;
  mem[p+2].int := curloop;
  mem[p+3].int := alignstate;
  mem[p+4].hh.lh := curhead;
  mem[p+4].hh.rh := curtail;
  alignptr := p;
  curhead := getavail;
End;
Procedure popalignment;

Var p: halfword;
Begin
  Begin
    mem[curhead].hh.rh := avail;
    avail := curhead;
    dynused := dynused-1;
  End;
  p := alignptr;
  curtail := mem[p+4].hh.rh;
  curhead := mem[p+4].hh.lh;
  alignstate := mem[p+3].int;
  curloop := mem[p+2].int;
  curspan := mem[p+1].hh.rh;
  mem[29992].hh.rh := mem[p+1].hh.lh;
  curalign := mem[p].hh.lh;
  alignptr := mem[p].hh.rh;
  freenode(p,5);
End;
{:772}{774:}{782:}
Procedure getpreambletoken;

Label 20;
Begin
  20: gettoken;
  While (curchr=256)And(curcmd=4) Do
    Begin
      gettoken;
      If curcmd>100 Then
        Begin
          expand;
          gettoken;
        End;
    End;
  If curcmd=9 Then fatalerror(595);
  If (curcmd=75)And(curchr=2893)Then
    Begin
      scanoptionalequals;
      scanglue(2);
      If eqtb[5306].int>0 Then geqdefine(2893,117,curval)
      Else eqdefine(2893,
                    117,curval);
      goto 20;
    End;
End;{:782}
Procedure alignpeek;
forward;
Procedure normalparagraph;
forward;
Procedure initalign;

Label 30,31,32,22;

Var savecsptr: halfword;
  p: halfword;
Begin
  savecsptr := curcs;
  pushalignment;
  alignstate := -1000000;
{776:}
  If (curlist.modefield=203)And((curlist.tailfield<>curlist.headfield
     )Or(curlist.auxfield.int<>0))Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(680);
      End;
      printesc(520);
      print(895);
      Begin
        helpptr := 3;
        helpline[2] := 896;
        helpline[1] := 897;
        helpline[0] := 898;
      End;
      error;
      flushmath;
    End{:776};
  pushnest;
{775:}
  If curlist.modefield=203 Then
    Begin
      curlist.modefield := -1;
      curlist.auxfield.int := nest[nestptr-2].auxfield.int;
    End
  Else If curlist.modefield>0 Then curlist.modefield := -curlist.
                                                        modefield{:775};
  scanspec(6,false);{777:}
  mem[29992].hh.rh := 0;
  curalign := 29992;
  curloop := 0;
  scannerstatus := 4;
  warningindex := savecsptr;
  alignstate := -1000000;
  While true Do
    Begin{778:}
      mem[curalign].hh.rh := newparamglue(11);
      curalign := mem[curalign].hh.rh{:778};
      If curcmd=5 Then goto 30;
{779:}{783:}
      p := 29996;
      mem[p].hh.rh := 0;
      While true Do
        Begin
          getpreambletoken;
          If curcmd=6 Then goto 31;
          If (curcmd<=5)And(curcmd>=4)And(alignstate=-1000000)Then If (p=29996)And(
                                                                      curloop=0)And(curcmd=4)Then
                                                                     curloop := curalign
          Else
            Begin
              Begin
                If 
                   interaction=3 Then;
                printnl(262);
                print(904);
              End;
              Begin
                helpptr := 3;
                helpline[2] := 905;
                helpline[1] := 906;
                helpline[0] := 907;
              End;
              backerror;
              goto 31;
            End
          Else If (curcmd<>10)Or(p<>29996)Then
                 Begin
                   mem[p].hh.rh := getavail;
                   p := mem[p].hh.rh;
                   mem[p].hh.lh := curtok;
                 End;
        End;
      31:{:783};
      mem[curalign].hh.rh := newnullbox;
      curalign := mem[curalign].hh.rh;
      mem[curalign].hh.lh := 29991;
      mem[curalign+1].int := -1073741824;
      mem[curalign+3].int := mem[29996].hh.rh;{784:}
      p := 29996;
      mem[p].hh.rh := 0;
      While true Do
        Begin
          22: getpreambletoken;
          If (curcmd<=5)And(curcmd>=4)And(alignstate=-1000000)Then goto 32;
          If curcmd=6 Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(908);
              End;
              Begin
                helpptr := 3;
                helpline[2] := 905;
                helpline[1] := 906;
                helpline[0] := 909;
              End;
              error;
              goto 22;
            End;
          mem[p].hh.rh := getavail;
          p := mem[p].hh.rh;
          mem[p].hh.lh := curtok;
        End;
      32: mem[p].hh.rh := getavail;
      p := mem[p].hh.rh;
      mem[p].hh.lh := 6714{:784};
      mem[curalign+2].int := mem[29996].hh.rh{:779};
    End;
  30: scannerstatus := 0{:777};
  newsavelevel(6);
  If eqtb[3420].hh.rh<>0 Then begintokenlist(eqtb[3420].hh.rh,13);
  alignpeek;
End;{:774}{786:}{787:}
Procedure initspan(p:halfword);
Begin
  pushnest;
  If curlist.modefield=-102 Then curlist.auxfield.hh.lh := 1000
  Else
    Begin
      curlist.auxfield.int := -65536000;
      normalparagraph;
    End;
  curspan := p;
End;
{:787}
Procedure initrow;
Begin
  pushnest;
  curlist.modefield := (-103)-curlist.modefield;
  If curlist.modefield=-102 Then curlist.auxfield.hh.lh := 0
  Else curlist.
    auxfield.int := 0;
  Begin
    mem[curlist.tailfield].hh.rh := newglue(mem[mem[29992].hh.rh+1].hh.
                                    lh);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  mem[curlist.tailfield].hh.b1 := 12;
  curalign := mem[mem[29992].hh.rh].hh.rh;
  curtail := curhead;
  initspan(curalign);
End;{:786}{788:}
Procedure initcol;
Begin
  mem[curalign+5].hh.lh := curcmd;
  If curcmd=63 Then alignstate := 0
  Else
    Begin
      backinput;
      begintokenlist(mem[curalign+3].int,1);
    End;
End;
{:788}{791:}
Function fincol: boolean;

Label 10;

Var p: halfword;
  q,r: halfword;
  s: halfword;
  u: halfword;
  w: scaled;
  o: glueord;
  n: halfword;
Begin
  If curalign=0 Then confusion(910);
  q := mem[curalign].hh.rh;
  If q=0 Then confusion(910);
  If alignstate<500000 Then fatalerror(595);
  p := mem[q].hh.rh;
{792:}
  If (p=0)And(mem[curalign+5].hh.lh<257)Then If curloop<>0 Then{793:}
                                               Begin
                                                 mem[q].hh.rh := newnullbox;
                                                 p := mem[q].hh.rh;
                                                 mem[p].hh.lh := 29991;
                                                 mem[p+1].int := -1073741824;
                                                 curloop := mem[curloop].hh.rh;{794:}
                                                 q := 29996;
                                                 r := mem[curloop+3].int;
                                                 While r<>0 Do
                                                   Begin
                                                     mem[q].hh.rh := getavail;
                                                     q := mem[q].hh.rh;
                                                     mem[q].hh.lh := mem[r].hh.lh;
                                                     r := mem[r].hh.rh;
                                                   End;
                                                 mem[q].hh.rh := 0;
                                                 mem[p+3].int := mem[29996].hh.rh;
                                                 q := 29996;
                                                 r := mem[curloop+2].int;
                                                 While r<>0 Do
                                                   Begin
                                                     mem[q].hh.rh := getavail;
                                                     q := mem[q].hh.rh;
                                                     mem[q].hh.lh := mem[r].hh.lh;
                                                     r := mem[r].hh.rh;
                                                   End;
                                                 mem[q].hh.rh := 0;
                                                 mem[p+2].int := mem[29996].hh.rh{:794};
                                                 curloop := mem[curloop].hh.rh;
                                                 mem[p].hh.rh := newglue(mem[curloop+1].hh.lh);
                                                 mem[mem[p].hh.rh].hh.b1 := 12;
                                               End{:793}
  Else
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(911);
      End;
      printesc(900);
      Begin
        helpptr := 3;
        helpline[2] := 912;
        helpline[1] := 913;
        helpline[0] := 914;
      End;
      mem[curalign+5].hh.lh := 257;
      error;
    End{:792};
  If mem[curalign+5].hh.lh<>256 Then
    Begin
      unsave;
      newsavelevel(6);
{796:}
      Begin
        If curlist.modefield=-102 Then
          Begin
            adjusttail := curtail;
            u := hpack(mem[curlist.headfield].hh.rh,0,1);
            w := mem[u+1].int;
            curtail := adjusttail;
            adjusttail := 0;
          End
        Else
          Begin
            u := vpackage(mem[curlist.headfield].hh.rh,0,1,0);
            w := mem[u+3].int;
          End;
        n := 0;
        If curspan<>curalign Then{798:}
          Begin
            q := curspan;
            Repeat
              n := n+1;
              q := mem[mem[q].hh.rh].hh.rh;
            Until q=curalign;
            If n>255 Then confusion(915);
            q := curspan;
            While mem[mem[q].hh.lh].hh.rh<n Do
              q := mem[q].hh.lh;
            If mem[mem[q].hh.lh].hh.rh>n Then
              Begin
                s := getnode(2);
                mem[s].hh.lh := mem[q].hh.lh;
                mem[s].hh.rh := n;
                mem[q].hh.lh := s;
                mem[s+1].int := w;
              End
            Else If mem[mem[q].hh.lh+1].int<w Then mem[mem[q].hh.lh+1].int := w;
          End{:798}
        Else If w>mem[curalign+1].int Then mem[curalign+1].int := w;
        mem[u].hh.b0 := 13;
        mem[u].hh.b1 := n;
{659:}
        If totalstretch[3]<>0 Then o := 3
        Else If totalstretch[2]<>0 Then o 
               := 2
        Else If totalstretch[1]<>0 Then o := 1
        Else o := 0{:659};
        mem[u+5].hh.b1 := o;
        mem[u+6].int := totalstretch[o];
{665:}
        If totalshrink[3]<>0 Then o := 3
        Else If totalshrink[2]<>0 Then o := 2
        Else If totalshrink[1]<>0 Then o := 1
        Else o := 0{:665};
        mem[u+5].hh.b0 := o;
        mem[u+4].int := totalshrink[o];
        popnest;
        mem[curlist.tailfield].hh.rh := u;
        curlist.tailfield := u;
      End{:796};
{795:}
      Begin
        mem[curlist.tailfield].hh.rh := newglue(mem[mem[curalign].hh.
                                        rh+1].hh.lh);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      mem[curlist.tailfield].hh.b1 := 12{:795};
      If mem[curalign+5].hh.lh>=257 Then
        Begin
          fincol := true;
          goto 10;
        End;
      initspan(p);
    End;
  alignstate := 1000000;{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  curalign := p;
  initcol;
  fincol := false;
  10:
End;
{:791}{799:}
Procedure finrow;

Var p: halfword;
Begin
  If curlist.modefield=-102 Then
    Begin
      p := hpack(mem[curlist.
           headfield].hh.rh,0,1);
      popnest;
      appendtovlist(p);
      If curhead<>curtail Then
        Begin
          mem[curlist.tailfield].hh.rh := mem[curhead
                                          ].hh.rh;
          curlist.tailfield := curtail;
        End;
    End
  Else
    Begin
      p := vpackage(mem[curlist.headfield].hh.rh,0,1,1073741823);
      popnest;
      mem[curlist.tailfield].hh.rh := p;
      curlist.tailfield := p;
      curlist.auxfield.hh.lh := 1000;
    End;
  mem[p].hh.b0 := 13;
  mem[p+6].int := 0;
  If eqtb[3420].hh.rh<>0 Then begintokenlist(eqtb[3420].hh.rh,13);
  alignpeek;
End;{:799}{800:}
Procedure doassignments;
forward;
Procedure resumeafterdisplay;
forward;
Procedure buildpage;
forward;
Procedure finalign;

Var p,q,r,s,u,v: halfword;
  t,w: scaled;
  o: scaled;
  n: halfword;
  rulesave: scaled;
  auxsave: memoryword;
Begin
  If curgroup<>6 Then confusion(916);
  unsave;
  If curgroup<>6 Then confusion(917);
  unsave;
  If nest[nestptr-1].modefield=203 Then o := eqtb[5845].int
  Else o := 0;
{801:}
  q := mem[mem[29992].hh.rh].hh.rh;
  Repeat
    flushlist(mem[q+3].int);
    flushlist(mem[q+2].int);
    p := mem[mem[q].hh.rh].hh.rh;
    If mem[q+1].int=-1073741824 Then{802:}
      Begin
        mem[q+1].int := 0;
        r := mem[q].hh.rh;
        s := mem[r+1].hh.lh;
        If s<>0 Then
          Begin
            mem[0].hh.rh := mem[0].hh.rh+1;
            deleteglueref(s);
            mem[r+1].hh.lh := 0;
          End;
      End{:802};
    If mem[q].hh.lh<>29991 Then{803:}
      Begin
        t := mem[q+1].int+mem[mem[mem[q].hh
             .rh+1].hh.lh+1].int;
        r := mem[q].hh.lh;
        s := 29991;
        mem[s].hh.lh := p;
        n := 1;
        Repeat
          mem[r+1].int := mem[r+1].int-t;
          u := mem[r].hh.lh;
          While mem[r].hh.rh>n Do
            Begin
              s := mem[s].hh.lh;
              n := mem[mem[s].hh.lh].hh.rh+1;
            End;
          If mem[r].hh.rh<n Then
            Begin
              mem[r].hh.lh := mem[s].hh.lh;
              mem[s].hh.lh := r;
              mem[r].hh.rh := mem[r].hh.rh-1;
              s := r;
            End
          Else
            Begin
              If mem[r+1].int>mem[mem[s].hh.lh+1].int Then mem[mem[s].
                hh.lh+1].int := mem[r+1].int;
              freenode(r,2);
            End;
          r := u;
        Until r=29991;
      End{:803};
    mem[q].hh.b0 := 13;
    mem[q].hh.b1 := 0;
    mem[q+3].int := 0;
    mem[q+2].int := 0;
    mem[q+5].hh.b1 := 0;
    mem[q+5].hh.b0 := 0;
    mem[q+6].int := 0;
    mem[q+4].int := 0;
    q := p;
  Until q=0{:801};{804:}
  saveptr := saveptr-2;
  packbeginline := -curlist.mlfield;
  If curlist.modefield=-1 Then
    Begin
      rulesave := eqtb[5846].int;
      eqtb[5846].int := 0;
      p := hpack(mem[29992].hh.rh,savestack[saveptr+1].int,savestack[saveptr+0].
           int);
      eqtb[5846].int := rulesave;
    End
  Else
    Begin
      q := mem[mem[29992].hh.rh].hh.rh;
      Repeat
        mem[q+3].int := mem[q+1].int;
        mem[q+1].int := 0;
        q := mem[mem[q].hh.rh].hh.rh;
      Until q=0;
      p := vpackage(mem[29992].hh.rh,savestack[saveptr+1].int,savestack[saveptr
           +0].int,1073741823);
      q := mem[mem[29992].hh.rh].hh.rh;
      Repeat
        mem[q+1].int := mem[q+3].int;
        mem[q+3].int := 0;
        q := mem[mem[q].hh.rh].hh.rh;
      Until q=0;
    End;
  packbeginline := 0{:804};
{805:}
  q := mem[curlist.headfield].hh.rh;
  s := curlist.headfield;
  While q<>0 Do
    Begin
      If Not(q>=himemmin)Then If mem[q].hh.b0=13 Then
{807:}
                                Begin
                                  If curlist.modefield=-1 Then
                                    Begin
                                      mem[q].hh.b0 := 0;
                                      mem[q+1].int := mem[p+1].int;
                                    End
                                  Else
                                    Begin
                                      mem[q].hh.b0 := 1;
                                      mem[q+3].int := mem[p+3].int;
                                    End;
                                  mem[q+5].hh.b1 := mem[p+5].hh.b1;
                                  mem[q+5].hh.b0 := mem[p+5].hh.b0;
                                  mem[q+6].gr := mem[p+6].gr;
                                  mem[q+4].int := o;
                                  r := mem[mem[q+5].hh.rh].hh.rh;
                                  s := mem[mem[p+5].hh.rh].hh.rh;
                                  Repeat{808:}
                                    n := mem[r].hh.b1;
                                    t := mem[s+1].int;
                                    w := t;
                                    u := 29996;
                                    While n>0 Do
                                      Begin
                                        n := n-1;{809:}
                                        s := mem[s].hh.rh;
                                        v := mem[s+1].hh.lh;
                                        mem[u].hh.rh := newglue(v);
                                        u := mem[u].hh.rh;
                                        mem[u].hh.b1 := 12;
                                        t := t+mem[v+1].int;
                                        If mem[p+5].hh.b0=1 Then
                                          Begin
                                            If mem[v].hh.b0=mem[p+5].hh.b1 Then t := t+
                                                                                     round(mem[p+6].
                                                                                     gr*mem[v+2].int
                                                                                     );
                                          End
                                        Else If mem[p+5].hh.b0=2 Then
                                               Begin
                                                 If mem[v].hh.b1=mem[p+5].hh.b1
                                                   Then t := t-round(mem[p+6].gr*mem[v+3].int);
                                               End;
                                        s := mem[s].hh.rh;
                                        mem[u].hh.rh := newnullbox;
                                        u := mem[u].hh.rh;
                                        t := t+mem[s+1].int;
                                        If curlist.modefield=-1 Then mem[u+1].int := mem[s+1].int
                                        Else
                                          Begin
                                            mem[u
                                            ].hh.b0 := 1;
                                            mem[u+3].int := mem[s+1].int;
                                          End{:809};
                                      End;
                                    If curlist.modefield=-1 Then{810:}
                                      Begin
                                        mem[r+3].int := mem[q+3].int;
                                        mem[r+2].int := mem[q+2].int;
                                        If t=mem[r+1].int Then
                                          Begin
                                            mem[r+5].hh.b0 := 0;
                                            mem[r+5].hh.b1 := 0;
                                            mem[r+6].gr := 0.0;
                                          End
                                        Else If t>mem[r+1].int Then
                                               Begin
                                                 mem[r+5].hh.b0 := 1;
                                                 If mem[r+6].int=0 Then mem[r+6].gr := 0.0
                                                 Else mem[r+6].gr := (t-mem[r+1].
                                                                     int)/mem[r+6].int;
                                               End
                                        Else
                                          Begin
                                            mem[r+5].hh.b1 := mem[r+5].hh.b0;
                                            mem[r+5].hh.b0 := 2;
                                            If mem[r+4].int=0 Then mem[r+6].gr := 0.0
                                            Else If (mem[r+5].hh.b1=0)And(mem
                                                    [r+1].int-t>mem[r+4].int)Then mem[r+6].gr := 1.0
                                            Else mem[r+6].gr := (mem[r
                                                                +1].int-t)/mem[r+4].int;
                                          End;
                                        mem[r+1].int := w;
                                        mem[r].hh.b0 := 0;
                                      End{:810}
                                    Else{811:}
                                      Begin
                                        mem[r+1].int := mem[q+1].int;
                                        If t=mem[r+3].int Then
                                          Begin
                                            mem[r+5].hh.b0 := 0;
                                            mem[r+5].hh.b1 := 0;
                                            mem[r+6].gr := 0.0;
                                          End
                                        Else If t>mem[r+3].int Then
                                               Begin
                                                 mem[r+5].hh.b0 := 1;
                                                 If mem[r+6].int=0 Then mem[r+6].gr := 0.0
                                                 Else mem[r+6].gr := (t-mem[r+3].
                                                                     int)/mem[r+6].int;
                                               End
                                        Else
                                          Begin
                                            mem[r+5].hh.b1 := mem[r+5].hh.b0;
                                            mem[r+5].hh.b0 := 2;
                                            If mem[r+4].int=0 Then mem[r+6].gr := 0.0
                                            Else If (mem[r+5].hh.b1=0)And(mem
                                                    [r+3].int-t>mem[r+4].int)Then mem[r+6].gr := 1.0
                                            Else mem[r+6].gr := (mem[r
                                                                +3].int-t)/mem[r+4].int;
                                          End;
                                        mem[r+3].int := w;
                                        mem[r].hh.b0 := 1;
                                      End{:811};
                                    mem[r+4].int := 0;
                                    If u<>29996 Then
                                      Begin
                                        mem[u].hh.rh := mem[r].hh.rh;
                                        mem[r].hh.rh := mem[29996].hh.rh;
                                        r := u;
                                      End{:808};
                                    r := mem[mem[r].hh.rh].hh.rh;
                                    s := mem[mem[s].hh.rh].hh.rh;
                                  Until r=0;
                                End{:807}
      Else If mem[q].hh.b0=2 Then{806:}
             Begin
               If (mem[q+1].int=
                  -1073741824)Then mem[q+1].int := mem[p+1].int;
               If (mem[q+3].int=-1073741824)Then mem[q+3].int := mem[p+3].int;
               If (mem[q+2].int=-1073741824)Then mem[q+2].int := mem[p+2].int;
               If o<>0 Then
                 Begin
                   r := mem[q].hh.rh;
                   mem[q].hh.rh := 0;
                   q := hpack(q,0,1);
                   mem[q+4].int := o;
                   mem[q].hh.rh := r;
                   mem[s].hh.rh := q;
                 End;
             End{:806};
      s := q;
      q := mem[q].hh.rh;
    End{:805};
  flushnodelist(p);
  popalignment;
{812:}
  auxsave := curlist.auxfield;
  p := mem[curlist.headfield].hh.rh;
  q := curlist.tailfield;
  popnest;
  If curlist.modefield=203 Then{1206:}
    Begin
      doassignments;
      If curcmd<>3 Then{1207:}
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(1171);
          End;
          Begin
            helpptr := 2;
            helpline[1] := 896;
            helpline[0] := 897;
          End;
          backerror;
        End{:1207}
      Else{1197:}
        Begin
          getxtoken;
          If curcmd<>3 Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1167);
              End;
              Begin
                helpptr := 2;
                helpline[1] := 1168;
                helpline[0] := 1169;
              End;
              backerror;
            End;
        End{:1197};
      popnest;
      Begin
        mem[curlist.tailfield].hh.rh := newpenalty(eqtb[5274].int);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      Begin
        mem[curlist.tailfield].hh.rh := newparamglue(3);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      mem[curlist.tailfield].hh.rh := p;
      If p<>0 Then curlist.tailfield := q;
      Begin
        mem[curlist.tailfield].hh.rh := newpenalty(eqtb[5275].int);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      Begin
        mem[curlist.tailfield].hh.rh := newparamglue(4);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      curlist.auxfield.int := auxsave.int;
      resumeafterdisplay;
    End{:1206}
  Else
    Begin
      curlist.auxfield := auxsave;
      mem[curlist.tailfield].hh.rh := p;
      If p<>0 Then curlist.tailfield := q;
      If curlist.modefield=1 Then buildpage;
    End{:812};
End;
{785:}
Procedure alignpeek;

Label 20;
Begin
  20: alignstate := 1000000;
{406:}
  Repeat
    getxtoken;
  Until curcmd<>10{:406};
  If curcmd=34 Then
    Begin
      scanleftbrace;
      newsavelevel(7);
      If curlist.modefield=-1 Then normalparagraph;
    End
  Else If curcmd=2 Then finalign
  Else If (curcmd=5)And(curchr=258)Then
         goto 20
  Else
    Begin
      initrow;
      initcol;
    End;
End;
{:785}{:800}{815:}{826:}
Function finiteshrink(p:halfword): halfword;

Var q: halfword;
Begin
  If noshrinkerroryet Then
    Begin
      noshrinkerroryet := false;
      If eqtb[5295].int>0 Then enddiagnostic(true);
      Begin
        If interaction=3 Then;
        printnl(262);
        print(918);
      End;
      Begin
        helpptr := 5;
        helpline[4] := 919;
        helpline[3] := 920;
        helpline[2] := 921;
        helpline[1] := 922;
        helpline[0] := 923;
      End;
      error;
      If eqtb[5295].int>0 Then begindiagnostic;
    End;
  q := newspec(p);
  mem[q].hh.b1 := 0;
  deleteglueref(p);
  finiteshrink := q;
End;
{:826}{829:}
Procedure trybreak(pi:integer;breaktype:smallnumber);

Label 10,30,31,22,60;

Var r: halfword;
  prevr: halfword;
  oldl: halfword;
  nobreakyet: boolean;{830:}
  prevprevr: halfword;
  s: halfword;
  q: halfword;
  v: halfword;
  t: integer;
  f: internalfontnumber;
  l: halfword;
  noderstaysactive: boolean;
  linewidth: scaled;
  fitclass: 0..3;
  b: halfword;
  d: integer;
  artificialdemerits: boolean;
  savelink: halfword;
  shortfall: scaled;
{:830}
Begin{831:}
  If abs(pi)>=10000 Then If pi>0 Then goto 10
  Else pi := 
             -10000{:831};
  nobreakyet := true;
  prevr := 29993;
  oldl := 0;
  curactivewidth[1] := activewidth[1];
  curactivewidth[2] := activewidth[2];
  curactivewidth[3] := activewidth[3];
  curactivewidth[4] := activewidth[4];
  curactivewidth[5] := activewidth[5];
  curactivewidth[6] := activewidth[6];
  While true Do
    Begin
      22: r := mem[prevr].hh.rh;
{832:}
      If mem[r].hh.b0=2 Then
        Begin
          curactivewidth[1] := curactivewidth[1]+
                               mem[r+1].int;
          curactivewidth[2] := curactivewidth[2]+mem[r+2].int;
          curactivewidth[3] := curactivewidth[3]+mem[r+3].int;
          curactivewidth[4] := curactivewidth[4]+mem[r+4].int;
          curactivewidth[5] := curactivewidth[5]+mem[r+5].int;
          curactivewidth[6] := curactivewidth[6]+mem[r+6].int;
          prevprevr := prevr;
          prevr := r;
          goto 22;
        End{:832};{835:}
      Begin
        l := mem[r+1].hh.lh;
        If l>oldl Then
          Begin
            If (minimumdemerits<1073741823)And((oldl<>easyline)
               Or(r=29993))Then{836:}
              Begin
                If nobreakyet Then{837:}
                  Begin
                    nobreakyet := 
                                  false;
                    breakwidth[1] := background[1];
                    breakwidth[2] := background[2];
                    breakwidth[3] := background[3];
                    breakwidth[4] := background[4];
                    breakwidth[5] := background[5];
                    breakwidth[6] := background[6];
                    s := curp;
                    If breaktype>0 Then If curp<>0 Then{840:}
                                          Begin
                                            t := mem[curp].hh.b1;
                                            v := curp;
                                            s := mem[curp+1].hh.rh;
                                            While t>0 Do
                                              Begin
                                                t := t-1;
                                                v := mem[v].hh.rh;
{841:}
                                                If (v>=himemmin)Then
                                                  Begin
                                                    f := mem[v].hh.b0;
                                                    breakwidth[1] := breakwidth[1]-fontinfo[
                                                                     widthbase[f]+fontinfo[charbase[
                                                                     f]+
                                                                     mem[v].hh.b1].qqqq.b0].int;
                                                  End
                                                Else Case mem[v].hh.b0 Of 
                                                       6:
                                                          Begin
                                                            f := mem[v+1].hh.b0;
                                                            breakwidth[1] := breakwidth[1]-fontinfo[
                                                                             widthbase[f]+fontinfo[
                                                                             charbase[f]+
                                                                             mem[v+1].hh.b1].qqqq.b0
                                                                             ].int;
                                                          End;
                                                       0,1,2,11: breakwidth[1] := breakwidth[1]-mem[
                                                                                  v+1].int;
                                                       Else confusion(924)
                                                  End{:841};
                                              End;
                                            While s<>0 Do
                                              Begin{842:}
                                                If (s>=himemmin)Then
                                                  Begin
                                                    f := mem[s].hh.b0;
                                                    breakwidth[1] := breakwidth[1]+fontinfo[
                                                                     widthbase[f]+fontinfo[charbase[
                                                                     f]+
                                                                     mem[s].hh.b1].qqqq.b0].int;
                                                  End
                                                Else Case mem[s].hh.b0 Of 
                                                       6:
                                                          Begin
                                                            f := mem[s+1].hh.b0;
                                                            breakwidth[1] := breakwidth[1]+fontinfo[
                                                                             widthbase[f]+fontinfo[
                                                                             charbase[f]+
                                                                             mem[s+1].hh.b1].qqqq.b0
                                                                             ].int;
                                                          End;
                                                       0,1,2,11: breakwidth[1] := breakwidth[1]+mem[
                                                                                  s+1].int;
                                                       Else confusion(925)
                                                  End{:842};
                                                s := mem[s].hh.rh;
                                              End;
                                            breakwidth[1] := breakwidth[1]+discwidth;
                                            If mem[curp+1].hh.rh=0 Then s := mem[v].hh.rh;
                                          End{:840};
                    While s<>0 Do
                      Begin
                        If (s>=himemmin)Then goto 30;
                        Case mem[s].hh.b0 Of 
                          10:{838:}
                              Begin
                                v := mem[s+1].hh.lh;
                                breakwidth[1] := breakwidth[1]-mem[v+1].int;
                                breakwidth[2+mem[v].hh.b0] := breakwidth[2+mem[v].hh.b0]-mem[v+2].
                                                              int;
                                breakwidth[6] := breakwidth[6]-mem[v+3].int;
                              End{:838};
                          12:;
                          9: breakwidth[1] := breakwidth[1]-mem[s+1].int;
                          11: If mem[s].hh.b1<>1 Then goto 30
                              Else breakwidth[1] := breakwidth[1]-mem
                                                    [s+1].int;
                          Else goto 30
                        End;
                        s := mem[s].hh.rh;
                      End;
                    30:
                  End{:837};
{843:}
                If mem[prevr].hh.b0=2 Then
                  Begin
                    mem[prevr+1].int := mem[prevr+1].
                                        int-curactivewidth[1]+breakwidth[1];
                    mem[prevr+2].int := mem[prevr+2].int-curactivewidth[2]+breakwidth[2];
                    mem[prevr+3].int := mem[prevr+3].int-curactivewidth[3]+breakwidth[3];
                    mem[prevr+4].int := mem[prevr+4].int-curactivewidth[4]+breakwidth[4];
                    mem[prevr+5].int := mem[prevr+5].int-curactivewidth[5]+breakwidth[5];
                    mem[prevr+6].int := mem[prevr+6].int-curactivewidth[6]+breakwidth[6];
                  End
                Else If prevr=29993 Then
                       Begin
                         activewidth[1] := breakwidth[1];
                         activewidth[2] := breakwidth[2];
                         activewidth[3] := breakwidth[3];
                         activewidth[4] := breakwidth[4];
                         activewidth[5] := breakwidth[5];
                         activewidth[6] := breakwidth[6];
                       End
                Else
                  Begin
                    q := getnode(7);
                    mem[q].hh.rh := r;
                    mem[q].hh.b0 := 2;
                    mem[q].hh.b1 := 0;
                    mem[q+1].int := breakwidth[1]-curactivewidth[1];
                    mem[q+2].int := breakwidth[2]-curactivewidth[2];
                    mem[q+3].int := breakwidth[3]-curactivewidth[3];
                    mem[q+4].int := breakwidth[4]-curactivewidth[4];
                    mem[q+5].int := breakwidth[5]-curactivewidth[5];
                    mem[q+6].int := breakwidth[6]-curactivewidth[6];
                    mem[prevr].hh.rh := q;
                    prevprevr := prevr;
                    prevr := q;
                  End{:843};
                If abs(eqtb[5279].int)>=1073741823-minimumdemerits Then minimumdemerits 
                  := 1073741822
                Else minimumdemerits := minimumdemerits+abs(eqtb[5279].int);
                For fitclass:=0 To 3 Do
                  Begin
                    If minimaldemerits[fitclass]<=
                       minimumdemerits Then{845:}
                      Begin
                        q := getnode(2);
                        mem[q].hh.rh := passive;
                        passive := q;
                        mem[q+1].hh.rh := curp;
                        passnumber := passnumber+1;
                        mem[q].hh.lh := passnumber;
                        mem[q+1].hh.lh := bestplace[fitclass];
                        q := getnode(3);
                        mem[q+1].hh.rh := passive;
                        mem[q+1].hh.lh := bestplline[fitclass]+1;
                        mem[q].hh.b1 := fitclass;
                        mem[q].hh.b0 := breaktype;
                        mem[q+2].int := minimaldemerits[fitclass];
                        mem[q].hh.rh := r;
                        mem[prevr].hh.rh := q;
                        prevr := q;
                        If eqtb[5295].int>0 Then{846:}
                          Begin
                            printnl(926);
                            printint(mem[passive].hh.lh);
                            print(927);
                            printint(mem[q+1].hh.lh-1);
                            printchar(46);
                            printint(fitclass);
                            If breaktype=1 Then printchar(45);
                            print(928);
                            printint(mem[q+2].int);
                            print(929);
                            If mem[passive+1].hh.lh=0 Then printchar(48)
                            Else printint(mem[mem[
                                          passive+1].hh.lh].hh.lh);
                          End{:846};
                      End{:845};
                    minimaldemerits[fitclass] := 1073741823;
                  End;
                minimumdemerits := 1073741823;
{844:}
                If r<>29993 Then
                  Begin
                    q := getnode(7);
                    mem[q].hh.rh := r;
                    mem[q].hh.b0 := 2;
                    mem[q].hh.b1 := 0;
                    mem[q+1].int := curactivewidth[1]-breakwidth[1];
                    mem[q+2].int := curactivewidth[2]-breakwidth[2];
                    mem[q+3].int := curactivewidth[3]-breakwidth[3];
                    mem[q+4].int := curactivewidth[4]-breakwidth[4];
                    mem[q+5].int := curactivewidth[5]-breakwidth[5];
                    mem[q+6].int := curactivewidth[6]-breakwidth[6];
                    mem[prevr].hh.rh := q;
                    prevprevr := prevr;
                    prevr := q;
                  End{:844};
              End{:836};
            If r=29993 Then goto 10;
{850:}
            If l>easyline Then
              Begin
                linewidth := secondwidth;
                oldl := 65534;
              End
            Else
              Begin
                oldl := l;
                If l>lastspecialline Then linewidth := secondwidth
                Else If eqtb[3412].hh.
                        rh=0 Then linewidth := firstwidth
                Else linewidth := mem[eqtb[3412].hh.rh+2*l
                                  ].int;
              End{:850};
          End;
      End{:835};{851:}
      Begin
        artificialdemerits := false;
        shortfall := linewidth-curactivewidth[1];
        If shortfall>0 Then{852:}If (curactivewidth[3]<>0)Or(curactivewidth[4]<>0
                                    )Or(curactivewidth[5]<>0)Then
                                   Begin
                                     b := 0;
                                     fitclass := 2;
                                   End
        Else
          Begin
            If shortfall>7230584 Then If curactivewidth[2]<1663497
                                        Then
                                        Begin
                                          b := 10000;
                                          fitclass := 0;
                                          goto 31;
                                        End;
            b := badness(shortfall,curactivewidth[2]);
            If b>12 Then If b>99 Then fitclass := 0
            Else fitclass := 1
            Else fitclass := 2;
            31:
          End{:852}
        Else{853:}
          Begin
            If -shortfall>curactivewidth[6]Then b := 10001
            Else b := badness(-shortfall,curactivewidth[6]);
            If b>12 Then fitclass := 3
            Else fitclass := 2;
          End{:853};
        If (b>10000)Or(pi=-10000)Then{854:}
          Begin
            If finalpass And(minimumdemerits
               =1073741823)And(mem[r].hh.rh=29993)And(prevr=29993)Then
              artificialdemerits := true
            Else If b>threshold Then goto 60;
            noderstaysactive := false;
          End{:854}
        Else
          Begin
            prevr := r;
            If b>threshold Then goto 22;
            noderstaysactive := true;
          End;
{855:}
        If artificialdemerits Then d := 0
        Else{859:}
          Begin
            d := eqtb[5265].int+
                 b;
            If abs(d)>=10000 Then d := 100000000
            Else d := d*d;
            If pi<>0 Then If pi>0 Then d := d+pi*pi
            Else If pi>-10000 Then d := d-pi*pi;
            If (breaktype=1)And(mem[r].hh.b0=1)Then If curp<>0 Then d := d+eqtb[5277].
                                                                         int
            Else d := d+eqtb[5278].int;
            If abs(fitclass-mem[r].hh.b1)>1 Then d := d+eqtb[5279].int;
          End{:859};
        If eqtb[5295].int>0 Then{856:}
          Begin
            If printednode<>curp Then{857:}
              Begin
                printnl(338);
                If curp=0 Then shortdisplay(mem[printednode].hh.rh)
                Else
                  Begin
                    savelink := 
                                mem[curp].hh.rh;
                    mem[curp].hh.rh := 0;
                    printnl(338);
                    shortdisplay(mem[printednode].hh.rh);
                    mem[curp].hh.rh := savelink;
                  End;
                printednode := curp;
              End{:857};
            printnl(64);
            If curp=0 Then printesc(597)
            Else If mem[curp].hh.b0<>10 Then
                   Begin
                     If 
                        mem[curp].hh.b0=12 Then printesc(531)
                     Else If mem[curp].hh.b0=7 Then
                            printesc(349)
                     Else If mem[curp].hh.b0=11 Then printesc(340)
                     Else printesc(
                                   343);
                   End;
            print(930);
            If mem[r+1].hh.rh=0 Then printchar(48)
            Else printint(mem[mem[r+1].hh.rh].
                          hh.lh);
            print(931);
            If b>10000 Then printchar(42)
            Else printint(b);
            print(932);
            printint(pi);
            print(933);
            If artificialdemerits Then printchar(42)
            Else printint(d);
          End{:856};
        d := d+mem[r+2].int;
        If d<=minimaldemerits[fitclass]Then
          Begin
            minimaldemerits[fitclass] := d;
            bestplace[fitclass] := mem[r+1].hh.rh;
            bestplline[fitclass] := l;
            If d<minimumdemerits Then minimumdemerits := d;
          End{:855};
        If noderstaysactive Then goto 22;
        60:{860:}mem[prevr].hh.rh := mem[r].hh.rh;
        freenode(r,3);
        If prevr=29993 Then{861:}
          Begin
            r := mem[29993].hh.rh;
            If mem[r].hh.b0=2 Then
              Begin
                activewidth[1] := activewidth[1]+mem[r+1].int
                ;
                activewidth[2] := activewidth[2]+mem[r+2].int;
                activewidth[3] := activewidth[3]+mem[r+3].int;
                activewidth[4] := activewidth[4]+mem[r+4].int;
                activewidth[5] := activewidth[5]+mem[r+5].int;
                activewidth[6] := activewidth[6]+mem[r+6].int;
                curactivewidth[1] := activewidth[1];
                curactivewidth[2] := activewidth[2];
                curactivewidth[3] := activewidth[3];
                curactivewidth[4] := activewidth[4];
                curactivewidth[5] := activewidth[5];
                curactivewidth[6] := activewidth[6];
                mem[29993].hh.rh := mem[r].hh.rh;
                freenode(r,7);
              End;
          End{:861}
        Else If mem[prevr].hh.b0=2 Then
               Begin
                 r := mem[prevr].hh.rh;
                 If r=29993 Then
                   Begin
                     curactivewidth[1] := curactivewidth[1]-mem[prevr+1].
                                          int;
                     curactivewidth[2] := curactivewidth[2]-mem[prevr+2].int;
                     curactivewidth[3] := curactivewidth[3]-mem[prevr+3].int;
                     curactivewidth[4] := curactivewidth[4]-mem[prevr+4].int;
                     curactivewidth[5] := curactivewidth[5]-mem[prevr+5].int;
                     curactivewidth[6] := curactivewidth[6]-mem[prevr+6].int;
                     mem[prevprevr].hh.rh := 29993;
                     freenode(prevr,7);
                     prevr := prevprevr;
                   End
                 Else If mem[r].hh.b0=2 Then
                        Begin
                          curactivewidth[1] := curactivewidth[
                                               1]+mem[r+1].int;
                          curactivewidth[2] := curactivewidth[2]+mem[r+2].int;
                          curactivewidth[3] := curactivewidth[3]+mem[r+3].int;
                          curactivewidth[4] := curactivewidth[4]+mem[r+4].int;
                          curactivewidth[5] := curactivewidth[5]+mem[r+5].int;
                          curactivewidth[6] := curactivewidth[6]+mem[r+6].int;
                          mem[prevr+1].int := mem[prevr+1].int+mem[r+1].int;
                          mem[prevr+2].int := mem[prevr+2].int+mem[r+2].int;
                          mem[prevr+3].int := mem[prevr+3].int+mem[r+3].int;
                          mem[prevr+4].int := mem[prevr+4].int+mem[r+4].int;
                          mem[prevr+5].int := mem[prevr+5].int+mem[r+5].int;
                          mem[prevr+6].int := mem[prevr+6].int+mem[r+6].int;
                          mem[prevr].hh.rh := mem[r].hh.rh;
                          freenode(r,7);
                        End;
               End{:860};
      End{:851};
    End;
  10:{858:}If curp=printednode Then If curp<>0 Then If mem[curp].hh.b0=7
                                                      Then
                                                      Begin
                                                        t := mem[curp].hh.b1;
                                                        While t>0 Do
                                                          Begin
                                                            t := t-1;
                                                            printednode := mem[printednode].hh.rh;
                                                          End;
                                                      End{:858}
End;
{:829}{877:}
Procedure postlinebreak(finalwidowpenalty:integer;
                        nonprunablep:halfword);

Label 30,31;

Var q,r,s: halfword;
  discbreak: boolean;
  postdiscbreak: boolean;
  curwidth: scaled;
  curindent: scaled;
  t: quarterword;
  pen: integer;
  curline: halfword;
Begin{878:}
  q := mem[bestbet+1].hh.rh;
  curp := 0;
  Repeat
    r := q;
    q := mem[q+1].hh.lh;
    mem[r+1].hh.lh := curp;
    curp := r;
  Until q=0{:878};
  curline := curlist.pgfield+1;
  Repeat{880:}{881:}
    q := mem[curp+1].hh.rh;
    discbreak := false;
    postdiscbreak := false;
    If q<>0 Then If mem[q].hh.b0=10 Then
                   Begin
                     deleteglueref(mem[q+1].hh.lh)
                     ;
                     mem[q+1].hh.lh := eqtb[2890].hh.rh;
                     mem[q].hh.b1 := 9;
                     mem[eqtb[2890].hh.rh].hh.rh := mem[eqtb[2890].hh.rh].hh.rh+1;
                     goto 30;
                   End
    Else
      Begin
        If mem[q].hh.b0=7 Then{882:}
          Begin
            t := mem[q].hh.b1;
{883:}
            If t=0 Then r := mem[q].hh.rh
            Else
              Begin
                r := q;
                While t>1 Do
                  Begin
                    r := mem[r].hh.rh;
                    t := t-1;
                  End;
                s := mem[r].hh.rh;
                r := mem[s].hh.rh;
                mem[s].hh.rh := 0;
                flushnodelist(mem[q].hh.rh);
                mem[q].hh.b1 := 0;
              End{:883};
            If mem[q+1].hh.rh<>0 Then{884:}
              Begin
                s := mem[q+1].hh.rh;
                While mem[s].hh.rh<>0 Do
                  s := mem[s].hh.rh;
                mem[s].hh.rh := r;
                r := mem[q+1].hh.rh;
                mem[q+1].hh.rh := 0;
                postdiscbreak := true;
              End{:884};
            If mem[q+1].hh.lh<>0 Then{885:}
              Begin
                s := mem[q+1].hh.lh;
                mem[q].hh.rh := s;
                While mem[s].hh.rh<>0 Do
                  s := mem[s].hh.rh;
                mem[q+1].hh.lh := 0;
                q := s;
              End{:885};
            mem[q].hh.rh := r;
            discbreak := true;
          End{:882}
        Else If (mem[q].hh.b0=9)Or(mem[q].hh.b0=11)Then mem[q+1].int := 0;
      End
    Else
      Begin
        q := 29997;
        While mem[q].hh.rh<>0 Do
          q := mem[q].hh.rh;
      End;
{886:}
    r := newparamglue(8);
    mem[r].hh.rh := mem[q].hh.rh;
    mem[q].hh.rh := r;
    q := r{:886};
    30:{:881};{887:}
    r := mem[q].hh.rh;
    mem[q].hh.rh := 0;
    q := mem[29997].hh.rh;
    mem[29997].hh.rh := r;
    If eqtb[2889].hh.rh<>0 Then
      Begin
        r := newparamglue(7);
        mem[r].hh.rh := q;
        q := r;
      End{:887};
{889:}
    If curline>lastspecialline Then
      Begin
        curwidth := secondwidth;
        curindent := secondindent;
      End
    Else If eqtb[3412].hh.rh=0 Then
           Begin
             curwidth := firstwidth;
             curindent := firstindent;
           End
    Else
      Begin
        curwidth := mem[eqtb[3412].hh.rh+2*curline].int;
        curindent := mem[eqtb[3412].hh.rh+2*curline-1].int;
      End;
    adjusttail := 29995;
    justbox := hpack(q,curwidth,0);
    mem[justbox+4].int := curindent{:889};
{888:}
    appendtovlist(justbox);
    If 29995<>adjusttail Then
      Begin
        mem[curlist.tailfield].hh.rh := mem[29995]
                                        .hh.rh;
        curlist.tailfield := adjusttail;
      End;
    adjusttail := 0{:888};
{890:}
    If curline+1<>bestline Then
      Begin
        pen := eqtb[5276].int;
        If curline=curlist.pgfield+1 Then pen := pen+eqtb[5268].int;
        If curline+2=bestline Then pen := pen+finalwidowpenalty;
        If discbreak Then pen := pen+eqtb[5271].int;
        If pen<>0 Then
          Begin
            r := newpenalty(pen);
            mem[curlist.tailfield].hh.rh := r;
            curlist.tailfield := r;
          End;
      End{:890}{:880};
    curline := curline+1;
    curp := mem[curp+1].hh.lh;
    If curp<>0 Then If Not postdiscbreak Then{879:}
                      Begin
                        r := 29997;
                        While true Do
                          Begin
                            q := mem[r].hh.rh;
                            If q=mem[curp+1].hh.rh Then goto 31;
                            If (q>=himemmin)Then goto 31;
                            If (mem[q].hh.b0<9)Then goto 31;
                            If q=nonprunablep Then goto 31;
                            If mem[q].hh.b0=11 Then If mem[q].hh.b1<>1 Then goto 31;
                            r := q;
                          End;
                        31: If r<>29997 Then
                              Begin
                                mem[r].hh.rh := 0;
                                flushnodelist(mem[29997].hh.rh);
                                mem[29997].hh.rh := q;
                              End;
                      End{:879};
  Until curp=0;
  If (curline<>bestline)Or(mem[29997].hh.rh<>0)Then confusion(940);
  curlist.pgfield := bestline-1;
End;
{:877}{895:}{906:}
Function reconstitute(j,n:smallnumber;
                      bchar,hchar:halfword): smallnumber;

Label 22,30;

Var p: halfword;
  t: halfword;
  q: fourquarters;
  currh: halfword;
  testchar: halfword;
  w: scaled;
  k: fontindex;
Begin
  hyphenpassed := 0;
  t := 29996;
  w := 0;
  mem[29996].hh.rh := 0;
{908:}
  curl := hu[j];
  curq := t;
  If j=0 Then
    Begin
      ligaturepresent := initlig;
      p := initlist;
      If ligaturepresent Then lfthit := initlft;
      While p>0 Do
        Begin
          Begin
            mem[t].hh.rh := getavail;
            t := mem[t].hh.rh;
            mem[t].hh.b0 := hf;
            mem[t].hh.b1 := mem[p].hh.b1;
          End;
          p := mem[p].hh.rh;
        End;
    End
  Else If curl<256 Then
         Begin
           mem[t].hh.rh := getavail;
           t := mem[t].hh.rh;
           mem[t].hh.b0 := hf;
           mem[t].hh.b1 := curl;
         End;
  ligstack := 0;
  Begin
    If j<n Then curr := hu[j+1]
    Else curr := bchar;
    If odd(hyf[j])Then currh := hchar
    Else currh := 256;
  End{:908};
  22:{909:}If curl=256 Then
             Begin
               k := bcharlabel[hf];
               If k=0 Then goto 30
               Else q := fontinfo[k].qqqq;
             End
      Else
        Begin
          q := fontinfo[charbase[hf]+curl].qqqq;
          If ((q.b2)Mod 4)<>1 Then goto 30;
          k := ligkernbase[hf]+q.b3;
          q := fontinfo[k].qqqq;
          If q.b0>128 Then
            Begin
              k := ligkernbase[hf]+256*q.b2+q.b3+32768-256*(128);
              q := fontinfo[k].qqqq;
            End;
        End;
  If currh<256 Then testchar := currh
  Else testchar := curr;
  While true Do
    Begin
      If q.b1=testchar Then If q.b0<=128 Then If currh<256
                                                Then
                                                Begin
                                                  hyphenpassed := j;
                                                  hchar := 256;
                                                  currh := 256;
                                                  goto 22;
                                                End
      Else
        Begin
          If hchar<256 Then If odd(hyf[j])Then
                              Begin
                                hyphenpassed := 
                                                j;
                                hchar := 256;
                              End;
          If q.b2<128 Then{911:}
            Begin
              If curl=256 Then lfthit := true;
              If j=n Then If ligstack=0 Then rthit := true;
              Begin
                If interrupt<>0 Then pauseforinstructions;
              End;
              Case q.b2 Of 
                1,5:
                     Begin
                       curl := q.b3;
                       ligaturepresent := true;
                     End;
                2,6:
                     Begin
                       curr := q.b3;
                       If ligstack>0 Then mem[ligstack].hh.b1 := curr
                       Else
                         Begin
                           ligstack := 
                                       newligitem(curr);
                           If j=n Then bchar := 256
                           Else
                             Begin
                               p := getavail;
                               mem[ligstack+1].hh.rh := p;
                               mem[p].hh.b1 := hu[j+1];
                               mem[p].hh.b0 := hf;
                             End;
                         End;
                     End;
                3:
                   Begin
                     curr := q.b3;
                     p := ligstack;
                     ligstack := newligitem(curr);
                     mem[ligstack].hh.rh := p;
                   End;
                7,11:
                      Begin
                        If ligaturepresent Then
                          Begin
                            p := newligature(hf,curl,mem[curq
                                 ].hh.rh);
                            If lfthit Then
                              Begin
                                mem[p].hh.b1 := 2;
                                lfthit := false;
                              End;
                            If false Then If ligstack=0 Then
                                            Begin
                                              mem[p].hh.b1 := mem[p].hh.b1+1;
                                              rthit := false;
                                            End;
                            mem[curq].hh.rh := p;
                            t := p;
                            ligaturepresent := false;
                          End;
                        curq := t;
                        curl := q.b3;
                        ligaturepresent := true;
                      End;
                Else
                  Begin
                    curl := q.b3;
                    ligaturepresent := true;
                    If ligstack>0 Then
                      Begin
                        If mem[ligstack+1].hh.rh>0 Then
                          Begin
                            mem[t].hh
                            .rh := mem[ligstack+1].hh.rh;
                            t := mem[t].hh.rh;
                            j := j+1;
                          End;
                        p := ligstack;
                        ligstack := mem[p].hh.rh;
                        freenode(p,2);
                        If ligstack=0 Then
                          Begin
                            If j<n Then curr := hu[j+1]
                            Else curr := bchar;
                            If odd(hyf[j])Then currh := hchar
                            Else currh := 256;
                          End
                        Else curr := mem[ligstack].hh.b1;
                      End
                    Else If j=n Then goto 30
                    Else
                      Begin
                        Begin
                          mem[t].hh.rh := getavail;
                          t := mem[t].hh.rh;
                          mem[t].hh.b0 := hf;
                          mem[t].hh.b1 := curr;
                        End;
                        j := j+1;
                        Begin
                          If j<n Then curr := hu[j+1]
                          Else curr := bchar;
                          If odd(hyf[j])Then currh := hchar
                          Else currh := 256;
                        End;
                      End;
                  End
              End;
              If q.b2>4 Then If q.b2<>7 Then goto 30;
              goto 22;
            End{:911};
          w := fontinfo[kernbase[hf]+256*q.b2+q.b3].int;
          goto 30;
        End;
      If q.b0>=128 Then If currh=256 Then goto 30
      Else
        Begin
          currh := 256;
          goto 22;
        End;
      k := k+q.b0+1;
      q := fontinfo[k].qqqq;
    End;
  30:{:909};
{910:}
  If ligaturepresent Then
    Begin
      p := newligature(hf,curl,mem[curq].hh.
           rh);
      If lfthit Then
        Begin
          mem[p].hh.b1 := 2;
          lfthit := false;
        End;
      If rthit Then If ligstack=0 Then
                      Begin
                        mem[p].hh.b1 := mem[p].hh.b1+1;
                        rthit := false;
                      End;
      mem[curq].hh.rh := p;
      t := p;
      ligaturepresent := false;
    End;
  If w<>0 Then
    Begin
      mem[t].hh.rh := newkern(w);
      t := mem[t].hh.rh;
      w := 0;
    End;
  If ligstack>0 Then
    Begin
      curq := t;
      curl := mem[ligstack].hh.b1;
      ligaturepresent := true;
      Begin
        If mem[ligstack+1].hh.rh>0 Then
          Begin
            mem[t].hh.rh := mem[ligstack+1
                            ].hh.rh;
            t := mem[t].hh.rh;
            j := j+1;
          End;
        p := ligstack;
        ligstack := mem[p].hh.rh;
        freenode(p,2);
        If ligstack=0 Then
          Begin
            If j<n Then curr := hu[j+1]
            Else curr := bchar;
            If odd(hyf[j])Then currh := hchar
            Else currh := 256;
          End
        Else curr := mem[ligstack].hh.b1;
      End;
      goto 22;
    End{:910};
  reconstitute := j;
End;{:906}
Procedure hyphenate;

Label 50,30,40,41,42,45,10;

Var {901:}i,j,l: 0..65;
  q,r,s: halfword;
  bchar: halfword;{:901}{912:}
  majortail,minortail: halfword;
  c: ASCIIcode;
  cloc: 0..63;
  rcount: integer;
  hyfnode: halfword;{:912}{922:}
  z: triepointer;
  v: integer;{:922}{929:}
  h: hyphpointer;
  k: strnumber;
  u: poolpointer;
{:929}
Begin{923:}
  For j:=0 To hn Do
    hyf[j] := 0;{930:}
  h := hc[1];
  hn := hn+1;
  hc[hn] := curlang;
  For j:=2 To hn Do
    h := (h+h+hc[j])Mod 307;
  While true Do
    Begin{931:}
      k := hyphword[h];
      If k=0 Then goto 45;
      If (strstart[k+1]-strstart[k])<hn Then goto 45;
      If (strstart[k+1]-strstart[k])=hn Then
        Begin
          j := 1;
          u := strstart[k];
          Repeat
            If strpool[u]<hc[j]Then goto 45;
            If strpool[u]>hc[j]Then goto 30;
            j := j+1;
            u := u+1;
          Until j>hn;{932:}
          s := hyphlist[h];
          While s<>0 Do
            Begin
              hyf[mem[s].hh.lh] := 1;
              s := mem[s].hh.rh;
            End{:932};
          hn := hn-1;
          goto 40;
        End;
      30:{:931};
      If h>0 Then h := h-1
      Else h := 307;
    End;
  45: hn := hn-1{:930};
  If trie[curlang+1].b1<>curlang Then goto 10;
  hc[0] := 0;
  hc[hn+1] := 0;
  hc[hn+2] := 256;
  For j:=0 To hn-rhyf+1 Do
    Begin
      z := trie[curlang+1].rh+hc[j];
      l := j;
      While hc[l]=trie[z].b1 Do
        Begin
          If trie[z].b0<>0 Then{924:}
            Begin
              v := trie
                   [z].b0;
              Repeat
                v := v+opstart[curlang];
                i := l-hyfdistance[v];
                If hyfnum[v]>hyf[i]Then hyf[i] := hyfnum[v];
                v := hyfnext[v];
              Until v=0;
            End{:924};
          l := l+1;
          z := trie[z].rh+hc[l];
        End;
    End;
  40: For j:=0 To lhyf-1 Do
        hyf[j] := 0;
  For j:=0 To rhyf-1 Do
    hyf[hn-j] := 0{:923};
{902:}
  For j:=lhyf To hn-rhyf Do
    If odd(hyf[j])Then goto 41;
  goto 10;
  41:{:902};{903:}
  q := mem[hb].hh.rh;
  mem[hb].hh.rh := 0;
  r := mem[ha].hh.rh;
  mem[ha].hh.rh := 0;
  bchar := hyfbchar;
  If (ha>=himemmin)Then If mem[ha].hh.b0<>hf Then goto 42
  Else
    Begin
      initlist := ha;
      initlig := false;
      hu[0] := mem[ha].hh.b1;
    End
  Else If mem[ha].hh.b0=6 Then If mem[ha+1].hh.b0<>hf Then goto 42
  Else
    Begin
      initlist := mem[ha+1].hh.rh;
      initlig := true;
      initlft := (mem[ha].hh.b1>1);
      hu[0] := mem[ha+1].hh.b1;
      If initlist=0 Then If initlft Then
                           Begin
                             hu[0] := 256;
                             initlig := false;
                           End;
      freenode(ha,2);
    End
  Else
    Begin
      If Not(r>=himemmin)Then If mem[r].hh.b0=6 Then If mem[r].
                                                        hh.b1>1 Then goto 42;
      j := 1;
      s := ha;
      initlist := 0;
      goto 50;
    End;
  s := curp;
  While mem[s].hh.rh<>ha Do
    s := mem[s].hh.rh;
  j := 0;
  goto 50;
  42: s := ha;
  j := 0;
  hu[0] := 256;
  initlig := false;
  initlist := 0;
  50: flushnodelist(r);
{913:}
  Repeat
    l := j;
    j := reconstitute(j,hn,bchar,hyfchar)+1;
    If hyphenpassed=0 Then
      Begin
        mem[s].hh.rh := mem[29996].hh.rh;
        While mem[s].hh.rh>0 Do
          s := mem[s].hh.rh;
        If odd(hyf[j-1])Then
          Begin
            l := j;
            hyphenpassed := j-1;
            mem[29996].hh.rh := 0;
          End;
      End;
    If hyphenpassed>0 Then{914:}Repeat
                                  r := getnode(2);
                                  mem[r].hh.rh := mem[29996].hh.rh;
                                  mem[r].hh.b0 := 7;
                                  majortail := r;
                                  rcount := 0;
                                  While mem[majortail].hh.rh>0 Do
                                    Begin
                                      majortail := mem[majortail].hh.rh;
                                      rcount := rcount+1;
                                    End;
                                  i := hyphenpassed;
                                  hyf[i] := 0;{915:}
                                  minortail := 0;
                                  mem[r+1].hh.lh := 0;
                                  hyfnode := newcharacter(hf,hyfchar);
                                  If hyfnode<>0 Then
                                    Begin
                                      i := i+1;
                                      c := hu[i];
                                      hu[i] := hyfchar;
                                      Begin
                                        mem[hyfnode].hh.rh := avail;
                                        avail := hyfnode;
                                        dynused := dynused-1;
                                      End;
                                    End;
                                  While l<=i Do
                                    Begin
                                      l := reconstitute(l,i,fontbchar[hf],256)+1;
                                      If mem[29996].hh.rh>0 Then
                                        Begin
                                          If minortail=0 Then mem[r+1].hh.lh := mem
                                                                                [29996].hh.rh
                                          Else mem[minortail].hh.rh := mem[29996].hh.rh;
                                          minortail := mem[29996].hh.rh;
                                          While mem[minortail].hh.rh>0 Do
                                            minortail := mem[minortail].hh.rh;
                                        End;
                                    End;
                                  If hyfnode<>0 Then
                                    Begin
                                      hu[i] := c;
                                      l := i;
                                      i := i-1;
                                    End{:915};
{916:}
                                  minortail := 0;
                                  mem[r+1].hh.rh := 0;
                                  cloc := 0;
                                  If bcharlabel[hf]<>0 Then
                                    Begin
                                      l := l-1;
                                      c := hu[l];
                                      cloc := l;
                                      hu[l] := 256;
                                    End;
                                  While l<j Do
                                    Begin
                                      Repeat
                                        l := reconstitute(l,hn,bchar,256)+1;
                                        If cloc>0 Then
                                          Begin
                                            hu[cloc] := c;
                                            cloc := 0;
                                          End;
                                        If mem[29996].hh.rh>0 Then
                                          Begin
                                            If minortail=0 Then mem[r+1].hh.rh := mem
                                                                                  [29996].hh.rh
                                            Else mem[minortail].hh.rh := mem[29996].hh.rh;
                                            minortail := mem[29996].hh.rh;
                                            While mem[minortail].hh.rh>0 Do
                                              minortail := mem[minortail].hh.rh;
                                          End;
                                      Until l>=j;
                                      While l>j Do{917:}
                                        Begin
                                          j := reconstitute(j,hn,bchar,256)+1;
                                          mem[majortail].hh.rh := mem[29996].hh.rh;
                                          While mem[majortail].hh.rh>0 Do
                                            Begin
                                              majortail := mem[majortail].hh.rh;
                                              rcount := rcount+1;
                                            End;
                                        End{:917};
                                    End{:916};
{918:}
                                  If rcount>127 Then
                                    Begin
                                      mem[s].hh.rh := mem[r].hh.rh;
                                      mem[r].hh.rh := 0;
                                      flushnodelist(r);
                                    End
                                  Else
                                    Begin
                                      mem[s].hh.rh := r;
                                      mem[r].hh.b1 := rcount;
                                    End;
                                  s := majortail{:918};
                                  hyphenpassed := j-1;
                                  mem[29996].hh.rh := 0;
      Until Not odd(hyf[j-1]){:914};
  Until j>hn;
  mem[s].hh.rh := q{:913};
  flushlist(initlist){:903};
  10:
End;
{:895}{942:}
{[944:]function newtrieop(d,n:smallnumber;
v:quarterword):quarterword;label 10;var h:-trieopsize..trieopsize;
u:quarterword;l:0..trieopsize;
begin h:=abs(n+313*d+361*v+1009*curlang)mod(trieopsize+trieopsize)-
trieopsize;while true do begin l:=trieophash[h];
if l=0 then begin if trieopptr=trieopsize then overflow(950,trieopsize);
u:=trieused[curlang];if u=255 then overflow(951,255);
trieopptr:=trieopptr+1;u:=u+1;trieused[curlang]:=u;
hyfdistance[trieopptr]:=d;hyfnum[trieopptr]:=n;hyfnext[trieopptr]:=v;
trieoplang[trieopptr]:=curlang;trieophash[h]:=trieopptr;
trieopval[trieopptr]:=u;newtrieop:=u;goto 10;end;
if(hyfdistance[l]=d)and(hyfnum[l]=n)and(hyfnext[l]=v)and(trieoplang[l]=
curlang)then begin newtrieop:=trieopval[l];goto 10;end;
if h>-trieopsize then h:=h-1 else h:=trieopsize;end;10:end;
[:944][948:]function trienode(p:triepointer):triepointer;label 10;
var h:triepointer;q:triepointer;
begin h:=abs(triec[p]+1009*trieo[p]+2718*triel[p]+3142*trier[p])mod
triesize;while true do begin q:=triehash[h];
if q=0 then begin triehash[h]:=p;trienode:=p;goto 10;end;
if(triec[q]=triec[p])and(trieo[q]=trieo[p])and(triel[q]=triel[p])and(
trier[q]=trier[p])then begin trienode:=q;goto 10;end;
if h>0 then h:=h-1 else h:=triesize;end;10:end;
[:948][949:]function compresstrie(p:triepointer):triepointer;
begin if p=0 then compresstrie:=0 else begin triel[p]:=compresstrie(
triel[p]);trier[p]:=compresstrie(trier[p]);compresstrie:=trienode(p);
end;end;[:949][953:]procedure firstfit(p:triepointer);label 45,40;
var h:triepointer;z:triepointer;q:triepointer;c:ASCIIcode;
l,r:triepointer;ll:1..256;begin c:=triec[p];z:=triemin[c];
while true do begin h:=z-c;
[954:]if triemax<h+256 then begin if triesize<=h+256 then overflow(952,
triesize);repeat triemax:=triemax+1;trietaken[triemax]:=false;
trie[triemax].rh:=triemax+1;trie[triemax].lh:=triemax-1;
until triemax=h+256;end[:954];if trietaken[h]then goto 45;
[955:]q:=trier[p];
while q>0 do begin if trie[h+triec[q]].rh=0 then goto 45;q:=trier[q];
end;goto 40[:955];45:z:=trie[z].rh;end;40:[956:]trietaken[h]:=true;
triehash[p]:=h;q:=p;repeat z:=h+triec[q];l:=trie[z].lh;r:=trie[z].rh;
trie[r].lh:=l;trie[l].rh:=r;trie[z].rh:=0;
if l<256 then begin if z<256 then ll:=z else ll:=256;
repeat triemin[l]:=r;l:=l+1;until l=ll;end;q:=trier[q];until q=0[:956];
end;[:953][957:]procedure triepack(p:triepointer);var q:triepointer;
begin repeat q:=triel[p];
if(q>0)and(triehash[q]=0)then begin firstfit(q);triepack(q);end;
p:=trier[p];until p=0;end;[:957][959:]procedure triefix(p:triepointer);
var q:triepointer;c:ASCIIcode;z:triepointer;begin z:=triehash[p];
repeat q:=triel[p];c:=triec[p];trie[z+c].rh:=triehash[q];
trie[z+c].b1:=c;trie[z+c].b0:=trieo[p];if q>0 then triefix(q);
p:=trier[p];until p=0;end;[:959][960:]procedure newpatterns;label 30,31;
var k,l:0..64;digitsensed:boolean;v:quarterword;p,q:triepointer;
firstchild:boolean;c:ASCIIcode;
begin if trienotready then begin if eqtb[5313].int<=0 then curlang:=0
else if eqtb[5313].int>255 then curlang:=0 else curlang:=eqtb[5313].int;
scanleftbrace;[961:]k:=0;hyf[0]:=0;digitsensed:=false;
while true do begin getxtoken;
case curcmd of 11,12:[962:]if digitsensed or(curchr<48)or(curchr>57)then
begin if curchr=46 then curchr:=0 else begin curchr:=eqtb[4239+curchr].
hh.rh;if curchr=0 then begin begin if interaction=3 then;printnl(262);
print(958);end;begin helpptr:=1;helpline[0]:=957;end;error;end;end;
if k<63 then begin k:=k+1;hc[k]:=curchr;hyf[k]:=0;digitsensed:=false;
end;end else if k<63 then begin hyf[k]:=curchr-48;digitsensed:=true;
end[:962];
10,2:begin if k>0 then[963:]begin[965:]if hc[1]=0 then hyf[0]:=0;
if hc[k]=0 then hyf[k]:=0;l:=k;v:=0;
while true do begin if hyf[l]<>0 then v:=newtrieop(k-l,hyf[l],v);
if l>0 then l:=l-1 else goto 31;end;31:[:965];q:=0;hc[0]:=curlang;
while l<=k do begin c:=hc[l];l:=l+1;p:=triel[q];firstchild:=true;
while(p>0)and(c>triec[p])do begin q:=p;p:=trier[q];firstchild:=false;
end;
if(p=0)or(c<triec[p])then[964:]begin if trieptr=triesize then overflow(
952,triesize);trieptr:=trieptr+1;trier[trieptr]:=p;p:=trieptr;
triel[p]:=0;if firstchild then triel[q]:=p else trier[q]:=p;triec[p]:=c;
trieo[p]:=0;end[:964];q:=p;end;
if trieo[q]<>0 then begin begin if interaction=3 then;printnl(262);
print(959);end;begin helpptr:=1;helpline[0]:=957;end;error;end;
trieo[q]:=v;end[:963];if curcmd=2 then goto 30;k:=0;hyf[0]:=0;
digitsensed:=false;end;else begin begin if interaction=3 then;
printnl(262);print(956);end;printesc(954);begin helpptr:=1;
helpline[0]:=957;end;error;end end;end;30:[:961];
end else begin begin if interaction=3 then;printnl(262);print(953);end;
printesc(954);begin helpptr:=1;helpline[0]:=955;end;error;
mem[29988].hh.rh:=scantoks(false,false);flushlist(defref);end;end;
[:960][966:]procedure inittrie;var p:triepointer;j,k,t:integer;
r,s:triepointer;h:twohalves;begin[952:][945:]opstart[0]:=-0;
for j:=1 to 255 do opstart[j]:=opstart[j-1]+trieused[j-1];
for j:=1 to trieopptr do trieophash[j]:=opstart[trieoplang[j]]+trieopval
[j];
for j:=1 to trieopptr do while trieophash[j]>j do begin k:=trieophash[j]
;t:=hyfdistance[k];hyfdistance[k]:=hyfdistance[j];hyfdistance[j]:=t;
t:=hyfnum[k];hyfnum[k]:=hyfnum[j];hyfnum[j]:=t;t:=hyfnext[k];
hyfnext[k]:=hyfnext[j];hyfnext[j]:=t;trieophash[j]:=trieophash[k];
trieophash[k]:=k;end[:945];for p:=0 to triesize do triehash[p]:=0;
triel[0]:=compresstrie(triel[0]);for p:=0 to trieptr do triehash[p]:=0;
for p:=0 to 255 do triemin[p]:=p+1;trie[0].rh:=1;triemax:=0[:952];
if triel[0]<>0 then begin firstfit(triel[0]);triepack(triel[0]);end;
[958:]h.rh:=0;h.b0:=0;h.b1:=0;
if triel[0]=0 then begin for r:=0 to 256 do trie[r]:=h;triemax:=256;
end else begin triefix(triel[0]);r:=0;repeat s:=trie[r].rh;trie[r]:=h;
r:=s;until r>triemax;end;trie[0].b1:=63;[:958];trienotready:=false;end;
[:966]}
{:942}
Procedure linebreak(finalwidowpenalty:integer);

Label 30,31,32,33,34,35,22;

Var {862:}autobreaking: boolean;
  nonprunablep: halfword;
  prevp: halfword;
  q,r,s,prevs: halfword;
  f: internalfontnumber;{:862}{893:}
  j: smallnumber;
  c: 0..255;
{:893}
Begin
  packbeginline := curlist.mlfield;
{816:}
  mem[29997].hh.rh := mem[curlist.headfield].hh.rh;
  If (curlist.tailfield>=himemmin)Then
    Begin
      mem[curlist.tailfield].hh.rh := 
                                      newpenalty(10000);
      curlist.tailfield := mem[curlist.tailfield].hh.rh;
    End
  Else If mem[curlist.tailfield].hh.b0<>10 Then
         Begin
           mem[curlist.
           tailfield].hh.rh := newpenalty(10000);
           curlist.tailfield := mem[curlist.tailfield].hh.rh;
         End
  Else
    Begin
      mem[curlist.tailfield].hh.b0 := 12;
      deleteglueref(mem[curlist.tailfield+1].hh.lh);
      flushnodelist(mem[curlist.tailfield+1].hh.rh);
      mem[curlist.tailfield+1].int := 10000;
    End;
  nonprunablep := curlist.tailfield;
  mem[curlist.tailfield].hh.rh := newparamglue(14);
  initcurlang := curlist.pgfield Mod 65536;
  initlhyf := curlist.pgfield Div 4194304;
  initrhyf := (curlist.pgfield Div 65536)Mod 64;
  popnest;
{:816}{827:}
  noshrinkerroryet := true;
  If (mem[eqtb[2889].hh.rh].hh.b1<>0)And(mem[eqtb[2889].hh.rh+3].int<>0)
    Then
    Begin
      eqtb[2889].hh.rh := finiteshrink(eqtb[2889].hh.rh);
    End;
  If (mem[eqtb[2890].hh.rh].hh.b1<>0)And(mem[eqtb[2890].hh.rh+3].int<>0)
    Then
    Begin
      eqtb[2890].hh.rh := finiteshrink(eqtb[2890].hh.rh);
    End;
  q := eqtb[2889].hh.rh;
  r := eqtb[2890].hh.rh;
  background[1] := mem[q+1].int+mem[r+1].int;
  background[2] := 0;
  background[3] := 0;
  background[4] := 0;
  background[5] := 0;
  background[2+mem[q].hh.b0] := mem[q+2].int;
  background[2+mem[r].hh.b0] := background[2+mem[r].hh.b0]+mem[r+2].int;
  background[6] := mem[q+3].int+mem[r+3].int;
{:827}{834:}
  minimumdemerits := 1073741823;
  minimaldemerits[3] := 1073741823;
  minimaldemerits[2] := 1073741823;
  minimaldemerits[1] := 1073741823;
  minimaldemerits[0] := 1073741823;
{:834}{848:}
  If eqtb[3412].hh.rh=0 Then If eqtb[5847].int=0 Then
                               Begin
                                 lastspecialline := 0;
                                 secondwidth := eqtb[5833].int;
                                 secondindent := 0;
                               End
  Else{849:}
    Begin
      lastspecialline := abs(eqtb[5304].int);
      If eqtb[5304].int<0 Then
        Begin
          firstwidth := eqtb[5833].int-abs(eqtb[5847]
                        .int);
          If eqtb[5847].int>=0 Then firstindent := eqtb[5847].int
          Else firstindent := 
                              0;
          secondwidth := eqtb[5833].int;
          secondindent := 0;
        End
      Else
        Begin
          firstwidth := eqtb[5833].int;
          firstindent := 0;
          secondwidth := eqtb[5833].int-abs(eqtb[5847].int);
          If eqtb[5847].int>=0 Then secondindent := eqtb[5847].int
          Else secondindent 
            := 0;
        End;
    End{:849}
  Else
    Begin
      lastspecialline := mem[eqtb[3412].hh.rh].hh.lh-1;
      secondwidth := mem[eqtb[3412].hh.rh+2*(lastspecialline+1)].int;
      secondindent := mem[eqtb[3412].hh.rh+2*lastspecialline+1].int;
    End;
  If eqtb[5282].int=0 Then easyline := lastspecialline
  Else easyline := 65535
{:848};{863:}
  threshold := eqtb[5263].int;
  If threshold>=0 Then
    Begin
      If eqtb[5295].int>0 Then
        Begin
          begindiagnostic;
          printnl(934);
        End;
      secondpass := false;
      finalpass := false;
    End
  Else
    Begin
      threshold := eqtb[5264].int;
      secondpass := true;
      finalpass := (eqtb[5850].int<=0);
      If eqtb[5295].int>0 Then begindiagnostic;
    End;
  While true Do
    Begin
      If threshold>10000 Then threshold := 10000;
      If secondpass Then{891:}
        Begin{if trienotready then inittrie;}
          curlang := initcurlang;
          lhyf := initlhyf;
          rhyf := initrhyf;
        End{:891};
{864:}
      q := getnode(3);
      mem[q].hh.b0 := 0;
      mem[q].hh.b1 := 2;
      mem[q].hh.rh := 29993;
      mem[q+1].hh.rh := 0;
      mem[q+1].hh.lh := curlist.pgfield+1;
      mem[q+2].int := 0;
      mem[29993].hh.rh := q;
      activewidth[1] := background[1];
      activewidth[2] := background[2];
      activewidth[3] := background[3];
      activewidth[4] := background[4];
      activewidth[5] := background[5];
      activewidth[6] := background[6];
      passive := 0;
      printednode := 29997;
      passnumber := 0;
      fontinshortdisplay := 0{:864};
      curp := mem[29997].hh.rh;
      autobreaking := true;
      prevp := curp;
      While (curp<>0)And(mem[29993].hh.rh<>29993) Do{866:}
        Begin
          If (curp>=
             himemmin)Then{867:}
            Begin
              prevp := curp;
              Repeat
                f := mem[curp].hh.b0;
                activewidth[1] := activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
                                  ]+mem[curp].hh.b1].qqqq.b0].int;
                curp := mem[curp].hh.rh;
              Until Not(curp>=himemmin);
            End{:867};
          Case mem[curp].hh.b0 Of 
            0,1,2: activewidth[1] := activewidth[1]+mem[curp+1]
                                     .int;
            8:{1362:}If mem[curp].hh.b1=4 Then
                       Begin
                         curlang := mem[curp+1].hh.rh;
                         lhyf := mem[curp+1].hh.b0;
                         rhyf := mem[curp+1].hh.b1;
                       End{:1362};
            10:
                Begin{868:}
                  If autobreaking Then
                    Begin
                      If (prevp>=himemmin)Then
                        trybreak(0,0)
                      Else If (mem[prevp].hh.b0<9)Then trybreak(0,0)
                      Else If (mem[
                              prevp].hh.b0=11)And(mem[prevp].hh.b1<>1)Then trybreak(0,0);
                    End;
                  If (mem[mem[curp+1].hh.lh].hh.b1<>0)And(mem[mem[curp+1].hh.lh+3].int<>0)
                    Then
                    Begin
                      mem[curp+1].hh.lh := finiteshrink(mem[curp+1].hh.lh);
                    End;
                  q := mem[curp+1].hh.lh;
                  activewidth[1] := activewidth[1]+mem[q+1].int;
                  activewidth[2+mem[q].hh.b0] := activewidth[2+mem[q].hh.b0]+mem[q+2].int;
                  activewidth[6] := activewidth[6]+mem[q+3].int{:868};
                  If secondpass And autobreaking Then{894:}
                    Begin
                      prevs := curp;
                      s := mem[prevs].hh.rh;
                      If s<>0 Then
                        Begin{896:}
                          While true Do
                            Begin
                              If (s>=himemmin)Then
                                Begin
                                  c 
                                  := mem[s].hh.b1;
                                  hf := mem[s].hh.b0;
                                End
                              Else If mem[s].hh.b0=6 Then If mem[s+1].hh.rh=0 Then goto 22
                              Else
                                Begin
                                  q := mem[s+1].hh.rh;
                                  c := mem[q].hh.b1;
                                  hf := mem[q].hh.b0;
                                End
                              Else If (mem[s].hh.b0=11)And(mem[s].hh.b1=0)Then goto 22
                              Else If mem[
                                      s].hh.b0=8 Then
                                     Begin{1363:}
                                       If mem[s].hh.b1=4 Then
                                         Begin
                                           curlang := mem[s
                                                      +1].hh.rh;
                                           lhyf := mem[s+1].hh.b0;
                                           rhyf := mem[s+1].hh.b1;
                                         End{:1363};
                                       goto 22;
                                     End
                              Else goto 31;
                              If eqtb[4239+c].hh.rh<>0 Then If (eqtb[4239+c].hh.rh=c)Or(eqtb[5301].
                                                               int>
                                                               0)Then goto 32
                              Else goto 31;
                              22: prevs := s;
                              s := mem[prevs].hh.rh;
                            End;
                          32: hyfchar := hyphenchar[hf];
                          If hyfchar<0 Then goto 31;
                          If hyfchar>255 Then goto 31;
                          ha := prevs{:896};
                          If lhyf+rhyf>63 Then goto 31;{897:}
                          hn := 0;
                          While true Do
                            Begin
                              If (s>=himemmin)Then
                                Begin
                                  If mem[s].hh.b0<>hf Then
                                    goto 33;
                                  hyfbchar := mem[s].hh.b1;
                                  c := hyfbchar;
                                  If eqtb[4239+c].hh.rh=0 Then goto 33;
                                  If hn=63 Then goto 33;
                                  hb := s;
                                  hn := hn+1;
                                  hu[hn] := c;
                                  hc[hn] := eqtb[4239+c].hh.rh;
                                  hyfbchar := 256;
                                End
                              Else If mem[s].hh.b0=6 Then{898:}
                                     Begin
                                       If mem[s+1].hh.b0<>hf Then
                                         goto 33;
                                       j := hn;
                                       q := mem[s+1].hh.rh;
                                       If q>0 Then hyfbchar := mem[q].hh.b1;
                                       While q>0 Do
                                         Begin
                                           c := mem[q].hh.b1;
                                           If eqtb[4239+c].hh.rh=0 Then goto 33;
                                           If j=63 Then goto 33;
                                           j := j+1;
                                           hu[j] := c;
                                           hc[j] := eqtb[4239+c].hh.rh;
                                           q := mem[q].hh.rh;
                                         End;
                                       hb := s;
                                       hn := j;
                                       If odd(mem[s].hh.b1)Then hyfbchar := fontbchar[hf]
                                       Else hyfbchar := 256;
                                     End{:898}
                              Else If (mem[s].hh.b0=11)And(mem[s].hh.b1=0)Then
                                     Begin
                                       hb := s;
                                       hyfbchar := fontbchar[hf];
                                     End
                              Else goto 33;
                              s := mem[s].hh.rh;
                            End;
                          33:{:897};
{899:}
                          If hn<lhyf+rhyf Then goto 31;
                          While true Do
                            Begin
                              If Not((s>=himemmin))Then Case mem[s].hh.b0 Of 
                                                          6:;
                                                          11: If mem[s].hh.b1<>0 Then goto 34;
                                                          8,10,12,3,5,4: goto 34;
                                                          Else goto 31
                                End;
                              s := mem[s].hh.rh;
                            End;
                          34:{:899};
                          hyphenate;
                        End;
                      31:
                    End{:894};
                End;
            11: If mem[curp].hh.b1=1 Then
                  Begin
                    If Not(mem[curp].hh.rh>=himemmin)And
                       autobreaking Then If mem[mem[curp].hh.rh].hh.b0=10 Then trybreak(0,0);
                    activewidth[1] := activewidth[1]+mem[curp+1].int;
                  End
                Else activewidth[1] := activewidth[1]+mem[curp+1].int;
            6:
               Begin
                 f := mem[curp+1].hh.b0;
                 activewidth[1] := activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
                                   ]+mem[curp+1].hh.b1].qqqq.b0].int;
               End;
            7:{869:}
               Begin
                 s := mem[curp+1].hh.lh;
                 discwidth := 0;
                 If s=0 Then trybreak(eqtb[5267].int,1)
                 Else
                   Begin
                     Repeat{870:}
                       If (s>=
                          himemmin)Then
                         Begin
                           f := mem[s].hh.b0;
                           discwidth := discwidth+fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[s].
                                        hh.b1].qqqq.b0].int;
                         End
                       Else Case mem[s].hh.b0 Of 
                              6:
                                 Begin
                                   f := mem[s+1].hh.b0;
                                   discwidth := discwidth+fontinfo[widthbase[f]+fontinfo[charbase[f]
                                                +mem[s+1]
                                                .hh.b1].qqqq.b0].int;
                                 End;
                              0,1,2,11: discwidth := discwidth+mem[s+1].int;
                              Else confusion(938)
                         End{:870};
                       s := mem[s].hh.rh;
                     Until s=0;
                     activewidth[1] := activewidth[1]+discwidth;
                     trybreak(eqtb[5266].int,1);
                     activewidth[1] := activewidth[1]-discwidth;
                   End;
                 r := mem[curp].hh.b1;
                 s := mem[curp].hh.rh;
                 While r>0 Do
                   Begin{871:}
                     If (s>=himemmin)Then
                       Begin
                         f := mem[s].hh.b0;
                         activewidth[1] := activewidth[1]+fontinfo[widthbase[f]+fontinfo[charbase[f
                                           ]+mem[s].hh.b1].qqqq.b0].int;
                       End
                     Else Case mem[s].hh.b0 Of 
                            6:
                               Begin
                                 f := mem[s+1].hh.b0;
                                 activewidth[1] := activewidth[1]+fontinfo[widthbase[f]+fontinfo[
                                                   charbase[f
                                                   ]+mem[s+1].hh.b1].qqqq.b0].int;
                               End;
                            0,1,2,11: activewidth[1] := activewidth[1]+mem[s+1].int;
                            Else confusion(939)
                       End{:871};
                     r := r-1;
                     s := mem[s].hh.rh;
                   End;
                 prevp := curp;
                 curp := s;
                 goto 35;
               End{:869};
            9:
               Begin
                 autobreaking := (mem[curp].hh.b1=1);
                 Begin
                   If Not(mem[curp].hh.rh>=himemmin)And autobreaking Then If mem[mem[
                                                                             curp].hh.rh].hh.b0=10
                                                                            Then trybreak(0,0);
                   activewidth[1] := activewidth[1]+mem[curp+1].int;
                 End;
               End;
            12: trybreak(mem[curp+1].int,0);
            4,3,5:;
            Else confusion(937)
          End;
          prevp := curp;
          curp := mem[curp].hh.rh;
          35:
        End{:866};
      If curp=0 Then{873:}
        Begin
          trybreak(-10000,1);
          If mem[29993].hh.rh<>29993 Then
            Begin{874:}
              r := mem[29993].hh.rh;
              fewestdemerits := 1073741823;
              Repeat
                If mem[r].hh.b0<>2 Then If mem[r+2].int<fewestdemerits Then
                                          Begin
                                            fewestdemerits := mem[r+2].int;
                                            bestbet := r;
                                          End;
                r := mem[r].hh.rh;
              Until r=29993;
              bestline := mem[bestbet+1].hh.lh{:874};
              If eqtb[5282].int=0 Then goto 30;{875:}
              Begin
                r := mem[29993].hh.rh;
                actuallooseness := 0;
                Repeat
                  If mem[r].hh.b0<>2 Then
                    Begin
                      linediff := mem[r+1].hh.lh-bestline;
                      If ((linediff<actuallooseness)And(eqtb[5282].int<=linediff))Or((linediff>
                         actuallooseness)And(eqtb[5282].int>=linediff))Then
                        Begin
                          bestbet := r;
                          actuallooseness := linediff;
                          fewestdemerits := mem[r+2].int;
                        End
                      Else If (linediff=actuallooseness)And(mem[r+2].int<fewestdemerits)
                             Then
                             Begin
                               bestbet := r;
                               fewestdemerits := mem[r+2].int;
                             End;
                    End;
                  r := mem[r].hh.rh;
                Until r=29993;
                bestline := mem[bestbet+1].hh.lh;
              End{:875};
              If (actuallooseness=eqtb[5282].int)Or finalpass Then goto 30;
            End;
        End{:873};{865:}
      q := mem[29993].hh.rh;
      While q<>29993 Do
        Begin
          curp := mem[q].hh.rh;
          If mem[q].hh.b0=2 Then freenode(q,7)
          Else freenode(q,3);
          q := curp;
        End;
      q := passive;
      While q<>0 Do
        Begin
          curp := mem[q].hh.rh;
          freenode(q,2);
          q := curp;
        End{:865};
      If Not secondpass Then
        Begin
          If eqtb[5295].int>0 Then printnl(935);
          threshold := eqtb[5264].int;
          secondpass := true;
          finalpass := (eqtb[5850].int<=0);
        End
      Else
        Begin
          If eqtb[5295].int>0 Then printnl(936);
          background[2] := background[2]+eqtb[5850].int;
          finalpass := true;
        End;
    End;
  30: If eqtb[5295].int>0 Then
        Begin
          enddiagnostic(true);
          normalizeselector;
        End;{:863};{876:}
  postlinebreak(finalwidowpenalty,nonprunablep){:876};
{865:}
  q := mem[29993].hh.rh;
  While q<>29993 Do
    Begin
      curp := mem[q].hh.rh;
      If mem[q].hh.b0=2 Then freenode(q,7)
      Else freenode(q,3);
      q := curp;
    End;
  q := passive;
  While q<>0 Do
    Begin
      curp := mem[q].hh.rh;
      freenode(q,2);
      q := curp;
    End{:865};
  packbeginline := 0;
End;{:815}{934:}
Procedure newhyphexceptions;

Label 21,10,40,45;

Var n: 0..64;
  j: 0..64;
  h: hyphpointer;
  k: strnumber;
  p: halfword;
  q: halfword;
  s,t: strnumber;
  u,v: poolpointer;
Begin
  scanleftbrace;
  If eqtb[5313].int<=0 Then curlang := 0
  Else If eqtb[5313].int>255 Then
         curlang := 0
  Else curlang := eqtb[5313].int;{935:}
  n := 0;
  p := 0;
  While true Do
    Begin
      getxtoken;
      21: Case curcmd Of 
            11,12,68:{937:}If curchr=45 Then{938:}
                             Begin
                               If n<63
                                 Then
                                 Begin
                                   q := getavail;
                                   mem[q].hh.rh := p;
                                   mem[q].hh.lh := n;
                                   p := q;
                                 End;
                             End{:938}
                      Else
                        Begin
                          If eqtb[4239+curchr].hh.rh=0 Then
                            Begin
                              Begin
                                If 
                                   interaction=3 Then;
                                printnl(262);
                                print(946);
                              End;
                              Begin
                                helpptr := 2;
                                helpline[1] := 947;
                                helpline[0] := 948;
                              End;
                              error;
                            End
                          Else If n<63 Then
                                 Begin
                                   n := n+1;
                                   hc[n] := eqtb[4239+curchr].hh.rh;
                                 End;
                        End{:937};
            16:
                Begin
                  scancharnum;
                  curchr := curval;
                  curcmd := 68;
                  goto 21;
                End;
            10,2:
                  Begin
                    If n>1 Then{939:}
                      Begin
                        n := n+1;
                        hc[n] := curlang;
                        Begin
                          If poolptr+n>poolsize Then overflow(257,poolsize-initpoolptr);
                        End;
                        h := 0;
                        For j:=1 To n Do
                          Begin
                            h := (h+h+hc[j])Mod 307;
                            Begin
                              strpool[poolptr] := hc[j];
                              poolptr := poolptr+1;
                            End;
                          End;
                        s := makestring;
{940:}
                        If hyphcount=307 Then overflow(949,307);
                        hyphcount := hyphcount+1;
                        While hyphword[h]<>0 Do
                          Begin{941:}
                            k := hyphword[h];
                            If (strstart[k+1]-strstart[k])<(strstart[s+1]-strstart[s])Then goto 40;
                            If (strstart[k+1]-strstart[k])>(strstart[s+1]-strstart[s])Then goto 45;
                            u := strstart[k];
                            v := strstart[s];
                            Repeat
                              If strpool[u]<strpool[v]Then goto 40;
                              If strpool[u]>strpool[v]Then goto 45;
                              u := u+1;
                              v := v+1;
                            Until u=strstart[k+1];
                            40: q := hyphlist[h];
                            hyphlist[h] := p;
                            p := q;
                            t := hyphword[h];
                            hyphword[h] := s;
                            s := t;
                            45:{:941};
                            If h>0 Then h := h-1
                            Else h := 307;
                          End;
                        hyphword[h] := s;
                        hyphlist[h] := p{:940};
                      End{:939};
                    If curcmd=2 Then goto 10;
                    n := 0;
                    p := 0;
                  End;
            Else{936:}
              Begin
                Begin
                  If interaction=3 Then;
                  printnl(262);
                  print(680);
                End;
                printesc(942);
                print(943);
                Begin
                  helpptr := 2;
                  helpline[1] := 944;
                  helpline[0] := 945;
                End;
                error;
              End{:936}
          End;
    End{:935};
  10:
End;
{:934}{968:}
Function prunepagetop(p:halfword): halfword;

Var prevp: halfword;
  q: halfword;
Begin
  prevp := 29997;
  mem[29997].hh.rh := p;
  While p<>0 Do
    Case mem[p].hh.b0 Of 
      0,1,2:{969:}
             Begin
               q := newskipparam(10)
               ;
               mem[prevp].hh.rh := q;
               mem[q].hh.rh := p;
               If mem[tempptr+1].int>mem[p+3].int Then mem[tempptr+1].int := mem[tempptr
                                                                             +1].int-mem[p+3].int
               Else mem[tempptr+1].int := 0;
               p := 0;
             End{:969};
      8,4,3:
             Begin
               prevp := p;
               p := mem[prevp].hh.rh;
             End;
      10,11,12:
                Begin
                  q := p;
                  p := mem[q].hh.rh;
                  mem[q].hh.rh := 0;
                  mem[prevp].hh.rh := p;
                  flushnodelist(q);
                End;
      Else confusion(960)
    End;
  prunepagetop := mem[29997].hh.rh;
End;
{:968}{970:}
Function vertbreak(p:halfword;h,d:scaled): halfword;

Label 30,45,90;

Var prevp: halfword;
  q,r: halfword;
  pi: integer;
  b: integer;
  leastcost: integer;
  bestplace: halfword;
  prevdp: scaled;
  t: smallnumber;
Begin
  prevp := p;
  leastcost := 1073741823;
  activewidth[1] := 0;
  activewidth[2] := 0;
  activewidth[3] := 0;
  activewidth[4] := 0;
  activewidth[5] := 0;
  activewidth[6] := 0;
  prevdp := 0;
  While true Do
    Begin{972:}
      If p=0 Then pi := -10000
      Else{973:}Case mem[p].hh
                     .b0 Of 
                  0,1,2:
                         Begin
                           activewidth[1] := activewidth[1]+prevdp+mem[p+3].int;
                           prevdp := mem[p+2].int;
                           goto 45;
                         End;
                  8:{1365:}goto 45{:1365};
                  10: If (mem[prevp].hh.b0<9)Then pi := 0
                      Else goto 90;
                  11:
                      Begin
                        If mem[p].hh.rh=0 Then t := 12
                        Else t := mem[mem[p].hh.rh].hh.b0;
                        If t=10 Then pi := 0
                        Else goto 90;
                      End;
                  12: pi := mem[p+1].int;
                  4,3: goto 45;
                  Else confusion(961)
        End{:973};
{974:}
      If pi<10000 Then
        Begin{975:}
          If activewidth[1]<h Then If (
                                      activewidth[3]<>0)Or(activewidth[4]<>0)Or(activewidth[5]<>0)
                                     Then b := 0
          Else b := badness(h-activewidth[1],activewidth[2])
          Else If activewidth[1]-h
                  >activewidth[6]Then b := 1073741823
          Else b := badness(activewidth[1]-h,
                    activewidth[6]){:975};
          If b<1073741823 Then If pi<=-10000 Then b := pi
          Else If b<10000 Then b := b+
                                    pi
          Else b := 100000;
          If b<=leastcost Then
            Begin
              bestplace := p;
              leastcost := b;
              bestheightplusdepth := activewidth[1]+prevdp;
            End;
          If (b=1073741823)Or(pi<=-10000)Then goto 30;
        End{:974};
      If (mem[p].hh.b0<10)Or(mem[p].hh.b0>11)Then goto 45;
      90:{976:}If mem[p].hh.b0=11 Then q := p
          Else
            Begin
              q := mem[p+1].hh.lh;
              activewidth[2+mem[q].hh.b0] := activewidth[2+mem[q].hh.b0]+mem[q+2].int;
              activewidth[6] := activewidth[6]+mem[q+3].int;
              If (mem[q].hh.b1<>0)And(mem[q+3].int<>0)Then
                Begin
                  Begin
                    If interaction=3
                      Then;
                    printnl(262);
                    print(962);
                  End;
                  Begin
                    helpptr := 4;
                    helpline[3] := 963;
                    helpline[2] := 964;
                    helpline[1] := 965;
                    helpline[0] := 923;
                  End;
                  error;
                  r := newspec(q);
                  mem[r].hh.b1 := 0;
                  deleteglueref(q);
                  mem[p+1].hh.lh := r;
                  q := r;
                End;
            End;
      activewidth[1] := activewidth[1]+prevdp+mem[q+1].int;
      prevdp := 0{:976};
      45: If prevdp>d Then
            Begin
              activewidth[1] := activewidth[1]+prevdp-d;
              prevdp := d;
            End;{:972};
      prevp := p;
      p := mem[prevp].hh.rh;
    End;
  30: vertbreak := bestplace;
End;{:970}{977:}
Function vsplit(n:eightbits;
                h:scaled): halfword;

Label 10,30;

Var v: halfword;
  p: halfword;
  q: halfword;
Begin
  v := eqtb[3678+n].hh.rh;
  If curmark[3]<>0 Then
    Begin
      deletetokenref(curmark[3]);
      curmark[3] := 0;
      deletetokenref(curmark[4]);
      curmark[4] := 0;
    End;
{978:}
  If v=0 Then
    Begin
      vsplit := 0;
      goto 10;
    End;
  If mem[v].hh.b0<>1 Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(338);
      End;
      printesc(966);
      print(967);
      printesc(968);
      Begin
        helpptr := 2;
        helpline[1] := 969;
        helpline[0] := 970;
      End;
      error;
      vsplit := 0;
      goto 10;
    End{:978};
  q := vertbreak(mem[v+5].hh.rh,h,eqtb[5836].int);{979:}
  p := mem[v+5].hh.rh;
  If p=q Then mem[v+5].hh.rh := 0
  Else While true Do
         Begin
           If mem[p].hh.b0=4
             Then If curmark[3]=0 Then
                    Begin
                      curmark[3] := mem[p+1].int;
                      curmark[4] := curmark[3];
                      mem[curmark[3]].hh.lh := mem[curmark[3]].hh.lh+2;
                    End
           Else
             Begin
               deletetokenref(curmark[4]);
               curmark[4] := mem[p+1].int;
               mem[curmark[4]].hh.lh := mem[curmark[4]].hh.lh+1;
             End;
           If mem[p].hh.rh=q Then
             Begin
               mem[p].hh.rh := 0;
               goto 30;
             End;
           p := mem[p].hh.rh;
         End;
  30:{:979};
  q := prunepagetop(q);
  p := mem[v+5].hh.rh;
  freenode(v,7);
  If q=0 Then eqtb[3678+n].hh.rh := 0
  Else eqtb[3678+n].hh.rh := vpackage(q,0,
                             1,1073741823);
  vsplit := vpackage(p,h,0,eqtb[5836].int);
  10:
End;
{:977}{985:}
Procedure printtotals;
Begin
  printscaled(pagesofar[1]);
  If pagesofar[2]<>0 Then
    Begin
      print(312);
      printscaled(pagesofar[2]);
      print(338);
    End;
  If pagesofar[3]<>0 Then
    Begin
      print(312);
      printscaled(pagesofar[3]);
      print(311);
    End;
  If pagesofar[4]<>0 Then
    Begin
      print(312);
      printscaled(pagesofar[4]);
      print(979);
    End;
  If pagesofar[5]<>0 Then
    Begin
      print(312);
      printscaled(pagesofar[5]);
      print(980);
    End;
  If pagesofar[6]<>0 Then
    Begin
      print(313);
      printscaled(pagesofar[6]);
    End;
End;{:985}{987:}
Procedure freezepagespecs(s:smallnumber);
Begin
  pagecontents := s;
  pagesofar[0] := eqtb[5834].int;
  pagemaxdepth := eqtb[5835].int;
  pagesofar[7] := 0;
  pagesofar[1] := 0;
  pagesofar[2] := 0;
  pagesofar[3] := 0;
  pagesofar[4] := 0;
  pagesofar[5] := 0;
  pagesofar[6] := 0;
  leastpagecost := 1073741823;
  If eqtb[5296].int>0 Then
    Begin
      begindiagnostic;
      printnl(988);
      printscaled(pagesofar[0]);
      print(989);
      printscaled(pagemaxdepth);
      enddiagnostic(false);
    End;
End;
{:987}{992:}
Procedure boxerror(n:eightbits);
Begin
  error;
  begindiagnostic;
  printnl(837);
  showbox(eqtb[3678+n].hh.rh);
  enddiagnostic(true);
  flushnodelist(eqtb[3678+n].hh.rh);
  eqtb[3678+n].hh.rh := 0;
End;
{:992}{993:}
Procedure ensurevbox(n:eightbits);

Var p: halfword;
Begin
  p := eqtb[3678+n].hh.rh;
  If p<>0 Then If mem[p].hh.b0=0 Then
                 Begin
                   Begin
                     If interaction=3 Then;
                     printnl(262);
                     print(990);
                   End;
                   Begin
                     helpptr := 3;
                     helpline[2] := 991;
                     helpline[1] := 992;
                     helpline[0] := 993;
                   End;
                   boxerror(n);
                 End;
End;
{:993}{994:}{1012:}
Procedure fireup(c:halfword);

Label 10;

Var p,q,r,s: halfword;
  prevp: halfword;
  n: 0..255;
  wait: boolean;
  savevbadness: integer;
  savevfuzz: scaled;
  savesplittopskip: halfword;
Begin{1013:}
  If mem[bestpagebreak].hh.b0=12 Then
    Begin
      geqworddefine(5302
                    ,mem[bestpagebreak+1].int);
      mem[bestpagebreak+1].int := 10000;
    End
  Else geqworddefine(5302,10000){:1013};
  If curmark[2]<>0 Then
    Begin
      If curmark[0]<>0 Then deletetokenref(curmark
                                           [0]);
      curmark[0] := curmark[2];
      mem[curmark[0]].hh.lh := mem[curmark[0]].hh.lh+1;
      deletetokenref(curmark[1]);
      curmark[1] := 0;
    End;
{1014:}
  If c=bestpagebreak Then bestpagebreak := 0;
{1015:}
  If eqtb[3933].hh.rh<>0 Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(338);
      End;
      printesc(409);
      print(1004);
      Begin
        helpptr := 2;
        helpline[1] := 1005;
        helpline[0] := 993;
      End;
      boxerror(255);
    End{:1015};
  insertpenalties := 0;
  savesplittopskip := eqtb[2892].hh.rh;
  If eqtb[5316].int<=0 Then{1018:}
    Begin
      r := mem[30000].hh.rh;
      While r<>30000 Do
        Begin
          If mem[r+2].hh.lh<>0 Then
            Begin
              n := mem[r].hh.b1;
              ensurevbox(n);
              If eqtb[3678+n].hh.rh=0 Then eqtb[3678+n].hh.rh := newnullbox;
              p := eqtb[3678+n].hh.rh+5;
              While mem[p].hh.rh<>0 Do
                p := mem[p].hh.rh;
              mem[r+2].hh.rh := p;
            End;
          r := mem[r].hh.rh;
        End;
    End{:1018};
  q := 29996;
  mem[q].hh.rh := 0;
  prevp := 29998;
  p := mem[prevp].hh.rh;
  While p<>bestpagebreak Do
    Begin
      If mem[p].hh.b0=3 Then
        Begin
          If eqtb[
             5316].int<=0 Then{1020:}
            Begin
              r := mem[30000].hh.rh;
              While mem[r].hh.b1<>mem[p].hh.b1 Do
                r := mem[r].hh.rh;
              If mem[r+2].hh.lh=0 Then wait := true
              Else
                Begin
                  wait := false;
                  s := mem[r+2].hh.rh;
                  mem[s].hh.rh := mem[p+4].hh.lh;
                  If mem[r+2].hh.lh=p Then{1021:}
                    Begin
                      If mem[r].hh.b0=1 Then If (mem[r+1].
                                                hh.lh=p)And(mem[r+1].hh.rh<>0)Then
                                               Begin
                                                 While mem[s].hh.rh<>mem[r+1].hh
                                                       .rh Do
                                                   s := mem[s].hh.rh;
                                                 mem[s].hh.rh := 0;
                                                 eqtb[2892].hh.rh := mem[p+4].hh.rh;
                                                 mem[p+4].hh.lh := prunepagetop(mem[r+1].hh.rh);
                                                 If mem[p+4].hh.lh<>0 Then
                                                   Begin
                                                     tempptr := vpackage(mem[p+4].hh.lh,0,1,
                                                                1073741823);
                                                     mem[p+3].int := mem[tempptr+3].int+mem[tempptr+
                                                                     2].int;
                                                     freenode(tempptr,7);
                                                     wait := true;
                                                   End;
                                               End;
                      mem[r+2].hh.lh := 0;
                      n := mem[r].hh.b1;
                      tempptr := mem[eqtb[3678+n].hh.rh+5].hh.rh;
                      freenode(eqtb[3678+n].hh.rh,7);
                      eqtb[3678+n].hh.rh := vpackage(tempptr,0,1,1073741823);
                    End{:1021}
                  Else
                    Begin
                      While mem[s].hh.rh<>0 Do
                        s := mem[s].hh.rh;
                      mem[r+2].hh.rh := s;
                    End;
                End;{1022:}
              mem[prevp].hh.rh := mem[p].hh.rh;
              mem[p].hh.rh := 0;
              If wait Then
                Begin
                  mem[q].hh.rh := p;
                  q := p;
                  insertpenalties := insertpenalties+1;
                End
              Else
                Begin
                  deleteglueref(mem[p+4].hh.rh);
                  freenode(p,5);
                End;
              p := prevp{:1022};
            End{:1020};
        End
      Else If mem[p].hh.b0=4 Then{1016:}
             Begin
               If curmark[1]=0 Then
                 Begin
                   curmark[1] := mem[p+1].int;
                   mem[curmark[1]].hh.lh := mem[curmark[1]].hh.lh+1;
                 End;
               If curmark[2]<>0 Then deletetokenref(curmark[2]);
               curmark[2] := mem[p+1].int;
               mem[curmark[2]].hh.lh := mem[curmark[2]].hh.lh+1;
             End{:1016};
      prevp := p;
      p := mem[prevp].hh.rh;
    End;
  eqtb[2892].hh.rh := savesplittopskip;
{1017:}
  If p<>0 Then
    Begin
      If mem[29999].hh.rh=0 Then If nestptr=0 Then
                                   curlist.tailfield := pagetail
      Else nest[0].tailfield := pagetail;
      mem[pagetail].hh.rh := mem[29999].hh.rh;
      mem[29999].hh.rh := p;
      mem[prevp].hh.rh := 0;
    End;
  savevbadness := eqtb[5290].int;
  eqtb[5290].int := 10000;
  savevfuzz := eqtb[5839].int;
  eqtb[5839].int := 1073741823;
  eqtb[3933].hh.rh := vpackage(mem[29998].hh.rh,bestsize,0,pagemaxdepth);
  eqtb[5290].int := savevbadness;
  eqtb[5839].int := savevfuzz;
  If lastglue<>65535 Then deleteglueref(lastglue);{991:}
  pagecontents := 0;
  pagetail := 29998;
  mem[29998].hh.rh := 0;
  lastglue := 65535;
  lastpenalty := 0;
  lastkern := 0;
  pagesofar[7] := 0;
  pagemaxdepth := 0{:991};
  If q<>29996 Then
    Begin
      mem[29998].hh.rh := mem[29996].hh.rh;
      pagetail := q;
    End{:1017};{1019:}
  r := mem[30000].hh.rh;
  While r<>30000 Do
    Begin
      q := mem[r].hh.rh;
      freenode(r,4);
      r := q;
    End;
  mem[30000].hh.rh := 30000{:1019}{:1014};
  If (curmark[0]<>0)And(curmark[1]=0)Then
    Begin
      curmark[1] := curmark[0];
      mem[curmark[0]].hh.lh := mem[curmark[0]].hh.lh+1;
    End;
  If eqtb[3413].hh.rh<>0 Then If deadcycles>=eqtb[5303].int Then{1024:}
                                Begin
                                  Begin
                                    If interaction=3 Then;
                                    printnl(262);
                                    print(1006);
                                  End;
                                  printint(deadcycles);
                                  print(1007);
                                  Begin
                                    helpptr := 3;
                                    helpline[2] := 1008;
                                    helpline[1] := 1009;
                                    helpline[0] := 1010;
                                  End;
                                  error;
                                End{:1024}
  Else{1025:}
    Begin
      outputactive := true;
      deadcycles := deadcycles+1;
      pushnest;
      curlist.modefield := -1;
      curlist.auxfield.int := -65536000;
      curlist.mlfield := -line;
      begintokenlist(eqtb[3413].hh.rh,6);
      newsavelevel(8);
      normalparagraph;
      scanleftbrace;
      goto 10;
    End{:1025};
{1023:}
  Begin
    If mem[29998].hh.rh<>0 Then
      Begin
        If mem[29999].hh.rh=0
          Then If nestptr=0 Then curlist.tailfield := pagetail
        Else nest[0].
          tailfield := pagetail
        Else mem[pagetail].hh.rh := mem[29999].hh.rh;
        mem[29999].hh.rh := mem[29998].hh.rh;
        mem[29998].hh.rh := 0;
        pagetail := 29998;
      End;
    shipout(eqtb[3933].hh.rh);
    eqtb[3933].hh.rh := 0;
  End{:1023};
  10:
End;
{:1012}
Procedure buildpage;

Label 10,30,31,22,80,90;

Var p: halfword;
  q,r: halfword;
  b,c: integer;
  pi: integer;
  n: 0..255;
  delta,h,w: scaled;
Begin
  If (mem[29999].hh.rh=0)Or outputactive Then goto 10;
  Repeat
    22: p := mem[29999].hh.rh;
{996:}
    If lastglue<>65535 Then deleteglueref(lastglue);
    lastpenalty := 0;
    lastkern := 0;
    If mem[p].hh.b0=10 Then
      Begin
        lastglue := mem[p+1].hh.lh;
        mem[lastglue].hh.rh := mem[lastglue].hh.rh+1;
      End
    Else
      Begin
        lastglue := 65535;
        If mem[p].hh.b0=12 Then lastpenalty := mem[p+1].int
        Else If mem[p].hh.b0=
                11 Then lastkern := mem[p+1].int;
      End{:996};
{997:}{1000:}
    Case mem[p].hh.b0 Of 
      0,1,2: If pagecontents<2 Then{1001:}
               Begin
                 If pagecontents=0 Then freezepagespecs(2)
                 Else pagecontents := 2;
                 q := newskipparam(9);
                 If mem[tempptr+1].int>mem[p+3].int Then mem[tempptr+1].int := mem[tempptr
                                                                               +1].int-mem[p+3].int
                 Else mem[tempptr+1].int := 0;
                 mem[q].hh.rh := p;
                 mem[29999].hh.rh := q;
                 goto 22;
               End{:1001}
             Else{1002:}
               Begin
                 pagesofar[1] := pagesofar[1]+pagesofar[7]+mem[p
                                 +3].int;
                 pagesofar[7] := mem[p+2].int;
                 goto 80;
               End{:1002};
      8:{1364:}goto 80{:1364};
      10: If pagecontents<2 Then goto 31
          Else If (mem[pagetail].hh.b0<9)Then pi 
                 := 0
          Else goto 90;
      11: If pagecontents<2 Then goto 31
          Else If mem[p].hh.rh=0 Then goto 10
          Else If mem[mem[p].hh.rh].hh.b0=10 Then pi := 0
          Else goto 90;
      12: If pagecontents<2 Then goto 31
          Else pi := mem[p+1].int;
      4: goto 80;
      3:{1008:}
         Begin
           If pagecontents=0 Then freezepagespecs(1);
           n := mem[p].hh.b1;
           r := 30000;
           While n>=mem[mem[r].hh.rh].hh.b1 Do
             r := mem[r].hh.rh;
           n := n;
           If mem[r].hh.b1<>n Then{1009:}
             Begin
               q := getnode(4);
               mem[q].hh.rh := mem[r].hh.rh;
               mem[r].hh.rh := q;
               r := q;
               mem[r].hh.b1 := n;
               mem[r].hh.b0 := 0;
               ensurevbox(n);
               If eqtb[3678+n].hh.rh=0 Then mem[r+3].int := 0
               Else mem[r+3].int := mem[eqtb
                                    [3678+n].hh.rh+3].int+mem[eqtb[3678+n].hh.rh+2].int;
               mem[r+2].hh.lh := 0;
               q := eqtb[2900+n].hh.rh;
               If eqtb[5318+n].int=1000 Then h := mem[r+3].int
               Else h := xovern(mem[r+3].
                         int,1000)*eqtb[5318+n].int;
               pagesofar[0] := pagesofar[0]-h-mem[q+1].int;
               pagesofar[2+mem[q].hh.b0] := pagesofar[2+mem[q].hh.b0]+mem[q+2].int;
               pagesofar[6] := pagesofar[6]+mem[q+3].int;
               If (mem[q].hh.b1<>0)And(mem[q+3].int<>0)Then
                 Begin
                   Begin
                     If interaction=3
                       Then;
                     printnl(262);
                     print(999);
                   End;
                   printesc(395);
                   printint(n);
                   Begin
                     helpptr := 3;
                     helpline[2] := 1000;
                     helpline[1] := 1001;
                     helpline[0] := 923;
                   End;
                   error;
                 End;
             End{:1009};
           If mem[r].hh.b0=1 Then insertpenalties := insertpenalties+mem[p+1].int
           Else
             Begin
               mem[r+2].hh.rh := p;
               delta := pagesofar[0]-pagesofar[1]-pagesofar[7]+pagesofar[6];
               If eqtb[5318+n].int=1000 Then h := mem[p+3].int
               Else h := xovern(mem[p+3].
                         int,1000)*eqtb[5318+n].int;
               If ((h<=0)Or(h<=delta))And(mem[p+3].int+mem[r+3].int<=eqtb[5851+n].int)
                 Then
                 Begin
                   pagesofar[0] := pagesofar[0]-h;
                   mem[r+3].int := mem[r+3].int+mem[p+3].int;
                 End
               Else{1010:}
                 Begin
                   If eqtb[5318+n].int<=0 Then w := 1073741823
                   Else
                     Begin
                       w := pagesofar[0]-pagesofar[1]-pagesofar[7];
                       If eqtb[5318+n].int<>1000 Then w := xovern(w,eqtb[5318+n].int)*1000;
                     End;
                   If w>eqtb[5851+n].int-mem[r+3].int Then w := eqtb[5851+n].int-mem[r+3].int
                   ;
                   q := vertbreak(mem[p+4].hh.lh,w,mem[p+2].int);
                   mem[r+3].int := mem[r+3].int+bestheightplusdepth;
                   If eqtb[5296].int>0 Then{1011:}
                     Begin
                       begindiagnostic;
                       printnl(1002);
                       printint(n);
                       print(1003);
                       printscaled(w);
                       printchar(44);
                       printscaled(bestheightplusdepth);
                       print(932);
                       If q=0 Then printint(-10000)
                       Else If mem[q].hh.b0=12 Then printint(mem[q
                                                             +1].int)
                       Else printchar(48);
                       enddiagnostic(false);
                     End{:1011};
                   If eqtb[5318+n].int<>1000 Then bestheightplusdepth := xovern(
                                                                         bestheightplusdepth,1000)*
                                                                         eqtb[5318+n].int;
                   pagesofar[0] := pagesofar[0]-bestheightplusdepth;
                   mem[r].hh.b0 := 1;
                   mem[r+1].hh.rh := q;
                   mem[r+1].hh.lh := p;
                   If q=0 Then insertpenalties := insertpenalties-10000
                   Else If mem[q].hh.b0=
                           12 Then insertpenalties := insertpenalties+mem[q+1].int;
                 End{:1010};
             End;
           goto 80;
         End{:1008};
      Else confusion(994)
    End{:1000};
{1005:}
    If pi<10000 Then
      Begin{1007:}
        If pagesofar[1]<pagesofar[0]Then If (
                                            pagesofar[3]<>0)Or(pagesofar[4]<>0)Or(pagesofar[5]<>0)
                                           Then b := 0
        Else b := 
                  badness(pagesofar[0]-pagesofar[1],pagesofar[2])
        Else If pagesofar[1]-
                pagesofar[0]>pagesofar[6]Then b := 1073741823
        Else b := badness(pagesofar[1]
                  -pagesofar[0],pagesofar[6]){:1007};
        If b<1073741823 Then If pi<=-10000 Then c := pi
        Else If b<10000 Then c := b+
                                  pi+insertpenalties
        Else c := 100000
        Else c := b;
        If insertpenalties>=10000 Then c := 1073741823;
        If eqtb[5296].int>0 Then{1006:}
          Begin
            begindiagnostic;
            printnl(37);
            print(928);
            printtotals;
            print(997);
            printscaled(pagesofar[0]);
            print(931);
            If b=1073741823 Then printchar(42)
            Else printint(b);
            print(932);
            printint(pi);
            print(998);
            If c=1073741823 Then printchar(42)
            Else printint(c);
            If c<=leastpagecost Then printchar(35);
            enddiagnostic(false);
          End{:1006};
        If c<=leastpagecost Then
          Begin
            bestpagebreak := p;
            bestsize := pagesofar[0];
            leastpagecost := c;
            r := mem[30000].hh.rh;
            While r<>30000 Do
              Begin
                mem[r+2].hh.lh := mem[r+2].hh.rh;
                r := mem[r].hh.rh;
              End;
          End;
        If (c=1073741823)Or(pi<=-10000)Then
          Begin
            fireup(p);
            If outputactive Then goto 10;
            goto 30;
          End;
      End{:1005};
    If (mem[p].hh.b0<10)Or(mem[p].hh.b0>11)Then goto 80;
    90:{1004:}If mem[p].hh.b0=11 Then q := p
        Else
          Begin
            q := mem[p+1].hh.lh;
            pagesofar[2+mem[q].hh.b0] := pagesofar[2+mem[q].hh.b0]+mem[q+2].int;
            pagesofar[6] := pagesofar[6]+mem[q+3].int;
            If (mem[q].hh.b1<>0)And(mem[q+3].int<>0)Then
              Begin
                Begin
                  If interaction=3
                    Then;
                  printnl(262);
                  print(995);
                End;
                Begin
                  helpptr := 4;
                  helpline[3] := 996;
                  helpline[2] := 964;
                  helpline[1] := 965;
                  helpline[0] := 923;
                End;
                error;
                r := newspec(q);
                mem[r].hh.b1 := 0;
                deleteglueref(q);
                mem[p+1].hh.lh := r;
                q := r;
              End;
          End;
    pagesofar[1] := pagesofar[1]+pagesofar[7]+mem[q+1].int;
    pagesofar[7] := 0{:1004};
    80:{1003:}If pagesofar[7]>pagemaxdepth Then
                Begin
                  pagesofar[1] := 
                                  pagesofar[1]+pagesofar[7]-pagemaxdepth;
                  pagesofar[7] := pagemaxdepth;
                End;
{:1003};{998:}
    mem[pagetail].hh.rh := p;
    pagetail := p;
    mem[29999].hh.rh := mem[p].hh.rh;
    mem[p].hh.rh := 0;
    goto 30{:998};
    31:{999:}mem[29999].hh.rh := mem[p].hh.rh;
    mem[p].hh.rh := 0;
    flushnodelist(p){:999};
    30:{:997};
  Until mem[29999].hh.rh=0;
{995:}
  If nestptr=0 Then curlist.tailfield := 29999
  Else nest[0].tailfield 
    := 29999{:995};
  10:
End;{:994}{1030:}{1043:}
Procedure appspace;

Var q: halfword;
Begin
  If (curlist.auxfield.hh.lh>=2000)And(eqtb[2895].hh.rh<>0)Then q := 
                                                                     newparamglue(13)
  Else
    Begin
      If eqtb[2894].hh.rh<>0 Then mainp := eqtb[2894]
                                           .hh.rh
      Else{1042:}
        Begin
          mainp := fontglue[eqtb[3934].hh.rh];
          If mainp=0 Then
            Begin
              mainp := newspec(0);
              maink := parambase[eqtb[3934].hh.rh]+2;
              mem[mainp+1].int := fontinfo[maink].int;
              mem[mainp+2].int := fontinfo[maink+1].int;
              mem[mainp+3].int := fontinfo[maink+2].int;
              fontglue[eqtb[3934].hh.rh] := mainp;
            End;
        End{:1042};
      mainp := newspec(mainp);
{1044:}
      If curlist.auxfield.hh.lh>=2000 Then mem[mainp+1].int := mem[mainp
                                                               +1].int+fontinfo[7+parambase[eqtb[
                                                               3934].hh.rh]].int;
      mem[mainp+2].int := xnoverd(mem[mainp+2].int,curlist.auxfield.hh.lh,1000);
      mem[mainp+3].int := xnoverd(mem[mainp+3].int,1000,curlist.auxfield.hh.lh)
{:1044};
      q := newglue(mainp);
      mem[mainp].hh.rh := 0;
    End;
  mem[curlist.tailfield].hh.rh := q;
  curlist.tailfield := q;
End;
{:1043}{1047:}
Procedure insertdollarsign;
Begin
  backinput;
  curtok := 804;
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1018);
  End;
  Begin
    helpptr := 2;
    helpline[1] := 1019;
    helpline[0] := 1020;
  End;
  inserror;
End;
{:1047}{1049:}
Procedure youcant;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(685);
  End;
  printcmdchr(curcmd,curchr);
  print(1021);
  printmode(curlist.modefield);
End;
{:1049}{1050:}
Procedure reportillegalcase;
Begin
  youcant;
  Begin
    helpptr := 4;
    helpline[3] := 1022;
    helpline[2] := 1023;
    helpline[1] := 1024;
    helpline[0] := 1025;
  End;
  error;
End;
{:1050}{1051:}
Function privileged: boolean;
Begin
  If curlist.modefield>0 Then privileged := true
  Else
    Begin
      reportillegalcase;
      privileged := false;
    End;
End;
{:1051}{1054:}
Function itsallover: boolean;

Label 10;
Begin
  If privileged Then
    Begin
      If (29998=pagetail)And(curlist.headfield=
         curlist.tailfield)And(deadcycles=0)Then
        Begin
          itsallover := true;
          goto 10;
        End;
      backinput;
      Begin
        mem[curlist.tailfield].hh.rh := newnullbox;
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      mem[curlist.tailfield+1].int := eqtb[5833].int;
      Begin
        mem[curlist.tailfield].hh.rh := newglue(8);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      Begin
        mem[curlist.tailfield].hh.rh := newpenalty(-1073741824);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      buildpage;
    End;
  itsallover := false;
  10:
End;{:1054}{1060:}
Procedure appendglue;

Var s: smallnumber;
Begin
  s := curchr;
  Case s Of 
    0: curval := 4;
    1: curval := 8;
    2: curval := 12;
    3: curval := 16;
    4: scanglue(2);
    5: scanglue(3);
  End;
  Begin
    mem[curlist.tailfield].hh.rh := newglue(curval);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  If s>=4 Then
    Begin
      mem[curval].hh.rh := mem[curval].hh.rh-1;
      If s>4 Then mem[curlist.tailfield].hh.b1 := 99;
    End;
End;
{:1060}{1061:}
Procedure appendkern;

Var s: quarterword;
Begin
  s := curchr;
  scandimen(s=99,false,false);
  Begin
    mem[curlist.tailfield].hh.rh := newkern(curval);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  mem[curlist.tailfield].hh.b1 := s;
End;{:1061}{1064:}
Procedure offsave;

Var p: halfword;
Begin
  If curgroup=0 Then{1066:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(777);
      End;
      printcmdchr(curcmd,curchr);
      Begin
        helpptr := 1;
        helpline[0] := 1044;
      End;
      error;
    End{:1066}
  Else
    Begin
      backinput;
      p := getavail;
      mem[29997].hh.rh := p;
      Begin
        If interaction=3 Then;
        printnl(262);
        print(625);
      End;{1065:}
      Case curgroup Of 
        14:
            Begin
              mem[p].hh.lh := 6711;
              printesc(516);
            End;
        15:
            Begin
              mem[p].hh.lh := 804;
              printchar(36);
            End;
        16:
            Begin
              mem[p].hh.lh := 6712;
              mem[p].hh.rh := getavail;
              p := mem[p].hh.rh;
              mem[p].hh.lh := 3118;
              printesc(1043);
            End;
        Else
          Begin
            mem[p].hh.lh := 637;
            printchar(125);
          End
      End{:1065};
      print(626);
      begintokenlist(mem[29997].hh.rh,4);
      Begin
        helpptr := 5;
        helpline[4] := 1038;
        helpline[3] := 1039;
        helpline[2] := 1040;
        helpline[1] := 1041;
        helpline[0] := 1042;
      End;
      error;
    End;
End;{:1064}{1069:}
Procedure extrarightbrace;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1049);
  End;
  Case curgroup Of 
    14: printesc(516);
    15: printchar(36);
    16: printesc(878);
  End;
  Begin
    helpptr := 5;
    helpline[4] := 1050;
    helpline[3] := 1051;
    helpline[2] := 1052;
    helpline[1] := 1053;
    helpline[0] := 1054;
  End;
  error;
  alignstate := alignstate+1;
End;{:1069}{1070:}
Procedure normalparagraph;
Begin
  If eqtb[5282].int<>0 Then eqworddefine(5282,0);
  If eqtb[5847].int<>0 Then eqworddefine(5847,0);
  If eqtb[5304].int<>1 Then eqworddefine(5304,1);
  If eqtb[3412].hh.rh<>0 Then eqdefine(3412,118,0);
End;
{:1070}{1075:}
Procedure boxend(boxcontext:integer);

Var p: halfword;
Begin
  If boxcontext<1073741824 Then{1076:}
    Begin
      If curbox<>0 Then
        Begin
          mem[curbox+4].int := boxcontext;
          If abs(curlist.modefield)=1 Then
            Begin
              appendtovlist(curbox);
              If adjusttail<>0 Then
                Begin
                  If 29995<>adjusttail Then
                    Begin
                      mem[curlist.
                      tailfield].hh.rh := mem[29995].hh.rh;
                      curlist.tailfield := adjusttail;
                    End;
                  adjusttail := 0;
                End;
              If curlist.modefield>0 Then buildpage;
            End
          Else
            Begin
              If abs(curlist.modefield)=102 Then curlist.auxfield.hh.lh 
                := 1000
              Else
                Begin
                  p := newnoad;
                  mem[p+1].hh.rh := 2;
                  mem[p+1].hh.lh := curbox;
                  curbox := p;
                End;
              mem[curlist.tailfield].hh.rh := curbox;
              curlist.tailfield := curbox;
            End;
        End;
    End{:1076}
  Else If boxcontext<1073742336 Then{1077:}If boxcontext<
                                              1073742080 Then eqdefine(-1073738146+boxcontext,119,
                                                                       curbox)
  Else
    geqdefine(-1073738402+boxcontext,119,curbox){:1077}
  Else If curbox<>0
         Then If boxcontext>1073742336 Then{1078:}
                Begin{404:}
                  Repeat
                    getxtoken;
                  Until (curcmd<>10)And(curcmd<>0){:404};
                  If ((curcmd=26)And(abs(curlist.modefield)<>1))Or((curcmd=27)And(abs(
                     curlist.modefield)=1))Then
                    Begin
                      appendglue;
                      mem[curlist.tailfield].hh.b1 := boxcontext-(1073742237);
                      mem[curlist.tailfield+1].hh.rh := curbox;
                    End
                  Else
                    Begin
                      Begin
                        If interaction=3 Then;
                        printnl(262);
                        print(1067);
                      End;
                      Begin
                        helpptr := 3;
                        helpline[2] := 1068;
                        helpline[1] := 1069;
                        helpline[0] := 1070;
                      End;
                      backerror;
                      flushnodelist(curbox);
                    End;
                End{:1078}
  Else shipout(curbox);
End;{:1075}{1079:}
Procedure beginbox(boxcontext:integer);

Label 10,30;

Var p,q: halfword;
  m: quarterword;
  k: halfword;
  n: eightbits;
Begin
  Case curchr Of 
    0:
       Begin
         scaneightbitint;
         curbox := eqtb[3678+curval].hh.rh;
         eqtb[3678+curval].hh.rh := 0;
       End;
    1:
       Begin
         scaneightbitint;
         curbox := copynodelist(eqtb[3678+curval].hh.rh);
       End;
    2:{1080:}
       Begin
         curbox := 0;
         If abs(curlist.modefield)=203 Then
           Begin
             youcant;
             Begin
               helpptr := 1;
               helpline[0] := 1071;
             End;
             error;
           End
         Else If (curlist.modefield=1)And(curlist.headfield=curlist.tailfield)
                Then
                Begin
                  youcant;
                  Begin
                    helpptr := 2;
                    helpline[1] := 1072;
                    helpline[0] := 1073;
                  End;
                  error;
                End
         Else
           Begin
             If Not(curlist.tailfield>=himemmin)Then If (mem[curlist.
                                                        tailfield].hh.b0=0)Or(mem[curlist.tailfield]
                                                        .hh.b0=1)Then{1081:}
                                                       Begin
                                                         q 
                                                         := curlist.headfield;
                                                         Repeat
                                                           p := q;
                                                           If Not(q>=himemmin)Then If mem[q].hh.b0=7
                                                                                     Then
                                                                                     Begin
                                                                                       For m:=1 To
                                                                                           mem[q].
                                                                                           hh.b1 Do
                                                                                         p := mem[p]
                                                                                              .hh.rh
                                                                                       ;
                                                                                       If p=curlist.
                                                                                          tailfield
                                                                                         Then goto
                                                                                         30;
                                                                                     End;
                                                           q := mem[p].hh.rh;
                                                         Until q=curlist.tailfield;
                                                         curbox := curlist.tailfield;
                                                         mem[curbox+4].int := 0;
                                                         curlist.tailfield := p;
                                                         mem[p].hh.rh := 0;
                                                         30:
                                                       End{:1081};
           End;
       End{:1080};
    3:{1082:}
       Begin
         scaneightbitint;
         n := curval;
         If Not scankeyword(843)Then
           Begin
             Begin
               If interaction=3 Then;
               printnl(262);
               print(1074);
             End;
             Begin
               helpptr := 2;
               helpline[1] := 1075;
               helpline[0] := 1076;
             End;
             error;
           End;
         scandimen(false,false,false);
         curbox := vsplit(n,curval);
       End{:1082};
    Else{1083:}
      Begin
        k := curchr-4;
        savestack[saveptr+0].int := boxcontext;
        If k=102 Then If (boxcontext<1073741824)And(abs(curlist.modefield)=1)Then
                        scanspec(3,true)
        Else scanspec(2,true)
        Else
          Begin
            If k=1 Then scanspec(4,
                                 true)
            Else
              Begin
                scanspec(5,true);
                k := 1;
              End;
            normalparagraph;
          End;
        pushnest;
        curlist.modefield := -k;
        If k=1 Then
          Begin
            curlist.auxfield.int := -65536000;
            If eqtb[3418].hh.rh<>0 Then begintokenlist(eqtb[3418].hh.rh,11);
          End
        Else
          Begin
            curlist.auxfield.hh.lh := 1000;
            If eqtb[3417].hh.rh<>0 Then begintokenlist(eqtb[3417].hh.rh,10);
          End;
        goto 10;
      End{:1083}
  End;
  boxend(boxcontext);
  10:
End;
{:1079}{1084:}
Procedure scanbox(boxcontext:integer);
Begin{404:}
  Repeat
    getxtoken;
  Until (curcmd<>10)And(curcmd<>0){:404};
  If curcmd=20 Then beginbox(boxcontext)
  Else If (boxcontext>=1073742337)And
          ((curcmd=36)Or(curcmd=35))Then
         Begin
           curbox := scanrulespec;
           boxend(boxcontext);
         End
  Else
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1077);
      End;
      Begin
        helpptr := 3;
        helpline[2] := 1078;
        helpline[1] := 1079;
        helpline[0] := 1080;
      End;
      backerror;
    End;
End;
{:1084}{1086:}
Procedure package(c:smallnumber);

Var h: scaled;
  p: halfword;
  d: scaled;
Begin
  d := eqtb[5837].int;
  unsave;
  saveptr := saveptr-3;
  If curlist.modefield=-102 Then curbox := hpack(mem[curlist.headfield].hh.
                                           rh,savestack[saveptr+2].int,savestack[saveptr+1].int)
  Else
    Begin
      curbox := 
                vpackage(mem[curlist.headfield].hh.rh,savestack[saveptr+2].int,savestack
                [saveptr+1].int,d);
      If c=4 Then{1087:}
        Begin
          h := 0;
          p := mem[curbox+5].hh.rh;
          If p<>0 Then If mem[p].hh.b0<=2 Then h := mem[p+3].int;
          mem[curbox+2].int := mem[curbox+2].int-h+mem[curbox+3].int;
          mem[curbox+3].int := h;
        End{:1087};
    End;
  popnest;
  boxend(savestack[saveptr+0].int);
End;
{:1086}{1091:}
Function normmin(h:integer): smallnumber;
Begin
  If h<=0 Then normmin := 1
  Else If h>=63 Then normmin := 63
  Else
    normmin := h;
End;
Procedure newgraf(indented:boolean);
Begin
  curlist.pgfield := 0;
  If (curlist.modefield=1)Or(curlist.headfield<>curlist.tailfield)Then
    Begin
      mem[curlist.tailfield].hh.rh := newparamglue(2);
      curlist.tailfield := mem[curlist.tailfield].hh.rh;
    End;
  pushnest;
  curlist.modefield := 102;
  curlist.auxfield.hh.lh := 1000;
  If eqtb[5313].int<=0 Then curlang := 0
  Else If eqtb[5313].int>255 Then
         curlang := 0
  Else curlang := eqtb[5313].int;
  curlist.auxfield.hh.rh := curlang;
  curlist.pgfield := (normmin(eqtb[5314].int)*64+normmin(eqtb[5315].int))
                     *65536+curlang;
  If indented Then
    Begin
      curlist.tailfield := newnullbox;
      mem[curlist.headfield].hh.rh := curlist.tailfield;
      mem[curlist.tailfield+1].int := eqtb[5830].int;
    End;
  If eqtb[3414].hh.rh<>0 Then begintokenlist(eqtb[3414].hh.rh,7);
  If nestptr=1 Then buildpage;
End;{:1091}{1093:}
Procedure indentinhmode;

Var p,q: halfword;
Begin
  If curchr>0 Then
    Begin
      p := newnullbox;
      mem[p+1].int := eqtb[5830].int;
      If abs(curlist.modefield)=102 Then curlist.auxfield.hh.lh := 1000
      Else
        Begin
          q := newnoad;
          mem[q+1].hh.rh := 2;
          mem[q+1].hh.lh := p;
          p := q;
        End;
      Begin
        mem[curlist.tailfield].hh.rh := p;
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
    End;
End;
{:1093}{1095:}
Procedure headforvmode;
Begin
  If curlist.modefield<0 Then If curcmd<>36 Then offsave
  Else
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(685);
      End;
      printesc(521);
      print(1083);
      Begin
        helpptr := 2;
        helpline[1] := 1084;
        helpline[0] := 1085;
      End;
      error;
    End
  Else
    Begin
      backinput;
      curtok := partoken;
      backinput;
      curinput.indexfield := 4;
    End;
End;{:1095}{1096:}
Procedure endgraf;
Begin
  If curlist.modefield=102 Then
    Begin
      If curlist.headfield=curlist.
         tailfield Then popnest
      Else linebreak(eqtb[5269].int);
      normalparagraph;
      errorcount := 0;
    End;
End;{:1096}{1099:}
Procedure begininsertoradjust;
Begin
  If curcmd=38 Then curval := 255
  Else
    Begin
      scaneightbitint;
      If curval=255 Then
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(1086);
          End;
          printesc(330);
          printint(255);
          Begin
            helpptr := 1;
            helpline[0] := 1087;
          End;
          error;
          curval := 0;
        End;
    End;
  savestack[saveptr+0].int := curval;
  saveptr := saveptr+1;
  newsavelevel(11);
  scanleftbrace;
  normalparagraph;
  pushnest;
  curlist.modefield := -1;
  curlist.auxfield.int := -65536000;
End;{:1099}{1101:}
Procedure makemark;

Var p: halfword;
Begin
  p := scantoks(false,true);
  p := getnode(2);
  mem[p].hh.b0 := 4;
  mem[p].hh.b1 := 0;
  mem[p+1].int := defref;
  mem[curlist.tailfield].hh.rh := p;
  curlist.tailfield := p;
End;
{:1101}{1103:}
Procedure appendpenalty;
Begin
  scanint;
  Begin
    mem[curlist.tailfield].hh.rh := newpenalty(curval);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  If curlist.modefield=1 Then buildpage;
End;
{:1103}{1105:}
Procedure deletelast;

Label 10;

Var p,q: halfword;
  m: quarterword;
Begin
  If (curlist.modefield=1)And(curlist.tailfield=curlist.headfield)
    Then{1106:}
    Begin
      If (curchr<>10)Or(lastglue<>65535)Then
        Begin
          youcant;
          Begin
            helpptr := 2;
            helpline[1] := 1072;
            helpline[0] := 1088;
          End;
          If curchr=11 Then helpline[0] := (1089)
          Else If curchr<>10 Then helpline[0] 
                 := (1090);
          error;
        End;
    End{:1106}
  Else
    Begin
      If Not(curlist.tailfield>=himemmin)Then If mem[
                                                 curlist.tailfield].hh.b0=curchr Then
                                                Begin
                                                  q := curlist.headfield;
                                                  Repeat
                                                    p := q;
                                                    If Not(q>=himemmin)Then If mem[q].hh.b0=7 Then
                                                                              Begin
                                                                                For m:=1 To mem[q].
                                                                                    hh.b1 Do
                                                                                  p := mem[p].hh.rh;
                                                                                If p=curlist.
                                                                                   tailfield Then
                                                                                  goto 10;
                                                                              End;
                                                    q := mem[p].hh.rh;
                                                  Until q=curlist.tailfield;
                                                  mem[p].hh.rh := 0;
                                                  flushnodelist(curlist.tailfield);
                                                  curlist.tailfield := p;
                                                End;
    End;
  10:
End;
{:1105}{1110:}
Procedure unpackage;

Label 10;

Var p: halfword;
  c: 0..1;
Begin
  c := curchr;
  scaneightbitint;
  p := eqtb[3678+curval].hh.rh;
  If p=0 Then goto 10;
  If (abs(curlist.modefield)=203)Or((abs(curlist.modefield)=1)And(mem[p].hh
     .b0<>1))Or((abs(curlist.modefield)=102)And(mem[p].hh.b0<>0))Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1098);
      End;
      Begin
        helpptr := 3;
        helpline[2] := 1099;
        helpline[1] := 1100;
        helpline[0] := 1101;
      End;
      error;
      goto 10;
    End;
  If c=1 Then mem[curlist.tailfield].hh.rh := copynodelist(mem[p+5].hh.rh)
  Else
    Begin
      mem[curlist.tailfield].hh.rh := mem[p+5].hh.rh;
      eqtb[3678+curval].hh.rh := 0;
      freenode(p,7);
    End;
  While mem[curlist.tailfield].hh.rh<>0 Do
    curlist.tailfield := mem[curlist.
                         tailfield].hh.rh;
  10:
End;{:1110}{1113:}
Procedure appenditaliccorrection;

Label 10;

Var p: halfword;
  f: internalfontnumber;
Begin
  If curlist.tailfield<>curlist.headfield Then
    Begin
      If (curlist.
         tailfield>=himemmin)Then p := curlist.tailfield
      Else If mem[curlist.
              tailfield].hh.b0=6 Then p := curlist.tailfield+1
      Else goto 10;
      f := mem[p].hh.b0;
      Begin
        mem[curlist.tailfield].hh.rh := newkern(fontinfo[italicbase[f]+(
                                        fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b2)Div 4].int);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      mem[curlist.tailfield].hh.b1 := 1;
    End;
  10:
End;
{:1113}{1117:}
Procedure appenddiscretionary;

Var c: integer;
Begin
  Begin
    mem[curlist.tailfield].hh.rh := newdisc;
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  If curchr=1 Then
    Begin
      c := hyphenchar[eqtb[3934].hh.rh];
      If c>=0 Then If c<256 Then mem[curlist.tailfield+1].hh.lh := newcharacter(
                                                                   eqtb[3934].hh.rh,c);
    End
  Else
    Begin
      saveptr := saveptr+1;
      savestack[saveptr-1].int := 0;
      newsavelevel(10);
      scanleftbrace;
      pushnest;
      curlist.modefield := -102;
      curlist.auxfield.hh.lh := 1000;
    End;
End;
{:1117}{1119:}
Procedure builddiscretionary;

Label 30,10;

Var p,q: halfword;
  n: integer;
Begin
  unsave;{1121:}
  q := curlist.headfield;
  p := mem[q].hh.rh;
  n := 0;
  While p<>0 Do
    Begin
      If Not(p>=himemmin)Then If mem[p].hh.b0>2 Then If 
                                                        mem[p].hh.b0<>11 Then If mem[p].hh.b0<>6
                                                                                Then
                                                                                Begin
                                                                                  Begin
                                                                                    If interaction
                                                                                       =3 Then;
                                                                                    printnl(262);
                                                                                    print(1108);
                                                                                  End;
                                                                                  Begin
                                                                                    helpptr := 1;
                                                                                    helpline[0] := 
                                                                                                1109
                                                                                    ;
                                                                                  End;
                                                                                  error;
                                                                                  begindiagnostic;
                                                                                  printnl(1110);
                                                                                  showbox(p);
                                                                                  enddiagnostic(true
                                                                                  );
                                                                                  flushnodelist(p);
                                                                                  mem[q].hh.rh := 0;
                                                                                  goto 30;
                                                                                End;
      q := p;
      p := mem[q].hh.rh;
      n := n+1;
    End;
  30:{:1121};
  p := mem[curlist.headfield].hh.rh;
  popnest;
  Case savestack[saveptr-1].int Of 
    0: mem[curlist.tailfield+1].hh.lh := p;
    1: mem[curlist.tailfield+1].hh.rh := p;
    2:{1120:}
       Begin
         If (n>0)And(abs(curlist.modefield)=203)Then
           Begin
             Begin
               If 
                  interaction=3 Then;
               printnl(262);
               print(1102);
             End;
             printesc(349);
             Begin
               helpptr := 2;
               helpline[1] := 1103;
               helpline[0] := 1104;
             End;
             flushnodelist(p);
             n := 0;
             error;
           End
         Else mem[curlist.tailfield].hh.rh := p;
         If n<=255 Then mem[curlist.tailfield].hh.b1 := n
         Else
           Begin
             Begin
               If 
                  interaction=3 Then;
               printnl(262);
               print(1105);
             End;
             Begin
               helpptr := 2;
               helpline[1] := 1106;
               helpline[0] := 1107;
             End;
             error;
           End;
         If n>0 Then curlist.tailfield := q;
         saveptr := saveptr-1;
         goto 10;
       End{:1120};
  End;
  savestack[saveptr-1].int := savestack[saveptr-1].int+1;
  newsavelevel(10);
  scanleftbrace;
  pushnest;
  curlist.modefield := -102;
  curlist.auxfield.hh.lh := 1000;
  10:
End;{:1119}{1123:}
Procedure makeaccent;

Var s,t: real;
  p,q,r: halfword;
  f: internalfontnumber;
  a,h,x,w,delta: scaled;
  i: fourquarters;
Begin
  scancharnum;
  f := eqtb[3934].hh.rh;
  p := newcharacter(f,curval);
  If p<>0 Then
    Begin
      x := fontinfo[5+parambase[f]].int;
      s := fontinfo[1+parambase[f]].int/65536.0;
      a := fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
      ;
      doassignments;{1124:}
      q := 0;
      f := eqtb[3934].hh.rh;
      If (curcmd=11)Or(curcmd=12)Or(curcmd=68)Then q := newcharacter(f,curchr)
      Else If curcmd=16 Then
             Begin
               scancharnum;
               q := newcharacter(f,curval);
             End
      Else backinput{:1124};
      If q<>0 Then{1125:}
        Begin
          t := fontinfo[1+parambase[f]].int/65536.0;
          i := fontinfo[charbase[f]+mem[q].hh.b1].qqqq;
          w := fontinfo[widthbase[f]+i.b0].int;
          h := fontinfo[heightbase[f]+(i.b1)Div 16].int;
          If h<>x Then
            Begin
              p := hpack(p,0,1);
              mem[p+4].int := x-h;
            End;
          delta := round((w-a)/2.0+h*t-x*s);
          r := newkern(delta);
          mem[r].hh.b1 := 2;
          mem[curlist.tailfield].hh.rh := r;
          mem[r].hh.rh := p;
          curlist.tailfield := newkern(-a-delta);
          mem[curlist.tailfield].hh.b1 := 2;
          mem[p].hh.rh := curlist.tailfield;
          p := q;
        End{:1125};
      mem[curlist.tailfield].hh.rh := p;
      curlist.tailfield := p;
      curlist.auxfield.hh.lh := 1000;
    End;
End;{:1123}{1127:}
Procedure alignerror;
Begin
  If abs(alignstate)>2 Then{1128:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1115);
      End;
      printcmdchr(curcmd,curchr);
      If curtok=1062 Then
        Begin
          Begin
            helpptr := 6;
            helpline[5] := 1116;
            helpline[4] := 1117;
            helpline[3] := 1118;
            helpline[2] := 1119;
            helpline[1] := 1120;
            helpline[0] := 1121;
          End;
        End
      Else
        Begin
          Begin
            helpptr := 5;
            helpline[4] := 1116;
            helpline[3] := 1122;
            helpline[2] := 1119;
            helpline[1] := 1120;
            helpline[0] := 1121;
          End;
        End;
      error;
    End{:1128}
  Else
    Begin
      backinput;
      If alignstate<0 Then
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(657);
          End;
          alignstate := alignstate+1;
          curtok := 379;
        End
      Else
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(1111);
          End;
          alignstate := alignstate-1;
          curtok := 637;
        End;
      Begin
        helpptr := 3;
        helpline[2] := 1112;
        helpline[1] := 1113;
        helpline[0] := 1114;
      End;
      inserror;
    End;
End;{:1127}{1129:}
Procedure noalignerror;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1115);
  End;
  printesc(527);
  Begin
    helpptr := 2;
    helpline[1] := 1123;
    helpline[0] := 1124;
  End;
  error;
End;
Procedure omiterror;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1115);
  End;
  printesc(530);
  Begin
    helpptr := 2;
    helpline[1] := 1125;
    helpline[0] := 1124;
  End;
  error;
End;
{:1129}{1131:}
Procedure doendv;
Begin
  baseptr := inputptr;
  inputstack[baseptr] := curinput;
  While (inputstack[baseptr].indexfield<>2)And(inputstack[baseptr].locfield
        =0)And(inputstack[baseptr].statefield=0) Do
    baseptr := baseptr-1;
  If (inputstack[baseptr].indexfield<>2)Or(inputstack[baseptr].locfield<>0)
     Or(inputstack[baseptr].statefield<>0)Then fatalerror(595);
  If curgroup=6 Then
    Begin
      endgraf;
      If fincol Then finrow;
    End
  Else offsave;
End;{:1131}{1135:}
Procedure cserror;
Begin
  Begin
    If interaction=3 Then;
    printnl(262);
    print(777);
  End;
  printesc(505);
  Begin
    helpptr := 1;
    helpline[0] := 1127;
  End;
  error;
End;
{:1135}{1136:}
Procedure pushmath(c:groupcode);
Begin
  pushnest;
  curlist.modefield := -203;
  curlist.auxfield.int := 0;
  newsavelevel(c);
End;
{:1136}{1138:}
Procedure initmath;

Label 21,40,45,30;

Var w: scaled;
  l: scaled;
  s: scaled;
  p: halfword;
  q: halfword;
  f: internalfontnumber;
  n: integer;
  v: scaled;
  d: scaled;
Begin
  gettoken;
  If (curcmd=3)And(curlist.modefield>0)Then{1145:}
    Begin
      If curlist.
         headfield=curlist.tailfield Then
        Begin
          popnest;
          w := -1073741823;
        End
      Else
        Begin
          linebreak(eqtb[5270].int);
{1146:}
          v := mem[justbox+4].int+2*fontinfo[6+parambase[eqtb[3934].hh.rh]].
               int;
          w := -1073741823;
          p := mem[justbox+5].hh.rh;
          While p<>0 Do
            Begin{1147:}
              21: If (p>=himemmin)Then
                    Begin
                      f := mem[p].hh.b0;
                      d := fontinfo[widthbase[f]+fontinfo[charbase[f]+mem[p].hh.b1].qqqq.b0].int
                      ;
                      goto 40;
                    End;
              Case mem[p].hh.b0 Of 
                0,1,2:
                       Begin
                         d := mem[p+1].int;
                         goto 40;
                       End;
                6:{652:}
                   Begin
                     mem[29988] := mem[p+1];
                     mem[29988].hh.rh := mem[p].hh.rh;
                     p := 29988;
                     goto 21;
                   End{:652};
                11,9: d := mem[p+1].int;
                10:{1148:}
                    Begin
                      q := mem[p+1].hh.lh;
                      d := mem[q+1].int;
                      If mem[justbox+5].hh.b0=1 Then
                        Begin
                          If (mem[justbox+5].hh.b1=mem[q].hh.
                             b0)And(mem[q+2].int<>0)Then v := 1073741823;
                        End
                      Else If mem[justbox+5].hh.b0=2 Then
                             Begin
                               If (mem[justbox+5].hh.b1=
                                  mem[q].hh.b1)And(mem[q+3].int<>0)Then v := 1073741823;
                             End;
                      If mem[p].hh.b1>=100 Then goto 40;
                    End{:1148};
                8:{1361:}d := 0{:1361};
                Else d := 0
              End{:1147};
              If v<1073741823 Then v := v+d;
              goto 45;
              40: If v<1073741823 Then
                    Begin
                      v := v+d;
                      w := v;
                    End
                  Else
                    Begin
                      w := 1073741823;
                      goto 30;
                    End;
              45: p := mem[p].hh.rh;
            End;
          30:{:1146};
        End;
{1149:}
      If eqtb[3412].hh.rh=0 Then If (eqtb[5847].int<>0)And(((eqtb[5304].
                                    int>=0)And(curlist.pgfield+2>eqtb[5304].int))Or(curlist.pgfield+
                                    1<-eqtb[
                                    5304].int))Then
                                   Begin
                                     l := eqtb[5833].int-abs(eqtb[5847].int);
                                     If eqtb[5847].int>0 Then s := eqtb[5847].int
                                     Else s := 0;
                                   End
      Else
        Begin
          l := eqtb[5833].int;
          s := 0;
        End
      Else
        Begin
          n := mem[eqtb[3412].hh.rh].hh.lh;
          If curlist.pgfield+2>=n Then p := eqtb[3412].hh.rh+2*n
          Else p := eqtb[3412].
                    hh.rh+2*(curlist.pgfield+2);
          s := mem[p-1].int;
          l := mem[p].int;
        End{:1149};
      pushmath(15);
      curlist.modefield := 203;
      eqworddefine(5307,-1);
      eqworddefine(5843,w);
      eqworddefine(5844,l);
      eqworddefine(5845,s);
      If eqtb[3416].hh.rh<>0 Then begintokenlist(eqtb[3416].hh.rh,9);
      If nestptr=1 Then buildpage;
    End{:1145}
  Else
    Begin
      backinput;
{1139:}
      Begin
        pushmath(15);
        eqworddefine(5307,-1);
        If eqtb[3415].hh.rh<>0 Then begintokenlist(eqtb[3415].hh.rh,8);
      End{:1139};
    End;
End;{:1138}{1142:}
Procedure starteqno;
Begin
  savestack[saveptr+0].int := curchr;
  saveptr := saveptr+1;
{1139:}
  Begin
    pushmath(15);
    eqworddefine(5307,-1);
    If eqtb[3415].hh.rh<>0 Then begintokenlist(eqtb[3415].hh.rh,8);
  End{:1139};
End;{:1142}{1151:}
Procedure scanmath(p:halfword);

Label 20,21,10;

Var c: integer;
Begin
  20:{404:}Repeat
             getxtoken;
      Until (curcmd<>10)And(curcmd<>0){:404};
  21: Case curcmd Of 
        11,12,68:
                  Begin
                    c := eqtb[5007+curchr].hh.rh;
                    If c=32768 Then
                      Begin{1152:}
                        Begin
                          curcs := curchr+1;
                          curcmd := eqtb[curcs].hh.b0;
                          curchr := eqtb[curcs].hh.rh;
                          xtoken;
                          backinput;
                        End{:1152};
                        goto 20;
                      End;
                  End;
        16:
            Begin
              scancharnum;
              curchr := curval;
              curcmd := 68;
              goto 21;
            End;
        17:
            Begin
              scanfifteenbitint;
              c := curval;
            End;
        69: c := curchr;
        15:
            Begin
              scantwentysevenbitint;
              c := curval Div 4096;
            End;
        Else{1153:}
          Begin
            backinput;
            scanleftbrace;
            savestack[saveptr+0].int := p;
            saveptr := saveptr+1;
            pushmath(9);
            goto 10;
          End{:1153}
      End;
  mem[p].hh.rh := 1;
  mem[p].hh.b1 := c Mod 256;
  If (c>=28672)And((eqtb[5307].int>=0)And(eqtb[5307].int<16))Then mem[p].hh
    .b0 := eqtb[5307].int
  Else mem[p].hh.b0 := (c Div 256)Mod 16;
  10:
End;
{:1151}{1155:}
Procedure setmathchar(c:integer);

Var p: halfword;
Begin
  If c>=32768 Then{1152:}
    Begin
      curcs := curchr+1;
      curcmd := eqtb[curcs].hh.b0;
      curchr := eqtb[curcs].hh.rh;
      xtoken;
      backinput;
    End{:1152}
  Else
    Begin
      p := newnoad;
      mem[p+1].hh.rh := 1;
      mem[p+1].hh.b1 := c Mod 256;
      mem[p+1].hh.b0 := (c Div 256)Mod 16;
      If c>=28672 Then
        Begin
          If ((eqtb[5307].int>=0)And(eqtb[5307].int<16))Then
            mem[p+1].hh.b0 := eqtb[5307].int;
          mem[p].hh.b0 := 16;
        End
      Else mem[p].hh.b0 := 16+(c Div 4096);
      mem[curlist.tailfield].hh.rh := p;
      curlist.tailfield := p;
    End;
End;{:1155}{1159:}
Procedure mathlimitswitch;

Label 10;
Begin
  If curlist.headfield<>curlist.tailfield Then If mem[curlist.
                                                  tailfield].hh.b0=17 Then
                                                 Begin
                                                   mem[curlist.tailfield].hh.b1 := curchr;
                                                   goto 10;
                                                 End;
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1131);
  End;
  Begin
    helpptr := 1;
    helpline[0] := 1132;
  End;
  error;
  10:
End;
{:1159}{1160:}
Procedure scandelimiter(p:halfword;r:boolean);
Begin
  If r Then scantwentysevenbitint
  Else
    Begin{404:}
      Repeat
        getxtoken;
      Until (curcmd<>10)And(curcmd<>0){:404};
      Case curcmd Of 
        11,12: curval := eqtb[5574+curchr].int;
        15: scantwentysevenbitint;
        Else curval := -1
      End;
    End;
  If curval<0 Then{1161:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1133);
      End;
      Begin
        helpptr := 6;
        helpline[5] := 1134;
        helpline[4] := 1135;
        helpline[3] := 1136;
        helpline[2] := 1137;
        helpline[1] := 1138;
        helpline[0] := 1139;
      End;
      backerror;
      curval := 0;
    End{:1161};
  mem[p].qqqq.b0 := (curval Div 1048576)Mod 16;
  mem[p].qqqq.b1 := (curval Div 4096)Mod 256;
  mem[p].qqqq.b2 := (curval Div 256)Mod 16;
  mem[p].qqqq.b3 := curval Mod 256;
End;{:1160}{1163:}
Procedure mathradical;
Begin
  Begin
    mem[curlist.tailfield].hh.rh := getnode(5);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  mem[curlist.tailfield].hh.b0 := 24;
  mem[curlist.tailfield].hh.b1 := 0;
  mem[curlist.tailfield+1].hh := emptyfield;
  mem[curlist.tailfield+3].hh := emptyfield;
  mem[curlist.tailfield+2].hh := emptyfield;
  scandelimiter(curlist.tailfield+4,true);
  scanmath(curlist.tailfield+1);
End;{:1163}{1165:}
Procedure mathac;
Begin
  If curcmd=45 Then{1166:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1140);
      End;
      printesc(523);
      print(1141);
      Begin
        helpptr := 2;
        helpline[1] := 1142;
        helpline[0] := 1143;
      End;
      error;
    End{:1166};
  Begin
    mem[curlist.tailfield].hh.rh := getnode(5);
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  mem[curlist.tailfield].hh.b0 := 28;
  mem[curlist.tailfield].hh.b1 := 0;
  mem[curlist.tailfield+1].hh := emptyfield;
  mem[curlist.tailfield+3].hh := emptyfield;
  mem[curlist.tailfield+2].hh := emptyfield;
  mem[curlist.tailfield+4].hh.rh := 1;
  scanfifteenbitint;
  mem[curlist.tailfield+4].hh.b1 := curval Mod 256;
  If (curval>=28672)And((eqtb[5307].int>=0)And(eqtb[5307].int<16))Then mem[
    curlist.tailfield+4].hh.b0 := eqtb[5307].int
  Else mem[curlist.tailfield+4]
    .hh.b0 := (curval Div 256)Mod 16;
  scanmath(curlist.tailfield+1);
End;
{:1165}{1172:}
Procedure appendchoices;
Begin
  Begin
    mem[curlist.tailfield].hh.rh := newchoice;
    curlist.tailfield := mem[curlist.tailfield].hh.rh;
  End;
  saveptr := saveptr+1;
  savestack[saveptr-1].int := 0;
  pushmath(13);
  scanleftbrace;
End;
{:1172}{1174:}{1184:}
Function finmlist(p:halfword): halfword;

Var q: halfword;
Begin
  If curlist.auxfield.int<>0 Then{1185:}
    Begin
      mem[curlist.auxfield.
      int+3].hh.rh := 3;
      mem[curlist.auxfield.int+3].hh.lh := mem[curlist.headfield].hh.rh;
      If p=0 Then q := curlist.auxfield.int
      Else
        Begin
          q := mem[curlist.auxfield.
               int+2].hh.lh;
          If mem[q].hh.b0<>30 Then confusion(878);
          mem[curlist.auxfield.int+2].hh.lh := mem[q].hh.rh;
          mem[q].hh.rh := curlist.auxfield.int;
          mem[curlist.auxfield.int].hh.rh := p;
        End;
    End{:1185}
  Else
    Begin
      mem[curlist.tailfield].hh.rh := p;
      q := mem[curlist.headfield].hh.rh;
    End;
  popnest;
  finmlist := q;
End;
{:1184}
Procedure buildchoices;

Label 10;

Var p: halfword;
Begin
  unsave;
  p := finmlist(0);
  Case savestack[saveptr-1].int Of 
    0: mem[curlist.tailfield+1].hh.lh := p;
    1: mem[curlist.tailfield+1].hh.rh := p;
    2: mem[curlist.tailfield+2].hh.lh := p;
    3:
       Begin
         mem[curlist.tailfield+2].hh.rh := p;
         saveptr := saveptr-1;
         goto 10;
       End;
  End;
  savestack[saveptr-1].int := savestack[saveptr-1].int+1;
  pushmath(13);
  scanleftbrace;
  10:
End;{:1174}{1176:}
Procedure subsup;

Var t: smallnumber;
  p: halfword;
Begin
  t := 0;
  p := 0;
  If curlist.tailfield<>curlist.headfield Then If (mem[curlist.tailfield].
                                                  hh.b0>=16)And(mem[curlist.tailfield].hh.b0<30)Then
                                                 Begin
                                                   p := curlist.
                                                        tailfield+2+curcmd-7;
                                                   t := mem[p].hh.rh;
                                                 End;
  If (p=0)Or(t<>0)Then{1177:}
    Begin
      Begin
        mem[curlist.tailfield].hh.rh := 
                                        newnoad;
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      p := curlist.tailfield+2+curcmd-7;
      If t<>0 Then
        Begin
          If curcmd=7 Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1144);
              End;
              Begin
                helpptr := 1;
                helpline[0] := 1145;
              End;
            End
          Else
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1146);
              End;
              Begin
                helpptr := 1;
                helpline[0] := 1147;
              End;
            End;
          error;
        End;
    End{:1177};
  scanmath(p);
End;{:1176}{1181:}
Procedure mathfraction;

Var c: smallnumber;
Begin
  c := curchr;
  If curlist.auxfield.int<>0 Then{1183:}
    Begin
      If c>=3 Then
        Begin
          scandelimiter(29988,false);
          scandelimiter(29988,false);
        End;
      If c Mod 3=0 Then scandimen(false,false,false);
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1154);
      End;
      Begin
        helpptr := 3;
        helpline[2] := 1155;
        helpline[1] := 1156;
        helpline[0] := 1157;
      End;
      error;
    End{:1183}
  Else
    Begin
      curlist.auxfield.int := getnode(6);
      mem[curlist.auxfield.int].hh.b0 := 25;
      mem[curlist.auxfield.int].hh.b1 := 0;
      mem[curlist.auxfield.int+2].hh.rh := 3;
      mem[curlist.auxfield.int+2].hh.lh := mem[curlist.headfield].hh.rh;
      mem[curlist.auxfield.int+3].hh := emptyfield;
      mem[curlist.auxfield.int+4].qqqq := nulldelimiter;
      mem[curlist.auxfield.int+5].qqqq := nulldelimiter;
      mem[curlist.headfield].hh.rh := 0;
      curlist.tailfield := curlist.headfield;
{1182:}
      If c>=3 Then
        Begin
          scandelimiter(curlist.auxfield.int+4,false);
          scandelimiter(curlist.auxfield.int+5,false);
        End;
      Case c Mod 3 Of 
        0:
           Begin
             scandimen(false,false,false);
             mem[curlist.auxfield.int+1].int := curval;
           End;
        1: mem[curlist.auxfield.int+1].int := 1073741824;
        2: mem[curlist.auxfield.int+1].int := 0;
      End{:1182};
    End;
End;
{:1181}{1191:}
Procedure mathleftright;

Var t: smallnumber;
  p: halfword;
Begin
  t := curchr;
  If (t=31)And(curgroup<>16)Then{1192:}
    Begin
      If curgroup=15 Then
        Begin
          scandelimiter(29988,false);
          Begin
            If interaction=3 Then;
            printnl(262);
            print(777);
          End;
          printesc(878);
          Begin
            helpptr := 1;
            helpline[0] := 1158;
          End;
          error;
        End
      Else offsave;
    End{:1192}
  Else
    Begin
      p := newnoad;
      mem[p].hh.b0 := t;
      scandelimiter(p+1,false);
      If t=30 Then
        Begin
          pushmath(16);
          mem[curlist.headfield].hh.rh := p;
          curlist.tailfield := p;
        End
      Else
        Begin
          p := finmlist(p);
          unsave;
          Begin
            mem[curlist.tailfield].hh.rh := newnoad;
            curlist.tailfield := mem[curlist.tailfield].hh.rh;
          End;
          mem[curlist.tailfield].hh.b0 := 23;
          mem[curlist.tailfield+1].hh.rh := 3;
          mem[curlist.tailfield+1].hh.lh := p;
        End;
    End;
End;
{:1191}{1194:}
Procedure aftermath;

Var l: boolean;
  danger: boolean;
  m: integer;
  p: halfword;
  a: halfword;{1198:}
  b: halfword;
  w: scaled;
  z: scaled;
  e: scaled;
  q: scaled;
  d: scaled;
  s: scaled;
  g1,g2: smallnumber;
  r: halfword;
  t: halfword;{:1198}
Begin
  danger := false;
{1195:}
  If (fontparams[eqtb[3937].hh.rh]<22)Or(fontparams[eqtb[3953].hh.rh
     ]<22)Or(fontparams[eqtb[3969].hh.rh]<22)Then
    Begin
      Begin
        If interaction=
           3 Then;
        printnl(262);
        print(1159);
      End;
      Begin
        helpptr := 3;
        helpline[2] := 1160;
        helpline[1] := 1161;
        helpline[0] := 1162;
      End;
      error;
      flushmath;
      danger := true;
    End
  Else If (fontparams[eqtb[3938].hh.rh]<13)Or(fontparams[eqtb[3954].hh.
          rh]<13)Or(fontparams[eqtb[3970].hh.rh]<13)Then
         Begin
           Begin
             If 
                interaction=3 Then;
             printnl(262);
             print(1163);
           End;
           Begin
             helpptr := 3;
             helpline[2] := 1164;
             helpline[1] := 1165;
             helpline[0] := 1166;
           End;
           error;
           flushmath;
           danger := true;
         End{:1195};
  m := curlist.modefield;
  l := false;
  p := finmlist(0);
  If curlist.modefield=-m Then
    Begin{1197:}
      Begin
        getxtoken;
        If curcmd<>3 Then
          Begin
            Begin
              If interaction=3 Then;
              printnl(262);
              print(1167);
            End;
            Begin
              helpptr := 2;
              helpline[1] := 1168;
              helpline[0] := 1169;
            End;
            backerror;
          End;
      End{:1197};
      curmlist := p;
      curstyle := 2;
      mlistpenalties := false;
      mlisttohlist;
      a := hpack(mem[29997].hh.rh,0,1);
      unsave;
      saveptr := saveptr-1;
      If savestack[saveptr+0].int=1 Then l := true;
      danger := false;
{1195:}
      If (fontparams[eqtb[3937].hh.rh]<22)Or(fontparams[eqtb[3953].hh.rh
         ]<22)Or(fontparams[eqtb[3969].hh.rh]<22)Then
        Begin
          Begin
            If interaction=
               3 Then;
            printnl(262);
            print(1159);
          End;
          Begin
            helpptr := 3;
            helpline[2] := 1160;
            helpline[1] := 1161;
            helpline[0] := 1162;
          End;
          error;
          flushmath;
          danger := true;
        End
      Else If (fontparams[eqtb[3938].hh.rh]<13)Or(fontparams[eqtb[3954].hh.
              rh]<13)Or(fontparams[eqtb[3970].hh.rh]<13)Then
             Begin
               Begin
                 If 
                    interaction=3 Then;
                 printnl(262);
                 print(1163);
               End;
               Begin
                 helpptr := 3;
                 helpline[2] := 1164;
                 helpline[1] := 1165;
                 helpline[0] := 1166;
               End;
               error;
               flushmath;
               danger := true;
             End{:1195};
      m := curlist.modefield;
      p := finmlist(0);
    End
  Else a := 0;
  If m<0 Then{1196:}
    Begin
      Begin
        mem[curlist.tailfield].hh.rh := newmath(eqtb
                                        [5831].int,0);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      curmlist := p;
      curstyle := 2;
      mlistpenalties := (curlist.modefield>0);
      mlisttohlist;
      mem[curlist.tailfield].hh.rh := mem[29997].hh.rh;
      While mem[curlist.tailfield].hh.rh<>0 Do
        curlist.tailfield := mem[curlist.
                             tailfield].hh.rh;
      Begin
        mem[curlist.tailfield].hh.rh := newmath(eqtb[5831].int,1);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      curlist.auxfield.hh.lh := 1000;
      unsave;
    End{:1196}
  Else
    Begin
      If a=0 Then{1197:}
        Begin
          getxtoken;
          If curcmd<>3 Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1167);
              End;
              Begin
                helpptr := 2;
                helpline[1] := 1168;
                helpline[0] := 1169;
              End;
              backerror;
            End;
        End{:1197};{1199:}
      curmlist := p;
      curstyle := 0;
      mlistpenalties := false;
      mlisttohlist;
      p := mem[29997].hh.rh;
      adjusttail := 29995;
      b := hpack(p,0,1);
      p := mem[b+5].hh.rh;
      t := adjusttail;
      adjusttail := 0;
      w := mem[b+1].int;
      z := eqtb[5844].int;
      s := eqtb[5845].int;
      If (a=0)Or danger Then
        Begin
          e := 0;
          q := 0;
        End
      Else
        Begin
          e := mem[a+1].int;
          q := e+fontinfo[6+parambase[eqtb[3937].hh.rh]].int;
        End;
      If w+q>z Then{1201:}
        Begin
          If (e<>0)And((w-totalshrink[0]+q<=z)Or(
             totalshrink[1]<>0)Or(totalshrink[2]<>0)Or(totalshrink[3]<>0))Then
            Begin
              freenode(b,7);
              b := hpack(p,z-q,0);
            End
          Else
            Begin
              e := 0;
              If w>z Then
                Begin
                  freenode(b,7);
                  b := hpack(p,z,0);
                End;
            End;
          w := mem[b+1].int;
        End{:1201};{1202:}
      d := half(z-w);
      If (e>0)And(d<2*e)Then
        Begin
          d := half(z-w-e);
          If p<>0 Then If Not(p>=himemmin)Then If mem[p].hh.b0=10 Then d := 0;
        End{:1202};
{1203:}
      Begin
        mem[curlist.tailfield].hh.rh := newpenalty(eqtb[5274].int);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      If (d+s<=eqtb[5843].int)Or l Then
        Begin
          g1 := 3;
          g2 := 4;
        End
      Else
        Begin
          g1 := 5;
          g2 := 6;
        End;
      If l And(e=0)Then
        Begin
          mem[a+4].int := s;
          appendtovlist(a);
          Begin
            mem[curlist.tailfield].hh.rh := newpenalty(10000);
            curlist.tailfield := mem[curlist.tailfield].hh.rh;
          End;
        End
      Else
        Begin
          mem[curlist.tailfield].hh.rh := newparamglue(g1);
          curlist.tailfield := mem[curlist.tailfield].hh.rh;
        End{:1203};
{1204:}
      If e<>0 Then
        Begin
          r := newkern(z-w-e-d);
          If l Then
            Begin
              mem[a].hh.rh := r;
              mem[r].hh.rh := b;
              b := a;
              d := 0;
            End
          Else
            Begin
              mem[b].hh.rh := r;
              mem[r].hh.rh := a;
            End;
          b := hpack(b,0,1);
        End;
      mem[b+4].int := s+d;
      appendtovlist(b){:1204};
{1205:}
      If (a<>0)And(e=0)And Not l Then
        Begin
          Begin
            mem[curlist.tailfield]
            .hh.rh := newpenalty(10000);
            curlist.tailfield := mem[curlist.tailfield].hh.rh;
          End;
          mem[a+4].int := s+z-mem[a+1].int;
          appendtovlist(a);
          g2 := 0;
        End;
      If t<>29995 Then
        Begin
          mem[curlist.tailfield].hh.rh := mem[29995].hh.rh;
          curlist.tailfield := t;
        End;
      Begin
        mem[curlist.tailfield].hh.rh := newpenalty(eqtb[5275].int);
        curlist.tailfield := mem[curlist.tailfield].hh.rh;
      End;
      If g2>0 Then
        Begin
          mem[curlist.tailfield].hh.rh := newparamglue(g2);
          curlist.tailfield := mem[curlist.tailfield].hh.rh;
        End{:1205};
      resumeafterdisplay{:1199};
    End;
End;
{:1194}{1200:}
Procedure resumeafterdisplay;
Begin
  If curgroup<>15 Then confusion(1170);
  unsave;
  curlist.pgfield := curlist.pgfield+3;
  pushnest;
  curlist.modefield := 102;
  curlist.auxfield.hh.lh := 1000;
  If eqtb[5313].int<=0 Then curlang := 0
  Else If eqtb[5313].int>255 Then
         curlang := 0
  Else curlang := eqtb[5313].int;
  curlist.auxfield.hh.rh := curlang;
  curlist.pgfield := (normmin(eqtb[5314].int)*64+normmin(eqtb[5315].int))
                     *65536+curlang;{443:}
  Begin
    getxtoken;
    If curcmd<>10 Then backinput;
  End{:443};
  If nestptr=1 Then buildpage;
End;
{:1200}{1211:}{1215:}
Procedure getrtoken;

Label 20;
Begin
  20: Repeat
        gettoken;
      Until curtok<>2592;
  If (curcs=0)Or(curcs>2614)Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1185);
      End;
      Begin
        helpptr := 5;
        helpline[4] := 1186;
        helpline[3] := 1187;
        helpline[2] := 1188;
        helpline[1] := 1189;
        helpline[0] := 1190;
      End;
      If curcs=0 Then backinput;
      curtok := 6709;
      inserror;
      goto 20;
    End;
End;
{:1215}{1229:}
Procedure trapzeroglue;
Begin
  If (mem[curval+1].int=0)And(mem[curval+2].int=0)And(mem[curval+3].
     int=0)Then
    Begin
      mem[0].hh.rh := mem[0].hh.rh+1;
      deleteglueref(curval);
      curval := 0;
    End;
End;
{:1229}{1236:}
Procedure doregistercommand(a:smallnumber);

Label 40,10;

Var l,q,r,s: halfword;
  p: 0..3;
Begin
  q := curcmd;
{1237:}
  Begin
    If q<>89 Then
      Begin
        getxtoken;
        If (curcmd>=73)And(curcmd<=76)Then
          Begin
            l := curchr;
            p := curcmd-73;
            goto 40;
          End;
        If curcmd<>89 Then
          Begin
            Begin
              If interaction=3 Then;
              printnl(262);
              print(685);
            End;
            printcmdchr(curcmd,curchr);
            print(686);
            printcmdchr(q,0);
            Begin
              helpptr := 1;
              helpline[0] := 1211;
            End;
            error;
            goto 10;
          End;
      End;
    p := curchr;
    scaneightbitint;
    Case p Of 
      0: l := curval+5318;
      1: l := curval+5851;
      2: l := curval+2900;
      3: l := curval+3156;
    End;
  End;
  40:{:1237};
  If q=89 Then scanoptionalequals
  Else If scankeyword(1207)Then;
  aritherror := false;
  If q<91 Then{1238:}If p<2 Then
                       Begin
                         If p=0 Then scanint
                         Else scandimen(
                                        false,false,false);
                         If q=90 Then curval := curval+eqtb[l].int;
                       End
  Else
    Begin
      scanglue(p);
      If q=90 Then{1239:}
        Begin
          q := newspec(curval);
          r := eqtb[l].hh.rh;
          deleteglueref(curval);
          mem[q+1].int := mem[q+1].int+mem[r+1].int;
          If mem[q+2].int=0 Then mem[q].hh.b0 := 0;
          If mem[q].hh.b0=mem[r].hh.b0 Then mem[q+2].int := mem[q+2].int+mem[r+2].
                                                            int
          Else If (mem[q].hh.b0<mem[r].hh.b0)And(mem[r+2].int<>0)Then
                 Begin
                   mem
                   [q+2].int := mem[r+2].int;
                   mem[q].hh.b0 := mem[r].hh.b0;
                 End;
          If mem[q+3].int=0 Then mem[q].hh.b1 := 0;
          If mem[q].hh.b1=mem[r].hh.b1 Then mem[q+3].int := mem[q+3].int+mem[r+3].
                                                            int
          Else If (mem[q].hh.b1<mem[r].hh.b1)And(mem[r+3].int<>0)Then
                 Begin
                   mem
                   [q+3].int := mem[r+3].int;
                   mem[q].hh.b1 := mem[r].hh.b1;
                 End;
          curval := q;
        End{:1239};
    End{:1238}
  Else{1240:}
    Begin
      scanint;
      If p<2 Then If q=91 Then If p=0 Then curval := multandadd(eqtb[l].int,
                                                     curval,0,2147483647)
      Else curval := multandadd(eqtb[l].int,curval,0,
                     1073741823)
      Else curval := xovern(eqtb[l].int,curval)
      Else
        Begin
          s := eqtb[l].
               hh.rh;
          r := newspec(s);
          If q=91 Then
            Begin
              mem[r+1].int := multandadd(mem[s+1].int,curval,0,
                              1073741823);
              mem[r+2].int := multandadd(mem[s+2].int,curval,0,1073741823);
              mem[r+3].int := multandadd(mem[s+3].int,curval,0,1073741823);
            End
          Else
            Begin
              mem[r+1].int := xovern(mem[s+1].int,curval);
              mem[r+2].int := xovern(mem[s+2].int,curval);
              mem[r+3].int := xovern(mem[s+3].int,curval);
            End;
          curval := r;
        End;
    End{:1240};
  If aritherror Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(1208);
      End;
      Begin
        helpptr := 2;
        helpline[1] := 1209;
        helpline[0] := 1210;
      End;
      If p>=2 Then deleteglueref(curval);
      error;
      goto 10;
    End;
  If p<2 Then If (a>=4)Then geqworddefine(l,curval)
  Else eqworddefine(l,
                    curval)
  Else
    Begin
      trapzeroglue;
      If (a>=4)Then geqdefine(l,117,curval)
      Else eqdefine(l,117,curval);
    End;
  10:
End;{:1236}{1243:}
Procedure alteraux;

Var c: halfword;
Begin
  If curchr<>abs(curlist.modefield)Then reportillegalcase
  Else
    Begin
      c := curchr;
      scanoptionalequals;
      If c=1 Then
        Begin
          scandimen(false,false,false);
          curlist.auxfield.int := curval;
        End
      Else
        Begin
          scanint;
          If (curval<=0)Or(curval>32767)Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1214);
              End;
              Begin
                helpptr := 1;
                helpline[0] := 1215;
              End;
              interror(curval);
            End
          Else curlist.auxfield.hh.lh := curval;
        End;
    End;
End;
{:1243}{1244:}
Procedure alterprevgraf;

Var p: 0..nestsize;
Begin
  nest[nestptr] := curlist;
  p := nestptr;
  While abs(nest[p].modefield)<>1 Do
    p := p-1;
  scanoptionalequals;
  scanint;
  If curval<0 Then
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(956);
      End;
      printesc(532);
      Begin
        helpptr := 1;
        helpline[0] := 1216;
      End;
      interror(curval);
    End
  Else
    Begin
      nest[p].pgfield := curval;
      curlist := nest[nestptr];
    End;
End;{:1244}{1245:}
Procedure alterpagesofar;

Var c: 0..7;
Begin
  c := curchr;
  scanoptionalequals;
  scandimen(false,false,false);
  pagesofar[c] := curval;
End;
{:1245}{1246:}
Procedure alterinteger;

Var c: 0..1;
Begin
  c := curchr;
  scanoptionalequals;
  scanint;
  If c=0 Then deadcycles := curval
  Else insertpenalties := curval;
End;
{:1246}{1247:}
Procedure alterboxdimen;

Var c: smallnumber;
  b: eightbits;
Begin
  c := curchr;
  scaneightbitint;
  b := curval;
  scanoptionalequals;
  scandimen(false,false,false);
  If eqtb[3678+b].hh.rh<>0 Then mem[eqtb[3678+b].hh.rh+c].int := curval;
End;
{:1247}{1257:}
Procedure newfont(a:smallnumber);

Label 50;

Var u: halfword;
  s: scaled;
  f: internalfontnumber;
  t: strnumber;
  oldsetting: 0..21;
  flushablestring: strnumber;
Begin
  If jobname=0 Then openlogfile;
  getrtoken;
  u := curcs;
  If u>=514 Then t := hash[u].rh
  Else If u>=257 Then If u=513 Then t := 1220
  Else t := u-257
  Else
    Begin
      oldsetting := selector;
      selector := 21;
      print(1220);
      print(u-1);
      selector := oldsetting;
      Begin
        If poolptr+1>poolsize Then overflow(257,poolsize-initpoolptr);
      End;
      t := makestring;
    End;
  If (a>=4)Then geqdefine(u,87,0)
  Else eqdefine(u,87,0);
  scanoptionalequals;
  scanfilename;{1258:}
  nameinprogress := true;
  If scankeyword(1221)Then{1259:}
    Begin
      scandimen(false,false,false);
      s := curval;
      If (s<=0)Or(s>=134217728)Then
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(1223);
          End;
          printscaled(s);
          print(1224);
          Begin
            helpptr := 2;
            helpline[1] := 1225;
            helpline[0] := 1226;
          End;
          error;
          s := 10*65536;
        End;
    End{:1259}
  Else If scankeyword(1222)Then
         Begin
           scanint;
           s := -curval;
           If (curval<=0)Or(curval>32768)Then
             Begin
               Begin
                 If interaction=3 Then;
                 printnl(262);
                 print(552);
               End;
               Begin
                 helpptr := 1;
                 helpline[0] := 553;
               End;
               interror(curval);
               s := -1000;
             End;
         End
  Else s := -1000;
  nameinprogress := false{:1258};{1260:}
  flushablestring := strptr-1;
  For f:=1 To fontptr Do
    If streqstr(fontname[f],curname)And streqstr(
       fontarea[f],curarea)Then
      Begin
        If curname=flushablestring Then
          Begin
            Begin
              strptr := strptr-1;
              poolptr := strstart[strptr];
            End;
            curname := fontname[f];
          End;
        If s>0 Then
          Begin
            If s=fontsize[f]Then goto 50;
          End
        Else If fontsize[f]=xnoverd(fontdsize[f],-s,1000)Then goto 50;
      End{:1260};
  f := readfontinfo(u,curname,curarea,s);
  50: eqtb[u].hh.rh := f;
  eqtb[2624+f] := eqtb[u];
  hash[2624+f].rh := t;
End;
{:1257}{1265:}
Procedure newinteraction;
Begin
  printnl(338);
  interaction := curchr;
{75:}
  If interaction=0 Then selector := 16
  Else selector := 17{:75};
  If logopened Then selector := selector+2;
End;
{:1265}
Procedure prefixedcommand;

Label 30,10;

Var a: smallnumber;
  f: internalfontnumber;
  j: halfword;
  k: fontindex;
  p,q: halfword;
  n: integer;
  e: boolean;
Begin
  a := 0;
  While curcmd=93 Do
    Begin
      If Not odd(a Div curchr)Then a := a+curchr;
{404:}
      Repeat
        getxtoken;
      Until (curcmd<>10)And(curcmd<>0){:404};
      If curcmd<=70 Then{1212:}
        Begin
          Begin
            If interaction=3 Then;
            printnl(262);
            print(1180);
          End;
          printcmdchr(curcmd,curchr);
          printchar(39);
          Begin
            helpptr := 1;
            helpline[0] := 1181;
          End;
          backerror;
          goto 10;
        End{:1212};
    End;
{1213:}
  If (curcmd<>97)And(a Mod 4<>0)Then
    Begin
      Begin
        If interaction=3
          Then;
        printnl(262);
        print(685);
      End;
      printesc(1172);
      print(1182);
      printesc(1173);
      print(1183);
      printcmdchr(curcmd,curchr);
      printchar(39);
      Begin
        helpptr := 1;
        helpline[0] := 1184;
      End;
      error;
    End{:1213};
{1214:}
  If eqtb[5306].int<>0 Then If eqtb[5306].int<0 Then
                              Begin
                                If (a>=4)
                                  Then a := a-4;
                              End
  Else
    Begin
      If Not(a>=4)Then a := a+4;
    End{:1214};
  Case curcmd Of {1217:}
    87: If (a>=4)Then geqdefine(3934,120,curchr)
        Else
          eqdefine(3934,120,curchr);
{:1217}{1218:}
    97:
        Begin
          If odd(curchr)And Not(a>=4)And(eqtb[5306].int>=0)
            Then a := a+4;
          e := (curchr>=2);
          getrtoken;
          p := curcs;
          q := scantoks(true,e);
          If (a>=4)Then geqdefine(p,111+(a Mod 4),defref)
          Else eqdefine(p,111+(a Mod
                        4),defref);
        End;{:1218}{1221:}
    94:
        Begin
          n := curchr;
          getrtoken;
          p := curcs;
          If n=0 Then
            Begin
              Repeat
                gettoken;
              Until curcmd<>10;
              If curtok=3133 Then
                Begin
                  gettoken;
                  If curcmd=10 Then gettoken;
                End;
            End
          Else
            Begin
              gettoken;
              q := curtok;
              gettoken;
              backinput;
              curtok := q;
              backinput;
            End;
          If curcmd>=111 Then mem[curchr].hh.lh := mem[curchr].hh.lh+1;
          If (a>=4)Then geqdefine(p,curcmd,curchr)
          Else eqdefine(p,curcmd,curchr);
        End;{:1221}{1224:}
    95:
        Begin
          n := curchr;
          getrtoken;
          p := curcs;
          If (a>=4)Then geqdefine(p,0,256)
          Else eqdefine(p,0,256);
          scanoptionalequals;
          Case n Of 
            0:
               Begin
                 scancharnum;
                 If (a>=4)Then geqdefine(p,68,curval)
                 Else eqdefine(p,68,curval);
               End;
            1:
               Begin
                 scanfifteenbitint;
                 If (a>=4)Then geqdefine(p,69,curval)
                 Else eqdefine(p,69,curval);
               End;
            Else
              Begin
                scaneightbitint;
                Case n Of 
                  2: If (a>=4)Then geqdefine(p,73,5318+curval)
                     Else eqdefine(p,73,
                                   5318+curval);
                  3: If (a>=4)Then geqdefine(p,74,5851+curval)
                     Else eqdefine(p,74,5851+curval
                       );
                  4: If (a>=4)Then geqdefine(p,75,2900+curval)
                     Else eqdefine(p,75,2900+curval
                       );
                  5: If (a>=4)Then geqdefine(p,76,3156+curval)
                     Else eqdefine(p,76,3156+curval
                       );
                  6: If (a>=4)Then geqdefine(p,72,3422+curval)
                     Else eqdefine(p,72,3422+curval
                       );
                End;
              End
          End;
        End;{:1224}{1225:}
    96:
        Begin
          scanint;
          n := curval;
          If Not scankeyword(843)Then
            Begin
              Begin
                If interaction=3 Then;
                printnl(262);
                print(1074);
              End;
              Begin
                helpptr := 2;
                helpline[1] := 1201;
                helpline[0] := 1202;
              End;
              error;
            End;
          getrtoken;
          p := curcs;
          readtoks(n,p);
          If (a>=4)Then geqdefine(p,111,curval)
          Else eqdefine(p,111,curval);
        End;
{:1225}{1226:}
    71,72:
           Begin
             q := curcs;
             If curcmd=71 Then
               Begin
                 scaneightbitint;
                 p := 3422+curval;
               End
             Else p := curchr;
             scanoptionalequals;{404:}
             Repeat
               getxtoken;
             Until (curcmd<>10)And(curcmd<>0){:404};
             If curcmd<>1 Then{1227:}
               Begin
                 If curcmd=71 Then
                   Begin
                     scaneightbitint;
                     curcmd := 72;
                     curchr := 3422+curval;
                   End;
                 If curcmd=72 Then
                   Begin
                     q := eqtb[curchr].hh.rh;
                     If q=0 Then If (a>=4)Then geqdefine(p,101,0)
                     Else eqdefine(p,101,0)
                     Else
                       Begin
                         mem[q].hh.lh := mem[q].hh.lh+1;
                         If (a>=4)Then geqdefine(p,111,q)
                         Else eqdefine(p,111,q);
                       End;
                     goto 30;
                   End;
               End{:1227};
             backinput;
             curcs := q;
             q := scantoks(false,false);
             If mem[defref].hh.rh=0 Then
               Begin
                 If (a>=4)Then geqdefine(p,101,0)
                 Else
                   eqdefine(p,101,0);
                 Begin
                   mem[defref].hh.rh := avail;
                   avail := defref;
                   dynused := dynused-1;
                 End;
               End
             Else
               Begin
                 If p=3413 Then
                   Begin
                     mem[q].hh.rh := getavail;
                     q := mem[q].hh.rh;
                     mem[q].hh.lh := 637;
                     q := getavail;
                     mem[q].hh.lh := 379;
                     mem[q].hh.rh := mem[defref].hh.rh;
                     mem[defref].hh.rh := q;
                   End;
                 If (a>=4)Then geqdefine(p,111,defref)
                 Else eqdefine(p,111,defref);
               End;
           End;
{:1226}{1228:}
    73:
        Begin
          p := curchr;
          scanoptionalequals;
          scanint;
          If (a>=4)Then geqworddefine(p,curval)
          Else eqworddefine(p,curval);
        End;
    74:
        Begin
          p := curchr;
          scanoptionalequals;
          scandimen(false,false,false);
          If (a>=4)Then geqworddefine(p,curval)
          Else eqworddefine(p,curval);
        End;
    75,76:
           Begin
             p := curchr;
             n := curcmd;
             scanoptionalequals;
             If n=76 Then scanglue(3)
             Else scanglue(2);
             trapzeroglue;
             If (a>=4)Then geqdefine(p,117,curval)
             Else eqdefine(p,117,curval);
           End;
{:1228}{1232:}
    85:
        Begin{1233:}
          If curchr=3983 Then n := 15
          Else If curchr=
                  5007 Then n := 32768
          Else If curchr=4751 Then n := 32767
          Else If curchr=5574
                 Then n := 16777215
          Else n := 255{:1233};
          p := curchr;
          scancharnum;
          p := p+curval;
          scanoptionalequals;
          scanint;
          If ((curval<0)And(p<5574))Or(curval>n)Then
            Begin
              Begin
                If interaction=3
                  Then;
                printnl(262);
                print(1203);
              End;
              printint(curval);
              If p<5574 Then print(1204)
              Else print(1205);
              printint(n);
              Begin
                helpptr := 1;
                helpline[0] := 1206;
              End;
              error;
              curval := 0;
            End;
          If p<5007 Then If (a>=4)Then geqdefine(p,120,curval)
          Else eqdefine(p,120,
                        curval)
          Else If p<5574 Then If (a>=4)Then geqdefine(p,120,curval)
          Else
            eqdefine(p,120,curval)
          Else If (a>=4)Then geqworddefine(p,curval)
          Else
            eqworddefine(p,curval);
        End;{:1232}{1234:}
    86:
        Begin
          p := curchr;
          scanfourbitint;
          p := p+curval;
          scanoptionalequals;
          scanfontident;
          If (a>=4)Then geqdefine(p,120,curval)
          Else eqdefine(p,120,curval);
        End;
{:1234}{1235:}
    89,90,91,92: doregistercommand(a);
{:1235}{1241:}
    98:
        Begin
          scaneightbitint;
          If (a>=4)Then n := 256+curval
          Else n := curval;
          scanoptionalequals;
          If setboxallowed Then scanbox(1073741824+n)
          Else
            Begin
              Begin
                If 
                   interaction=3 Then;
                printnl(262);
                print(680);
              End;
              printesc(536);
              Begin
                helpptr := 2;
                helpline[1] := 1212;
                helpline[0] := 1213;
              End;
              error;
            End;
        End;
{:1241}{1242:}
    79: alteraux;
    80: alterprevgraf;
    81: alterpagesofar;
    82: alterinteger;
    83: alterboxdimen;
{:1242}{1248:}
    84:
        Begin
          scanoptionalequals;
          scanint;
          n := curval;
          If n<=0 Then p := 0
          Else
            Begin
              p := getnode(2*n+1);
              mem[p].hh.lh := n;
              For j:=1 To n Do
                Begin
                  scandimen(false,false,false);
                  mem[p+2*j-1].int := curval;
                  scandimen(false,false,false);
                  mem[p+2*j].int := curval;
                End;
            End;
          If (a>=4)Then geqdefine(3412,118,p)
          Else eqdefine(3412,118,p);
        End;
{:1248}{1252:}
    99: If curchr=1 Then
          Begin{newpatterns;goto 30;}
            Begin
              If interaction=3 Then;
              printnl(262);
              print(1217);
            End;
            helpptr := 0;
            error;
            Repeat
              gettoken;
            Until curcmd=2;
            goto 10;
          End
        Else
          Begin
            newhyphexceptions;
            goto 30;
          End;
{:1252}{1253:}
    77:
        Begin
          findfontdimen(true);
          k := curval;
          scanoptionalequals;
          scandimen(false,false,false);
          fontinfo[k].int := curval;
        End;
    78:
        Begin
          n := curchr;
          scanfontident;
          f := curval;
          scanoptionalequals;
          scanint;
          If n=0 Then hyphenchar[f] := curval
          Else skewchar[f] := curval;
        End;
{:1253}{1256:}
    88: newfont(a);{:1256}{1264:}
    100: newinteraction;
{:1264}
    Else confusion(1179)
  End;
  30:{1269:}If aftertoken<>0 Then
              Begin
                curtok := aftertoken;
                backinput;
                aftertoken := 0;
              End{:1269};
  10:
End;{:1211}{1270:}
Procedure doassignments;

Label 10;
Begin
  While true Do
    Begin{404:}
      Repeat
        getxtoken;
      Until (curcmd<>10)And(curcmd<>0){:404};
      If curcmd<=70 Then goto 10;
      setboxallowed := false;
      prefixedcommand;
      setboxallowed := true;
    End;
  10:
End;
{:1270}{1275:}
Procedure openorclosein;

Var c: 0..1;
  n: 0..15;
Begin
  c := curchr;
  scanfourbitint;
  n := curval;
  If readopen[n]<>2 Then
    Begin
      aclose(readfile[n]);
      readopen[n] := 2;
    End;
  If c<>0 Then
    Begin
      scanoptionalequals;
      scanfilename;
      If curext=338 Then curext := 791;
      packfilename(curname,curarea,curext);
      If aopenin(readfile[n])Then readopen[n] := 1;
    End;
End;
{:1275}{1279:}
Procedure issuemessage;

Var oldsetting: 0..21;
  c: 0..1;
  s: strnumber;
Begin
  c := curchr;
  mem[29988].hh.rh := scantoks(false,true);
  oldsetting := selector;
  selector := 21;
  tokenshow(defref);
  selector := oldsetting;
  flushlist(defref);
  Begin
    If poolptr+1>poolsize Then overflow(257,poolsize-initpoolptr);
  End;
  s := makestring;
  If c=0 Then{1280:}
    Begin
      If termoffset+(strstart[s+1]-strstart[s])>
         maxprintline-2 Then println
      Else If (termoffset>0)Or(fileoffset>0)Then
             printchar(32);
      slowprint(s);
      flush(output);
    End{:1280}
  Else{1283:}
    Begin
      Begin
        If interaction=3 Then;
        printnl(262);
        print(338);
      End;
      slowprint(s);
      If eqtb[3421].hh.rh<>0 Then useerrhelp := true
      Else If longhelpseen Then
             Begin
               helpptr := 1;
               helpline[0] := 1233;
             End
      Else
        Begin
          If interaction<3 Then longhelpseen := true;
          Begin
            helpptr := 4;
            helpline[3] := 1234;
            helpline[2] := 1235;
            helpline[1] := 1236;
            helpline[0] := 1237;
          End;
        End;
      error;
      useerrhelp := false;
    End{:1283};
  Begin
    strptr := strptr-1;
    poolptr := strstart[strptr];
  End;
End;
{:1279}{1288:}
Procedure shiftcase;

Var b: halfword;
  p: halfword;
  t: halfword;
  c: eightbits;
Begin
  b := curchr;
  p := scantoks(false,false);
  p := mem[defref].hh.rh;
  While p<>0 Do
    Begin{1289:}
      t := mem[p].hh.lh;
      If t<4352 Then
        Begin
          c := t Mod 256;
          If eqtb[b+c].hh.rh<>0 Then mem[p].hh.lh := t-c+eqtb[b+c].hh.rh;
        End{:1289};
      p := mem[p].hh.rh;
    End;
  begintokenlist(mem[defref].hh.rh,3);
  Begin
    mem[defref].hh.rh := avail;
    avail := defref;
    dynused := dynused-1;
  End;
End;
{:1288}{1293:}
Procedure showwhatever;

Label 50;

Var p: halfword;
Begin
  Case curchr Of 
    3:
       Begin
         begindiagnostic;
         showactivities;
       End;
    1:{1296:}
       Begin
         scaneightbitint;
         begindiagnostic;
         printnl(1255);
         printint(curval);
         printchar(61);
         If eqtb[3678+curval].hh.rh=0 Then print(410)
         Else showbox(eqtb[3678+
                      curval].hh.rh);
       End{:1296};
    0:{1294:}
       Begin
         gettoken;
         If interaction=3 Then;
         printnl(1249);
         If curcs<>0 Then
           Begin
             sprintcs(curcs);
             printchar(61);
           End;
         printmeaning;
         goto 50;
       End{:1294};
    Else{1297:}
      Begin
        p := thetoks;
        If interaction=3 Then;
        printnl(1249);
        tokenshow(29997);
        flushlist(mem[29997].hh.rh);
        goto 50;
      End{:1297}
  End;
{1298:}
  enddiagnostic(true);
  Begin
    If interaction=3 Then;
    printnl(262);
    print(1256);
  End;
  If selector=19 Then If eqtb[5292].int<=0 Then
                        Begin
                          selector := 17;
                          print(1257);
                          selector := 19;
                        End{:1298};
  50: If interaction<3 Then
        Begin
          helpptr := 0;
          errorcount := errorcount-1;
        End
      Else If eqtb[5292].int>0 Then
             Begin
               Begin
                 helpptr := 3;
                 helpline[2] := 1244;
                 helpline[1] := 1245;
                 helpline[0] := 1246;
               End;
             End
      Else
        Begin
          Begin
            helpptr := 5;
            helpline[4] := 1244;
            helpline[3] := 1245;
            helpline[2] := 1246;
            helpline[1] := 1247;
            helpline[0] := 1248;
          End;
        End;
  error;
End;
{:1293}{1302:}
{procedure storefmtfile;label 41,42,31,32;
var j,k,l:integer;p,q:halfword;x:integer;w:fourquarters;
begin[1304:]if saveptr<>0 then begin begin if interaction=3 then;
printnl(262);print(1259);end;begin helpptr:=1;helpline[0]:=1260;end;
begin if interaction=3 then interaction:=2;if logopened then error;
[if interaction>0 then debughelp;]history:=3;jumpout;end;end[:1304];
[1328:]selector:=21;print(1273);print(jobname);printchar(32);
printint(eqtb[5286].int);printchar(46);printint(eqtb[5285].int);
printchar(46);printint(eqtb[5284].int);printchar(41);
if interaction=0 then selector:=18 else selector:=19;
begin if poolptr+1>poolsize then overflow(257,poolsize-initpoolptr);end;
formatident:=makestring;packjobname(786);
while not wopenout(fmtfile)do promptfilename(1274,786);printnl(1275);
slowprint(wmakenamestring(fmtfile));begin strptr:=strptr-1;
poolptr:=strstart[strptr];end;printnl(338);
slowprint(formatident)[:1328];[1307:]begin fmtfile^.int:=305924274;
put(fmtfile);end;begin fmtfile^.int:=0;put(fmtfile);end;
begin fmtfile^.int:=30000;put(fmtfile);end;begin fmtfile^.int:=6106;
put(fmtfile);end;begin fmtfile^.int:=1777;put(fmtfile);end;
begin fmtfile^.int:=307;put(fmtfile);end[:1307];
[1309:]begin fmtfile^.int:=poolptr;put(fmtfile);end;
begin fmtfile^.int:=strptr;put(fmtfile);end;
for k:=0 to strptr do begin fmtfile^.int:=strstart[k];put(fmtfile);end;
k:=0;while k+4<poolptr do begin w.b0:=strpool[k];w.b1:=strpool[k+1];
w.b2:=strpool[k+2];w.b3:=strpool[k+3];begin fmtfile^.qqqq:=w;
put(fmtfile);end;k:=k+4;end;k:=poolptr-4;w.b0:=strpool[k];
w.b1:=strpool[k+1];w.b2:=strpool[k+2];w.b3:=strpool[k+3];
begin fmtfile^.qqqq:=w;put(fmtfile);end;println;printint(strptr);
print(1261);printint(poolptr)[:1309];[1311:]sortavail;varused:=0;
begin fmtfile^.int:=lomemmax;put(fmtfile);end;begin fmtfile^.int:=rover;
put(fmtfile);end;p:=0;q:=rover;x:=0;
repeat for k:=p to q+1 do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+q+2-p;varused:=varused+q-p;p:=q+mem[q].hh.lh;q:=mem[q+1].hh.rh;
until q=rover;varused:=varused+lomemmax-p;dynused:=memend+1-himemmin;
for k:=p to lomemmax do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+lomemmax+1-p;begin fmtfile^.int:=himemmin;put(fmtfile);end;
begin fmtfile^.int:=avail;put(fmtfile);end;
for k:=himemmin to memend do begin fmtfile^:=mem[k];put(fmtfile);end;
x:=x+memend+1-himemmin;p:=avail;while p<>0 do begin dynused:=dynused-1;
p:=mem[p].hh.rh;end;begin fmtfile^.int:=varused;put(fmtfile);end;
begin fmtfile^.int:=dynused;put(fmtfile);end;println;printint(x);
print(1262);printint(varused);printchar(38);printint(dynused)[:1311];
[1313:][1315:]k:=1;repeat j:=k;
while j<5262 do begin if(eqtb[j].hh.rh=eqtb[j+1].hh.rh)and(eqtb[j].hh.b0
=eqtb[j+1].hh.b0)and(eqtb[j].hh.b1=eqtb[j+1].hh.b1)then goto 41;j:=j+1;
end;l:=5263;goto 31;41:j:=j+1;l:=j;
while j<5262 do begin if(eqtb[j].hh.rh<>eqtb[j+1].hh.rh)or(eqtb[j].hh.b0
<>eqtb[j+1].hh.b0)or(eqtb[j].hh.b1<>eqtb[j+1].hh.b1)then goto 31;j:=j+1;
end;31:begin fmtfile^.int:=l-k;put(fmtfile);end;
while k<l do begin begin fmtfile^:=eqtb[k];put(fmtfile);end;k:=k+1;end;
k:=j+1;begin fmtfile^.int:=k-l;put(fmtfile);end;until k=5263[:1315];
[1316:]repeat j:=k;
while j<6106 do begin if eqtb[j].int=eqtb[j+1].int then goto 42;j:=j+1;
end;l:=6107;goto 32;42:j:=j+1;l:=j;
while j<6106 do begin if eqtb[j].int<>eqtb[j+1].int then goto 32;j:=j+1;
end;32:begin fmtfile^.int:=l-k;put(fmtfile);end;
while k<l do begin begin fmtfile^:=eqtb[k];put(fmtfile);end;k:=k+1;end;
k:=j+1;begin fmtfile^.int:=k-l;put(fmtfile);end;until k>6106[:1316];
begin fmtfile^.int:=parloc;put(fmtfile);end;
begin fmtfile^.int:=writeloc;put(fmtfile);end;
[1318:]begin fmtfile^.int:=hashused;put(fmtfile);end;
cscount:=2613-hashused;
for p:=514 to hashused do if hash[p].rh<>0 then begin begin fmtfile^.int
:=p;put(fmtfile);end;begin fmtfile^.hh:=hash[p];put(fmtfile);end;
cscount:=cscount+1;end;
for p:=hashused+1 to 2880 do begin fmtfile^.hh:=hash[p];put(fmtfile);
end;begin fmtfile^.int:=cscount;put(fmtfile);end;println;
printint(cscount);print(1263)[:1318][:1313];
[1320:]begin fmtfile^.int:=fmemptr;put(fmtfile);end;
for k:=0 to fmemptr-1 do begin fmtfile^:=fontinfo[k];put(fmtfile);end;
begin fmtfile^.int:=fontptr;put(fmtfile);end;
for k:=0 to fontptr do[1322:]begin begin fmtfile^.qqqq:=fontcheck[k];
put(fmtfile);end;begin fmtfile^.int:=fontsize[k];put(fmtfile);end;
begin fmtfile^.int:=fontdsize[k];put(fmtfile);end;
begin fmtfile^.int:=fontparams[k];put(fmtfile);end;
begin fmtfile^.int:=hyphenchar[k];put(fmtfile);end;
begin fmtfile^.int:=skewchar[k];put(fmtfile);end;
begin fmtfile^.int:=fontname[k];put(fmtfile);end;
begin fmtfile^.int:=fontarea[k];put(fmtfile);end;
begin fmtfile^.int:=fontbc[k];put(fmtfile);end;
begin fmtfile^.int:=fontec[k];put(fmtfile);end;
begin fmtfile^.int:=charbase[k];put(fmtfile);end;
begin fmtfile^.int:=widthbase[k];put(fmtfile);end;
begin fmtfile^.int:=heightbase[k];put(fmtfile);end;
begin fmtfile^.int:=depthbase[k];put(fmtfile);end;
begin fmtfile^.int:=italicbase[k];put(fmtfile);end;
begin fmtfile^.int:=ligkernbase[k];put(fmtfile);end;
begin fmtfile^.int:=kernbase[k];put(fmtfile);end;
begin fmtfile^.int:=extenbase[k];put(fmtfile);end;
begin fmtfile^.int:=parambase[k];put(fmtfile);end;
begin fmtfile^.int:=fontglue[k];put(fmtfile);end;
begin fmtfile^.int:=bcharlabel[k];put(fmtfile);end;
begin fmtfile^.int:=fontbchar[k];put(fmtfile);end;
begin fmtfile^.int:=fontfalsebchar[k];put(fmtfile);end;printnl(1266);
printesc(hash[2624+k].rh);printchar(61);
printfilename(fontname[k],fontarea[k],338);
if fontsize[k]<>fontdsize[k]then begin print(741);
printscaled(fontsize[k]);print(397);end;end[:1322];println;
printint(fmemptr-7);print(1264);printint(fontptr-0);print(1265);
if fontptr<>1 then printchar(115)[:1320];
[1324:]begin fmtfile^.int:=hyphcount;put(fmtfile);end;
for k:=0 to 307 do if hyphword[k]<>0 then begin begin fmtfile^.int:=k;
put(fmtfile);end;begin fmtfile^.int:=hyphword[k];put(fmtfile);end;
begin fmtfile^.int:=hyphlist[k];put(fmtfile);end;end;println;
printint(hyphcount);print(1267);if hyphcount<>1 then printchar(115);
if trienotready then inittrie;begin fmtfile^.int:=triemax;put(fmtfile);
end;for k:=0 to triemax do begin fmtfile^.hh:=trie[k];put(fmtfile);end;
begin fmtfile^.int:=trieopptr;put(fmtfile);end;
for k:=1 to trieopptr do begin begin fmtfile^.int:=hyfdistance[k];
put(fmtfile);end;begin fmtfile^.int:=hyfnum[k];put(fmtfile);end;
begin fmtfile^.int:=hyfnext[k];put(fmtfile);end;end;printnl(1268);
printint(triemax);print(1269);printint(trieopptr);print(1270);
if trieopptr<>1 then printchar(115);print(1271);printint(trieopsize);
for k:=255 downto 0 do if trieused[k]>0 then begin printnl(801);
printint(trieused[k]);print(1272);printint(k);begin fmtfile^.int:=k;
put(fmtfile);end;begin fmtfile^.int:=trieused[k];put(fmtfile);end;
end[:1324];[1326:]begin fmtfile^.int:=interaction;put(fmtfile);end;
begin fmtfile^.int:=formatident;put(fmtfile);end;
begin fmtfile^.int:=69069;put(fmtfile);end;eqtb[5294].int:=0[:1326];
[1329:]wclose(fmtfile)[:1329];end;}
{:1302}{1348:}{1349:}
Procedure newwhatsit(s:smallnumber;w:smallnumber);

Var p: halfword;
Begin
  p := getnode(w);
  mem[p].hh.b0 := 8;
  mem[p].hh.b1 := s;
  mem[curlist.tailfield].hh.rh := p;
  curlist.tailfield := p;
End;
{:1349}{1350:}
Procedure newwritewhatsit(w:smallnumber);
Begin
  newwhatsit(curchr,w);
  If w<>2 Then scanfourbitint
  Else
    Begin
      scanint;
      If curval<0 Then curval := 17
      Else If curval>15 Then curval := 16;
    End;
  mem[curlist.tailfield+1].hh.lh := curval;
End;{:1350}
Procedure doextension;

Var i,j,k: integer;
  p,q,r: halfword;
Begin
  Case curchr Of 
    0:{1351:}
       Begin
         newwritewhatsit(3);
         scanoptionalequals;
         scanfilename;
         mem[curlist.tailfield+1].hh.rh := curname;
         mem[curlist.tailfield+2].hh.lh := curarea;
         mem[curlist.tailfield+2].hh.rh := curext;
       End{:1351};
    1:{1352:}
       Begin
         k := curcs;
         newwritewhatsit(2);
         curcs := k;
         p := scantoks(false,false);
         mem[curlist.tailfield+1].hh.rh := defref;
       End{:1352};
    2:{1353:}
       Begin
         newwritewhatsit(2);
         mem[curlist.tailfield+1].hh.rh := 0;
       End{:1353};
    3:{1354:}
       Begin
         newwhatsit(3,2);
         mem[curlist.tailfield+1].hh.lh := 0;
         p := scantoks(false,true);
         mem[curlist.tailfield+1].hh.rh := defref;
       End{:1354};
    4:{1375:}
       Begin
         getxtoken;
         If (curcmd=59)And(curchr<=2)Then
           Begin
             p := curlist.tailfield;
             doextension;
             outwhat(curlist.tailfield);
             flushnodelist(curlist.tailfield);
             curlist.tailfield := p;
             mem[p].hh.rh := 0;
           End
         Else backinput;
       End{:1375};
    5:{1377:}If abs(curlist.modefield)<>102 Then reportillegalcase
       Else
         Begin
           newwhatsit(4,2);
           scanint;
           If curval<=0 Then curlist.auxfield.hh.rh := 0
           Else If curval>255 Then
                  curlist.auxfield.hh.rh := 0
           Else curlist.auxfield.hh.rh := curval;
           mem[curlist.tailfield+1].hh.rh := curlist.auxfield.hh.rh;
           mem[curlist.tailfield+1].hh.b0 := normmin(eqtb[5314].int);
           mem[curlist.tailfield+1].hh.b1 := normmin(eqtb[5315].int);
         End{:1377};
    Else confusion(1292)
  End;
End;{:1348}{1376:}
Procedure fixlanguage;

Var l: ASCIIcode;
Begin
  If eqtb[5313].int<=0 Then l := 0
  Else If eqtb[5313].int>255 Then l := 
                                       0
  Else l := eqtb[5313].int;
  If l<>curlist.auxfield.hh.rh Then
    Begin
      newwhatsit(4,2);
      mem[curlist.tailfield+1].hh.rh := l;
      curlist.auxfield.hh.rh := l;
      mem[curlist.tailfield+1].hh.b0 := normmin(eqtb[5314].int);
      mem[curlist.tailfield+1].hh.b1 := normmin(eqtb[5315].int);
    End;
End;
{:1376}{1068:}
Procedure handlerightbrace;

Var p,q: halfword;
  d: scaled;
  f: integer;
Begin
  Case curgroup Of 
    1: unsave;
    0:
       Begin
         Begin
           If interaction=3 Then;
           printnl(262);
           print(1045);
         End;
         Begin
           helpptr := 2;
           helpline[1] := 1046;
           helpline[0] := 1047;
         End;
         error;
       End;
    14,15,16: extrarightbrace;{1085:}
    2: package(0);
    3:
       Begin
         adjusttail := 29995;
         package(0);
       End;
    4:
       Begin
         endgraf;
         package(0);
       End;
    5:
       Begin
         endgraf;
         package(4);
       End;{:1085}{1100:}
    11:
        Begin
          endgraf;
          q := eqtb[2892].hh.rh;
          mem[q].hh.rh := mem[q].hh.rh+1;
          d := eqtb[5836].int;
          f := eqtb[5305].int;
          unsave;
          saveptr := saveptr-1;
          p := vpackage(mem[curlist.headfield].hh.rh,0,1,1073741823);
          popnest;
          If savestack[saveptr+0].int<255 Then
            Begin
              Begin
                mem[curlist.tailfield].
                hh.rh := getnode(5);
                curlist.tailfield := mem[curlist.tailfield].hh.rh;
              End;
              mem[curlist.tailfield].hh.b0 := 3;
              mem[curlist.tailfield].hh.b1 := savestack[saveptr+0].int;
              mem[curlist.tailfield+3].int := mem[p+3].int+mem[p+2].int;
              mem[curlist.tailfield+4].hh.lh := mem[p+5].hh.rh;
              mem[curlist.tailfield+4].hh.rh := q;
              mem[curlist.tailfield+2].int := d;
              mem[curlist.tailfield+1].int := f;
            End
          Else
            Begin
              Begin
                mem[curlist.tailfield].hh.rh := getnode(2);
                curlist.tailfield := mem[curlist.tailfield].hh.rh;
              End;
              mem[curlist.tailfield].hh.b0 := 5;
              mem[curlist.tailfield].hh.b1 := 0;
              mem[curlist.tailfield+1].int := mem[p+5].hh.rh;
              deleteglueref(q);
            End;
          freenode(p,7);
          If nestptr=0 Then buildpage;
        End;
    8:{1026:}
       Begin
         If (curinput.locfield<>0)Or((curinput.indexfield<>6)And(
            curinput.indexfield<>3))Then{1027:}
           Begin
             Begin
               If interaction=3 Then;
               printnl(262);
               print(1011);
             End;
             Begin
               helpptr := 2;
               helpline[1] := 1012;
               helpline[0] := 1013;
             End;
             error;
             Repeat
               gettoken;
             Until curinput.locfield=0;
           End{:1027};
         endtokenlist;
         endgraf;
         unsave;
         outputactive := false;
         insertpenalties := 0;
{1028:}
         If eqtb[3933].hh.rh<>0 Then
           Begin
             Begin
               If interaction=3 Then;
               printnl(262);
               print(1014);
             End;
             printesc(409);
             printint(255);
             Begin
               helpptr := 3;
               helpline[2] := 1015;
               helpline[1] := 1016;
               helpline[0] := 1017;
             End;
             boxerror(255);
           End{:1028};
         If curlist.tailfield<>curlist.headfield Then
           Begin
             mem[pagetail].hh.rh := 
                                    mem[curlist.headfield].hh.rh;
             pagetail := curlist.tailfield;
           End;
         If mem[29998].hh.rh<>0 Then
           Begin
             If mem[29999].hh.rh=0 Then nest[0].
               tailfield := pagetail;
             mem[pagetail].hh.rh := mem[29999].hh.rh;
             mem[29999].hh.rh := mem[29998].hh.rh;
             mem[29998].hh.rh := 0;
             pagetail := 29998;
           End;
         popnest;
         buildpage;
       End{:1026};{:1100}{1118:}
    10: builddiscretionary;
{:1118}{1132:}
    6:
       Begin
         backinput;
         curtok := 6710;
         Begin
           If interaction=3 Then;
           printnl(262);
           print(625);
         End;
         printesc(900);
         print(626);
         Begin
           helpptr := 1;
           helpline[0] := 1126;
         End;
         inserror;
       End;
{:1132}{1133:}
    7:
       Begin
         endgraf;
         unsave;
         alignpeek;
       End;
{:1133}{1168:}
    12:
        Begin
          endgraf;
          unsave;
          saveptr := saveptr-2;
          p := vpackage(mem[curlist.headfield].hh.rh,savestack[saveptr+1].int,
               savestack[saveptr+0].int,1073741823);
          popnest;
          Begin
            mem[curlist.tailfield].hh.rh := newnoad;
            curlist.tailfield := mem[curlist.tailfield].hh.rh;
          End;
          mem[curlist.tailfield].hh.b0 := 29;
          mem[curlist.tailfield+1].hh.rh := 2;
          mem[curlist.tailfield+1].hh.lh := p;
        End;{:1168}{1173:}
    13: buildchoices;
{:1173}{1186:}
    9:
       Begin
         unsave;
         saveptr := saveptr-1;
         mem[savestack[saveptr+0].int].hh.rh := 3;
         p := finmlist(0);
         mem[savestack[saveptr+0].int].hh.lh := p;
         If p<>0 Then If mem[p].hh.rh=0 Then If mem[p].hh.b0=16 Then
                                               Begin
                                                 If mem
                                                    [p+3].hh.rh=0 Then If mem[p+2].hh.rh=0 Then
                                                                         Begin
                                                                           mem[savestack[saveptr
                                                                           +0].int].hh := mem[p+1].
                                                                                          hh;
                                                                           freenode(p,4);
                                                                         End;
                                               End
         Else If mem[p].hh.b0=28 Then If savestack[saveptr+0].int=curlist.
                                         tailfield+1 Then If mem[curlist.tailfield].hh.b0=16 Then
                                                            {1187:}
                                                            Begin
                                                              q := 
                                                                   curlist.headfield;
                                                              While mem[q].hh.rh<>curlist.tailfield 
                                                                Do
                                                                q := mem[q].hh.rh;
                                                              mem[q].hh.rh := p;
                                                              freenode(curlist.tailfield,4);
                                                              curlist.tailfield := p;
                                                            End{:1187};
       End;{:1186}
    Else confusion(1048)
  End;
End;
{:1068}
Procedure maincontrol;

Label 60,21,70,80,90,91,92,95,100,101,110,111,112,120,10;

Var t: integer;
Begin
  If eqtb[3419].hh.rh<>0 Then begintokenlist(eqtb[3419].hh.rh,12);
  60: getxtoken;
  21:{1031:}If interrupt<>0 Then If OKtointerrupt Then
                                   Begin
                                     backinput;
                                     Begin
                                       If interrupt<>0 Then pauseforinstructions;
                                     End;
                                     goto 60;
                                   End;
{if panicking then checkmem(false);}
  If eqtb[5299].int>0 Then showcurcmdchr{:1031};
  Case abs(curlist.modefield)+curcmd Of 
    113,114,170: goto 70;
    118:
         Begin
           scancharnum;
           curchr := curval;
           goto 70;
         End;
    167:
         Begin
           getxtoken;
           If (curcmd=11)Or(curcmd=12)Or(curcmd=68)Or(curcmd=16)Then cancelboundary 
             := true;
           goto 21;
         End;
    112: If curlist.auxfield.hh.lh=1000 Then goto 120
         Else appspace;
    166,267: goto 120;{1045:}
    1,102,203,11,213,268:;
    40,141,242:
                Begin{406:}
                  Repeat
                    getxtoken;
                  Until curcmd<>10{:406};
                  goto 21;
                End;
    15: If itsallover Then goto 10;
{1048:}
    23,123,224,71,172,273,{:1048}{1098:}39,{:1098}{1111:}45,{:1111}
{1144:}49,150,{:1144}7,108,209: reportillegalcase;
{1046:}
    8,109,9,110,18,119,70,171,51,152,16,117,50,151,53,154,67,168,54,
    155,55,156,57,158,56,157,31,132,52,153,29,130,47,148,212,216,217,230,227
    ,236,239{:1046}: insertdollarsign;
{1056:}
    37,137,238:
                Begin
                  Begin
                    mem[curlist.tailfield].hh.rh := scanrulespec
                    ;
                    curlist.tailfield := mem[curlist.tailfield].hh.rh;
                  End;
                  If abs(curlist.modefield)=1 Then curlist.auxfield.int := -65536000
                  Else If 
                          abs(curlist.modefield)=102 Then curlist.auxfield.hh.lh := 1000;
                End;
{:1056}{1057:}
    28,128,229,231: appendglue;
    30,131,232,233: appendkern;
{:1057}{1063:}
    2,103: newsavelevel(1);
    62,163,264: newsavelevel(14);
    63,164,265: If curgroup=14 Then unsave
                Else offsave;
{:1063}{1067:}
    3,104,205: handlerightbrace;
{:1067}{1073:}
    22,124,225:
                Begin
                  t := curchr;
                  scandimen(false,false,false);
                  If t=0 Then scanbox(curval)
                  Else scanbox(-curval);
                End;
    32,133,234: scanbox(1073742237+curchr);
    21,122,223: beginbox(0);
{:1073}{1090:}
    44: newgraf(curchr>0);
    12,13,17,69,4,24,36,46,48,27,34,65,66:
                                           Begin
                                             backinput;
                                             newgraf(true);
                                           End;
{:1090}{1092:}
    145,246: indentinhmode;
{:1092}{1094:}
    14:
        Begin
          normalparagraph;
          If curlist.modefield>0 Then buildpage;
        End;
    115:
         Begin
           If alignstate<0 Then offsave;
           endgraf;
           If curlist.modefield=1 Then buildpage;
         End;
    116,129,138,126,134: headforvmode;
{:1094}{1097:}
    38,139,240,140,241: begininsertoradjust;
    19,120,221: makemark;{:1097}{1102:}
    43,144,245: appendpenalty;
{:1102}{1104:}
    26,127,228: deletelast;{:1104}{1109:}
    25,125,226: unpackage;
{:1109}{1112:}
    146: appenditaliccorrection;
    247:
         Begin
           mem[curlist.tailfield].hh.rh := newkern(0);
           curlist.tailfield := mem[curlist.tailfield].hh.rh;
         End;
{:1112}{1116:}
    149,250: appenddiscretionary;{:1116}{1122:}
    147: makeaccent;
{:1122}{1126:}
    6,107,208,5,106,207: alignerror;
    35,136,237: noalignerror;
    64,165,266: omiterror;{:1126}{1130:}
    33,135: initalign;
    235: If privileged Then If curgroup=15 Then initalign
         Else offsave;
    10,111: doendv;{:1130}{1134:}
    68,169,270: cserror;
{:1134}{1137:}
    105: initmath;
{:1137}{1140:}
    251: If privileged Then If curgroup=15 Then starteqno
         Else
           offsave;
{:1140}{1150:}
    204:
         Begin
           Begin
             mem[curlist.tailfield].hh.rh := newnoad;
             curlist.tailfield := mem[curlist.tailfield].hh.rh;
           End;
           backinput;
           scanmath(curlist.tailfield+1);
         End;
{:1150}{1154:}
    214,215,271: setmathchar(eqtb[5007+curchr].hh.rh);
    219:
         Begin
           scancharnum;
           curchr := curval;
           setmathchar(eqtb[5007+curchr].hh.rh);
         End;
    220:
         Begin
           scanfifteenbitint;
           setmathchar(curval);
         End;
    272: setmathchar(curchr);
    218:
         Begin
           scantwentysevenbitint;
           setmathchar(curval Div 4096);
         End;
{:1154}{1158:}
    253:
         Begin
           Begin
             mem[curlist.tailfield].hh.rh := newnoad;
             curlist.tailfield := mem[curlist.tailfield].hh.rh;
           End;
           mem[curlist.tailfield].hh.b0 := curchr;
           scanmath(curlist.tailfield+1);
         End;
    254: mathlimitswitch;{:1158}{1162:}
    269: mathradical;
{:1162}{1164:}
    248,249: mathac;{:1164}{1167:}
    259:
         Begin
           scanspec(12,false);
           normalparagraph;
           pushnest;
           curlist.modefield := -1;
           curlist.auxfield.int := -65536000;
           If eqtb[3418].hh.rh<>0 Then begintokenlist(eqtb[3418].hh.rh,11);
         End;
{:1167}{1171:}
    256:
         Begin
           mem[curlist.tailfield].hh.rh := newstyle(curchr);
           curlist.tailfield := mem[curlist.tailfield].hh.rh;
         End;
    258:
         Begin
           Begin
             mem[curlist.tailfield].hh.rh := newglue(0);
             curlist.tailfield := mem[curlist.tailfield].hh.rh;
           End;
           mem[curlist.tailfield].hh.b1 := 98;
         End;
    257: appendchoices;
{:1171}{1175:}
    211,210: subsup;{:1175}{1180:}
    255: mathfraction;
{:1180}{1190:}
    252: mathleftright;
{:1190}{1193:}
    206: If curgroup=15 Then aftermath
         Else offsave;
{:1193}{1210:}
    72,173,274,73,174,275,74,175,276,75,176,277,76,177,278,77,
    178,279,78,179,280,79,180,281,80,181,282,81,182,283,82,183,284,83,184,
    285,84,185,286,85,186,287,86,187,288,87,188,289,88,189,290,89,190,291,90
    ,191,292,91,192,293,92,193,294,93,194,295,94,195,296,95,196,297,96,197,
    298,97,198,299,98,199,300,99,200,301,100,201,302,101,202,303:
                                                                  prefixedcommand;{:1210}{1268:}
    41,142,243:
                Begin
                  gettoken;
                  aftertoken := curtok;
                End;{:1268}{1271:}
    42,143,244:
                Begin
                  gettoken;
                  saveforafter(curtok);
                End;{:1271}{1274:}
    61,162,263: openorclosein;
{:1274}{1276:}
    59,160,261: issuemessage;
{:1276}{1285:}
    58,159,260: shiftcase;
{:1285}{1290:}
    20,121,222: showwhatever;
{:1290}{1347:}
    60,161,262: doextension;{:1347}{:1045}
  End;
  goto 60;
  70:{1034:}mains := eqtb[4751+curchr].hh.rh;
  If mains=1000 Then curlist.auxfield.hh.lh := 1000
  Else If mains<1000 Then
         Begin
           If mains>0 Then curlist.auxfield.hh.lh := mains;
         End
  Else If curlist.auxfield.hh.lh<1000 Then curlist.auxfield.hh.lh := 
                                                                     1000
  Else curlist.auxfield.hh.lh := mains;
  mainf := eqtb[3934].hh.rh;
  bchar := fontbchar[mainf];
  falsebchar := fontfalsebchar[mainf];
  If curlist.modefield>0 Then If eqtb[5313].int<>curlist.auxfield.hh.rh
                                Then fixlanguage;
  Begin
    ligstack := avail;
    If ligstack=0 Then ligstack := getavail
    Else
      Begin
        avail := mem[ligstack].hh
                 .rh;
        mem[ligstack].hh.rh := 0;
        dynused := dynused+1;
      End;
  End;
  mem[ligstack].hh.b0 := mainf;
  curl := curchr;
  mem[ligstack].hh.b1 := curl;
  curq := curlist.tailfield;
  If cancelboundary Then
    Begin
      cancelboundary := false;
      maink := 0;
    End
  Else maink := bcharlabel[mainf];
  If maink=0 Then goto 92;
  curr := curl;
  curl := 256;
  goto 111;
  80:{1035:}If curl<256 Then
              Begin
                If mem[curq].hh.rh>0 Then If mem[
                                             curlist.tailfield].hh.b1=hyphenchar[mainf]Then insdisc 
                                            := true;
                If ligaturepresent Then
                  Begin
                    mainp := newligature(mainf,curl,mem[curq].hh
                             .rh);
                    If lfthit Then
                      Begin
                        mem[mainp].hh.b1 := 2;
                        lfthit := false;
                      End;
                    If rthit Then If ligstack=0 Then
                                    Begin
                                      mem[mainp].hh.b1 := mem[mainp].hh.
                                                          b1+1;
                                      rthit := false;
                                    End;
                    mem[curq].hh.rh := mainp;
                    curlist.tailfield := mainp;
                    ligaturepresent := false;
                  End;
                If insdisc Then
                  Begin
                    insdisc := false;
                    If curlist.modefield>0 Then
                      Begin
                        mem[curlist.tailfield].hh.rh := newdisc;
                        curlist.tailfield := mem[curlist.tailfield].hh.rh;
                      End;
                  End;
              End{:1035};
  90:{1036:}If ligstack=0 Then goto 21;
  curq := curlist.tailfield;
  curl := mem[ligstack].hh.b1;
  91: If Not(ligstack>=himemmin)Then goto 95;
  92: If (curchr<fontbc[mainf])Or(curchr>fontec[mainf])Then
        Begin
          charwarning(mainf,curchr);
          Begin
            mem[ligstack].hh.rh := avail;
            avail := ligstack;
            dynused := dynused-1;
          End;
          goto 60;
        End;
  maini := fontinfo[charbase[mainf]+curl].qqqq;
  If Not(maini.b0>0)Then
    Begin
      charwarning(mainf,curchr);
      Begin
        mem[ligstack].hh.rh := avail;
        avail := ligstack;
        dynused := dynused-1;
      End;
      goto 60;
    End;
  mem[curlist.tailfield].hh.rh := ligstack;
  curlist.tailfield := ligstack{:1036};
  100:{1038:}getnext;
  If curcmd=11 Then goto 101;
  If curcmd=12 Then goto 101;
  If curcmd=68 Then goto 101;
  xtoken;
  If curcmd=11 Then goto 101;
  If curcmd=12 Then goto 101;
  If curcmd=68 Then goto 101;
  If curcmd=16 Then
    Begin
      scancharnum;
      curchr := curval;
      goto 101;
    End;
  If curcmd=65 Then bchar := 256;
  curr := bchar;
  ligstack := 0;
  goto 110;
  101: mains := eqtb[4751+curchr].hh.rh;
  If mains=1000 Then curlist.auxfield.hh.lh := 1000
  Else If mains<1000 Then
         Begin
           If mains>0 Then curlist.auxfield.hh.lh := mains;
         End
  Else If curlist.auxfield.hh.lh<1000 Then curlist.auxfield.hh.lh := 
                                                                     1000
  Else curlist.auxfield.hh.lh := mains;
  Begin
    ligstack := avail;
    If ligstack=0 Then ligstack := getavail
    Else
      Begin
        avail := mem[ligstack].hh
                 .rh;
        mem[ligstack].hh.rh := 0;
        dynused := dynused+1;
      End;
  End;
  mem[ligstack].hh.b0 := mainf;
  curr := curchr;
  mem[ligstack].hh.b1 := curr;
  If curr=falsebchar Then curr := 256{:1038};
  110:{1039:}If ((maini.b2)Mod 4)<>1 Then goto 80;
  If curr=256 Then goto 80;
  maink := ligkernbase[mainf]+maini.b3;
  mainj := fontinfo[maink].qqqq;
  If mainj.b0<=128 Then goto 112;
  maink := ligkernbase[mainf]+256*mainj.b2+mainj.b3+32768-256*(128);
  111: mainj := fontinfo[maink].qqqq;
  112: If mainj.b1=curr Then If mainj.b0<=128 Then{1040:}
                               Begin
                                 If mainj.b2
                                    >=128 Then
                                   Begin
                                     If curl<256 Then
                                       Begin
                                         If mem[curq].hh.rh>0 Then If mem
                                                                      [curlist.tailfield].hh.b1=
                                                                      hyphenchar[mainf]Then insdisc 
                                                                     := true;
                                         If ligaturepresent Then
                                           Begin
                                             mainp := newligature(mainf,curl,mem[curq].hh
                                                      .rh);
                                             If lfthit Then
                                               Begin
                                                 mem[mainp].hh.b1 := 2;
                                                 lfthit := false;
                                               End;
                                             If rthit Then If ligstack=0 Then
                                                             Begin
                                                               mem[mainp].hh.b1 := mem[mainp].hh.
                                                                                   b1+1;
                                                               rthit := false;
                                                             End;
                                             mem[curq].hh.rh := mainp;
                                             curlist.tailfield := mainp;
                                             ligaturepresent := false;
                                           End;
                                         If insdisc Then
                                           Begin
                                             insdisc := false;
                                             If curlist.modefield>0 Then
                                               Begin
                                                 mem[curlist.tailfield].hh.rh := newdisc;
                                                 curlist.tailfield := mem[curlist.tailfield].hh.rh;
                                               End;
                                           End;
                                       End;
                                     Begin
                                       mem[curlist.tailfield].hh.rh := newkern(fontinfo[kernbase[
                                                                       mainf]+256
                                                                       *mainj.b2+mainj.b3].int);
                                       curlist.tailfield := mem[curlist.tailfield].hh.rh;
                                     End;
                                     goto 90;
                                   End;
                                 If curl=256 Then lfthit := true
                                 Else If ligstack=0 Then rthit := true;
                                 Begin
                                   If interrupt<>0 Then pauseforinstructions;
                                 End;
                                 Case mainj.b2 Of 
                                   1,5:
                                        Begin
                                          curl := mainj.b3;
                                          maini := fontinfo[charbase[mainf]+curl].qqqq;
                                          ligaturepresent := true;
                                        End;
                                   2,6:
                                        Begin
                                          curr := mainj.b3;
                                          If ligstack=0 Then
                                            Begin
                                              ligstack := newligitem(curr);
                                              bchar := 256;
                                            End
                                          Else If (ligstack>=himemmin)Then
                                                 Begin
                                                   mainp := ligstack;
                                                   ligstack := newligitem(curr);
                                                   mem[ligstack+1].hh.rh := mainp;
                                                 End
                                          Else mem[ligstack].hh.b1 := curr;
                                        End;
                                   3:
                                      Begin
                                        curr := mainj.b3;
                                        mainp := ligstack;
                                        ligstack := newligitem(curr);
                                        mem[ligstack].hh.rh := mainp;
                                      End;
                                   7,11:
                                         Begin
                                           If curl<256 Then
                                             Begin
                                               If mem[curq].hh.rh>0 Then If mem[
                                                                            curlist.tailfield].hh.b1
                                                                            =hyphenchar[mainf]Then
                                                                           insdisc := true;
                                               If ligaturepresent Then
                                                 Begin
                                                   mainp := newligature(mainf,curl,mem[curq].hh
                                                            .rh);
                                                   If lfthit Then
                                                     Begin
                                                       mem[mainp].hh.b1 := 2;
                                                       lfthit := false;
                                                     End;
                                                   If false Then If ligstack=0 Then
                                                                   Begin
                                                                     mem[mainp].hh.b1 := mem[mainp].
                                                                                         hh.
                                                                                         b1+1;
                                                                     rthit := false;
                                                                   End;
                                                   mem[curq].hh.rh := mainp;
                                                   curlist.tailfield := mainp;
                                                   ligaturepresent := false;
                                                 End;
                                               If insdisc Then
                                                 Begin
                                                   insdisc := false;
                                                   If curlist.modefield>0 Then
                                                     Begin
                                                       mem[curlist.tailfield].hh.rh := newdisc;
                                                       curlist.tailfield := mem[curlist.tailfield].
                                                                            hh.rh;
                                                     End;
                                                 End;
                                             End;
                                           curq := curlist.tailfield;
                                           curl := mainj.b3;
                                           maini := fontinfo[charbase[mainf]+curl].qqqq;
                                           ligaturepresent := true;
                                         End;
                                   Else
                                     Begin
                                       curl := mainj.b3;
                                       ligaturepresent := true;
                                       If ligstack=0 Then goto 80
                                       Else goto 91;
                                     End
                                 End;
                                 If mainj.b2>4 Then If mainj.b2<>7 Then goto 80;
                                 If curl<256 Then goto 110;
                                 maink := bcharlabel[mainf];
                                 goto 111;
                               End{:1040};
  If mainj.b0=0 Then maink := maink+1
  Else
    Begin
      If mainj.b0>=128 Then goto
        80;
      maink := maink+mainj.b0+1;
    End;
  goto 111{:1039};
  95:{1037:}mainp := mem[ligstack+1].hh.rh;
  If mainp>0 Then
    Begin
      mem[curlist.tailfield].hh.rh := mainp;
      curlist.tailfield := mem[curlist.tailfield].hh.rh;
    End;
  tempptr := ligstack;
  ligstack := mem[tempptr].hh.rh;
  freenode(tempptr,2);
  maini := fontinfo[charbase[mainf]+curl].qqqq;
  ligaturepresent := true;
  If ligstack=0 Then If mainp>0 Then goto 100
  Else curr := bchar
  Else curr := 
               mem[ligstack].hh.b1;
  goto 110{:1037}{:1034};
  120:{1041:}If eqtb[2894].hh.rh=0 Then
               Begin{1042:}
                 Begin
                   mainp := fontglue[
                            eqtb[3934].hh.rh];
                   If mainp=0 Then
                     Begin
                       mainp := newspec(0);
                       maink := parambase[eqtb[3934].hh.rh]+2;
                       mem[mainp+1].int := fontinfo[maink].int;
                       mem[mainp+2].int := fontinfo[maink+1].int;
                       mem[mainp+3].int := fontinfo[maink+2].int;
                       fontglue[eqtb[3934].hh.rh] := mainp;
                     End;
                 End{:1042};
                 tempptr := newglue(mainp);
               End
       Else tempptr := newparamglue(12);
  mem[curlist.tailfield].hh.rh := tempptr;
  curlist.tailfield := tempptr;
  goto 60{:1041};
  10:
End;{:1030}{1284:}
Procedure giveerrhelp;
Begin
  tokenshow(eqtb[3421].hh.rh);
End;
{:1284}{1303:}{524:}
Function openfmtfile: boolean;

Label 40,10;

Var j: 0..bufsize;
Begin
  j := curinput.locfield;
  If buffer[curinput.locfield]=38 Then
    Begin
      curinput.locfield := curinput.
                           locfield+1;
      j := curinput.locfield;
      buffer[last] := 32;
      While buffer[j]<>32 Do
        j := j+1;
      packbufferedname(0,curinput.locfield,j-1);
      If wopenin(fmtfile)Then goto 40;
      packbufferedname(11,curinput.locfield,j-1);
      If wopenin(fmtfile)Then goto 40;;
      writeln(output,'Sorry, I can''t find that format;',' will try PLAIN.');
      flush(output);
    End;
  packbufferedname(16,1,0);
  If Not wopenin(fmtfile)Then
    Begin;
      writeln(output,'I can''t find TeXformats/plain.fmt!');
      openfmtfile := false;
      goto 10;
    End;
  40: curinput.locfield := j;
  openfmtfile := true;
  10:
End;{:524}
Function loadfmtfile: boolean;

Label 6666,10;

Var j,k: integer;
  p,q: halfword;
  x: integer;
  w: fourquarters;
Begin{1308:}
  x := fmtfile^.int;
  If x<>305924274 Then goto 6666;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If x<>0 Then goto 6666;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If x<>30000 Then goto 6666;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If x<>6106 Then goto 6666;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If x<>1777 Then goto 6666;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If x<>307 Then goto 6666{:1308};
{1310:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<0 Then goto 6666;
    If x>poolsize Then
      Begin;
        writeln(output,'---! Must increase the ','string pool size');
        goto 6666;
      End
    Else poolptr := x;
  End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<0 Then goto 6666;
    If x>maxstrings Then
      Begin;
        writeln(output,'---! Must increase the ','max strings');
        goto 6666;
      End
    Else strptr := x;
  End;
  For k:=0 To strptr Do
    Begin
      Begin
        get(fmtfile);
        x := fmtfile^.int;
      End;
      If (x<0)Or(x>poolptr)Then goto 6666
      Else strstart[k] := x;
    End;
  k := 0;
  While k+4<poolptr Do
    Begin
      Begin
        get(fmtfile);
        w := fmtfile^.qqqq;
      End;
      strpool[k] := w.b0;
      strpool[k+1] := w.b1;
      strpool[k+2] := w.b2;
      strpool[k+3] := w.b3;
      k := k+4;
    End;
  k := poolptr-4;
  Begin
    get(fmtfile);
    w := fmtfile^.qqqq;
  End;
  strpool[k] := w.b0;
  strpool[k+1] := w.b1;
  strpool[k+2] := w.b2;
  strpool[k+3] := w.b3;
  initstrptr := strptr;
  initpoolptr := poolptr{:1310};{1312:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<1019)Or(x>29986)Then goto 6666
    Else lomemmax := x;
  End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<20)Or(x>lomemmax)Then goto 6666
    Else rover := x;
  End;
  p := 0;
  q := rover;
  Repeat
    For k:=p To q+1 Do
      Begin
        get(fmtfile);
        mem[k] := fmtfile^;
      End;
    p := q+mem[q].hh.lh;
    If (p>lomemmax)Or((q>=mem[q+1].hh.rh)And(mem[q+1].hh.rh<>rover))Then goto
      6666;
    q := mem[q+1].hh.rh;
  Until q=rover;
  For k:=p To lomemmax Do
    Begin
      get(fmtfile);
      mem[k] := fmtfile^;
    End;
  If memmin<-2 Then
    Begin
      p := mem[rover+1].hh.lh;
      q := memmin+1;
      mem[memmin].hh.rh := 0;
      mem[memmin].hh.lh := 0;
      mem[p+1].hh.rh := q;
      mem[rover+1].hh.lh := q;
      mem[q+1].hh.rh := rover;
      mem[q+1].hh.lh := p;
      mem[q].hh.rh := 65535;
      mem[q].hh.lh := -0-q;
    End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<lomemmax+1)Or(x>29987)Then goto 6666
    Else himemmin := x;
  End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<0)Or(x>30000)Then goto 6666
    Else avail := x;
  End;
  memend := 30000;
  For k:=himemmin To memend Do
    Begin
      get(fmtfile);
      mem[k] := fmtfile^;
    End;
  Begin
    get(fmtfile);
    varused := fmtfile^.int;
  End;
  Begin
    get(fmtfile);
    dynused := fmtfile^.int;
  End{:1312};{1314:}{1317:}
  k := 1;
  Repeat
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<1)Or(k+x>6107)Then goto 6666;
    For j:=k To k+x-1 Do
      Begin
        get(fmtfile);
        eqtb[j] := fmtfile^;
      End;
    k := k+x;
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<0)Or(k+x>6107)Then goto 6666;
    For j:=k To k+x-1 Do
      eqtb[j] := eqtb[k-1];
    k := k+x;
  Until k>6106{:1317};
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<514)Or(x>2614)Then goto 6666
    Else parloc := x;
  End;
  partoken := 4095+parloc;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<514)Or(x>2614)Then goto 6666
    Else writeloc := x;
  End;
{1319:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<514)Or(x>2614)Then goto 6666
    Else hashused := x;
  End;
  p := 513;
  Repeat
    Begin
      Begin
        get(fmtfile);
        x := fmtfile^.int;
      End;
      If (x<p+1)Or(x>hashused)Then goto 6666
      Else p := x;
    End;
    Begin
      get(fmtfile);
      hash[p] := fmtfile^.hh;
    End;
  Until p=hashused;
  For p:=hashused+1 To 2880 Do
    Begin
      get(fmtfile);
      hash[p] := fmtfile^.hh;
    End;
  Begin
    get(fmtfile);
    cscount := fmtfile^.int;
  End{:1319}{:1314};
{1321:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<7 Then goto 6666;
    If x>fontmemsize Then
      Begin;
        writeln(output,'---! Must increase the ','font mem size');
        goto 6666;
      End
    Else fmemptr := x;
  End;
  For k:=0 To fmemptr-1 Do
    Begin
      get(fmtfile);
      fontinfo[k] := fmtfile^;
    End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<0 Then goto 6666;
    If x>fontmax Then
      Begin;
        writeln(output,'---! Must increase the ','font max');
        goto 6666;
      End
    Else fontptr := x;
  End;
  For k:=0 To fontptr Do{1323:}
    Begin
      Begin
        get(fmtfile);
        fontcheck[k] := fmtfile^.qqqq;
      End;
      Begin
        get(fmtfile);
        fontsize[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        fontdsize[k] := fmtfile^.int;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>65535)Then goto 6666
        Else fontparams[k] := x;
      End;
      Begin
        get(fmtfile);
        hyphenchar[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        skewchar[k] := fmtfile^.int;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>strptr)Then goto 6666
        Else fontname[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>strptr)Then goto 6666
        Else fontarea[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>255)Then goto 6666
        Else fontbc[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>255)Then goto 6666
        Else fontec[k] := x;
      End;
      Begin
        get(fmtfile);
        charbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        widthbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        heightbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        depthbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        italicbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        ligkernbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        kernbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        extenbase[k] := fmtfile^.int;
      End;
      Begin
        get(fmtfile);
        parambase[k] := fmtfile^.int;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>lomemmax)Then goto 6666
        Else fontglue[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>fmemptr-1)Then goto 6666
        Else bcharlabel[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>256)Then goto 6666
        Else fontbchar[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>256)Then goto 6666
        Else fontfalsebchar[k] := x;
      End;
    End{:1323}{:1321};{1325:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<0)Or(x>307)Then goto 6666
    Else hyphcount := x;
  End;
  For k:=1 To hyphcount Do
    Begin
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>307)Then goto 6666
        Else j := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>strptr)Then goto 6666
        Else hyphword[j] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>65535)Then goto 6666
        Else hyphlist[j] := x;
      End;
    End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<0 Then goto 6666;
    If x>triesize Then
      Begin;
        writeln(output,'---! Must increase the ','trie size');
        goto 6666;
      End
    Else j := x;
  End;{triemax:=j;}
  For k:=0 To j Do
    Begin
      get(fmtfile);
      trie[k] := fmtfile^.hh;
    End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If x<0 Then goto 6666;
    If x>trieopsize Then
      Begin;
        writeln(output,'---! Must increase the ','trie op size');
        goto 6666;
      End
    Else j := x;
  End;{trieopptr:=j;}
  For k:=1 To j Do
    Begin
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>63)Then goto 6666
        Else hyfdistance[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>63)Then goto 6666
        Else hyfnum[k] := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>255)Then goto 6666
        Else hyfnext[k] := x;
      End;
    End;
{for k:=0 to 255 do trieused[k]:=0;}
  k := 256;
  While j>0 Do
    Begin
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<0)Or(x>k-1)Then goto 6666
        Else k := x;
      End;
      Begin
        Begin
          get(fmtfile);
          x := fmtfile^.int;
        End;
        If (x<1)Or(x>j)Then goto 6666
        Else x := x;
      End;
{trieused[k]:=x;}
      j := j-x;
      opstart[k] := j;
    End;{trienotready:=false}{:1325};
{1327:}
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<0)Or(x>3)Then goto 6666
    Else interaction := x;
  End;
  Begin
    Begin
      get(fmtfile);
      x := fmtfile^.int;
    End;
    If (x<0)Or(x>strptr)Then goto 6666
    Else formatident := x;
  End;
  Begin
    get(fmtfile);
    x := fmtfile^.int;
  End;
  If (x<>69069)Then goto 6666{:1327};
  loadfmtfile := true;
  goto 10;
  6666:;
  writeln(output,'(Fatal format file error; I''m stymied)');
  loadfmtfile := false;
  10:
End;
{:1303}{1330:}{1333:}
Procedure closefilesandterminate;

Var k: integer;
Begin{1378:}
  For k:=0 To 15 Do
    If writeopen[k]Then aclose(writefile[k])
{:1378};
  eqtb[5312].int := -1;
  If eqtb[5294].int>0 Then{1334:}If logopened Then
                                   Begin
                                     writeln(logfile,
                                             ' ');
                                     writeln(logfile,'Here is how much of TeX''s memory',
                                             ' you used:');
                                     write(logfile,' ',strptr-initstrptr:1,' string');
                                     If strptr<>initstrptr+1 Then write(logfile,'s');
                                     writeln(logfile,' out of ',maxstrings-initstrptr:1);
                                     writeln(logfile,' ',poolptr-initpoolptr:1,
                                             ' string characters out of ',
                                             poolsize-initpoolptr:1);
                                     writeln(logfile,' ',lomemmax-memmin+memend-himemmin+2:1,
                                             ' words of memory out of ',memend+1-memmin:1);
                                     writeln(logfile,' ',cscount:1,
                                             ' multiletter control sequences out of ',
                                             2100:1);
                                     write(logfile,' ',fmemptr:1,' words of font info for ',fontptr-
                                           0:1,
                                           ' font');
                                     If fontptr<>1 Then write(logfile,'s');
                                     writeln(logfile,', out of ',fontmemsize:1,' for ',fontmax-0:1);
                                     write(logfile,' ',hyphcount:1,' hyphenation exception');
                                     If hyphcount<>1 Then write(logfile,'s');
                                     writeln(logfile,' out of ',307:1);
                                     writeln(logfile,' ',maxinstack:1,'i,',maxneststack:1,'n,',
                                             maxparamstack:
                                             1,'p,',maxbufstack+1:1,'b,',maxsavestack+6:1,
                                             's stack positions out of '
                                             ,stacksize:1,'i,',nestsize:1,'n,',paramsize:1,'p,',
                                             bufsize:1,'b,',
                                             savesize:1,'s');
                                   End{:1334};;
{642:}
  While curs>-1 Do
    Begin
      If curs>0 Then
        Begin
          dvibuf[dviptr] := 142;
          dviptr := dviptr+1;
          If dviptr=dvilimit Then dviswap;
        End
      Else
        Begin
          Begin
            dvibuf[dviptr] := 140;
            dviptr := dviptr+1;
            If dviptr=dvilimit Then dviswap;
          End;
          totalpages := totalpages+1;
        End;
      curs := curs-1;
    End;
  If totalpages=0 Then printnl(838)
  Else
    Begin
      Begin
        dvibuf[dviptr] := 248;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      dvifour(lastbop);
      lastbop := dvioffset+dviptr-5;
      dvifour(25400000);
      dvifour(473628672);
      preparemag;
      dvifour(eqtb[5280].int);
      dvifour(maxv);
      dvifour(maxh);
      Begin
        dvibuf[dviptr] := maxpush Div 256;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      Begin
        dvibuf[dviptr] := maxpush Mod 256;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      Begin
        dvibuf[dviptr] := (totalpages Div 256)Mod 256;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      Begin
        dvibuf[dviptr] := totalpages Mod 256;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
{643:}
      While fontptr>0 Do
        Begin
          If fontused[fontptr]Then dvifontdef(
                                              fontptr);
          fontptr := fontptr-1;
        End{:643};
      Begin
        dvibuf[dviptr] := 249;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      dvifour(lastbop);
      Begin
        dvibuf[dviptr] := 2;
        dviptr := dviptr+1;
        If dviptr=dvilimit Then dviswap;
      End;
      k := 4+((dvibufsize-dviptr)Mod 4);
      While k>0 Do
        Begin
          Begin
            dvibuf[dviptr] := 223;
            dviptr := dviptr+1;
            If dviptr=dvilimit Then dviswap;
          End;
          k := k-1;
        End;
{599:}
      If dvilimit=halfbuf Then writedvi(halfbuf,dvibufsize-1);
      If dviptr>0 Then writedvi(0,dviptr-1){:599};
      printnl(839);
      slowprint(outputfilename);
      print(286);
      printint(totalpages);
      print(840);
      If totalpages<>1 Then printchar(115);
      print(841);
      printint(dvioffset+dviptr);
      print(842);
      bclose(dvifile);
    End{:642};
  If logopened Then
    Begin
      writeln(logfile);
      aclose(logfile);
      selector := selector-2;
      If selector=17 Then
        Begin
          printnl(1276);
          slowprint(logname);
          printchar(46);
          println;
        End;
    End;
End;
{:1333}{1335:}
Procedure finalcleanup;

Label 10;

Var c: smallnumber;
Begin
  c := curchr;
  If c<>1 Then eqtb[5312].int := -1;
  If jobname=0 Then openlogfile;
  While inputptr>0 Do
    If curinput.statefield=0 Then endtokenlist
    Else
      endfilereading;
  While openparens>0 Do
    Begin
      print(1277);
      openparens := openparens-1;
    End;
  If curlevel>1 Then
    Begin
      printnl(40);
      printesc(1278);
      print(1279);
      printint(curlevel-1);
      printchar(41);
    End;
  While condptr<>0 Do
    Begin
      printnl(40);
      printesc(1278);
      print(1280);
      printcmdchr(105,curif);
      If ifline<>0 Then
        Begin
          print(1281);
          printint(ifline);
        End;
      print(1282);
      ifline := mem[condptr+1].int;
      curif := mem[condptr].hh.b1;
      tempptr := condptr;
      condptr := mem[condptr].hh.rh;
      freenode(tempptr,2);
    End;
  If history<>0 Then If ((history=1)Or(interaction<3))Then If selector=19
                                                             Then
                                                             Begin
                                                               selector := 17;
                                                               printnl(1283);
                                                               selector := 19;
                                                             End;
  If c=1 Then
    Begin
{for c:=0 to 4 do if curmark[c]<>0 then deletetokenref(
curmark[c]);if lastglue<>65535 then deleteglueref(lastglue);
storefmtfile;goto 10;}
      printnl(1284);
      goto 10;
    End;
  10:
End;
{:1335}{1336:}
{procedure initprim;begin nonewcontrolsequence:=false;
[226:]primitive(376,75,2882);primitive(377,75,2883);
primitive(378,75,2884);primitive(379,75,2885);primitive(380,75,2886);
primitive(381,75,2887);primitive(382,75,2888);primitive(383,75,2889);
primitive(384,75,2890);primitive(385,75,2891);primitive(386,75,2892);
primitive(387,75,2893);primitive(388,75,2894);primitive(389,75,2895);
primitive(390,75,2896);primitive(391,76,2897);primitive(392,76,2898);
primitive(393,76,2899);[:226][230:]primitive(398,72,3413);
primitive(399,72,3414);primitive(400,72,3415);primitive(401,72,3416);
primitive(402,72,3417);primitive(403,72,3418);primitive(404,72,3419);
primitive(405,72,3420);primitive(406,72,3421);
[:230][238:]primitive(420,73,5263);primitive(421,73,5264);
primitive(422,73,5265);primitive(423,73,5266);primitive(424,73,5267);
primitive(425,73,5268);primitive(426,73,5269);primitive(427,73,5270);
primitive(428,73,5271);primitive(429,73,5272);primitive(430,73,5273);
primitive(431,73,5274);primitive(432,73,5275);primitive(433,73,5276);
primitive(434,73,5277);primitive(435,73,5278);primitive(436,73,5279);
primitive(437,73,5280);primitive(438,73,5281);primitive(439,73,5282);
primitive(440,73,5283);primitive(441,73,5284);primitive(442,73,5285);
primitive(443,73,5286);primitive(444,73,5287);primitive(445,73,5288);
primitive(446,73,5289);primitive(447,73,5290);primitive(448,73,5291);
primitive(449,73,5292);primitive(450,73,5293);primitive(451,73,5294);
primitive(452,73,5295);primitive(453,73,5296);primitive(454,73,5297);
primitive(455,73,5298);primitive(456,73,5299);primitive(457,73,5300);
primitive(458,73,5301);primitive(459,73,5302);primitive(460,73,5303);
primitive(461,73,5304);primitive(462,73,5305);primitive(463,73,5306);
primitive(464,73,5307);primitive(465,73,5308);primitive(466,73,5309);
primitive(467,73,5310);primitive(468,73,5311);primitive(469,73,5312);
primitive(470,73,5313);primitive(471,73,5314);primitive(472,73,5315);
primitive(473,73,5316);primitive(474,73,5317);
[:238][248:]primitive(478,74,5830);primitive(479,74,5831);
primitive(480,74,5832);primitive(481,74,5833);primitive(482,74,5834);
primitive(483,74,5835);primitive(484,74,5836);primitive(485,74,5837);
primitive(486,74,5838);primitive(487,74,5839);primitive(488,74,5840);
primitive(489,74,5841);primitive(490,74,5842);primitive(491,74,5843);
primitive(492,74,5844);primitive(493,74,5845);primitive(494,74,5846);
primitive(495,74,5847);primitive(496,74,5848);primitive(497,74,5849);
primitive(498,74,5850);[:248][265:]primitive(32,64,0);
primitive(47,44,0);primitive(508,45,0);primitive(509,90,0);
primitive(510,40,0);primitive(511,41,0);primitive(512,61,0);
primitive(513,16,0);primitive(504,107,0);primitive(514,15,0);
primitive(515,92,0);primitive(505,67,0);primitive(516,62,0);
hash[2616].rh:=516;eqtb[2616]:=eqtb[curval];primitive(517,102,0);
primitive(518,88,0);primitive(519,77,0);primitive(520,32,0);
primitive(521,36,0);primitive(522,39,0);primitive(330,37,0);
primitive(351,18,0);primitive(523,46,0);primitive(524,17,0);
primitive(525,54,0);primitive(526,91,0);primitive(527,34,0);
primitive(528,65,0);primitive(529,103,0);primitive(335,55,0);
primitive(530,63,0);primitive(408,84,0);primitive(531,42,0);
primitive(532,80,0);primitive(533,66,0);primitive(534,96,0);
primitive(535,0,256);hash[2621].rh:=535;eqtb[2621]:=eqtb[curval];
primitive(536,98,0);primitive(537,109,0);primitive(407,71,0);
primitive(352,38,0);primitive(538,33,0);primitive(539,56,0);
primitive(540,35,0);[:265][334:]primitive(597,13,256);parloc:=curval;
partoken:=4095+parloc;[:334][376:]primitive(629,104,0);
primitive(630,104,1);[:376][384:]primitive(631,110,0);
primitive(632,110,1);primitive(633,110,2);primitive(634,110,3);
primitive(635,110,4);[:384][411:]primitive(476,89,0);
primitive(500,89,1);primitive(395,89,2);primitive(396,89,3);
[:411][416:]primitive(668,79,102);primitive(669,79,1);
primitive(670,82,0);primitive(671,82,1);primitive(672,83,1);
primitive(673,83,3);primitive(674,83,2);primitive(675,70,0);
primitive(676,70,1);primitive(677,70,2);primitive(678,70,3);
primitive(679,70,4);[:416][468:]primitive(735,108,0);
primitive(736,108,1);primitive(737,108,2);primitive(738,108,3);
primitive(739,108,4);primitive(740,108,5);
[:468][487:]primitive(757,105,0);primitive(758,105,1);
primitive(759,105,2);primitive(760,105,3);primitive(761,105,4);
primitive(762,105,5);primitive(763,105,6);primitive(764,105,7);
primitive(765,105,8);primitive(766,105,9);primitive(767,105,10);
primitive(768,105,11);primitive(769,105,12);primitive(770,105,13);
primitive(771,105,14);primitive(772,105,15);primitive(773,105,16);
[:487][491:]primitive(774,106,2);hash[2618].rh:=774;
eqtb[2618]:=eqtb[curval];primitive(775,106,4);primitive(776,106,3);
[:491][553:]primitive(802,87,0);hash[2624].rh:=802;
eqtb[2624]:=eqtb[curval];[:553][780:]primitive(899,4,256);
primitive(900,5,257);hash[2615].rh:=900;eqtb[2615]:=eqtb[curval];
primitive(901,5,258);hash[2619].rh:=902;hash[2620].rh:=902;
eqtb[2620].hh.b0:=9;eqtb[2620].hh.rh:=29989;eqtb[2620].hh.b1:=1;
eqtb[2619]:=eqtb[2620];eqtb[2619].hh.b0:=115;
[:780][983:]primitive(971,81,0);primitive(972,81,1);primitive(973,81,2);
primitive(974,81,3);primitive(975,81,4);primitive(976,81,5);
primitive(977,81,6);primitive(978,81,7);
[:983][1052:]primitive(1026,14,0);primitive(1027,14,1);
[:1052][1058:]primitive(1028,26,4);primitive(1029,26,0);
primitive(1030,26,1);primitive(1031,26,2);primitive(1032,26,3);
primitive(1033,27,4);primitive(1034,27,0);primitive(1035,27,1);
primitive(1036,27,2);primitive(1037,27,3);primitive(336,28,5);
primitive(340,29,1);primitive(342,30,99);
[:1058][1071:]primitive(1055,21,1);primitive(1056,21,0);
primitive(1057,22,1);primitive(1058,22,0);primitive(409,20,0);
primitive(1059,20,1);primitive(1060,20,2);primitive(966,20,3);
primitive(1061,20,4);primitive(968,20,5);primitive(1062,20,106);
primitive(1063,31,99);primitive(1064,31,100);primitive(1065,31,101);
primitive(1066,31,102);[:1071][1088:]primitive(1081,43,1);
primitive(1082,43,0);[:1088][1107:]primitive(1091,25,12);
primitive(1092,25,11);primitive(1093,25,10);primitive(1094,23,0);
primitive(1095,23,1);primitive(1096,24,0);primitive(1097,24,1);
[:1107][1114:]primitive(45,47,1);primitive(349,47,0);
[:1114][1141:]primitive(1128,48,0);primitive(1129,48,1);
[:1141][1156:]primitive(867,50,16);primitive(868,50,17);
primitive(869,50,18);primitive(870,50,19);primitive(871,50,20);
primitive(872,50,21);primitive(873,50,22);primitive(874,50,23);
primitive(876,50,26);primitive(875,50,27);primitive(1130,51,0);
primitive(879,51,1);primitive(880,51,2);
[:1156][1169:]primitive(862,53,0);primitive(863,53,2);
primitive(864,53,4);primitive(865,53,6);
[:1169][1178:]primitive(1148,52,0);primitive(1149,52,1);
primitive(1150,52,2);primitive(1151,52,3);primitive(1152,52,4);
primitive(1153,52,5);[:1178][1188:]primitive(877,49,30);
primitive(878,49,31);hash[2617].rh:=878;eqtb[2617]:=eqtb[curval];
[:1188][1208:]primitive(1172,93,1);primitive(1173,93,2);
primitive(1174,93,4);primitive(1175,97,0);primitive(1176,97,1);
primitive(1177,97,2);primitive(1178,97,3);
[:1208][1219:]primitive(1192,94,0);primitive(1193,94,1);
[:1219][1222:]primitive(1194,95,0);primitive(1195,95,1);
primitive(1196,95,2);primitive(1197,95,3);primitive(1198,95,4);
primitive(1199,95,5);primitive(1200,95,6);
[:1222][1230:]primitive(415,85,3983);primitive(419,85,5007);
primitive(416,85,4239);primitive(417,85,4495);primitive(418,85,4751);
primitive(477,85,5574);primitive(412,86,3935);primitive(413,86,3951);
primitive(414,86,3967);[:1230][1250:]primitive(942,99,0);
primitive(954,99,1);[:1250][1254:]primitive(1218,78,0);
primitive(1219,78,1);[:1254][1262:]primitive(274,100,0);
primitive(275,100,1);primitive(276,100,2);primitive(1228,100,3);
[:1262][1272:]primitive(1229,60,1);primitive(1230,60,0);
[:1272][1277:]primitive(1231,58,0);primitive(1232,58,1);
[:1277][1286:]primitive(1238,57,4239);primitive(1239,57,4495);
[:1286][1291:]primitive(1240,19,0);primitive(1241,19,1);
primitive(1242,19,2);primitive(1243,19,3);
[:1291][1344:]primitive(1286,59,0);primitive(594,59,1);writeloc:=curval;
primitive(1287,59,2);primitive(1288,59,3);primitive(1289,59,4);
primitive(1290,59,5);[:1344];nonewcontrolsequence:=true;end;}
{:1336}{1338:}
{procedure debughelp;label 888,10;var k,l,m,n:integer;
begin;while true do begin;printnl(1285);flush(output);
if eof(input)then goto 10;read(input,m);
if m<0 then goto 10 else if m=0 then begin goto 888;888:m:=0;
['BREAKPOINT']end else begin if eof(input)then goto 10;read(input,n);
case m of[1339:]1:printword(mem[n]);2:printint(mem[n].hh.lh);
3:printint(mem[n].hh.rh);4:printword(eqtb[n]);5:printword(fontinfo[n]);
6:printword(savestack[n]);7:showbox(n);8:begin breadthmax:=10000;
depththreshold:=poolsize-poolptr-10;shownodelist(n);end;
9:showtokenlist(n,0,1000);10:slowprint(n);11:checkmem(n>0);
12:searchmem(n);13:begin if eof(input)then goto 10;read(input,l);
printcmdchr(n,l);end;14:for k:=0 to n do print(buffer[k]);
15:begin fontinshortdisplay:=0;shortdisplay(n);end;
16:panicking:=not panicking;[:1339]else print(63)end;end;end;10:end;}
{:1338}{1380:}
Procedure execeditor;

Const argsize = 100;
  editor = 'vi';
{editor='ed';}
  editorlength = 2;

Var i,l: integer;
  j: poolpointer;
  s: strnumber;
  sel: integer;
  editorarg,linearg,filearg: array[1..argsize] Of char;
  argv: array[0..3] Of pchar;
Begin
  l := editorlength;
  For j:=1 To l Do
    editorarg[j] := editor[j];
  editorarg[l+1] := chr(0);
  sel := selector;
  selector := 21;
  printint(line);
  selector := sel;
  s := makestring;
  linearg[1] := '+';
  j := strstart[s];
  l := (strstart[s+1]-strstart[s])+1;
  For i:=2 To l Do
    Begin
      linearg[i] := xchr[strpool[j]];
      j := j+1
    End;
  linearg[l+1] := chr(0);
  j := strstart[inputstack[baseptr].namefield];
  l := (strstart[inputstack[baseptr].namefield+1]-strstart[inputstack[
       baseptr].namefield]);
  If l+1>argsize Then
    Begin
      writeln(
              'File name longer than 100 bytes! Nice try!');
      halt(100);
    End;
  For i:=1 To l Do
    Begin
      filearg[i] := xchr[strpool[j]];
      j := j+1
    End;
  filearg[l+1] := chr(0);
  argv[0] := @editorarg;
  argv[1] := @linearg;
  argv[2] := @filearg;
  argv[3] := Nil;{argv[1]:=@filearg;argv[2]:=nil;}
  fpexecvp(editor,argv);
  writeln('Sorry, executing the editor failed.');
End;{:1380}{:1330}{1332:}
Begin
  history := 3;;
  If readyalready=314159 Then goto 1;{14:}
  bad := 0;
  If (halferrorline<30)Or(halferrorline>errorline-15)Then bad := 1;
  If maxprintline<60 Then bad := 2;
  If dvibufsize Mod 8<>0 Then bad := 3;
  If 1100>30000 Then bad := 4;
  If 1777>2100 Then bad := 5;
  If maxinopen>=128 Then bad := 6;
  If 30000<267 Then bad := 7;
{:14}{111:}{if(memmin<>0)or(memmax<>30000)then bad:=10;}
  If (memmin>0)Or(memmax<30000)Then bad := 10;
  If (0>0)Or(255<127)Then bad := 11;
  If (0>0)Or(65535<32767)Then bad := 12;
  If (0<0)Or(255>65535)Then bad := 13;
  If (memmin<0)Or(memmax>=65535)Or(-0-memmin>65536)Then bad := 14;
  If (0<0)Or(fontmax>255)Then bad := 15;
  If fontmax>256 Then bad := 16;
  If (savesize>65535)Or(maxstrings>65535)Then bad := 17;
  If bufsize>65535 Then bad := 18;
  If 255<255 Then bad := 19;
{:111}{290:}
  If 6976>65535 Then bad := 21;
{:290}{522:}
  If 20>filenamesize Then bad := 31;
{:522}{1249:}
  If 2*65535<30000-memmin Then bad := 41;
{:1249}
  If bad>0 Then
    Begin
      writeln(output,
              'Ouch---my internal constants have been clobbered!','---case ',bad:1);
      goto 9999;
    End;
  initialize;
{if not getstringsstarted then goto 9999;
initprim;initstrptr:=strptr;initpoolptr:=poolptr;fixdateandtime;}
  readyalready := 314159;
  1:{55:}selector := 17;
  tally := 0;
  termoffset := 0;
  fileoffset := 0;{:55}{61:}
  write(output,'This is TeX-FPC, 4th ed.');
  If formatident=0 Then writeln(output,' (no format preloaded)')
  Else
    Begin
      slowprint(formatident);
      println;
    End;
  flush(output);{:61}{528:}
  jobname := 0;
  nameinprogress := false;
  logopened := false;{:528}{533:}
  outputfilename := 0;
{:533};{1337:}
  Begin{331:}
    Begin
      inputptr := 0;
      maxinstack := 0;
      inopen := 0;
      openparens := 0;
      maxbufstack := 0;
      paramptr := 0;
      maxparamstack := 0;
      first := bufsize;
      Repeat
        buffer[first] := 0;
        first := first-1;
      Until first=0;
      scannerstatus := 0;
      warningindex := 0;
      first := 1;
      curinput.statefield := 33;
      curinput.startfield := 1;
      curinput.indexfield := 0;
      line := 0;
      curinput.namefield := 0;
      forceeof := false;
      alignstate := 1000000;
      If Not initterminal Then goto 9999;
      curinput.limitfield := last;
      first := last+1;
    End{:331};
    If (formatident=0)Or(buffer[curinput.locfield]=38)Then
      Begin
        If 
           formatident<>0 Then initialize;
        If Not openfmtfile Then goto 9999;
        If Not loadfmtfile Then
          Begin
            wclose(fmtfile);
            goto 9999;
          End;
        wclose(fmtfile);
        While (curinput.locfield<curinput.limitfield)And(buffer[curinput.locfield
              ]=32) Do
          curinput.locfield := curinput.locfield+1;
      End;
    If (eqtb[5311].int<0)Or(eqtb[5311].int>255)Then curinput.limitfield := 
                                                                           curinput.limitfield-1
    Else buffer[curinput.limitfield] := eqtb[5311].int;
    fixdateandtime;{765:}
    magicoffset := strstart[893]-9*16{:765};
{75:}
    If interaction=0 Then selector := 16
    Else selector := 17{:75};
    If (curinput.locfield<curinput.limitfield)And(eqtb[3983+buffer[curinput.
       locfield]].hh.rh<>0)Then startinput;
  End{:1337};
  history := 0;
  maincontrol;
  finalcleanup;
  9998: closefilesandterminate;
  9999: If wantedit Then execeditor;
  halt(history);
End.{:1332}
