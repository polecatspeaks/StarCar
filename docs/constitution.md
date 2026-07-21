# The StarCar Constitution

Status: **DRAFT - pending owner ratification.** Derived from the meta-principles of a
sibling project's constitution (eight ordered laws governing a race-strategy system);
the SHAPE ports, the content is re-derived for what StarCar is: a visualizer that renders
the truth of a multi-agent process to the human running it. Ordered - earlier laws
outrank later ones when they conflict.

## 1. Truth

StarCar never renders what it cannot back. A yard board that shows a car as merged when
it is not, a gate as green when it is pending, or a train as idle when it is burning
tokens is worse than no board at all - a confident falsehood on a status surface is the
worst defect this project can ship, because the whole point of the project is that the
human trusts the board instead of asking. Unknown states render AS unknown, honestly.

## 2. The Dispatcher Commands

The human running the yard outranks the board. StarCar informs decisions; it never makes
them, never hides information "for their own good," and never resists an override. If a
dispatcher marks a train held, the board renders held - even if the data says rolling.

## 3. Actionability

The board exists to answer "what needs my attention NOW" faster than reading logs. Every
rendered element earns its pixels by shortening the path from state to decision: a
REJECT should be visible before the report is read; a stalled car should look stalled at
a glance. Decoration that does not inform is cut.

## 4. Nothing Silently Lost

Every train, car, verdict, and gate outcome the adapters can see is rendered or counted -
never silently dropped. If an adapter fails or a source is unreachable, the board says
so, loudly, in place: a missing lane reading as "no trains" is a lie of omission.

## 5. Self-Knowledge

StarCar is honest about its own state: data freshness is always visible (as-of
timestamps, staleness warnings), adapter health is a first-class surface, and the board
degrades loudly, never silently. A stale board that looks live is the lying-canary
disease this project's ancestors fought all year.

## 6. One Truth

Adapters own the facts; the view renders them. The UI never computes its own state,
never derives a verdict the source system did not issue, and never maintains a second
copy of anything that can drift. Where two sources disagree, the board SHOWS the
disagreement rather than picking a winner silently.

## 7. The Stranger

StarCar is built for the shop that did not build it: pluggable adapters, no hardcoded
board schemas or label taxonomies, synthetic demo data in-repo, and documentation a
stranger can deploy from. The flagship deployment is private; the project is public.

## 8. Growth

Every incident in StarCar's own development feeds the Healing Loop: classified to class,
guarded mechanically, written into the institution. The repo's review records are public
on purpose - the process is the showcase.
