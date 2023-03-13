/-
Copyright (c) 2022 Julian Kuelshammer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Julian Kuelshammer

! This file was ported from Lean 3 source module combinatorics.catalan
! leanprover-community/mathlib commit 26b40791e4a5772a4e53d0e28e4df092119dc7da
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Algebra.BigOperators.NatAntidiagonal
import Mathlib.Algebra.CharZero.Lemmas
import Mathlib.Data.Finset.NatAntidiagonal
import Mathlib.Data.Nat.Choose.Central
import Mathlib.Data.Tree
import Mathlib.Tactic.FieldSimp

/-!
# Catalan numbers

The Catalan numbers (http://oeis.org/A000108) are probably the most ubiquitous sequence of integers
in mathematics. They enumerate several important objects like binary trees, Dyck paths, and
triangulations of convex polygons.

## Main definitions

* `catalan n`: the `n`th Catalan number, defined recursively as
  `catalan (n + 1) = ∑ i : Fin n.succ, catalan i * catalan (n - i)`.

## Main results

* `catalan_eq_centralBinom_div `: The explicit formula for the Catalan number using the central
  binomial coefficient, `catalan n = Nat.centralBinom n / (n + 1)`.

* `treesOfNodesEq_card_eq_catalan`: The number of binary trees with `n` internal nodes
  is `catalan n`

## Implementation details

The proof of `catalan_eq_centralBinom_div` follows https://math.stackexchange.com/questions/3304415

## TODO

* Prove that the Catalan numbers enumerate many interesting objects.
* Provide the many variants of Catalan numbers, e.g. associated to complex reflection groups,
  Fuss-Catalan, etc.

-/


open BigOperators

open Finset

open Finset.Nat.antidiagonal (fst_le snd_le)

/-- The recursive definition of the sequence of Catalan numbers:
`catalan (n + 1) = ∑ i : Fin n.succ, catalan i * catalan (n - i)` -/
def catalan : ℕ → ℕ
  | 0 => 1
  | n + 1 =>
    ∑ i : Fin n.succ,
      catalan i * catalan (n - i)
#align catalan catalan

@[simp]
theorem catalan_zero : catalan 0 = 1 := by rw [catalan]
#align catalan_zero catalan_zero

theorem catalan_succ (n : ℕ) : catalan (n + 1) = ∑ i : Fin n.succ, catalan i * catalan (n - i) := by
  rw [catalan]
#align catalan_succ catalan_succ

theorem catalan_succ' (n : ℕ) :
    catalan (n + 1) = ∑ ij in Nat.antidiagonal n, catalan ij.1 * catalan ij.2 := by
  rw [catalan_succ, Nat.sum_antidiagonal_eq_sum_range_succ (fun x y => catalan x * catalan y) n,
    sum_range]
#align catalan_succ' catalan_succ'

@[simp]
theorem catalan_one : catalan 1 = 1 := by simp [catalan_succ]
#align catalan_one catalan_one

/-- A helper sequence that can be used to prove the equality of the recursive and the explicit
definition using a telescoping sum argument. -/
private def gosperCatalan (n j : ℕ) : ℚ :=
  Nat.centralBinom j * Nat.centralBinom (n - j) * (2 * j - n) / (2 * n * (n + 1))

private theorem gosper_trick {n i : ℕ} (h : i ≤ n) :
    gosperCatalan (n + 1) (i + 1) - gosperCatalan (n + 1) i =
      Nat.centralBinom i / (i + 1) * Nat.centralBinom (n - i) / (n - i + 1) := by
  have l₁ : (n : ℚ) + 1 ≠ 0 := by norm_cast; exact n.succ_ne_zero
  have l₂ : (n : ℚ) + 1 + 1 ≠ 0 := by norm_cast; exact (n + 1).succ_ne_zero
  have l₃ : (i : ℚ) + 1 ≠ 0 := by norm_cast; exact i.succ_ne_zero
  have l₄ : (n : ℚ) - i + 1 ≠ 0 := by norm_cast; exact (n - i).succ_ne_zero
  have h₁ := (mul_div_cancel_left (↑(Nat.centralBinom (i + 1))) l₃).symm
  have h₂ := (mul_div_cancel_left (↑(Nat.centralBinom (n - i + 1))) l₄).symm
  have h₃ : ((i : ℚ) + 1) * (i + 1).centralBinom = 2 * (2 * i + 1) * i.centralBinom := by
    exact_mod_cast Nat.succ_mul_centralBinom_succ i
  have h₄ :
    ((n : ℚ) - i + 1) * (n - i + 1).centralBinom = 2 * (2 * (n - i) + 1) * (n - i).centralBinom :=
    by exact_mod_cast Nat.succ_mul_centralBinom_succ (n - i)
  simp only [gosperCatalan]
  push_cast
  rw [show n + 1 - i = n - i + 1 by rw [Nat.add_comm (n - i) 1, ←(Nat.add_sub_assoc h 1), add_comm]]
  rw [h₁, h₂, h₃, h₄]
  field_simp
  ring_nf

private theorem gosper_catalan_sub_eq_central_binom_div (n : ℕ) :
    gosperCatalan (n + 1) (n + 1) - gosperCatalan (n + 1) 0 = Nat.centralBinom (n + 1) / (n + 2) :=
  by
  have : (n : ℚ) + 1 ≠ 0 := by norm_cast; exact n.succ_ne_zero
  have : (n : ℚ) + 1 + 1 ≠ 0 := by norm_cast; exact (n + 1).succ_ne_zero
  have h : (n : ℚ) + 2 ≠ 0 := by norm_cast; exact (n + 1).succ_ne_zero
  simp only [gosperCatalan, Nat.sub_zero, Nat.centralBinom_zero, Nat.sub_self]
  field_simp
  ring_nf

theorem catalan_eq_centralBinom_div (n : ℕ) : catalan n = n.centralBinom / (n + 1) := by
  suffices (catalan n : ℚ) = Nat.centralBinom n / (n + 1) by
    have h := Nat.succ_dvd_centralBinom n
    exact_mod_cast this
  induction' n using Nat.case_strong_induction_on with d hd
  · simp
  · simp_rw [catalan_succ, Nat.cast_sum, Nat.cast_mul]
    trans (∑ i : Fin d.succ, Nat.centralBinom i / (i + 1) *
                             (Nat.centralBinom (d - i) / (d - i + 1)) : ℚ)
    · congr
      ext1 x
      have m_le_d : x.val ≤ d := by apply Nat.le_of_lt_succ; apply x.2
      have d_minus_x_le_d : (d - x.val) ≤ d := tsub_le_self
      rw [hd _ m_le_d, hd _ d_minus_x_le_d]
      norm_cast
    · trans (∑ i : Fin d.succ, (gosperCatalan (d + 1) (i + 1) - gosperCatalan (d + 1) i))
      · refine' sum_congr rfl fun i _ => _
        rw [gosper_trick i.is_le, mul_div]
      · rw [← sum_range fun i => gosperCatalan (d + 1) (i + 1) - gosperCatalan (d + 1) i,
            sum_range_sub, Nat.succ_eq_add_one]
        rw [gosper_catalan_sub_eq_central_binom_div d]
        norm_cast
#align catalan_eq_central_binom_div catalan_eq_centralBinom_div

theorem succ_mul_catalan_eq_centralBinom (n : ℕ) : (n + 1) * catalan n = n.centralBinom :=
  (Nat.eq_mul_of_div_eq_right n.succ_dvd_centralBinom (catalan_eq_centralBinom_div n).symm).symm
#align succ_mul_catalan_eq_central_binom succ_mul_catalan_eq_centralBinom

theorem catalan_two : catalan 2 = 2 := by unfold catalan; rfl
#align catalan_two catalan_two

theorem catalan_three : catalan 3 = 5 := by unfold catalan; rfl
#align catalan_three catalan_three

namespace Tree

open Tree

/-- Given two finsets, find all trees that can be formed with
  left child in `a` and right child in `b` -/
@[reducible]
def pairwiseNode (a b : Finset (Tree Unit)) : Finset (Tree Unit) :=
  (a ×ᶠ b).map ⟨fun x => x.1 △ x.2, fun ⟨x₁, x₂⟩ ⟨y₁, y₂⟩ => fun h => by simpa using h⟩
#align tree.pairwise_node Tree.pairwiseNode

/-- A Finset of all trees with `n` nodes. See `mem_treesOfNodesEq` -/
def treesOfNumNodesEq : ℕ → Finset (Tree Unit)
  | 0 => {nil}
  | n + 1 =>
    (Finset.Nat.antidiagonal n).attach.bunionᵢ fun ijh =>
      -- Porting note: `unusedHavesSuffices` linter is not happy with this. Commented out.
      -- have := Nat.lt_succ_of_le (fst_le ijh.2)
      -- have := Nat.lt_succ_of_le (snd_le ijh.2)
      pairwiseNode (treesOfNumNodesEq ijh.1.1) (treesOfNumNodesEq ijh.1.2)
  -- Porting note: Add this to satisfy the linter.
  decreasing_by
      simp_wf
      try exact Nat.lt_succ_of_le (fst_le ijh.2)
      try exact Nat.lt_succ_of_le (snd_le ijh.2)
#align tree.trees_of_num_nodes_eq Tree.treesOfNumNodesEq

@[simp]
theorem treesOfNodesEq_zero : treesOfNumNodesEq 0 = {nil} := by rw [treesOfNumNodesEq]
#align tree.trees_of_nodes_eq_zero Tree.treesOfNodesEq_zero

theorem treesOfNodesEq_succ (n : ℕ) :
    treesOfNumNodesEq (n + 1) =
      (Nat.antidiagonal n).bunionᵢ fun ij =>
        pairwiseNode (treesOfNumNodesEq ij.1) (treesOfNumNodesEq ij.2) := by
  rw [treesOfNumNodesEq]
  ext
  simp
#align tree.trees_of_nodes_eq_succ Tree.treesOfNodesEq_succ

@[simp]
theorem mem_treesOfNodesEq {x : Tree Unit} {n : ℕ} : x ∈ treesOfNumNodesEq n ↔ x.numNodes = n :=
  by
  induction x using Tree.unitRecOn generalizing n <;> cases n <;>
    simp [treesOfNodesEq_succ, Nat.succ_eq_add_one, *]
  exact (Nat.succ_ne_zero _).symm
#align tree.mem_trees_of_nodes_eq Tree.mem_treesOfNodesEq

theorem mem_trees_of_nodes_eq_numNodes (x : Tree Unit) : x ∈ treesOfNumNodesEq x.numNodes :=
  mem_treesOfNodesEq.mpr rfl
#align tree.mem_trees_of_nodes_eq_num_nodes Tree.mem_trees_of_nodes_eq_numNodes

@[simp, norm_cast]
theorem coe_treesOfNodesEq (n : ℕ) :
    ↑(treesOfNumNodesEq n) = { x : Tree Unit | x.numNodes = n } :=
  Set.ext (by simp)
#align tree.coe_trees_of_nodes_eq Tree.coe_treesOfNodesEq

theorem treesOfNodesEq_card_eq_catalan (n : ℕ) : (treesOfNumNodesEq n).card = catalan n := by
  induction' n using Nat.case_strong_induction_on with n ih
  · simp
  rw [treesOfNodesEq_succ, card_bunionᵢ, catalan_succ']
  · apply sum_congr rfl
    rintro ⟨i, j⟩ H
    rw [card_map, card_product, ih _ (fst_le H), ih _ (snd_le H)]
  · simp_rw [disjoint_left]
    rintro ⟨i, j⟩ _ ⟨i', j'⟩ _
    -- Porting note: was clear * -; tidy
    intros h a
    cases' a with a l r
    · intro h; simp at h
    · intro h1 h2
      apply h
      trans (numNodes l, numNodes r)
      · simp at h1; simp [h1]
      · simp at h2; simp [h2]
#align tree.trees_of_nodes_eq_card_eq_catalan Tree.treesOfNodesEq_card_eq_catalan

end Tree