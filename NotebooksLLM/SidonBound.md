---
notebook: SidonBound
title: The counting bound for Sidon sets in cyclic groups, and where it is attained
model: Claude Opus 5 (claude-opus-5[1m])
date: 2026-08-21
operator: Pavel Hájek
freedom: Open exploration
prompt: asked for a short paper carrying material below the settled tier, so that the tier rules could be exercised with the journal off; no topic, method or target statement was named.
---

## Abstract

A Sidon set in $\mathbb{Z}_n$ has all of its nonzero differences distinct, which bounds its size by roughly $\sqrt{n}$.
We prove that bound by counting differences, and we determine the first cyclic group in which it is not attained.
The bound holds for every $n$, and it is attained for every $n$ with $3 \le n \le 21$ and not for $n = 22$.
The search that settles the negative half is a finite enumeration and is reproduced below.

## Introduction

A set of integers is a Sidon set when its pairwise differences are distinct, and the cyclic version of the condition asks for the differences to be distinct modulo $n$.
The condition is restrictive: distinct differences cannot repeat and there are only $n - 1$ nonzero residues to hold them, so a Sidon set in $\mathbb{Z}_n$ has about $\sqrt{n}$ elements at most.
This paper writes that counting argument out and then asks whether the resulting bound is met.

The bound is $s(n) \le \lfloor (1 + \sqrt{4n-3})/2 \rfloor$, where $s(n)$ is the largest size of a Sidon set in $\mathbb{Z}_n$, and it is proved in [Thm:Bound].
It is attained for every $n$ from $3$ to $21$, and $s(22) = 4$ while the bound at $22$ is $5$, by [Prop:First].
The negative half of that statement is a finite check rather than an argument, and the enumeration behind it is stated in *Ruliology*.

Section 2 fixes the definitions and proves the bound.
Section 3 settles attainment up to the first failure.
The closing question asks whether failures continue.

## The counting bound

This section fixes the two objects the paper is about and bounds one by the other.

**Definition.** Let $n \ge 2$. A subset $A \subseteq \mathbb{Z}_n$ is a *Sidon set* if the differences $a - a'$, taken over all ordered pairs of distinct $a, a' \in A$, are pairwise distinct in $\mathbb{Z}_n$. {#Def:Sidon}

**Example.** In $\mathbb{Z}_7$ the set $\{0, 1, 3\}$ is a Sidon set: its six differences are the six nonzero residues, each once.

```wolfram
Sort[ Mod[ #1 - #2, 7 ] & @@@ Select[ Tuples[ { 0, 1, 3 }, 2 ], Apply[ Unequal ] ] ]
```

**Definition.** For $n \ge 2$ let $s(n)$ denote the largest size of a Sidon set in $\mathbb{Z}_n$. {#Def:MaxSize}

**Example.** $s(7) = 3$, the set of the previous example being one of the largest.

```wolfram
maxSidon[ 7 ]
```

**Theorem.** For every $n \ge 2$,
$$s(n) \le \frac{1 + \sqrt{4n - 3}}{2}.$$ {#Eq:Bound}
{#Thm:Bound}

**Proof.** Let $A \subseteq \mathbb{Z}_n$ be a Sidon set and put $k = |A|$.
There are $k(k-1)$ ordered pairs of distinct elements of $A$, and each contributes a difference $a - a'$.
Each such difference is nonzero, since $a \neq a'$ in $\mathbb{Z}_n$.
The $k(k-1)$ differences are pairwise distinct by [Def:Sidon], so they are $k(k-1)$ distinct nonzero elements of $\mathbb{Z}_n$.
There are exactly $n - 1$ nonzero elements available, whence $k(k-1) \le n-1$.
So $k$ satisfies $k^2 - k - (n-1) \le 0$, and since $k \ge 0$ this holds precisely when $k$ is at most the positive root $(1 + \sqrt{4n-3})/2$.
Taking the largest such $k$ over all Sidon sets gives [Eq:Bound] by [Def:MaxSize].

**Remark.** Since $s(n)$ is an integer, [Thm:Bound] gives $s(n) \le b(n)$ with $b(n) = \lfloor (1 + \sqrt{4n-3})/2 \rfloor$, and it is this integer form that the next section tests.

**Example.** At $n = 22$ the bound is $b(22) = 5$.

```wolfram
Floor[ ( 1 + Sqrt[ 4*22 - 3 ] )/2 ]
```

## Attainment, and the first failure

The bound of [Thm:Bound] is met by every small cyclic group but not by all of them.

**Proposition.** $s(n) = b(n)$ for every $n$ with $3 \le n \le 21$, and $s(22) = 4 < 5 = b(22)$. {#Prop:First}

**Proof.** The inequality $s(n) \le b(n)$ holds for all $n$ by [Thm:Bound] and the remark above it.
For the positive half it therefore suffices to exhibit, for each $n$ with $3 \le n \le 21$, one Sidon set of size $b(n)$, and the nineteen sets are listed in *Ruliology*.
For the negative half we must rule out a Sidon set of size $5$ in $\mathbb{Z}_{22}$.
If $A$ is a Sidon set then so is $A + t$ for every $t$, since translation leaves every difference unchanged by [Def:Sidon], so we may assume $0 \in A$.
There are $\binom{21}{4} = 5985$ five-element subsets of $\mathbb{Z}_{22}$ containing $0$, and testing each against [Def:Sidon] finds none that is Sidon; the function `maxSidon` of the Initialization section performs that enumeration and returns $4$.
Since a Sidon set of size $4$ exists, namely $\{0, 1, 3, 7\}$, we get $s(22) = 4$.

**Example.** The maximum at $n = 21$ is $5$, attained by $\{0, 1, 4, 14, 16\}$; the maximum at $n = 22$ is $4$.

```wolfram
{ maxSidon[ 21 ], maxSidon[ 22 ] }
```

## Ruliology

The values of $s(n)$ for $3 \le n \le 40$ were computed twice, by two searches written independently: a direct enumeration of subsets in decreasing size, and a backtracking search that extends a partial set only while its differences stay distinct.
The two agree on $3 \le n \le 26$, where the direct enumeration is still cheap, and the backtracking search alone carries $27 \le n \le 40$.
Over that range $s(n) = b(n)$ except at $n = 22, 32, 33, 34$, which is the evidence behind [Q:Finite]; the nineteen maximum sets used by [Prop:First] are the witnesses returned for $3 \le n \le 21$.

```wolfram
Grid[ Table[ { n, bound[ n ], maxSidonBT[ n ] }, { n, 3, 40 } ] ]
```

## Outlook

**Question.** Is the set $\{ n : s(n) < b(n) \}$ finite? {#Q:Finite}

A single construction attaining $b(n)$ for all $n$ beyond some point would settle it one way, and an infinite family of failures the other; the first unchecked case is $n = 41$.

## Retained material (no journal)

*[ Retained — no journal ]* The material below is not paper content.
It fails the settled tier and its home is the journal, which is off in this project, so it was retained here on the operator's ruling rather than dropped.
Each item is removable in one pass once a journal exists.

**Remark.** *[ Retained — no journal ]* Hedged claim. For every $k \ge 3$ the bound $b$ appears to be attained at $n = k^2 - k + 1$ exactly when $k - 1$ is a prime power, the first failure of that form being $n = 43$, where $s(43) = 6 < 7$. Checked for $3 \le k \le 7$ only, and unproved for every $k$.

**Remark.** *[ Retained — no journal ]* Failed attempt. To prove attainment in general we tried the greedy Mian–Chowla prefixes $\{0, 1, 3, 7, 12, 20, \ldots\}$ reduced modulo $n$, which are the maximum sets returned at $n = 25$ and $n = 26$. The route is dead: the prefix $\{0, 1, 3, 7, 12\}$ is not a Sidon set in $\mathbb{Z}_{21}$, where $\{0, 1, 4, 14, 16\}$ is.

**Remark.** *[ Retained — no journal ]* Unresolved [lookup]. Singer's theorem is said to give a Sidon set of size $q + 1$ in $\mathbb{Z}_{q^2+q+1}$ for every prime power $q$, which would attain the bound at those $n$. No source was read, so the statement is unverified here, and the hedged claim above and [Q:Finite] both lean on it.

## Initialization

```wolfram
bound[ n_ ] := Floor[ ( 1 + Sqrt[ 4 n - 3 ] )/2 ];

sidonQ[ a_List, n_ ] := With[ { d = Mod[ Flatten @ Table[ x - y, { x, a }, { y, a } ], n ] },
  DuplicateFreeQ[ DeleteCases[ d, 0 ] ] && Count[ d, 0 ] == Length[ a ] ];

maxSidon[ n_ ] := Module[ { k, s },
  Do[ s = SelectFirst[ Subsets[ Range[ n - 1 ], { k - 1 } ], sidonQ[ Prepend[ #, 0 ], n ] & ];
      If[ s =!= Missing[ "NotFound" ], Return[ { k, Prepend[ s, 0 ] }, Module ] ],
      { k, bound[ n ], 1, -1 } ] ];

hasSidonK[ n_, k_ ] := Module[ { res = False, ext },
  ext[ a_, used_ ] := Module[ { d },
    If[ Length[ a ] == k, res = True; Return[ ] ];
    Do[ d = Join[ Mod[ c - a, n ], Mod[ a - c, n ] ];
        If[ DuplicateFreeQ[ d ] && Intersection[ used, d ] === { }, ext[ Append[ a, c ], Join[ used, d ] ] ];
        If[ res, Return[ ] ], { c, Last[ a ] + 1, n - 1 } ] ];
  ext[ { 0 }, { } ]; res ];

maxSidonBT[ n_ ] := SelectFirst[ Range[ bound[ n ], 1, -1 ], hasSidonK[ n, # ] & ];
```

The MathNotebook palette's **Apply stylesheet** menu offers `AMSArticle`, `ArXivArticle`, `RevTeXAPS`, `SpringerJournal`, `ComplexSystems` and Default, and a selection can be converted to MaTeX from the same palette.
