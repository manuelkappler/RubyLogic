# Introduction

RubyLogic aims to do a slate of things helpful for students and teachers of logic. Among them are:

- Generate truth tables for arbitrary formulas (already implemented as part of MarkdownTruthtable, which will be merged into this project)
- Work through simplifications with equivalence laws
- Work through deduction proofs, including branching

## Current State

The repo at the moment focuses on deduction proofs. Starting the program (`ruby deriver.rb`) will prompt for input of a comma-separated set of premises and of conclusions; it then asks which implication law to use, applies it, and checks for contradictory premises.

## TODO

Listed in decreasing order of importance

- Fully implement all implication laws
    - This involves implementing branching in the proof, which is what I'm currently working on
    - Full list:
        - [x] Conditional conclusion law
        - [x] Conjunction premise law
        - [x] Disjunction conclusion law
        - [x] Substitution of equivalents
        - [x] Disjoining of premises
        - [x] Monotonicity
        - [ ]  Disjunction premise law (**Branching**)
        - [ ]  Conjunction conclusion law (**Branching**)
- [ ] Implement checking for premises including conclusion
- [ ] Allow for printing of proofs as TeX file
- [ ] Implement simplification via equivalence laws
- [ ] Merge `markdowntruthtable` into the project and create an overarching menu
