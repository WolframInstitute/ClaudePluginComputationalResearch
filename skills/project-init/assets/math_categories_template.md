<!-- Math-Domain Taxonomy
     Adapted (taxonomy only, prose and symbol-scouting reports stripped) from
     WolframInstitute/PureMath  docs/categories.md  (MIT-licensed).
     Trim aggressively to match the scope of THIS project. The intent is a
     working catalogue of fields touched by the project, with anchors for
     external references. -->

# Math Domains

This file is the project's working taxonomy of mathematical fields. It is
**meant to be edited**: prune everything that doesn't touch the project,
add subfields you actually use, and link wiki articles + external references
under each entry as they appear.

For each domain you keep, the recommended structure is:

```markdown
### <Domain>

- Scope: <one-line scope statement for this project>
- Wiki: [[../Definitions/X]], [[../Theorems/Y]]
- References: MathWorld, nLab, DLMF, textbook, papers
```

## Foundational

- **Logic & Set Theory** — propositional / first-order / higher-order logic,
  Zermelo–Fraenkel, large cardinals, descriptive set theory.
- **Category Theory** — categories, functors, natural transformations,
  limits/colimits, monoidal structure, higher categories, topos theory.
- **Type Theory** — dependent types, HoTT, intuitionistic foundations.
- **Model Theory** — first-order theories, definability, stability.
- **Proof Theory** — formal systems, cut elimination, ordinal analysis.
- **Computability** — recursion, Turing degrees, complexity.

## Algebra

- **Group Theory** — finite and infinite groups, representation theory,
  group cohomology.
- **Ring & Module Theory** — commutative rings, modules, ideals, Galois
  theory, homological algebra.
- **Field Theory** — extensions, Galois theory, transcendence.
- **Lie Theory** — Lie groups, Lie algebras, root systems, representations.
- **Algebraic Geometry** — schemes, varieties, sheaves, cohomology.
- **Algebraic Topology** — homotopy, (co)homology, spectra, K-theory.
- **Commutative Algebra** — local rings, dimension, Cohen–Macaulay,
  Gorenstein.
- **Noncommutative Algebra** — operator algebras, quantum groups, Hopf
  algebras.

## Analysis

- **Real Analysis** — measure, integration, function spaces.
- **Complex Analysis** — holomorphic functions, Riemann surfaces, complex
  manifolds.
- **Functional Analysis** — Banach/Hilbert spaces, operator theory,
  spectral theory.
- **Harmonic Analysis** — Fourier analysis, representation theory of
  topological groups.
- **PDE / ODE** — existence, regularity, asymptotics.
- **Calculus of Variations & Optimal Control**.
- **Special Functions** — Bessel, Legendre, hypergeometric, theta, modular
  forms. See DLMF.

## Geometry & Topology

- **Differential Geometry** — manifolds, connections, curvature, Riemannian
  & Lorentzian.
- **Symplectic & Contact Geometry**.
- **Algebraic Topology** — duplicated under Algebra; keep the project's
  preferred home.
- **Geometric Topology** — knots, 3- and 4-manifolds.
- **Metric Geometry** — length spaces, Gromov–Hausdorff, CAT(κ), Alexandrov.
- **Discrete & Combinatorial Geometry** — polytopes, arrangements, rigidity.

## Number Theory

- **Elementary** — primes, factorisation, Diophantine equations.
- **Algebraic** — number fields, class field theory, Galois representations.
- **Analytic** — L-functions, sieves, distribution of primes.
- **Arithmetic Geometry** — schemes over Z, modular forms, motives.
- **Computational** — sequence lookup (see OEIS), explicit computations.

## Discrete Mathematics

- **Combinatorics** — enumeration, bijections, generating functions.
- **Graph Theory** — paths, flows, colourings, spectral graph theory.
- **Order Theory** — posets, lattices, Galois connections.
- **Matroid Theory**.

## Probability & Statistics

- **Probability Theory** — measure-theoretic foundations, stochastic
  processes, large deviations.
- **Statistical Inference** — estimation, hypothesis testing, Bayes.
- **Statistical Mechanics** (mathematical) — Gibbs measures, phase
  transitions.

## Applied & Computational

- **Numerical Analysis** — error analysis, stability, finite elements.
- **Optimisation** — convex, integer, stochastic.
- **Mathematical Physics** — classical and quantum systems, integrable
  systems, gauge theory.
- **Dynamical Systems** — flows, maps, ergodic theory.
- **Information Theory & Coding**.
- **Cryptography**.

## External reference sources (for any domain)

| Source | Best for |
|--------|----------|
| MathWorld | Encyclopedic definitions, classical results. |
| nLab | Categorical / higher-structure formulations. |
| DLMF | Special functions, identities, asymptotics. |
| OEIS | Integer sequences. |
| Wikipedia | First-pass overview, citations. |
| Mathlib (Lean) | Formalized statements. |
| SageMath, GAP, PARI/GP | Algorithmic implementations for cross-checking Wolfram. |
