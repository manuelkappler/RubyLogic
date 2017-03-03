# Introduction

RubyLogic aims to do a slate of things helpful for students and teachers of logic. Among them are:

- Generate truth tables for arbitrary formulas (already implemented as part of MarkdownTruthtable, which will be merged into this project)
- Work through simplifications with equivalence laws
- Work through deduction proofs, including branching

## Current State

The repo at the moment focuses on deduction proofs. Starting the program (`ruby deriver.rb`) will prompt for input of a comma-separated set of premises and of conclusions; it then asks which implication law to use, applies it, and checks for validity.

## TODO

Listed in decreasing order of importance

- [ ] Allow for printing of proofs as TeX file
- [ ] Allow for automated proofs
- [x] Implement checking for premises including conclusion
- [ ] Implement simplification via equivalence laws
    - Mostly done. Missing:
        - [ ] Reverse laws (esp. Reverse DeMorgan)
- [ ] Merge `markdowntruthtable` into the project and create an overarching menu
- Fully implement all implication laws
    - This involves implementing branching in the proof, which is what I'm currently working on
    - Full list:
        - [x] Conditional conclusion law
        - [x] Conjunction premise law
        - [x] Disjunction conclusion law
        - [x] Substitution of equivalents
        - [x] Disjoining of premises
        - [x] Monotonicity
        - [x] Disjunction premise law 
        - [x] Conjunction conclusion law 
        - [ ] Conjunction premise law
        - [ ] Biconditional laws (premise/conclusion)
        - [ ] Contradictory conclusion law (required for proofs by contradiction)
