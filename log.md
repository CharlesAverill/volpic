# Goal

I want to verify the correctness of TeX and/or Metafont. My expectation is that
I'll have to do the following: 

1. Recompile TeX/MF to the most modern dialect of Pascal (Free Pascal)
2. Export a Pascal AST from the Free Pascal Compiler (FPC)
3. Write a lifter program that reads in Pascal ASTs and writes out Gallina code
4. Ensure the Gallina code can be extracted to OCaml/Haskell code
5. Write correctness specifications for core operations
6. Verify the correctness of said operations

# Recompilation

Thankfully, TeX and MF have already been recompiled via the [`tex-fpc`](https://ctan.org/pkg/tex-fpc?lang=en)
package. I've included some scripts to smooth this process out.

# AST Export

This is trickier. FPC offers a flag `-vp` that dumps a parse tree to a file,
but it doesn't seem to contain all of the information I need. Namely, string
constants are not included in the output. Additionally, it seems like a very
complex output format.

# Lifter

Step 1 is the parser. This was very tedious, FPC's parse tree dump language is
awful (and it's been a long time since I've written a grammar this complex, I
really need to read up on LR(1) parsing again). I ran into a ton of menhir 
stability issues and bad error messages, and yacc isn't expressive enough for
a large part of the grammar, which is unfortunate because its conflict files are
paradoxically vastly easier to read than menhir's. Some of the grammar is 
context-sensitive, which I will have to delay to a custom parser later in the 
pipeline.

Parser has hit first milestone: I can parse a standard "Hello World" with an assignment
as well as an empty program. Next step: parsing mf and tex. After that, I can start
lifting into Gallina.

Parser has parsed the ASTs for TeX and MF! The grammar has a number of conflicts
and there are surely translation bugs but this is a huge milestone. Now that I
have an OCaml program that can read Pascal programs, I can begin to export Gallina 
code.

I've begun lifting. Initially, I thought to hook into the `coq-core` library in
order to utilize existing infrastructure for generating Coq ASTs. Unfortunately,
the library is devilishly complex, and I have yet to find a clean way to generate
even something as simple as a constant Definition vernacular. I've resorted to
implementing my own code generator, and I've found this to be conducive to quick
development. I feel uneasy about doing string generation on something this complex,
but I've decided I'll deal with those problems when I get to them. I'm currently
working on implementing imperative behavior, and the biggest issue is retrieving
from the store. Variables can have many types, so I'm left with a few options:

1. Have one store that contains all variable values. A sum type is required to
distinguish between them.
2. Have multiple stores, one for each type. This requires a much larger amount
of architectural design, and I think it will make for more difficult proof goals.

I prefer step 1. It has some issues: for example, I believe I'll need to check
for the presence of identifiers in the store for any statement that draws from 
the store. If any aren't present, the file must still compile, so the store is
forced to return a default value like 0, instead of making the store return
`option value`. As a saving grace, I can implement poison values, similar to how
LLVM prevents bad data from progressing through a program. At the beginning of
each statement, I can have something like:

```
let store, poison = 
    if all_present store [<id in expr 1>; <id in expr 2>; ... <id in expr n>]
    then
        <new store computation>, poison
    else 
        store, true 
    in
...
```

This way, computations just aren't performed if the program state is poisoned
by an undeclared identifier. The function can return a store and poison value,
and the poison should propagate all the way through the control flow. I like this
approach for a few reasons:

1. It will reduce in proof states very easily thanks to automatic reduction of
the `update` function
2. It can be expanded to a number of other errors, such as overflows that might
be bugs
3. It is a tangible target for verification (forall inputs, is_poisoned (f inputs) = false)

It does have a pretty annoying issue: I still have a store with a sum type, so if
I want to retrieve from it I have to have `get_int`, `get_string`, etc. functions
that DO contain a default value. This default value is never used thanks to our
poison check, but it's still required to compile.

I just realized I'll need a typing context so I know which get function to call...
ugh.

Huge issue encountered! FPC does not export some pretty important data points:

- Values of string constants
- Record field names when loading/storing

I've patched the compiler to support string constants, currently working on 
field names, but it seems much more complicated. Going to submit a merge request
when I finish, exciting!

[Merge Request](https://gitlab.com/freepascal.org/fpc/source/-/merge_requests/567) 
complete! Was about as challenging as I was expecting. Still waiting on approval,
but the code works as I need it to, so I'll be going forward using my own branch. 

# Extraction

Work on extraction began briefly after the first successful lift was performed.
I'm very thankful that I had mentioned I was considering verifying another 
project of mine to my advisor a few months ago, because he gave me a piece of
advice that was crucial to piecing things together here (I'm paraphrasing):
    "If you want to verify code that has side effect functions, like printing
    or rendering to a screen, you'll have to admit those as axioms in Coq."
I was very disappointed in 
- The official Coq page on code extraction (although not surprised given how 
lackluster all official Coq documentation is)
- The Software Foundations "Extraction" chapter (very surprised given how 
incredible the rest of the textbook is)
- The CoqOfOCaml project, which seemed like a good first place to start looking
for lifting a simple "Hello World!" program, but does not have a MWE available
via the latest opam distribution.

It turns out extraction of side effect functions is as easy as 
admitting them as axioms, and then giving Coq an exact textual
representation of what you want that side effect function to 
extract to. For example:

```coq
Axiom print_endline : string -> unit.
Extract Inlined Constant print_endline => "print_endline".

(* This one is necessary because Coq extracts coq strings as
ocaml char lists *)
Axiom string_of_char_list : string -> string.
Extract Constant string_of_char_list => "fun cl -> (String.of_seq (List.to_seq cl))".
```

You don't even have to make them axioms. One issue I was having was
when I generated side effect code, if I used 
`let _ = <side effect> in <rest of program>`, Coq just wouldn't
extract the side effect at all. The solution was to make them
definitions rather than axioms, meaning I could make them perform
any side effects on the global state that I wanted, but still
give them a reasonable extraction value:

```coq
Definition fpc_write_text_uint (s : store) (_ _ : Z) := s.
Extract Inlined Constant fpc_write_text_uint => "(fun s x _ -> print_int x; s)".
```

I currently only have support for OCaml because of 
`Extract Inlined Constant` vernaculars like this one, but it
shouldn't be very difficult to write Haskell versions of 
everything, and then parametrize my generated Coq code to include
either an OCaml or Haskell extraction library.

I've implemented struct accesses by "unfolding" the structs; each field has its
own symbol in the store, which is just "<struct variable name>_<field name>".
This is fine for now, but brings up a problem: if a struct is returned from a 
function, the caller would have to rename (?) the result variables. Although now
that I'm thinking about it, wouldn't this need to happen anyways? 

Nevermind! That was easy enough to implement.

It is now a few weeks later (Jan 29), I let this project sit for a bit while I did 
some other work (and got stuck in airports for a week). I'm scaling back a bit and
have decided to tackle the following features before I look at TeX/MF again:

- Vectors/Arrays
- While loops
- Break statements

My goal is to lift a simple algorithms test and then verify the correctness of
a bubble sort, a linear search, and a binary search. I hope to have these done
before February 7th, when I'll be presenting this research at the Dallas Hackers'
Association as my final talk there.

# Correctness

# Verification

# Methodology

This section doesn't have anything specific to do with the project, but I want
to answer a question I get frequently, which is: 
    "How do you go about completing your projects."
So now that you've read a brief history of the project, I can give some examples
that will put my methodology into context.

## Step 1 - Don't Plan Ahead

Step 1 is less of an action and more of a feeling. I have a loose idea of what
I want to accomplish, and very often I know little to nothing about what tools,
practices, languages, architectures, pipelines, or other facilities that I will
use. Oftentimes, if I think I know something about any of those facilities, it
will turn out to be wrong before a week of development has gone by!
I will mention some examples like these throughout this section.

My [Goal Section](#goal) was a day-1 rough idea of what I thought
the entire pipeline would look like. As I write this in between
working on the lifter and extraction, it seems to have been a 
pretty accurate plan.

## Step 2 - Go Blindly Into That Good Night

The first action I take during development is simple - just start
writing some code. Technically I didn't do this step first for
Volpic, as I had to transliterate TeX and MF for FPC, which I would
consider to be "environment setup" rather than code writing. 
Regardless, right after that is when I started writing. I knew I
would need access to parse trees, so I began writing a parser.
And what better language to write a parser in than OCaml? Within
a day, I had a very bad parser (that would get better!) written for
a **subset** of FPC's (terrible) AST dump language.

## Step 3 - Baby Steps

Once I have a rudimentary project going, the space of possible
features to add grows exponentially. After I could parse a subset
of the AST language, I could now parse a slightly larger subset.
Rinse and repeat about 20 times, throw in breaks to debug the 
(still heavily conflicted) language grammar, and I had a pretty
okay parser that could successfully parse a simple "Hello World!"

With a parser written, I could now jump over to lifting, the part
I've been most excited to work on. I'll talk more about what 
happened there, but the main idea is that I eventually got to a 
point to where I could work on parsing, lifting, extraction, and
verification at any point in time. This is where my "flow state"
begins. I feel like a cowboy on the frontier, exploring the unknown
with nobody to answer to. I'm still in the middle of this state,
and I love how frequently I get to say:

    "Look, the first pascal program with multiple functions lifted into Coq!"

    "Look, the first OCaml program automatically generated from Coq code that's been lifted from Pascal!"

    "Look, the first proof about a pascal program automatically lifted into Coq!"
    
Even though these are things that have been done similarly for a 
large number of other languages, it's very rewarding to be able
to say that I've done these things, largely through my own effort.

## Step 4 - Give Up

This one's weird, and I'm actually hoping it doesn't happen on this
project, but I'd be lying if I left it out of my development 
process: whenever I get bored of a project, or I hit an improvement
that is more than monumental to add, I will usually give up on it.
There are a few reasons for this:

1. I like working on things that interest me. Software engineering
is not inherently interesting, but building things from the 
ground-up is. So when I hit the late stages of a project, and the
challenges turn from "learn how rendering pipelines work so you 
can write a raytracer" into "refactor your raytracer into a 
raymarcher so that you can add relativistic effects," I very
quickly lose steam.
2. My interests vary, not just in computer science. My project 
ideas usually stem from overhearing or reading something, letting
that roll around in my head for a few weeks, and then eventually
putting it into action. Many times, these brain-rolling periods
overlap, and as I'm working on "tedious problem #9" on project A,
I begin to think about how I would solve "interesting problem #1"
on project B, and then it isn't that I'm not still interested in
project A, but project B is just so enticing that I can't resist.
On rare occasions I've gone back to my project B's, and it's 
very rewarding.
3. Being just plain busy. This doesn't apply so much anymore, as 
I've just graduated with my Bachelor's degree a few weeks ago,
but many times I've had to give up a project for a week in order
to study for an exam, write a lecture, maintain a social life, or
a number of other things that students have to worry about. I hate
these times, because one week is just enough time for me to forget 
50% of the knowledge I'd gained but forgotten to write down in
my source code, leading to me having to study code for a few days
to get back to where I was, which isn't fun!

