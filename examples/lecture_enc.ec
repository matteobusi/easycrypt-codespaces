(*
  Slightly adapted from
    https://easycrypt.gitlab.io/easycrypt-web/docs/tutorials/encryption-from-prf
  by Matteo Busi for the guest lecture
    "Lab 04: Computational analysis & EasyCrypt"
  within the course
    "Cryptographic Protocols for Secure Networks and Applications"
  at the University of Trento

  24th Apr. 2026
*)
require import AllCore Distr List.

type key, text, nonce.
type cipher = text.

op f : key -> nonce -> text.
op (+) : text -> text -> text.

op dkey : key distr.
op [lossless full uniform] dtext : text distr.
op dcipher : cipher distr = dtext.

(*
  What can we do with this stuff? 

  We can assume properties about it...
*)
axiom addpA (x y z : text) : x + y + z = x + (y + z).
axiom addpC (x y : text) : x + y = y + x.
axiom addKp (x y : text) : x + x + y = y.

(* axiom ff : false. *)

(* Or we can prove lemmas, this is the right self-cancellation property of our "+" symbol *)
lemma addpK (x y : text) : x + y + y = x.
proof.
  rewrite addpA.
  rewrite addpC.
  rewrite addKp.
  trivial. (* auto, reflexivity, move => // *)
qed.

(* Let's go back to the slides ... *)

(* 
  === This is the implementation of our Nonce-Respecting PRF theory ===
  We won't cover it during the lecture, but it is needed and will be explained intuitively!
*)

module type NRPRF_Oracle = {
  proc init () : unit
  proc get (n : nonce) : text option
}.

module O_NRPRF_real : NRPRF_Oracle = {
  var k : key (* Secret key *)
  var log : nonce list (* Log of queried nonces *)

  proc init() : unit = {
    k <$ dkey;
    log <- [];
  }

  proc get(n : nonce) : text option = {
    var r : text option;

    if (! (n \in log)) {
      log <- n :: log;
      r <- Some (f k n);
    } else {
      r <- None;
    }

    return r;
  }
}.

module O_NRPRF_ideal : NRPRF_Oracle = {
  var log : nonce list 

  proc init() = {

    log <- [];
  }

  proc get(n : nonce) = {
    var y : text;
    var r : text option; 
    
    if (! (n \in log)) {
      log <- n :: log;
      y <$ dtext;
      r <- Some y;
    } else {
      r <- None;
    }

    return r;
  }
}.

module type Adv_NRPRF (O : NRPRF_Oracle) = {
  proc distinguish() : bool { O.get } 
}.

module Exp_NRPRF (O : NRPRF_Oracle) (D : Adv_NRPRF) = {
  proc run() : bool = {
    var b : bool;

    O.init();
    b <@ D(O).distinguish();

    return b;
  }
}.
(* === End of the implementation of our Nonce-respecting PRF theory === *)

(* Define the module type for an Nonce-based Encryption Scheme, ENC *)
module type ENC = {
  proc keygen () : key
  proc enc (k : key, n : nonce, m : text) : cipher
  proc dec (k : key, n : nonce, c : cipher) : text
}.

(* Specification of the considered (symmetric) nonce-based encryption scheme *)
module E : ENC = {
  proc keygen (): key = {
    var k : key;
    k <$ dkey;
    return k;
  }

  proc enc (k : key, n : nonce, m : text) : cipher = {
    return (f k n) + m;
  }

  proc dec(k : key, n : nonce, c : cipher) : text = {
    return (f k n) + c;
  }
}.

module type NRCPA_Oracle = {
  proc init () : unit
  proc enc (n : nonce, m : text) : cipher option
}.

module O_NRCPA_real (S : ENC) : NRCPA_Oracle = {
  var k : key 
  var log : nonce list 

  proc init() : unit = {
    k <@ S.keygen ();
    log <- [];
  }

  proc enc (n : nonce, m : text) : cipher option = {
    var c  : cipher;
    var r : cipher option; 

    if (! (n \in log)) {
      log <- n :: log;
      c <@ S.enc (k, n, m);
      r <- Some c;
    } else {
      r <- None;
    }

    return r;
  }
}.

module O_NRCPA_ideal : NRCPA_Oracle = {
  var log : nonce list 

  proc init() : unit = {
    log <- [];
  }

  proc enc (n : nonce, m : text) : cipher option = {
    var c  : cipher;
    var r : cipher option; 

    if (! (n \in log)) {
      log <- n :: log;
      c <$ dcipher;
      r <- Some c;
    } else {
      r <- None;
    }

    return r;
  }
}.

module type Adv_IND_NRCPA (O : NRCPA_Oracle) = {
  proc distinguish () : bool { O.enc }
}.

module Exp_IND_NRCPA (O : NRCPA_Oracle) (D : Adv_IND_NRCPA) = {
  proc run() : bool = {
    var b : bool;
    O.init();
    b <@ D(O).distinguish();
    return b;
  }
}.

(* === Back to the slides === *)

module (R_NRPRF_IND_NRCPA (D : Adv_IND_NRCPA) : Adv_NRPRF) (O_NRPRF : NRPRF_Oracle) = {
  module O_NRCPA : NRCPA_Oracle = {
    proc init () : unit = { }

    proc enc (n : nonce, m : text) : cipher option = {
      var p  : text option;
      var r : cipher option; 

      p <@ O_NRPRF.get(n);
      r <- if p = None then None else Some (oget p + m);

      return r;
    }
  }

  proc distinguish() : bool = {
    var b : bool; 

    b <@ D(O_NRCPA).distinguish();

    return b;
  }
}.


section E_IND_NRCPA.

(*
  Declare the relevant adversary module.
  Note that, by default, a module can access any other module's variables.
  So, to prevent the adversary from illegally sabotaging the games that it is used in,
  we need to restrict the adversary from accessing the variables of the modules used in
  these games.
*)
declare module D <: Adv_IND_NRCPA { -O_NRCPA_real, -O_NRCPA_ideal, -O_NRPRF_real, -O_NRPRF_ideal }.

(*
  Lemma.
  The probability of D returning true in the IND$-NRCPA game when given the
  real NR-CPA oracle is equal to the probability of R_NRPRF_IND_NRCPA returning true
  when given D and the real NR-PRF oracle.

  This lemma is local (indicated by the "local" keyword), meaning that it is only
  useable inside the section and, as such, can depend on local entities.
*)
local lemma EqPr_IND_NRCPA_NRPRF_real &m:
  Pr[Exp_IND_NRCPA(O_NRCPA_real(E), D).run() @ &m : res]
  =
  Pr[Exp_NRPRF(O_NRPRF_real, R_NRPRF_IND_NRCPA(D)).run() @ &m : res].
proof.
  byequiv (_ : ={glob D} ==> ={res}).
  - proc; inline *.
    sim (_ : ={k}(O_NRCPA_real, O_NRPRF_real) /\ ={log}(O_NRCPA_real, O_NRPRF_real)).
    proc; inline *.
    auto.
  - trivial.
  - trivial.
qed.

(*
  Lemma.
  The probablity of D returning true in the IND$-NRCPA game when given the
  ideal NR-CPA oracle is equal to the probability of R_NRPRF_IND_NRCPA returning true
  when given D and the ideal NR-PRF oracle.

  This lemma is local (indicated by the "local" keyword), meaning that it is only
  useable inside the section and, as such, can depend on local entities.
*)
local lemma EqPr_IND_NRCPA_NRPRF_ideal &m:
  Pr[Exp_IND_NRCPA(O_NRCPA_ideal, D).run() @ &m: res]
  =
  Pr[Exp_NRPRF(O_NRPRF_ideal, R_NRPRF_IND_NRCPA(D)).run() @ &m: res].
proof.
  byequiv (_ : ={glob D} ==> ={res}); trivial.
  proc; inline *.
  wp.
  call (_ : ={log}(O_NRCPA_ideal, O_NRPRF_ideal)).
  - proc; inline *.
    sp.
    if => //.
    - wp.
      rnd (fun (p : text) => p + m{2}).
      wp.
      skip => />.
      move => &2 _.
      split.
      - move => y _.
        rewrite addpK //.
      - move => _ c.
        rewrite addpK //.
    - auto.
  - auto.
qed.

lemma EqAdvantage_IND_NRCPA_NRPRF &m:
  `| Pr[Exp_IND_NRCPA(O_NRCPA_real(E), D).run() @ &m: res]
     - Pr[Exp_IND_NRCPA(O_NRCPA_ideal, D).run() @ &m: res] |
  =
  `| Pr[Exp_NRPRF(O_NRPRF_real, R_NRPRF_IND_NRCPA(D)).run() @ &m: res]
     - Pr[Exp_NRPRF(O_NRPRF_ideal, R_NRPRF_IND_NRCPA(D)).run() @ &m: res] |.
proof.
  by rewrite EqPr_IND_NRCPA_NRPRF_real EqPr_IND_NRCPA_NRPRF_ideal.
qed.

end section E_IND_NRCPA.
