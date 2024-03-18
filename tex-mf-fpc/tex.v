(*Preamble*)
Require Import Volpic_preamble.
Require Import Volpic_notation.
Require Import String.
Require Import ZArith.
Require Import List.
Require Import Bool.
Require Import ExtrOcamlBasic.
Require Import ExtrOcamlString.
Extraction Language OCaml.
Open Scope string_scope.
Open Scope Z_scope.
Open Scope volpic_notation.
Import ListNotations.

(*Failed to convert initialize: Couldn't find key "field" in data list*)

(*Failed to convert println: casen not yet supported for statement parsing*)

(*Failed to convert printchar: goton not yet supported for statement parsing*)

(*Failed to convert print: goton not yet supported for statement parsing*)

(*Failed to convert slowprint: orn not yet supported for expression parsing*)

(*Failed to convert printnl: orn not yet supported for expression parsing*)

(*Failed to convert printesc: subscriptn not yet supported for expression parsing*)

Definition printthedigs (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (while ( fun VP_store => get_int VP_store "VP_K" >? 0 ) with VP_store upto 1000%nat begin fun VP_store => (*Block: next 2 statements*)
		let VP_store := update VP_store "VP_K" (VInteger ( get_int VP_store "VP_K" - 1 )) in
		let VP_store := if (subscript (get_array VP_store "VP_DIG") (get_int VP_store "VP_K") 0 <? 10) then
 	 (let VP_store := printchar VP_store (48 + subscript (VP_store "VP_DIG") (get_int VP_store "VP_K") 0) in VP_store) 
else
 	(let VP_store := printchar VP_store (55 + subscript (VP_store "VP_DIG") (get_int VP_store "VP_K") 0) in VP_store) in VP_store end,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printthedigs.

(*Failed to convert printint: blockn not yet supported for expression parsing*)

(*Failed to convert printcs: subscriptn not yet supported for expression parsing*)

(*Failed to convert sprintcs: subscriptn not yet supported for expression parsing*)

Definition printfilename (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := slowprint VP_store (get_int VP_store "VP_A") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := slowprint VP_store (get_int VP_store "VP_N") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := slowprint VP_store (get_int VP_store "VP_E") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printfilename.

Definition printsize (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_S" =? 0) then
 	 (let VP_store := printesc VP_store 412 in VP_store) 
else
 	(let VP_store := if (get_int VP_store "VP_S" =? 16) then
 	 (let VP_store := printesc VP_store 413 in VP_store) 
else
 	(let VP_store := printesc VP_store 414 in VP_store) in VP_store) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printsize.

(*Failed to convert printwritewhatsit: subscriptn not yet supported for expression parsing*)

(*Failed to convert jumpout: goton not yet supported for statement parsing*)

(*Failed to convert error: labeln not yet supported for statement parsing*)

(*Failed to convert fatalerror: Haven't set coq type for RTR Boolean*)

(*Failed to convert overflow: Haven't set coq type for RTR Boolean*)

(*Failed to convert confusion: Haven't set coq type for RTR Boolean*)

Definition catchsignal (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_INTERRUPT" (VInteger ( get_int VP_store "VP_I" )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" catchsignal.

(*Failed to convert aopenin: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert aopenout: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert bopenin: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert bopenout: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert wopenin: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert wopenout: Expected procedure or Function call, but got $IOResult:Word*)

(*Failed to convert aclose: Haven't set coq type for RTR Text*)

Definition bclose (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := Close VP_store (VP_store "VP_F") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" bclose.

Definition wclose (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := Close VP_store (VP_store "VP_F") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" wclose.

(*Failed to convert inputln: Couldn't find key "field" in data list*)

(*Failed to convert inputcommandln: Couldn't find key "field" in data list*)

(*Failed to convert initterminal:boolean: Couldn't find key "field" in data list*)

Definition makestring (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_STRPTR" =? 3000) then
 	 (let VP_store := overflow VP_store (3000 - get_int VP_store "VP_INITSTRPTR") 258 in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_STRPTR" (VInteger ( get_int VP_store "VP_STRPTR" + 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)STRSTART" (VInteger ( get_int VP_store "VP_POOLPTR" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_result" (VInteger ( get_int VP_store "VP_STRPTR" - 1 )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" makestring:smallint.

(*Failed to convert streqbuf: goton not yet supported for statement parsing*)

(*Failed to convert streqstr: goton not yet supported for statement parsing*)

(*Failed to convert printtwo: blockn not yet supported for expression parsing*)

(*Failed to convert printhex: blockn not yet supported for expression parsing*)

(*Failed to convert printromanint: goton not yet supported for statement parsing*)

Definition printcurrentstring (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_J" (VInteger ( subscript (VP_store "VP_STRSTART") (get_int VP_store "VP_STRPTR") 0 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (while ( fun VP_store => get_int VP_store "VP_J" <? get_int VP_store "VP_POOLPTR" ) with VP_store upto 1000%nat begin fun VP_store => (*Block: next 2 statements*)
		let VP_store := printchar VP_store (subscript (VP_store "VP_STRPOOL") (get_int VP_store "VP_J") 0) in
update VP_store "VP_J" (VInteger ( get_int VP_store "VP_J" + 1 )) end,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printcurrentstring.

(*Failed to convert terminput: Haven't set coq type for RTR Text*)

Definition interror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := print VP_store 286 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printint VP_store (get_int VP_store "VP_N") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printchar VP_store 41 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" interror.

(*Failed to convert normalizeselector: Haven't set coq type for RTR Boolean*)

(*Failed to convert pauseforinstructions: orn not yet supported for expression parsing*)

(*Failed to lift half: Haven't set coq type for RTR Boolean*)
(*Failed to convert rounddecimals: muln not yet supported for expression parsing*)

(*Failed to convert printscaled: unaryminusn not yet supported for expression parsing*)

(*Failed to convert multandadd: unaryminusn not yet supported for expression parsing*)

(*Failed to convert xovern: unaryminusn not yet supported for expression parsing*)

(*Failed to convert xnoverd: unaryminusn not yet supported for expression parsing*)

(*Failed to convert badness: muln not yet supported for expression parsing*)

(*Failed to convert showtokenlist: goton not yet supported for statement parsing*)

(*Failed to convert runaway: casen not yet supported for statement parsing*)

(*Failed to convert getavail:word: subscriptn not yet supported for expression parsing*)

(*Failed to convert flushlist: subscriptn not yet supported for expression parsing*)

(*Failed to convert getnode: labeln not yet supported for statement parsing*)

(*Failed to convert freenode: Couldn't find key "field" in data list*)

(*Failed to convert newnullbox:word: Couldn't find key "field" in data list*)

(*Failed to convert newrule:word: Couldn't find key "field" in data list*)

(*Failed to convert newligature: Couldn't find key "field" in data list*)

(*Failed to convert newligitem: Couldn't find key "field" in data list*)

(*Failed to convert newdisc:word: Couldn't find key "field" in data list*)

(*Failed to convert newmath: Couldn't find key "field" in data list*)

(*Failed to convert newspec: Couldn't find key "field" in data list*)

(*Failed to convert newparamglue: Couldn't find key "field" in data list*)

(*Failed to convert newglue: Couldn't find key "field" in data list*)

(*Failed to convert newskipparam: subscriptn not yet supported for expression parsing*)

(*Failed to convert newkern: Couldn't find key "field" in data list*)

(*Failed to convert newpenalty: Couldn't find key "field" in data list*)

(*Failed to convert shortdisplay: casen not yet supported for statement parsing*)

(*Failed to convert printfontandchar: subscriptn not yet supported for expression parsing*)

(*Failed to convert printmark: subscriptn not yet supported for expression parsing*)

Definition printruledimen (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_D" =? -1073741824) then
 	 (let VP_store := printchar VP_store 42 in VP_store) 
else
 	(let VP_store := printscaled VP_store (get_int VP_store "VP_D") in VP_store) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printruledimen.

(*Failed to convert printglue: orn not yet supported for expression parsing*)

(*Failed to convert printspec: subscriptn not yet supported for expression parsing*)

(*Failed to convert printfamandchar: subscriptn not yet supported for expression parsing*)

(*Failed to convert printdelimiter: subscriptn not yet supported for expression parsing*)

(*Failed to convert printsubsidiarydata: casen not yet supported for statement parsing*)

(*Failed to convert printstyle: casen not yet supported for statement parsing*)

(*Failed to convert printskipparam: casen not yet supported for statement parsing*)

(*Failed to convert shownodelist: goton not yet supported for statement parsing*)

(*Failed to convert showbox: subscriptn not yet supported for expression parsing*)

(*Failed to convert deletetokenref: subscriptn not yet supported for expression parsing*)

(*Failed to convert deleteglueref: subscriptn not yet supported for expression parsing*)

(*Failed to convert flushnodelist: subscriptn not yet supported for expression parsing*)

(*Failed to convert copynodelist: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert printmode: casen not yet supported for statement parsing*)

(*Failed to convert pushnest: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert popnest: Couldn't find key "field" in data list*)

(*Failed to convert showactivities: subscriptn not yet supported for expression parsing*)

(*Failed to convert printparam: casen not yet supported for statement parsing*)

(*Failed to convert fixdateandtime: Expected procedure or Function call, but got $Now:Double*)

(*Failed to convert begindiagnostic: andn not yet supported for expression parsing*)

(*Failed to convert enddiagnostic: Haven't set coq type for RTR Boolean*)

(*Failed to convert printlengthparam: casen not yet supported for statement parsing*)

(*Failed to convert printcmdchr: casen not yet supported for statement parsing*)

(*Failed to convert showeqtb: subscriptn not yet supported for expression parsing*)

(*Failed to convert idlookup: goton not yet supported for statement parsing*)

(*Failed to convert newsavelevel: Couldn't find key "field" in data list*)

(*Failed to convert eqdestroy: casen not yet supported for statement parsing*)

(*Failed to convert eqsave: Couldn't find key "field" in data list*)

(*Failed to convert eqdefine: subscriptn not yet supported for expression parsing*)

(*Failed to convert eqworddefine: Couldn't find key "field" in data list*)

(*Failed to convert geqdefine: Couldn't find key "field" in data list*)

(*Failed to convert geqworddefine: Couldn't find key "field" in data list*)

(*Failed to convert saveforafter: Couldn't find key "field" in data list*)

Definition restoretrace (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := begindiagnostic VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printchar VP_store 123 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := print VP_store (get_int VP_store "VP_S") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printchar VP_store 32 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := showeqtb VP_store (get_int VP_store "VP_P") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printchar VP_store 125 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := enddiagnostic VP_store 0 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" restoretrace.

(*Failed to convert unsave: goton not yet supported for statement parsing*)

(*Failed to convert preparemag: subscriptn not yet supported for expression parsing*)

(*Failed to convert tokenshow: subscriptn not yet supported for expression parsing*)

Definition printmeaning (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printcmdchr VP_store (get_int VP_store "VP_CURCHR") (get_int VP_store "VP_CURCMD") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_CURCMD" >=? 111) then
 	 ((*Block: next 3 statements*)
	let VP_store := printchar VP_store 58 in
	let VP_store := println VP_store in
	let VP_store := tokenshow VP_store (get_int VP_store "VP_CURCHR") in VP_store) 
else
 	(let VP_store := if (get_int VP_store "VP_CURCMD" =? 110) then
 	 ((*Block: next 3 statements*)
	let VP_store := printchar VP_store 58 in
	let VP_store := println VP_store in
	let VP_store := tokenshow VP_store (subscript (VP_store "VP_CURMARK") (get_int VP_store "VP_CURCHR") 0) in VP_store) 
else
 	VP_store in VP_store) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printmeaning.

(*Failed to convert showcurcmdchr: subscriptn not yet supported for expression parsing*)

(*Failed to convert showcontext: orn not yet supported for expression parsing*)

(*Failed to convert begintokenlist: Couldn't find key "field" in data list*)

(*Failed to convert endtokenlist: subscriptn not yet supported for expression parsing*)

(*Failed to convert backinput: andn not yet supported for expression parsing*)

Definition backerror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_OKTOINTERRUPT" (VInteger ( 0 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := backinput VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_OKTOINTERRUPT" (VInteger ( 1 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" backerror.

(*Failed to convert inserror: Couldn't find key "field" in data list*)

(*Failed to convert beginfilereading: Couldn't find key "field" in data list*)

(*Failed to convert endfilereading: subscriptn not yet supported for expression parsing*)

(*Failed to convert clearforerrorprompt: andn not yet supported for expression parsing*)

(*Failed to convert checkoutervalidity: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert getnext: labeln not yet supported for statement parsing*)

(*Failed to convert firmuptheline: Couldn't find key "field" in data list*)

(*Failed to convert gettoken: muln not yet supported for expression parsing*)

(*Failed to convert macrocall: subscriptn not yet supported for expression parsing*)

(*Failed to convert insertrelax: Couldn't find key "field" in data list*)

(*Failed to convert expand: subscriptn not yet supported for expression parsing*)

(*Failed to convert getxtoken: labeln not yet supported for statement parsing*)

(*Failed to convert xtoken: muln not yet supported for expression parsing*)

(*Failed to convert scanleftbrace: andn not yet supported for expression parsing*)

Definition scanoptionalequals (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (while ( fun VP_store => get_int VP_store "VP_CURCMD" !=? 10 ) with VP_store upto 1000%nat begin fun VP_store => 		let VP_store := getxtoken VP_store in end,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_CURTOK" !=? 3133) then
 	 (let VP_store := backinput VP_store in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" scanoptionalequals.

(*Failed to convert scankeyword: Couldn't find key "field" in data list*)

Definition muerror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := if (get_int VP_store "VP_INTERACTION" =? 3) then
 	 
else
 	((*nothing and mid-seq*) VP_store) in
	let VP_store := printnl VP_store 262 in
	let VP_store := print VP_store 662 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 2 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 1 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 663 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" muerror.

(*Failed to convert scaneightbitint: orn not yet supported for expression parsing*)

(*Failed to convert scancharnum: orn not yet supported for expression parsing*)

(*Failed to convert scanfourbitint: orn not yet supported for expression parsing*)

(*Failed to convert scanfifteenbitint: orn not yet supported for expression parsing*)

(*Failed to convert scantwentysevenbitint: orn not yet supported for expression parsing*)

(*Failed to convert scanfontident: subscriptn not yet supported for expression parsing*)

(*Failed to convert findfontdimen: andn not yet supported for expression parsing*)

(*Failed to convert scansomethinginternal: casen not yet supported for statement parsing*)

(*Failed to convert scanint: notn not yet supported for expression parsing*)

(*Failed to convert scandimen: notn not yet supported for expression parsing*)

(*Failed to convert scanglue: notn not yet supported for expression parsing*)

(*Failed to convert scanrulespec:word: Expected procedure or Function call, but got $newrule:Word*)

(*Failed to convert strtoks: Couldn't find key "field" in data list*)

(*Failed to convert thetoks:word: casen not yet supported for statement parsing*)

(*Failed to convert insthetoks: Expected procedure or Function call, but got $thetoks:Word*)

(*Failed to convert convtoks: casen not yet supported for statement parsing*)

(*Failed to convert scantoks: Haven't set coq type for RTR Boolean*)

(*Failed to convert readtoks: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert passtext: goton not yet supported for statement parsing*)

(*Failed to convert changeiflimit: Couldn't find key "field" in data list*)

(*Failed to convert conditional: Couldn't find key "field" in data list*)

Definition beginname (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_AREADELIMITER" (VInteger ( 0 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_EXTDELIMITER" (VInteger ( 0 )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" beginname.

(*Failed to convert morename: andn not yet supported for expression parsing*)

(*Failed to convert endname: Expected procedure or Function call, but got $makestring:SmallInt*)

(*Failed to lift packfilename: RTR Byte not yet supported in store_string_of_expr*)
(*Failed to lift packbufferedname: Haven't set coq type for RTR Char*)
(*Failed to convert makenamestring:smallint: Expected procedure or Function call, but got $makestring:SmallInt*)

(*Failed to convert amakenamestring: Expected procedure or Function call, but got $makenamestring:SmallInt*)

(*Failed to convert bmakenamestring: Expected procedure or Function call, but got $makenamestring:SmallInt*)

(*Failed to convert wmakenamestring: Expected procedure or Function call, but got $makenamestring:SmallInt*)

(*Failed to convert scanfilename: goton not yet supported for statement parsing*)

Definition packjobname (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_CURAREA" (VInteger ( 338 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_CUREXT" (VInteger ( get_int VP_store "VP_S" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_CURNAME" (VInteger ( get_int VP_store "VP_JOBNAME" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := packfilename VP_store (get_int VP_store "VP_CUREXT") (get_int VP_store "VP_CURAREA") (get_int VP_store "VP_CURNAME") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" packjobname.

(*Failed to convert promptfilename: andn not yet supported for expression parsing*)

(*Failed to convert openlogfile: Haven't set coq type for RTR Text*)

(*Failed to convert startinput: goton not yet supported for statement parsing*)

(*Failed to convert readfontinfo: goton not yet supported for statement parsing*)

(*Failed to convert charwarning: subscriptn not yet supported for expression parsing*)

(*Failed to convert newcharacter: Expected procedure or Function call, but got $getavail:Word*)

Definition writedvi (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := BlockWrite VP_store (get_int VP_store "VP_B" - get_int VP_store "VP_A" + 1) (subscript (VP_store "VP_DVIBUF") (get_int VP_store "VP_A") 0) (VP_store "VP_DVIFILE") in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" writedvi.

Definition dviswap (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_DVILIMIT" =? 800) then
 	 (*Block: next 4 statements*)
	let VP_store := writedvi VP_store (get_int VP_store "VP_HALFBUF" - 1) 0 in
	let VP_store := update VP_store "VP_DVILIMIT" (VInteger ( get_int VP_store "VP_HALFBUF" )) in
	let VP_store := update VP_store "VP_DVIOFFSET" (VInteger ( get_int VP_store "VP_DVIOFFSET" + 800 )) in
update VP_store "VP_DVIPTR" (VInteger ( 0 )) 
else
 	(*Block: next 2 statements*)
	let VP_store := writedvi VP_store 799 (get_int VP_store "VP_HALFBUF") in
update VP_store "VP_DVILIMIT" (VInteger ( 800 )) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_DVIGONE" (VInteger ( get_int VP_store "VP_DVIGONE" + get_int VP_store "VP_HALFBUF" )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" dviswap.

(*Failed to convert dvifour: blockn not yet supported for expression parsing*)

(*Failed to convert dvipop: andn not yet supported for expression parsing*)

(*Failed to convert dvifontdef: subscriptn not yet supported for expression parsing*)

(*Failed to convert movement: Couldn't find key "field" in data list*)

(*Failed to convert prunemovements: goton not yet supported for statement parsing*)

(*Failed to convert specialout: subscriptn not yet supported for expression parsing*)

(*Failed to convert writeout: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert outwhat: casen not yet supported for statement parsing*)

(*Failed to convert hlistout: realconstn not yet supported for expression parsing*)

(*Failed to convert vlistout: realconstn not yet supported for expression parsing*)

(*Failed to convert shipout: subscriptn not yet supported for expression parsing*)

(*Failed to convert scanspec: subscriptn not yet supported for expression parsing*)

(*Failed to convert hpack: Couldn't find key "field" in data list*)

(*Failed to convert vpackage: Couldn't find key "field" in data list*)

(*Failed to convert appendtovlist: subscriptn not yet supported for expression parsing*)

(*Failed to convert newnoad:word: Couldn't find key "field" in data list*)

(*Failed to convert newstyle: Couldn't find key "field" in data list*)

(*Failed to convert newchoice:word: Couldn't find key "field" in data list*)

(*Failed to convert showinfo: subscriptn not yet supported for expression parsing*)

(*Failed to convert fractionrule: Expected procedure or Function call, but got $newrule:Word*)

(*Failed to convert overbar: Couldn't find key "field" in data list*)

(*Failed to convert charbox: subscriptn not yet supported for expression parsing*)

(*Failed to convert stackintobox: subscriptn not yet supported for expression parsing*)

(*Failed to convert heightplusdepth: subscriptn not yet supported for expression parsing*)

(*Failed to convert vardelimiter: subscriptn not yet supported for expression parsing*)

(*Failed to convert rebox: Couldn't find key "field" in data list*)

(*Failed to convert mathglue: subscriptn not yet supported for expression parsing*)

(*Failed to convert mathkern: subscriptn not yet supported for expression parsing*)

(*Failed to convert flushmath: subscriptn not yet supported for expression parsing*)

(*Failed to convert cleanbox: casen not yet supported for statement parsing*)

(*Failed to convert fetch: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeover: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeunder: muln not yet supported for expression parsing*)

(*Failed to convert makevcenter: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeradical: muln not yet supported for expression parsing*)

(*Failed to convert makemathaccent: subscriptn not yet supported for expression parsing*)

(*Failed to convert makefraction: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeop: Couldn't find key "field" in data list*)

(*Failed to convert makeord: labeln not yet supported for statement parsing*)

(*Failed to convert makescripts: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeleftright: muln not yet supported for expression parsing*)

(*Failed to convert mlisttohlist: Haven't set coq type for RTR Boolean*)

(*Failed to convert pushalignment: Couldn't find key "field" in data list*)

(*Failed to convert popalignment: Couldn't find key "field" in data list*)

(*Failed to convert getpreambletoken: labeln not yet supported for statement parsing*)

(*Failed to convert initalign: andn not yet supported for expression parsing*)

(*Failed to convert initspan: Couldn't find key "field" in data list*)

(*Failed to convert initrow: subscriptn not yet supported for expression parsing*)

(*Failed to convert initcol: Couldn't find key "field" in data list*)

(*Failed to convert fincol:boolean: subscriptn not yet supported for expression parsing*)

(*Failed to convert finrow: subscriptn not yet supported for expression parsing*)

(*Failed to convert finalign: subscriptn not yet supported for expression parsing*)

(*Failed to convert alignpeek: labeln not yet supported for statement parsing*)

(*Failed to convert finiteshrink: subscriptn not yet supported for expression parsing*)

(*Failed to convert trybreak: goton not yet supported for statement parsing*)

(*Failed to convert postlinebreak: subscriptn not yet supported for expression parsing*)

(*Failed to convert reconstitute: Couldn't find key "field" in data list*)

(*Failed to convert hyphenate: blockn not yet supported for expression parsing*)

(*Failed to convert linebreak: subscriptn not yet supported for expression parsing*)

(*Failed to convert newhyphexceptions: subscriptn not yet supported for expression parsing*)

(*Failed to convert prunepagetop: Couldn't find key "field" in data list*)

(*Failed to convert vertbreak: casen not yet supported for statement parsing*)

(*Failed to convert vsplit: subscriptn not yet supported for expression parsing*)

Definition printtotals (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 1 0) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (subscript (VP_store "VP_PAGESOFAR") 2 0 !=? 0) then
 	 ((*Block: next 3 statements*)
	let VP_store := print VP_store 312 in
	let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 2 0) in
	let VP_store := print VP_store 338 in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (subscript (VP_store "VP_PAGESOFAR") 3 0 !=? 0) then
 	 ((*Block: next 3 statements*)
	let VP_store := print VP_store 312 in
	let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 3 0) in
	let VP_store := print VP_store 311 in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (subscript (VP_store "VP_PAGESOFAR") 4 0 !=? 0) then
 	 ((*Block: next 3 statements*)
	let VP_store := print VP_store 312 in
	let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 4 0) in
	let VP_store := print VP_store 979 in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (subscript (VP_store "VP_PAGESOFAR") 5 0 !=? 0) then
 	 ((*Block: next 3 statements*)
	let VP_store := print VP_store 312 in
	let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 5 0) in
	let VP_store := print VP_store 980 in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (subscript (VP_store "VP_PAGESOFAR") 6 0 !=? 0) then
 	 ((*Block: next 2 statements*)
	let VP_store := print VP_store 313 in
	let VP_store := printscaled VP_store (subscript (VP_store "VP_PAGESOFAR") 6 0) in VP_store) 
else
 	VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" printtotals.

(*Failed to convert freezepagespecs: subscriptn not yet supported for expression parsing*)

(*Failed to convert boxerror: subscriptn not yet supported for expression parsing*)

(*Failed to convert ensurevbox: subscriptn not yet supported for expression parsing*)

(*Failed to convert fireup: subscriptn not yet supported for expression parsing*)

(*Failed to convert buildpage: goton not yet supported for statement parsing*)

(*Failed to convert appspace: subscriptn not yet supported for expression parsing*)

Definition insertdollarsign (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := backinput VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_CURTOK" (VInteger ( 804 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := if (get_int VP_store "VP_INTERACTION" =? 3) then
 	 
else
 	((*nothing and mid-seq*) VP_store) in
	let VP_store := printnl VP_store 262 in
	let VP_store := print VP_store 1018 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 2 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1019 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1020 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := inserror VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" insertdollarsign.

(*Failed to convert youcant: subscriptn not yet supported for expression parsing*)

Definition reportillegalcase (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := youcant VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 5 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 4 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1022 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1023 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1024 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1025 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" reportillegalcase.

(*Failed to convert privileged:boolean: subscriptn not yet supported for expression parsing*)

(*Failed to convert itsallover:boolean: goton not yet supported for statement parsing*)

(*Failed to convert appendglue: casen not yet supported for statement parsing*)

(*Failed to convert appendkern: Couldn't find key "field" in data list*)

(*Failed to convert offsave: Expected procedure or Function call, but got $getavail:Word*)

(*Failed to convert extrarightbrace: casen not yet supported for statement parsing*)

(*Failed to convert normalparagraph: subscriptn not yet supported for expression parsing*)

(*Failed to convert boxend: andn not yet supported for expression parsing*)

(*Failed to convert beginbox: casen not yet supported for statement parsing*)

(*Failed to convert scanbox: andn not yet supported for expression parsing*)

(*Failed to convert package: subscriptn not yet supported for expression parsing*)

Definition normmin (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_H" <=? 0) then
 	 (update VP_store "VP_result" (VInteger ( 1 ))) 
else
 	(let VP_store := if (get_int VP_store "VP_H" >=? 63) then
 	 (update VP_store "VP_result" (VInteger ( 63 ))) 
else
 	(update VP_store "VP_result" (VInteger ( get_int VP_store "VP_H" ))) in VP_store) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" normmin.

(*Failed to convert newgraf: Couldn't find key "field" in data list*)

(*Failed to convert indentinhmode: Expected procedure or Function call, but got $newnullbox:Word*)

(*Failed to convert headforvmode: Couldn't find key "field" in data list*)

(*Failed to convert endgraf: subscriptn not yet supported for expression parsing*)

(*Failed to convert begininsertoradjust: Couldn't find key "field" in data list*)

(*Failed to convert makemark: Couldn't find key "field" in data list*)

(*Failed to convert appendpenalty: Couldn't find key "field" in data list*)

(*Failed to convert deletelast: subscriptn not yet supported for expression parsing*)

(*Failed to convert unpackage: subscriptn not yet supported for expression parsing*)

(*Failed to convert appenditaliccorrection: goton not yet supported for statement parsing*)

(*Failed to convert appenddiscretionary: Expected procedure or Function call, but got $newdisc:Word*)

(*Failed to convert builddiscretionary: subscriptn not yet supported for expression parsing*)

(*Failed to convert makeaccent: subscriptn not yet supported for expression parsing*)

(*Failed to convert alignerror: Inline function in_abs_long not yet supported*)

Definition noalignerror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := if (get_int VP_store "VP_INTERACTION" =? 3) then
 	 
else
 	((*nothing and mid-seq*) VP_store) in
	let VP_store := printnl VP_store 262 in
	let VP_store := print VP_store 1115 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printesc VP_store 527 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 2 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1123 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1124 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" noalignerror.

Definition omiterror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := if (get_int VP_store "VP_INTERACTION" =? 3) then
 	 
else
 	((*nothing and mid-seq*) VP_store) in
	let VP_store := printnl VP_store 262 in
	let VP_store := print VP_store 1115 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printesc VP_store 530 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 2 )) in
	let VP_store := update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1125 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1124 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" omiterror.

(*Failed to convert doendv: andn not yet supported for expression parsing*)

Definition cserror (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 3 statements*)
	let VP_store := if (get_int VP_store "VP_INTERACTION" =? 3) then
 	 
else
 	((*nothing and mid-seq*) VP_store) in
	let VP_store := printnl VP_store 262 in
	let VP_store := print VP_store 777 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := printesc VP_store 505 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 ((*Block: next 2 statements*)
	let VP_store := update VP_store "VP_HELPPTR" (VInteger ( 1 )) in
update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)HELPLINE" (VInteger ( 1127 )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := error VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" cserror.

(*Failed to convert pushmath: Couldn't find key "field" in data list*)

(*Failed to convert initmath: subscriptn not yet supported for expression parsing*)

(*Failed to convert starteqno: Couldn't find key "field" in data list*)

(*Failed to convert scanmath: labeln not yet supported for statement parsing*)

(*Failed to convert setmathchar: Expected procedure or Function call, but got $newnoad:Word*)

(*Failed to convert mathlimitswitch: Couldn't find key "field" in data list*)

(*Failed to convert scandelimiter: andn not yet supported for expression parsing*)

(*Failed to convert mathradical: Couldn't find key "field" in data list*)

(*Failed to convert mathac: Couldn't find key "field" in data list*)

(*Failed to convert appendchoices: Expected procedure or Function call, but got $newchoice:Word*)

(*Failed to convert finmlist: Couldn't find key "field" in data list*)

(*Failed to convert buildchoices: casen not yet supported for statement parsing*)

(*Failed to convert subsup: subscriptn not yet supported for expression parsing*)

(*Failed to convert mathfraction: Couldn't find key "field" in data list*)

(*Failed to convert mathleftright: Expected procedure or Function call, but got $newnoad:Word*)

(*Failed to convert aftermath: orn not yet supported for expression parsing*)

(*Failed to convert resumeafterdisplay: subscriptn not yet supported for expression parsing*)

(*Failed to convert getrtoken: labeln not yet supported for statement parsing*)

(*Failed to convert trapzeroglue: subscriptn not yet supported for expression parsing*)

(*Failed to convert doregistercommand: goton not yet supported for statement parsing*)

(*Failed to convert alteraux: Couldn't find key "field" in data list*)

(*Failed to convert alterprevgraf: Inline function in_abs_long not yet supported*)

Definition alterpagesofar (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_C" (VInteger ( get_int VP_store "VP_CURCHR" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := scanoptionalequals VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := scandimen VP_store 0 0 0 in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_(* This is a vecn id_of_parse_tree, something's gonna go wrong *)PAGESOFAR" (VInteger ( get_int VP_store "VP_CURVAL" )),VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" alterpagesofar.

Definition alterinteger (VP_store: store) := 
	let VP_poison := false in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (update VP_store "VP_C" (VInteger ( get_int VP_store "VP_CURCHR" )),VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := scanoptionalequals VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := scanint VP_store in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
	let (VP_store,VP_poison) := 
		(if (negb VP_poison) then
 			 (let VP_store := if (get_int VP_store "VP_C" =? 0) then
 	 (update VP_store "VP_DEADCYCLES" (VInteger ( get_int VP_store "VP_CURVAL" ))) 
else
 	(update VP_store "VP_INSERTPENALTIES" (VInteger ( get_int VP_store "VP_CURVAL" ))) in VP_store,VP_poison) 
		else
 			(VP_store,true)) in
VP_store.
Extraction "tex.ml" alterinteger.

(*Failed to convert alterboxdimen: Couldn't find key "field" in data list*)

(*Failed to convert newfont: Expected procedure or Function call, but got $makestring:SmallInt*)

(*Failed to convert newinteraction: Haven't set coq type for RTR Boolean*)

(*Failed to convert prefixedcommand: notn not yet supported for expression parsing*)

(*Failed to convert doassignments: andn not yet supported for expression parsing*)

(*Failed to lift openorclosein: Haven't set coq type for RTR Text*)
(*Failed to convert issuemessage: Couldn't find key "field" in data list*)

(*Failed to convert shiftcase: subscriptn not yet supported for expression parsing*)

(*Failed to convert showwhatever: casen not yet supported for statement parsing*)

(*Failed to convert newwhatsit: Couldn't find key "field" in data list*)

(*Failed to convert newwritewhatsit: Couldn't find key "field" in data list*)

(*Failed to convert doextension: casen not yet supported for statement parsing*)

(*Failed to convert fixlanguage: subscriptn not yet supported for expression parsing*)

(*Failed to convert handlerightbrace: casen not yet supported for statement parsing*)

(*Failed to convert maincontrol: subscriptn not yet supported for expression parsing*)

(*Failed to convert giveerrhelp: subscriptn not yet supported for expression parsing*)

(*Failed to convert openfmtfile:boolean: subscriptn not yet supported for expression parsing*)

(*Failed to convert loadfmtfile:boolean: subscriptn not yet supported for expression parsing*)

(*Failed to convert closefilesandterminate: Couldn't find key "field" in data list*)

(*Failed to convert finalcleanup: Couldn't find key "field" in data list*)

(*Failed to convert execeditor: Couldn't find key "value" in data list*)

(*Failed to convert $main: goton not yet supported for statement parsing*)

Compute (main fresh_store).
