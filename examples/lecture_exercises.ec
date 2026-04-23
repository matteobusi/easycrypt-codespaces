require import AllCore Distr List.

type key, nonce, text.
type cipher = text.
op dkey : key distr.

op (+) : text -> text -> text.
op f : key -> nonce -> text.
axiom addpA (x y z : text) : x + y + z = x + (y + z).
axiom addpC (x y : text) : x + y = y + x.
axiom addKp (x y : text) : x + x + y = y.

(* 
  Exercise 1: Prove the following property using only the axioms 
  addpA, addpC, and addKp.
*)
lemma exercise_1 (x y z : text) : (x + y) + (z + x) = y + z.
proof.
  admit.
  (* Hint: you can rewrite a lemma or axiom in the "other" direction with rewrite -axiom_name *)
qed.

(* Exercise 2: Prove the correctness of the encryption scheme E.
  Show that decrypting a ciphertext with the correct key and nonce 
  returns the original message.
*)
module type ENC = {
  proc keygen () : key
  proc enc (k : key, n : nonce, m : text) : cipher
  proc dec (k : key, n : nonce, c : cipher) : text
}.

op enc_logic (k : key) (n : nonce) (m : text) : cipher = (f k n) + m.
op dec_logic (k : key) (n : nonce) (c : cipher) : text = (f k n) + c.
module E : ENC = {
  proc keygen (): key = {
    var k : key;
    k <$ dkey;
    return k;
  }

  proc enc (k : key, n : nonce, m : text) : cipher = {
    return enc_logic k n m;
  }

  proc dec(k : key, n : nonce, c : cipher) : text = {
    return dec_logic k n c;
  }
}.

lemma E_correctness (k : key) (n : nonce) (m : text) :
  dec_logic k n (enc_logic k n m) = m.
proof.
  (* Hint: Use 'rewrite /operator_name' to expand the definitions of operators. Then use the lemmas/axioms for the '+' operator. *)
  admit.
qed.

(* Exercise 3 (Discussion/Manual Change):
  
  Modify O_NRCPA_ideal to be "insecure":
  
  module O_NRCPA_ideal : NRCPA_Oracle = {
    var log : nonce list 
    proc init() = { log <- []; }
    proc enc (n : nonce, m : text) = {
      var r : cipher option; 
      if (! (n \in log)) {
        log <- n :: log;
        r <- Some m; (* <--- WEAKNESS: Returns the message itself *)
      } else { r <- None; }
      return r;
    }
  }.

  Question: If you change the oracle as above, does the lemmas still hold? Why? Can you think of a general property that encryption schemes SHOULD NOT have in order to be secure according to our definitions?
*)
