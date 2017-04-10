Introduction to Sentential Logic

## Sentential logic

### Introduction
- The basic unit for all these programs is the sentence. A sentence is the smallest unit that is always either \\(true\\) or \\(false\\) (and not both).
- Sentential logic takes sentences as fundamental and provides insight into relations between these sentences:
  - Given the truth value of two sentences \\(A\\) and \\(B\\), would it be true to say \\(A \\wedge B\\) (read *A and B*)? How about \\(A \\rightarrow B\\) (read *If A then B*)?
  - In technical terms, sentential logic tells us how to evaluate the truth or falsity of arbitrary compound sentences.

### Truth tables

- [Truth Tables](/truthtables) display the results of sentential logic. In the truth table program, you can input a list of arbitrary combinations of sentences and you will be given a table that shows their truth values given the truth values of their smallest components. Click on a column to render the True cells in green and the False cells in red.
- If two columns in a truth table agree completely, we can say that the two sentences are equivalent.

### Proofs

- [The sentential proof tool](/sentential_logic) deals, instead with the distinct topic of proving arguments to be valid, called **Implication**.
- In logic, we aim to determine which arguments are valid and which are not.   
- **Validity** is a technical notion, meaning that whenever all the premises of an argument are true, the conclusion must be true as well.
- The basic structure to show validity is an implication claim, symbolized by the turnstile symbol \\(\\models\\)
    - The following is a valid argument
        - I like ice cream
        - If I like ice cream, I should eat it
        - Therefore I should eat ice cream
    - We have already said that sentential logic doesn't care about the exact structure of the sentences in question. We can thus symbolize the argument above as follows: \\(A, A \\rightarrow B \\models B\\)
    - We read the last claim as follows: "A is true. If A is true, then B is true as well. Therefore B is true"
    - This argument is intuitively valid, but with the implication checker, we can show that it is formally valid by applying a few fundamental laws regarding implication
- In sentential logic, we can show for every argument whether it is valid or not simply by applying the implication laws.
 
### Implication laws

- Implication laws guarantee that applying them will not change the validity of the argument. If an argument is valid and I apply any number of laws (**correctly**), the argument will stay valid.
- There are implication laws to deal with any and all the connectives.
