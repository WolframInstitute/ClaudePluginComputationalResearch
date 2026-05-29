#import "macros.typ": *
#show: macros

#align(center)[
  #text(17pt)[*{{TITLE}}*]

  #v(0.4em)
  {{AUTHOR}} \
  #link("mailto:{{EMAIL}}")[#"{{EMAIL}}"]

  #datetime.today().display("[month repr:long] [day], [year]")
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
