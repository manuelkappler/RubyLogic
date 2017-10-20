---
author: Manuel
title: Intro to Predicate Logic
---
### Introduction

Whereas in sentential logic, we took sentences as basic, in predicate logic we are also interested in the *internal structure* of sentences. Specifically, we now separate **Predicates**, which correspond to *properties of things* or *relations between things*, and **Terms**, which are either *constants* (referring directly to things) or *variables* (ranging over a variety of things).

To deal with the increased richness of the vocabulary, one also needs some new rules and machinery. All relevant material can be accessed via the Predicate Logic menu at the top. For the fully fledged language, choose "Proofs in FOL" (First-Order Logic). Here's an example of such a proof, first in natural language and then in the program:

**Natural language**:
- All teachers are human
- There is a teacher who likes Broccoli
- Some human being likes broccoli

**In the software**:
- First, formalize the sentences as follows:
	- For all t, if t is a teacher, t is human
	- There exists a t such that t is a teacher and t likes Broccoli
	- There exists a h such that h is a human and h likes Broccoli
- Use FOL-notation:
	- ∀x(T(x) -> H(x))
	- ∃x(T(x) ∧ B(x))
	- ∃y(H(y) ∧ B(y))
- Open the FOL proof tool and enter the formulae, the first two as premises (comma-separated), the third as conclusion
- Create a proof by contradiction as follows:
	- First, click on the conclusion. Choose "Contradictory conclusion". We aim to show that assuming the contrary, we'll run into a contradiction.
	- Now, the conclusion shows up among the premises. Click on it again to push in the negation.
	- Next, instantiate the existential quantifier (click on it to create a sentence "T(a) and B(a)", meaning that 'a' is a teacher and likes broccoli
	- Proceed by instantiating universal quantifiers and using basic implication laws. The implication can be proven valid in about ten steps.

