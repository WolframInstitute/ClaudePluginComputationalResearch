#import "macros.typ": *
#show: macros

#align(center)[
  #text(17pt)[*{{TITLE}}*]

  #v(0.4em)
  {{MODEL}}

  #datetime.today().display("[month repr:long] [day], [year]")
]

// The author is the model. The operator ran the session and is named here -- not
// as an author -- with the freedom the model had (Directed / Guided / Open
// exploration, in bold) and the instructions it worked under.
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

#outline()

= Introduction <sec:intro>



#bibliography("references.bib")
