# 07 - Documentation and Knowledge

## Documentation is Mandatory
Every new code addition or behavior change must update documentation in the same change.

## Required Documentation Fields
- What changed.
- Why it changed.
- How it works (inputs, outputs, failure mode).
- How to validate it.
- How to rollback it.

## Knowledge Transfer
- Keep architecture and runbook documents current.
- Link all new docs from a central index.
- Avoid undocumented tribal knowledge for production-critical behavior.

## NOGO Documentation Cases
- New feature without docs.
- New env variable not documented.
- Release without updated validation steps.

## Plans: Architectural AND Functional (Mandatory)

Every implementation plan MUST carry three things. A plan missing any of them is not ready to be
reviewed, because it cannot be reviewed.

1. **A diagram.** At least one drawing: the components in boxes, what flows between them as arrows.
   Mermaid counts. Without a drawing, the reader has to rebuild the shape in their head — which is
   the work a plan exists to spare them.
2. **The architectural side.** How it is built: the components, what flows between them, the
   decisions taken and **why**. A plan that only lists files to modify is a shopping list.
3. **The functional side.** What the person will live through: the journeys, the rules, what they
   will see on screen, what changes for them. This is the part a reader may read in full, and the
   part that lets them say yes or no.

Enforced by `automation/hooks/plan-architectural-et-fonctionnel.sh` (Claude Code `PreToolUse` on
`ExitPlanMode`): it refuses and names what is missing. Escape hatch for a genuinely tiny change:
`PLAN_SANS_SCHEMA=1`, deliberately explicit.

## Write for a Human (Mandatory)

Anything handed over to be read — a plan, a report, a pull request, a commit body, a ticket — is
written for a person, not for a code reviewer.

- One idea per sentence.
- The everyday word over the technical one when both say the same thing.
- A table rather than a paragraph as soon as things are being compared.
- A necessary technical term is explained the first time it appears.
- Say first what changes for the person, then how it is built.

This is **recalled, not policed**: `automation/hooks/phrases-comprehensibles.sh` injects the reminder
on every turn (Claude Code `UserPromptSubmit`). Readability cannot be measured without being wrong —
counting words per sentence would punish one good long sentence and wave through three unreadable
short ones. Judgement writes; a counter does not.

*Origin: Yann, 2026-09-22, handed a plan that was right on substance and painful to read.*
