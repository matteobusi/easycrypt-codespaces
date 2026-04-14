(* ======================================================================
   hello_easycrypt.ec — a minimal EasyCrypt file for getting started
   ====================================================================== *)

(* ----- Basic logic -------------------------------------------------------- *)

(* A simple lemma: conjunction is commutative.
   Try stepping through the proof with Ctrl+Alt+Down (next step)
   or Ctrl+Alt+Up (undo step). *)
lemma and_comm (P Q : bool) : P /\ Q => Q /\ P.
proof.
  move=> [hp hq].  (* destructure the hypothesis *)
  split.
  - exact hq.
  - exact hp.
qed.

(* ----- Working with integers ---------------------------------------------- *)

lemma add_comm (x y : int) : x + y = y + x.
proof. ring. qed.

lemma mul_distr (x y z : int) : x * (y + z) = x * y + x * z.
proof. ring. qed.

(* ----- A simple module / procedure ---------------------------------------- *)

(* Modules in EasyCrypt model probabilistic programs.
   This module represents a simple counter. *)
module Counter = {
  var count : int

  proc init() : unit = {
    count <- 0;
  }

  proc increment() : unit = {
    count <- count + 1;
  }

  proc get() : int = {
    return count;
  }
}.

(* A Hoare triple: after init(), the counter is 0. *)
lemma counter_init :
  hoare [Counter.init : true ==> Counter.count = 0].
proof.
  proc.
  auto.
qed.

(* After one increment from 0, the counter equals 1. *)
lemma counter_one :
  hoare [Counter.increment :
    Counter.count = 0 ==> Counter.count = 1].
proof.
  proc.
  auto.
qed.

(* ----- Probabilistic programming ------------------------------------------ *)

require import AllCore Distr.

(* A module that samples a random boolean *)
module Coin = {
  proc flip() : bool = {
    var b : bool;
    b <$ {0,1};   (* sample uniformly from {false, true} *)
    return b;
  }
}.

(* The output of flip is uniformly distributed — a pRHL statement *)
lemma coin_uniform :
  phoare [Coin.flip : true ==> res] = (1%r / 2%r).
proof.
  proc.
  rnd (fun b => b).
  auto => />.
  rewrite DBool.dbool1E //.
qed.
