# 17 "tools/coqwc.mll"
       
open Printf
open Lexing
open Filename
(*i*)

(*s Command-line options. *)

let spec_only = ref false
let proof_only = ref false
let percentage = ref false
let skip_header = ref true

(*s Counters. [clines] counts the number of code lines of the current
    file, and [dlines] the number of comment lines. [tclines] and [tdlines]
    are the corresponding totals. *)

let slines = ref 0
let plines = ref 0
let dlines = ref 0

let tslines = ref 0
let tplines = ref 0
let tdlines = ref 0

let update_totals () =
  tslines := !tslines + !slines; 
  tplines := !tplines + !plines; 
  tdlines := !tdlines + !dlines

(*s The following booleans indicate whether we have seen spec, proof or
    comment so far on the current line; when a newline is reached, [newline]
    is called and updates the counters accordingly. *)

let seen_spec = ref false
let seen_proof = ref false
let seen_comment = ref false

let newline () =
  if !seen_spec then incr slines; 
  if !seen_proof then incr plines; 
  if !seen_comment then incr dlines; 
  seen_spec := false; seen_proof := false; seen_comment := false

let reset_counters () = 
  seen_spec := false; seen_proof := false; seen_comment := false;
  slines := 0; plines := 0; dlines := 0

(*s Print results. *)

let print_line sl pl dl fo =
  if not !proof_only then printf " %8d" sl;
  if not !spec_only then printf " %8d" pl;
  if not (!proof_only || !spec_only) then printf " %8d" dl;
  (match fo with Some f -> printf " %s" f | _ -> ());
  if !percentage then begin
    let s = sl + pl + dl in
    let p = if s > 0 then 100 * dl / s else 0 in
    printf " (%d%%)" p
  end;
  print_newline ()

let print_file fo = print_line !slines !plines !dlines fo

let print_totals () = print_line !tslines !tplines !tdlines (Some "total")

(*i*)
# 70 "tools/coqwc.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\247\255\248\255\002\000\000\000\000\000\001\000\001\000\
    \000\000\002\000\000\000\003\000\253\255\254\255\000\000\001\000\
    \003\000\252\255\004\000\002\000\000\000\005\000\000\000\005\000\
    \250\255\251\255\001\000\006\000\001\000\000\000\000\000\008\000\
    \003\000\004\000\000\000\011\000\011\000\006\000\007\000\021\000\
    \024\000\008\000\015\000\025\000\012\000\013\000\027\000\025\000\
    \021\000\027\000\017\000\029\000\024\000\026\000\014\000\249\255\
    \098\000\008\000\000\000\108\000\049\000\249\255\250\255\046\000\
    \060\000\157\000\253\255\254\255\018\000\019\000\022\000\251\255\
    \252\255\129\000\026\000\149\000\180\000\231\000\248\255\249\255\
    \047\000\160\000\162\000\005\000\253\255\254\255\030\000\032\000\
    \036\000\250\255\252\255\251\255\230\000\036\000\198\000\242\000\
    \035\001\247\255\248\255\051\000\042\000\040\000\041\000\047\000\
    \031\000\252\255\178\000\254\255\037\000\038\000\174\000\253\255\
    \063\000\065\000\086\000\229\000\251\255\041\001\046\001\075\000\
    \094\000\161\000\249\255\109\000\109\000\108\000\107\000\117\000\
    \119\000\109\000\108\000\107\000\056\001\048\000\071\001\081\001\
    \137\001\249\255\250\255\220\000\048\001\252\255\051\001\254\255\
    \049\000\051\000\183\000\253\255\251\255\136\001\057\000\146\001\
    \156\001\205\001\249\255\250\255\227\000\085\001\252\255\253\255\
    \185\000\215\000\218\000\226\000\251\255\254\255\209\001\223\000\
    \219\001\229\001\052\001\251\255\252\255\253\255\048\001\255\255\
    \254\255\142\001\251\255\252\255\132\001\254\255\222\000\255\255\
    \232\000\252\255\253\255\231\000\235\000\255\255\254\255\042\001\
    \253\255\254\255\255\255";
  Lexing.lex_backtrk = 
   "\255\255\255\255\255\255\007\000\007\000\007\000\007\000\007\000\
    \007\000\007\000\007\000\003\000\255\255\255\255\007\000\000\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\005\000\
    \004\000\005\000\255\255\255\255\005\000\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \006\000\005\000\006\000\006\000\255\255\255\255\006\000\000\000\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\007\000\007\000\007\000\007\000\007\000\
    \007\000\255\255\002\000\255\255\007\000\000\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\005\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\005\000\005\000\255\255\002\000\255\255\
    \005\000\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\005\000\004\000\255\255\255\255\
    \005\000\005\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\003\000\255\255\
    \255\255\255\255\255\255\255\255\002\000\255\255\003\000\255\255\
    \255\255\255\255\255\255\002\000\002\000\255\255\255\255\255\255\
    \255\255\255\255\255\255";
  Lexing.lex_default = 
   "\002\000\000\000\000\000\057\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\000\000\000\000\255\255\255\255\
    \255\255\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\000\000\
    \255\255\255\255\255\255\255\255\062\000\000\000\000\000\074\000\
    \255\255\255\255\000\000\000\000\255\255\255\255\255\255\000\000\
    \000\000\255\255\255\255\255\255\255\255\079\000\000\000\000\000\
    \093\000\255\255\255\255\255\255\000\000\000\000\255\255\255\255\
    \255\255\000\000\000\000\000\000\255\255\255\255\255\255\255\255\
    \098\000\000\000\000\000\133\000\255\255\255\255\255\255\255\255\
    \255\255\000\000\255\255\000\000\255\255\255\255\255\255\000\000\
    \255\255\255\255\255\255\255\255\000\000\255\255\255\255\255\255\
    \255\255\121\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \138\000\000\000\000\000\150\000\255\255\000\000\255\255\000\000\
    \255\255\255\255\255\255\000\000\000\000\255\255\255\255\255\255\
    \255\255\155\000\000\000\000\000\167\000\255\255\000\000\000\000\
    \255\255\255\255\255\255\255\255\000\000\000\000\255\255\255\255\
    \255\255\255\255\172\000\000\000\000\000\000\000\255\255\000\000\
    \000\000\179\000\000\000\000\000\255\255\000\000\255\255\000\000\
    \186\000\000\000\000\000\255\255\255\255\000\000\000\000\193\000\
    \000\000\000\000\000\000";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\011\000\012\000\000\000\011\000\011\000\025\000\024\000\
    \011\000\000\000\025\000\000\000\000\000\000\000\000\000\055\000\
    \000\000\000\000\000\000\055\000\000\000\000\000\000\000\000\000\
    \011\000\000\000\013\000\011\000\000\000\025\000\000\000\003\000\
    \014\000\255\255\015\000\016\000\017\000\016\000\055\000\002\000\
    \059\000\059\000\059\000\059\000\059\000\059\000\059\000\059\000\
    \059\000\059\000\064\000\066\000\069\000\070\000\064\000\071\000\
    \070\000\062\000\090\000\005\000\004\000\064\000\008\000\006\000\
    \087\000\064\000\088\000\079\000\009\000\089\000\088\000\109\000\
    \110\000\064\000\007\000\067\000\010\000\255\255\255\255\098\000\
    \063\000\068\000\255\255\145\000\064\000\146\000\056\000\065\000\
    \138\000\029\000\023\000\030\000\033\000\046\000\031\000\026\000\
    \018\000\019\000\022\000\023\000\036\000\023\000\027\000\037\000\
    \035\000\020\000\021\000\028\000\023\000\032\000\034\000\023\000\
    \038\000\039\000\040\000\041\000\042\000\043\000\044\000\045\000\
    \023\000\047\000\048\000\049\000\050\000\051\000\052\000\053\000\
    \054\000\057\000\073\000\092\000\129\000\124\000\123\000\132\000\
    \119\000\112\000\058\000\058\000\058\000\058\000\058\000\058\000\
    \058\000\058\000\058\000\058\000\057\000\057\000\057\000\057\000\
    \057\000\057\000\057\000\057\000\057\000\057\000\072\000\072\000\
    \074\000\081\000\072\000\091\000\091\000\081\000\113\000\091\000\
    \114\000\075\000\075\000\075\000\075\000\075\000\075\000\075\000\
    \075\000\075\000\075\000\106\000\115\000\072\000\057\000\106\000\
    \081\000\120\000\091\000\121\000\057\000\076\000\076\000\076\000\
    \076\000\076\000\076\000\076\000\076\000\076\000\076\000\122\000\
    \057\000\121\000\106\000\125\000\057\000\126\000\057\000\111\000\
    \110\000\127\000\128\000\121\000\130\000\074\000\131\000\121\000\
    \147\000\146\000\165\000\074\000\074\000\074\000\074\000\074\000\
    \074\000\074\000\074\000\074\000\074\000\074\000\117\000\074\000\
    \081\000\084\000\117\000\074\000\081\000\074\000\095\000\095\000\
    \095\000\095\000\095\000\095\000\095\000\095\000\095\000\095\000\
    \001\000\162\000\255\255\255\255\163\000\117\000\155\000\081\000\
    \183\000\085\000\255\255\164\000\163\000\093\000\080\000\086\000\
    \187\000\190\000\188\000\116\000\189\000\082\000\094\000\094\000\
    \094\000\094\000\094\000\094\000\094\000\094\000\094\000\094\000\
    \000\000\083\000\093\000\093\000\093\000\093\000\093\000\093\000\
    \093\000\093\000\093\000\093\000\106\000\105\000\255\255\255\255\
    \106\000\061\000\118\000\255\255\194\000\000\000\118\000\118\000\
    \149\000\148\000\148\000\118\000\142\000\148\000\173\000\166\000\
    \142\000\000\000\093\000\106\000\000\000\107\000\000\000\000\000\
    \093\000\118\000\099\000\108\000\000\000\000\000\118\000\000\000\
    \148\000\000\000\176\000\142\000\093\000\000\000\175\000\116\000\
    \093\000\000\000\093\000\000\000\116\000\000\000\157\000\133\000\
    \000\000\000\000\157\000\000\000\100\000\000\000\000\000\101\000\
    \134\000\134\000\134\000\134\000\134\000\134\000\134\000\134\000\
    \134\000\134\000\000\000\104\000\102\000\157\000\103\000\135\000\
    \135\000\135\000\135\000\135\000\135\000\135\000\135\000\135\000\
    \135\000\133\000\133\000\133\000\133\000\133\000\133\000\133\000\
    \133\000\133\000\133\000\000\000\176\000\180\000\000\000\000\000\
    \174\000\180\000\142\000\141\000\133\000\000\000\142\000\180\000\
    \181\000\000\000\133\000\180\000\000\000\072\000\176\000\000\000\
    \000\000\255\255\091\000\000\000\180\000\000\000\133\000\000\000\
    \000\000\142\000\133\000\143\000\133\000\000\000\180\000\150\000\
    \139\000\144\000\000\000\000\000\000\000\000\000\182\000\140\000\
    \151\000\151\000\151\000\151\000\151\000\151\000\151\000\151\000\
    \151\000\151\000\152\000\152\000\152\000\152\000\152\000\152\000\
    \152\000\152\000\152\000\152\000\150\000\150\000\150\000\150\000\
    \150\000\150\000\150\000\150\000\150\000\150\000\157\000\158\000\
    \000\000\000\000\157\000\000\000\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\150\000\000\000\000\000\078\000\
    \185\000\000\000\150\000\000\000\000\000\157\000\000\000\159\000\
    \000\000\000\000\000\000\000\000\156\000\161\000\150\000\160\000\
    \167\000\000\000\150\000\000\000\150\000\000\000\000\000\000\000\
    \000\000\168\000\168\000\168\000\168\000\168\000\168\000\168\000\
    \168\000\168\000\168\000\169\000\169\000\169\000\169\000\169\000\
    \169\000\169\000\169\000\169\000\169\000\167\000\167\000\167\000\
    \167\000\167\000\167\000\167\000\167\000\167\000\167\000\000\000\
    \000\000\000\000\000\000\097\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\192\000\000\000\000\000\167\000\000\000\000\000\
    \148\000\000\000\000\000\167\000\171\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\167\000\
    \000\000\000\000\000\000\167\000\000\000\167\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\137\000\000\000\000\000\000\000\000\000\178\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\154\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\255\255\011\000\000\000\023\000\023\000\
    \011\000\255\255\023\000\255\255\255\255\255\255\255\255\054\000\
    \255\255\255\255\255\255\054\000\255\255\255\255\255\255\255\255\
    \000\000\255\255\000\000\011\000\255\255\023\000\255\255\000\000\
    \000\000\003\000\014\000\015\000\016\000\016\000\054\000\057\000\
    \058\000\058\000\058\000\058\000\058\000\058\000\058\000\058\000\
    \058\000\058\000\060\000\060\000\068\000\069\000\060\000\070\000\
    \070\000\074\000\083\000\000\000\000\000\064\000\000\000\000\000\
    \086\000\064\000\087\000\093\000\000\000\088\000\088\000\108\000\
    \109\000\060\000\000\000\060\000\000\000\063\000\080\000\133\000\
    \060\000\060\000\099\000\144\000\064\000\145\000\003\000\060\000\
    \150\000\008\000\028\000\029\000\032\000\004\000\007\000\009\000\
    \010\000\018\000\021\000\034\000\035\000\022\000\026\000\005\000\
    \006\000\019\000\020\000\027\000\030\000\031\000\033\000\036\000\
    \037\000\038\000\039\000\040\000\041\000\042\000\043\000\044\000\
    \045\000\046\000\047\000\048\000\049\000\050\000\051\000\052\000\
    \053\000\056\000\063\000\080\000\100\000\101\000\102\000\099\000\
    \103\000\104\000\056\000\056\000\056\000\056\000\056\000\056\000\
    \056\000\056\000\056\000\056\000\059\000\059\000\059\000\059\000\
    \059\000\059\000\059\000\059\000\059\000\059\000\065\000\065\000\
    \073\000\081\000\065\000\082\000\082\000\081\000\112\000\082\000\
    \113\000\073\000\073\000\073\000\073\000\073\000\073\000\073\000\
    \073\000\073\000\073\000\106\000\114\000\065\000\056\000\106\000\
    \081\000\119\000\082\000\120\000\056\000\075\000\075\000\075\000\
    \075\000\075\000\075\000\075\000\075\000\075\000\075\000\121\000\
    \056\000\123\000\106\000\124\000\056\000\125\000\056\000\110\000\
    \110\000\126\000\127\000\128\000\129\000\073\000\130\000\131\000\
    \146\000\146\000\160\000\073\000\076\000\076\000\076\000\076\000\
    \076\000\076\000\076\000\076\000\076\000\076\000\115\000\073\000\
    \077\000\077\000\115\000\073\000\077\000\073\000\094\000\094\000\
    \094\000\094\000\094\000\094\000\094\000\094\000\094\000\094\000\
    \000\000\161\000\003\000\139\000\162\000\115\000\167\000\077\000\
    \182\000\077\000\156\000\163\000\163\000\092\000\077\000\077\000\
    \184\000\187\000\184\000\115\000\188\000\077\000\092\000\092\000\
    \092\000\092\000\092\000\092\000\092\000\092\000\092\000\092\000\
    \255\255\077\000\095\000\095\000\095\000\095\000\095\000\095\000\
    \095\000\095\000\095\000\095\000\096\000\096\000\063\000\080\000\
    \096\000\060\000\117\000\099\000\191\000\255\255\117\000\118\000\
    \139\000\140\000\140\000\118\000\142\000\140\000\170\000\156\000\
    \142\000\255\255\092\000\096\000\255\255\096\000\255\255\255\255\
    \092\000\117\000\096\000\096\000\255\255\255\255\118\000\255\255\
    \140\000\255\255\174\000\142\000\092\000\255\255\170\000\117\000\
    \092\000\255\255\092\000\255\255\118\000\255\255\157\000\132\000\
    \255\255\255\255\157\000\255\255\096\000\255\255\255\255\096\000\
    \132\000\132\000\132\000\132\000\132\000\132\000\132\000\132\000\
    \132\000\132\000\255\255\096\000\096\000\157\000\096\000\134\000\
    \134\000\134\000\134\000\134\000\134\000\134\000\134\000\134\000\
    \134\000\135\000\135\000\135\000\135\000\135\000\135\000\135\000\
    \135\000\135\000\135\000\255\255\174\000\180\000\255\255\255\255\
    \170\000\180\000\136\000\136\000\132\000\255\255\136\000\177\000\
    \177\000\255\255\132\000\177\000\255\255\065\000\174\000\255\255\
    \255\255\121\000\082\000\255\255\180\000\255\255\132\000\255\255\
    \255\255\136\000\132\000\136\000\132\000\255\255\177\000\149\000\
    \136\000\136\000\255\255\255\255\255\255\255\255\177\000\136\000\
    \149\000\149\000\149\000\149\000\149\000\149\000\149\000\149\000\
    \149\000\149\000\151\000\151\000\151\000\151\000\151\000\151\000\
    \151\000\151\000\151\000\151\000\152\000\152\000\152\000\152\000\
    \152\000\152\000\152\000\152\000\152\000\152\000\153\000\153\000\
    \255\255\255\255\153\000\255\255\139\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\156\000\149\000\255\255\255\255\077\000\
    \184\000\255\255\149\000\255\255\255\255\153\000\255\255\153\000\
    \255\255\255\255\255\255\255\255\153\000\153\000\149\000\153\000\
    \166\000\255\255\149\000\255\255\149\000\255\255\255\255\255\255\
    \255\255\166\000\166\000\166\000\166\000\166\000\166\000\166\000\
    \166\000\166\000\166\000\168\000\168\000\168\000\168\000\168\000\
    \168\000\168\000\168\000\168\000\168\000\169\000\169\000\169\000\
    \169\000\169\000\169\000\169\000\169\000\169\000\169\000\255\255\
    \255\255\255\255\255\255\096\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\191\000\255\255\255\255\166\000\255\255\255\255\
    \140\000\255\255\255\255\166\000\170\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\166\000\
    \255\255\255\255\255\255\166\000\255\255\166\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\136\000\255\255\255\255\255\255\255\255\177\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\153\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec spec lexbuf =
    __ocaml_lex_spec_rec lexbuf 0
and __ocaml_lex_spec_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 107 "tools/coqwc.mll"
           ( comment lexbuf; spec lexbuf )
# 359 "tools/coqwc.ml"

  | 1 ->
# 108 "tools/coqwc.mll"
           ( let n = string lexbuf in slines := !slines + n; 
	     seen_spec := true; spec lexbuf )
# 365 "tools/coqwc.ml"

  | 2 ->
# 110 "tools/coqwc.mll"
           ( newline (); spec lexbuf )
# 370 "tools/coqwc.ml"

  | 3 ->
# 112 "tools/coqwc.mll"
           ( spec lexbuf )
# 375 "tools/coqwc.ml"

  | 4 ->
# 114 "tools/coqwc.mll"
           ( seen_spec := true; spec_to_dot lexbuf; proof lexbuf )
# 380 "tools/coqwc.ml"

  | 5 ->
# 116 "tools/coqwc.mll"
           ( seen_spec := true; newline (); spec_to_dot lexbuf; proof lexbuf )
# 385 "tools/coqwc.ml"

  | 6 ->
# 118 "tools/coqwc.mll"
           ( seen_spec := true; definition lexbuf )
# 390 "tools/coqwc.ml"

  | 7 ->
# 120 "tools/coqwc.mll"
    ( seen_spec := true; spec lexbuf )
# 395 "tools/coqwc.ml"

  | 8 ->
# 121 "tools/coqwc.mll"
           ( () )
# 400 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_spec_rec lexbuf __ocaml_lex_state

and spec_to_dot lexbuf =
    __ocaml_lex_spec_to_dot_rec lexbuf 60
and __ocaml_lex_spec_to_dot_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 126 "tools/coqwc.mll"
           ( comment lexbuf; spec_to_dot lexbuf )
# 412 "tools/coqwc.ml"

  | 1 ->
# 127 "tools/coqwc.mll"
           ( let n = string lexbuf in slines := !slines + n; 
	     seen_spec := true; spec_to_dot lexbuf )
# 418 "tools/coqwc.ml"

  | 2 ->
# 129 "tools/coqwc.mll"
           ( newline (); spec_to_dot lexbuf )
# 423 "tools/coqwc.ml"

  | 3 ->
# 130 "tools/coqwc.mll"
           ( () )
# 428 "tools/coqwc.ml"

  | 4 ->
# 132 "tools/coqwc.mll"
           ( spec_to_dot lexbuf )
# 433 "tools/coqwc.ml"

  | 5 ->
# 134 "tools/coqwc.mll"
    ( seen_spec := true; spec_to_dot lexbuf )
# 438 "tools/coqwc.ml"

  | 6 ->
# 135 "tools/coqwc.mll"
           ( () )
# 443 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_spec_to_dot_rec lexbuf __ocaml_lex_state

and definition lexbuf =
    __ocaml_lex_definition_rec lexbuf 77
and __ocaml_lex_definition_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 141 "tools/coqwc.mll"
           ( comment lexbuf; definition lexbuf )
# 455 "tools/coqwc.ml"

  | 1 ->
# 142 "tools/coqwc.mll"
           ( let n = string lexbuf in slines := !slines + n; 
	     seen_spec := true; definition lexbuf )
# 461 "tools/coqwc.ml"

  | 2 ->
# 144 "tools/coqwc.mll"
           ( newline (); definition lexbuf )
# 466 "tools/coqwc.ml"

  | 3 ->
# 145 "tools/coqwc.mll"
           ( seen_spec := true; spec lexbuf )
# 471 "tools/coqwc.ml"

  | 4 ->
# 146 "tools/coqwc.mll"
           ( proof lexbuf )
# 476 "tools/coqwc.ml"

  | 5 ->
# 148 "tools/coqwc.mll"
           ( definition lexbuf )
# 481 "tools/coqwc.ml"

  | 6 ->
# 150 "tools/coqwc.mll"
    ( seen_spec := true; definition lexbuf )
# 486 "tools/coqwc.ml"

  | 7 ->
# 151 "tools/coqwc.mll"
           ( () )
# 491 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_definition_rec lexbuf __ocaml_lex_state

and proof lexbuf =
    __ocaml_lex_proof_rec lexbuf 96
and __ocaml_lex_proof_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 156 "tools/coqwc.mll"
           ( comment lexbuf; proof lexbuf )
# 503 "tools/coqwc.ml"

  | 1 ->
# 157 "tools/coqwc.mll"
           ( let n = string lexbuf in plines := !plines + n; 
	     seen_proof := true; proof lexbuf )
# 509 "tools/coqwc.ml"

  | 2 ->
# 160 "tools/coqwc.mll"
           ( proof lexbuf )
# 514 "tools/coqwc.ml"

  | 3 ->
# 161 "tools/coqwc.mll"
           ( newline (); proof lexbuf )
# 519 "tools/coqwc.ml"

  | 4 ->
# 163 "tools/coqwc.mll"
           ( seen_proof := true; proof lexbuf )
# 524 "tools/coqwc.ml"

  | 5 ->
# 165 "tools/coqwc.mll"
           ( proof_term lexbuf )
# 529 "tools/coqwc.ml"

  | 6 ->
# 167 "tools/coqwc.mll"
           ( seen_proof := true; spec lexbuf )
# 534 "tools/coqwc.ml"

  | 7 ->
# 169 "tools/coqwc.mll"
    ( seen_proof := true; proof lexbuf )
# 539 "tools/coqwc.ml"

  | 8 ->
# 170 "tools/coqwc.mll"
           ( () )
# 544 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_proof_rec lexbuf __ocaml_lex_state

and proof_term lexbuf =
    __ocaml_lex_proof_term_rec lexbuf 136
and __ocaml_lex_proof_term_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 173 "tools/coqwc.mll"
           ( comment lexbuf; proof_term lexbuf )
# 556 "tools/coqwc.ml"

  | 1 ->
# 174 "tools/coqwc.mll"
           ( let n = string lexbuf in plines := !plines + n; 
	     seen_proof := true; proof_term lexbuf )
# 562 "tools/coqwc.ml"

  | 2 ->
# 177 "tools/coqwc.mll"
           ( proof_term lexbuf )
# 567 "tools/coqwc.ml"

  | 3 ->
# 178 "tools/coqwc.mll"
           ( newline (); proof_term lexbuf )
# 572 "tools/coqwc.ml"

  | 4 ->
# 179 "tools/coqwc.mll"
           ( spec lexbuf )
# 577 "tools/coqwc.ml"

  | 5 ->
# 181 "tools/coqwc.mll"
    ( seen_proof := true; proof_term lexbuf )
# 582 "tools/coqwc.ml"

  | 6 ->
# 182 "tools/coqwc.mll"
           ( () )
# 587 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_proof_term_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 153
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 187 "tools/coqwc.mll"
           ( comment lexbuf; comment lexbuf )
# 599 "tools/coqwc.ml"

  | 1 ->
# 188 "tools/coqwc.mll"
           ( () )
# 604 "tools/coqwc.ml"

  | 2 ->
# 189 "tools/coqwc.mll"
           ( let n = string lexbuf in dlines := !dlines + n; 
	     seen_comment := true; comment lexbuf )
# 610 "tools/coqwc.ml"

  | 3 ->
# 191 "tools/coqwc.mll"
           ( newline (); comment lexbuf )
# 615 "tools/coqwc.ml"

  | 4 ->
# 193 "tools/coqwc.mll"
    ( comment lexbuf )
# 620 "tools/coqwc.ml"

  | 5 ->
# 195 "tools/coqwc.mll"
    ( seen_comment := true; comment lexbuf )
# 625 "tools/coqwc.ml"

  | 6 ->
# 196 "tools/coqwc.mll"
           ( () )
# 630 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and string lexbuf =
    __ocaml_lex_string_rec lexbuf 170
and __ocaml_lex_string_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 202 "tools/coqwc.mll"
         ( 0 )
# 642 "tools/coqwc.ml"

  | 1 ->
# 203 "tools/coqwc.mll"
                            ( string lexbuf )
# 647 "tools/coqwc.ml"

  | 2 ->
# 204 "tools/coqwc.mll"
         ( succ (string lexbuf) )
# 652 "tools/coqwc.ml"

  | 3 ->
# 205 "tools/coqwc.mll"
         ( string lexbuf )
# 657 "tools/coqwc.ml"

  | 4 ->
# 206 "tools/coqwc.mll"
         ( 0 )
# 662 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_string_rec lexbuf __ocaml_lex_state

and read_header lexbuf =
    __ocaml_lex_read_header_rec lexbuf 177
and __ocaml_lex_read_header_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 215 "tools/coqwc.mll"
           ( skip_comment lexbuf; skip_until_nl lexbuf; 
	     read_header lexbuf )
# 675 "tools/coqwc.ml"

  | 1 ->
# 217 "tools/coqwc.mll"
           ( () )
# 680 "tools/coqwc.ml"

  | 2 ->
# 218 "tools/coqwc.mll"
           ( read_header lexbuf )
# 685 "tools/coqwc.ml"

  | 3 ->
# 219 "tools/coqwc.mll"
           ( lexbuf.lex_curr_pos <- lexbuf.lex_curr_pos - 1 )
# 690 "tools/coqwc.ml"

  | 4 ->
# 220 "tools/coqwc.mll"
           ( () )
# 695 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_read_header_rec lexbuf __ocaml_lex_state

and skip_comment lexbuf =
    __ocaml_lex_skip_comment_rec lexbuf 184
and __ocaml_lex_skip_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 223 "tools/coqwc.mll"
         ( () )
# 707 "tools/coqwc.ml"

  | 1 ->
# 224 "tools/coqwc.mll"
         ( skip_comment lexbuf; skip_comment lexbuf )
# 712 "tools/coqwc.ml"

  | 2 ->
# 225 "tools/coqwc.mll"
         ( skip_comment lexbuf )
# 717 "tools/coqwc.ml"

  | 3 ->
# 226 "tools/coqwc.mll"
         ( () )
# 722 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_skip_comment_rec lexbuf __ocaml_lex_state

and skip_until_nl lexbuf =
    __ocaml_lex_skip_until_nl_rec lexbuf 191
and __ocaml_lex_skip_until_nl_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 229 "tools/coqwc.mll"
         ( () )
# 734 "tools/coqwc.ml"

  | 1 ->
# 230 "tools/coqwc.mll"
         ( skip_until_nl lexbuf )
# 739 "tools/coqwc.ml"

  | 2 ->
# 231 "tools/coqwc.mll"
         ( () )
# 744 "tools/coqwc.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; 
      __ocaml_lex_skip_until_nl_rec lexbuf __ocaml_lex_state

;;

# 233 "tools/coqwc.mll"
      (*i*)

(*s Processing files and channels. *)

let process_channel ch =
  let lb = Lexing.from_channel ch in
  reset_counters ();
  if !skip_header then read_header lb;
  spec lb

let process_file f =
  try
    let ch = open_in f in
    process_channel ch;
    close_in ch;
    print_file (Some f);
    update_totals ()
  with
    | Sys_error "Is a directory" -> 
	flush stdout; eprintf "coqwc: %s: Is a directory\n" f; flush stderr
    | Sys_error s -> 
	flush stdout; eprintf "coqwc: %s\n" s; flush stderr

(*s Parsing of the command line. *)

let usage () =
  prerr_endline "usage: coqwc [options] [files]";
  prerr_endline "Options are:";
  prerr_endline "  -p   print percentage of comments";
  prerr_endline "  -s   print only the spec size";
  prerr_endline "  -r   print only the proof size";
  prerr_endline "  -e   (everything) do not skip headers";
  exit 1

let rec parse = function
  | [] -> []
  | ("-h" | "-?" | "-help" | "--help") :: _ -> usage ()
  | ("-s" | "--spec-only") :: args -> 
      proof_only := false; spec_only := true; parse args
  | ("-r" | "--proof-only") :: args -> 
      spec_only := false; proof_only := true; parse args
  | ("-p" | "--percentage") :: args -> percentage := true; parse args
  | ("-e" | "--header") :: args -> skip_header := false; parse args
  | f :: args -> f :: (parse args)

(*s Main program. *)

let main () =
  let files = parse (List.tl (Array.to_list Sys.argv)) in
  if not (!spec_only || !proof_only) then 
    printf "     spec    proof comments\n";
  match files with
    | [] -> process_channel stdin; print_file None
    | [f] -> process_file f
    | _ -> List.iter process_file files; print_totals ()

let _ = Printexc.catch main ()

(*i*)
# 811 "tools/coqwc.ml"
