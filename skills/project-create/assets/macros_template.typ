// macros.typ — shared Typst preamble, imported by main.typ / journal.typ
// Apply with:  #show: macros

// ── Document style ──
#let macros(body) = {
  set page(paper: "a4", margin: 2.5cm)
  set text(font: "New Computer Modern", size: 10pt)
  set par(justify: true)
  set heading(numbering: "1.1")
  set math.equation(numbering: "(1)")
  show link: set text(fill: rgb("#b000b0"))
  show ref: set text(fill: rgb("#0050b0"))
  body
}

// ── Math shorthand (mirrors \NN, \ZZ, … from macros.sty) ──
#let NN = math.bb("N")
#let ZZ = math.bb("Z")
#let QQ = math.bb("Q")
#let RR = math.bb("R")
#let CC = math.bb("C")
#let FF = math.bb("F")
#let GG = math.cal("G")
#let VV = math.cal("V")
#let EE = math.cal("E")
#let dist = math.op("dist")
#let diam = math.op("diam")
#let Aut = math.op("Aut")
#let End = math.op("End")
#let Hom = math.op("Hom")

// ── Theorem environments (dependency-free, section-numbered) ──
// For richer numbering/styling, switch to: #import "@preview/ctheorems:1.1.3": *
#let thmcounter = counter("thm")
#let thmbox(kind, body, italic: true) = block(width: 100%, breakable: true)[
  #thmcounter.step()
  *#kind #context {
    let h = counter(heading).get().first()
    [#h.#thmcounter.display()]
  }.* #if italic { emph(body) } else { body }
]
#let theorem(body) = thmbox("Theorem", body)
#let lemma(body) = thmbox("Lemma", body)
#let proposition(body) = thmbox("Proposition", body)
#let corollary(body) = thmbox("Corollary", body)
#let conjecture(body) = thmbox("Conjecture", body)
#let definition(body) = thmbox("Definition", body, italic: false)
#let example(body) = thmbox("Example", body, italic: false)
#let remark(body) = thmbox("Remark", body, italic: false)
#let claim(body) = thmbox("Claim", body)
#let observation(body) = thmbox("Observation", body, italic: false)
#let question(body) = thmbox("Question", body, italic: false)
#let construction(body) = thmbox("Construction", body, italic: false)
#let proof(body) = block(width: 100%)[_Proof._ #body #h(1fr) $square$]
