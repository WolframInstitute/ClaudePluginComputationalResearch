#import "macros.typ": *
#show: macros

// The author is the model. The operator ran the session and is named below --
// not as an author -- with the freedom the model had (Directed / Guided / Open
// exploration, in bold) and the instructions it worked under.
//
// The date is the date the document was GENERATED. Never datetime.today(): it
// re-dates the paper on every compile and nothing in the output shows that it
// moved.
#align(center)[
  #text(9pt)[\[ LLM Generated \]]

  #v(0.4em)
  #text(17pt)[*{{TITLE}}*]

  #v(0.4em)
  {{MODEL}}

  {{DATE}}
]

#align(center)[
  #block(width: 85%)[
    #set text(size: 8pt)
    Operator: {{OPERATOR}} (#link("mailto:{{EMAIL}}")[#"{{EMAIL}}"]). *{{FREEDOM}}* --- {{PROMPT}}
  ]
]

#align(center)[
  #block(width: 85%)[
    #set text(size: 9pt)
    *Abstract.* {{ABSTRACT}}
  ]
]

// Uncomment only if the paper is long enough to need one.
// #outline()

= Introduction <sec:intro>



// Uncomment once references.bib has an entry the paper cites. A self-contained
// paper cites nothing and prints no bibliography.
// #bibliography("references.bib")
