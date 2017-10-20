# Introduction

RubyLogic aims to do a slate of things helpful for students and teachers of logic, at least for those following Haim Gaifmann's idiosyncratic approach to it. 
Among them are:

- Generate truth tables for arbitrary formulas
- Work through deduction proofs and generate counterexamples to claims
- Work through simplifications with equivalence laws

## Current State

The program relies on Sinatra to open up a web interface that allows for proving implication claims 


## TODO

Listed in decreasing order of importance

- [x] Re-enable the sentential logic component of the program on a joint web interface
    - [x] Implement syntax_sentential, semantics_sentential, parse_string_sentential, and proof_sentential
    - [x] Move logic-specific web code to a different app file and let the main app only control routes and basic interface
    - [x] Cleanly separate all syntax-specific code from ProofTree helper class
- [x] Allow for printing of proofs as TeX file (proofs can now be displayed as a raw LaTeX-Tabular environment (A counterexample is given below if necessary)
- [x] Implement checking for premises including conclusion
- [x] Implement simplification via equivalence laws
- [x] Rewrite codebase from sentential logic to predicate logic
- Fully implement all implication laws
    - Full list:
        - [x] Conditional conclusion law
        - [x] Conjunction premise law
        - [x] Disjunction conclusion law
        - [x] Substitution of equivalents
        - [x] Disjoining of premises
        - [x] Monotonicity
        - [x] Disjunction premise law 
        - [x] Conjunction conclusion law 
        - [x] Conjunction premise law
        - [x] Biconditional laws (premise/conclusion)
        - [x] Contradictory conclusion law (required for proofs by contradiction)
- [ ] Allow for automated proofs (this is not really relevant, although it would be cool)
