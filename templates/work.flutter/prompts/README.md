# Prompts

Project-specific reusable prompts. `YYYYMMDD-<slug>.md`.

The framework ships general-purpose lenses in `concepts/`. This directory holds the ones that only make sense **here** — because they encode this project's domain, its recurring defects, or its specific review needs.

---

## Index

| Prompt | Purpose | Added |
|--------|---------|-------|

---

## When to add one

A prompt earns a place here when the same review question has been asked manually three times. At that point it is a repeated judgement, and repeated judgements should be written down so they are applied consistently rather than whenever someone remembers.

Good candidates: a domain invariant that is easy to violate, a defect class this codebase keeps reproducing, a compliance check specific to this product's regulatory context, a review pass for an unusual integration.

---

## Shape

Follow the concept prompt structure: why it exists, the questions, the output shape, and explicit verdict rules with severities. A prompt without verdict rules produces observations nobody acts on.

If a prompt turns out to be general rather than project-specific, propose it as a framework concept through `CONTRIBUTING.md` instead of keeping a local copy that drifts.
