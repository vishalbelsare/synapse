%import common.WS
%import common.LCASE_LETTER
%import common.LETTER
%import common.DIGIT
%import common.ESCAPED_STRING

query: WSCOMM? ((command | queryoption | editopers | oper) WSCOMM?)*

command: "|" WS? stormcmd WSCOMM? ["|"]

queryoption: "%" WS? LCASE_LETTER+ WS? "=" (LETTER | DIGIT)+
editopers: "[" WS? (editoper WS?)* "]"
editoper: editpropset | editunivset | edittagadd | editpropdel | editunivdel | edittagdel | editnodeadd
edittagadd: "+" tagname [WS? "=" valu]
editunivdel: "-" UNIVPROP
edittagdel: "-" tagname
editpropset: RELPROP WS? "=" WS? valu
editpropdel: "-" RELPROP
editunivset: UNIVPROP WS? "=" WS? valu
editnodeadd: ABSPROP WS? "=" WS? valu
ABSPROP: VARSETS // must be a propname

oper: subquery | formpivot | formjoin | formpivotin | formjoinin | lifttagtag | opervarlist | filtoper | liftbytag
    | liftpropby | stormcmd | operrelprop | forloop | switchcase | "break" | "continue" | valuvar

forloop: "for" WS? (VARNAME | varlist) WS? "in" WS? VARNAME WS? subquery
subquery: "{" query "}"
switchcase: "switch" WS? varvalu WS? "{" (WSCOMM? (("*" WS? ":" subquery) | (CASEVALU WSCOMM? subquery)) )* WSCOMM? "}"
varlist: "(" [WS? VARNAME (WS? "," WS? VARNAME)*] WS? ["," WS?] ")"
CASEVALU: (DOUBLEQUOTEDSTRING WSCOMM? ":") | /[^:]+:/

// Note: changed from syntax.py in that cannot start with ':' or '.'
VARSETS: ("$" | "." | LETTER | DIGIT) ("$" | "." | ":" | LETTER | DIGIT)*

// TAGMATCH and tagname/TAG are redundant
formpivot: "->" WS? ("*" | TAGMATCH | ABSPROP)
formjoin:   "-+>" WS? ("*" | ABSPROP)
formpivotin: "<-" WS? ("*" | ABSPROP)
formjoinin: "<+-" WS? ("*" | ABSPROP)
opervarlist: varlist WS? "=" WS? valu

operrelprop: RELPROP [WS? (proppivot | propjoin)]
proppivot: "->" WS? ("*" | ABSPROP)
propjoin: "-*>" WS? ABSPROP

valuvar: VARNAME WS? "=" WS? valu

liftpropby: PROPNAME [(tagname [WS? CMPR valu]) | (WS? CMPR WS? valu)]
lifttagtag: "#" tagname
liftbytag: tagname
tagname: "#" WS? (VARNAME | TAG)

VARNAME: "$" WS? VARTOKN
VARTOKN: VARCHARS
VARCHARS: (LETTER | DIGIT | "_")+
stormcmd: CMDNAME (WS cmdargv)* [WS? "|"]
cmdargv: subquery | DOUBLEQUOTEDSTRING | SINGLEQUOTEDSTRING | NONCMDQUOTE

// Note: different from syntax.py in explicitly disallowing # as first char
TAG: /[^#=\)\]},@ \t\n][^=\)\]},@ \t\n]*/
TAGMATCH: /#[^=)\]},@ \t\n]*/

CMPR: /\*.*?=|[!<>@^~=]+/
valu: NONQUOTEWORD | valulist | varvalu | RELPROPVALU | UNIVPROPVALU | tagname | DOUBLEQUOTEDSTRING
    | SINGLEQUOTEDSTRING
valulist: "(" [WS? valu (WS? "," WS? valu)*] WS? ["," WS?] ")"

NONCMDQUOTE: /[^ \t\n|}]+/
NONQUOTEWORD: (LETTER | DIGIT | "-" | "?") /[^ \t\n\),=\]}|]*/

varvalu:  VARNAME (VARDEREF | varcall)*
varcall: valulist
filtoper: ("+" | "-") cond

cond: condexpr | condsubq | ("not" WS? cond)
    | ((RELPROP | UNIVPROP | tagname | ABSPROP) [WS? CMPR WS? valu])
condexpr: "(" WS? cond (WS? (("and" | "or") WS? cond))* WS? ")"
condsubq: "{" WSCOMM? query WS? "}" [WSCOMM? CMPR valu]
VARDEREF: "." VARTOKN
DOUBLEQUOTEDSTRING: ESCAPED_STRING
SINGLEQUOTEDSTRING: "'" /[^']/ "'"
UNIVPROP:  "." VARSETS
UNIVPROPVALU: UNIVPROP

RELPROP: ":" VARSETS
RELPROPVALU: RELPROP

// Whitespace or comments
WSCOMM: (CCOMMENT | CPPCOMMENT | WS)+

// From https://stackoverflow.com/a/36328890/6518334
CCOMMENT: /\/\*+[^*]*\*+(?:[^\/*][^*]*\*+)*\//
CPPCOMMENT: /\/\/[^\n]*/

// TOOD:  fix all one-word propnames and define propname as word with a colon
PROPNAME: "inet:fqdn" | "inet:dns:a" | "inet:dns:query" | "syn:tag" | "teststr:tick" | "teststr" | ".created"
    | "refs" | ".seen" | ".hehe" | "testcomp:haha" | "testcomp" | "testint:loc" | "testint" | "wentto"
    | ".favcolor" | "file:bytes:size" | "pivcomp:tick" | "pivcomp" | "pivtarg" | "inet:ipv4:loc"
    | "inet:ipv4" | "seen:source" | "inet:user" | "media:news"
    | "ps:person" | "geo:place:latlong" | "geo:place" | "cluster" | "testguid" | "inet:asn"
    | "tel:mob:telem:latlong" | "source" // FIXME: all the props

CMDNAME: "help" | "iden" | "movetag" | "noderefs" | "sudo" | "limit" | "reindex" | "delnode" | "uniq" | "count"
    | "spin" | "graph" | "max" | "min" | "sleep" // FIXME: all the commands
