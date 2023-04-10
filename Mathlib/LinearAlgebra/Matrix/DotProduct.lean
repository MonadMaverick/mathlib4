/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.matrix.dot_product
! leanprover-community/mathlib commit 738c19f572805cff525a93aa4ffbdf232df05aa8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.StdBasis

/-!
# Dot product of two vectors

This file contains some results on the map `Matrix.dotProduct`, which maps two
vectors `v w : n → R` to the sum of the entrywise products `v i * w i`.

## Main results

* `Matrix.dotProduct_stdBasis_one`: the dot product of `v` with the `i`th
  standard basis vector is `v i`
* `Matrix.dotProduct_eq_zero_iff`: if `v`'s' dot product with all `w` is zero,
  then `v` is zero

## Tags

matrix, reindex

-/


universe v w

namespace Matrix

variable {R : Type v} [Semiring R] {n : Type w} [Fintype n]

@[simp]
theorem dotProduct_stdBasis_eq_mul [DecidableEq n] (v : n → R) (c : R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i c) = v i * c := by
  rw [dotProduct, Finset.sum_eq_single i, LinearMap.stdBasis_same]
  exact fun _ _ hb => by rw [LinearMap.stdBasis_ne _ _ _ _ hb, MulZeroClass.mul_zero]
  exact fun hi => False.elim (hi <| Finset.mem_univ _)
#align matrix.dot_product_std_basis_eq_mul Matrix.dotProduct_stdBasis_eq_mul

-- @[simp] -- Porting note: simp can prove this
theorem dotProduct_stdBasis_one [DecidableEq n] (v : n → R) (i : n) :
    dotProduct v (LinearMap.stdBasis R (fun _ => R) i 1) = v i := by
  rw [dotProduct_stdBasis_eq_mul, mul_one]
#align matrix.dot_product_std_basis_one Matrix.dotProduct_stdBasis_one

theorem dotProduct_eq (v w : n → R) (h : ∀ u, dotProduct v u = dotProduct w u) : v = w := by
  funext x
  classical rw [← dotProduct_stdBasis_one v x, ← dotProduct_stdBasis_one w x, h]
#align matrix.dot_product_eq Matrix.dotProduct_eq

theorem dotProduct_eq_iff {v w : n → R} : (∀ u, dotProduct v u = dotProduct w u) ↔ v = w :=
  ⟨fun h => dotProduct_eq v w h, fun h _ => h ▸ rfl⟩
#align matrix.dot_product_eq_iff Matrix.dotProduct_eq_iff

theorem dotProduct_eq_zero (v : n → R) (h : ∀ w, dotProduct v w = 0) : v = 0 :=
  dotProduct_eq _ _ fun u => (h u).symm ▸ (zero_dotProduct u).symm
#align matrix.dot_product_eq_zero Matrix.dotProduct_eq_zero

theorem dotProduct_eq_zero_iff {v : n → R} : (∀ w, dotProduct v w = 0) ↔ v = 0 :=
  ⟨fun h => dotProduct_eq_zero v h, fun h w => h.symm ▸ zero_dotProduct w⟩
#align matrix.dot_product_eq_zero_iff Matrix.dotProduct_eq_zero_iff

end Matrix