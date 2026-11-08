# Mobile audit (run 2) — verified

Re-run of the mobile/a11y sweep with 3 local Qwen workers (1 per server slot),
this time primed with the design-system vocabulary (`TOUCH_TARGET`, `pointer-coarse:`,
`max-w-*`, `CloseButtonComponent`) that caused run 1's false positives.

- Scope: 46 components + 6 Stimulus controllers, partitioned forms / overlays / display.
- Coverage: all assigned files checked (worker reports in `.git/qwen-workers/mobile-audit-2-*.report.json`).
- Raw findings: 15. **Confirmed real after opening every cited line: 2.**

## Confirmed & fixed
| File | Rule | Sev | Fix |
|---|---|---|---|
| navbar_component.rb | R8 focus | med | `TOGGLER_BASE` had `ring-primary/25` (color) but no `ring-4` (width) or `outline-none`, so the intended focus ring never rendered. Added `focus-visible:outline-none focus-visible:ring-4` to match `LINK_BASE`. |
| list_group_item_component.rb | R1 tap-target | low | Actionable rows were `py-2` (~40px). Added `pointer-coarse:py-2.5` to `ACTION` so touch rows reach 44px (matches the dropdown item pattern). |

## Dropped (false positive / already fixed)
- `toast_container` R4 safe-area — already fixed in merged PR #22 (workers branched from a pre-#22 HEAD).
- `alert` / `toast` close buttons R1 — render `CloseButtonComponent` (has `TOUCH_TARGET`).
- `carousel` control R1 — `absolute top-0 bottom-0 w-[15%]` is full-height and ≥44px wide at 320px.
- `tooltip` / `popover` R5 hover-only — component already binds `focusin/focusout` (keyboard path exists).
- `dropdown`, `scrollspy`, `badge` R1 — self-cancelling (worker noted `TOUCH_TARGET`/decorative then listed anyway).
- `input_group` / `stepper` R1 — standard input height / tap size not confirmable < 44px; by design.
- `error_summary` R3, carousel swipe-threshold — not real overflow / opinion, not a11y.

## Process notes
- Priming the briefs cut false positives from 19/21 (run 1) to 13/15, and the surviving
  real findings were genuinely new (focus ring, list rows), not re-hashes.
- Workers branched from the checkout's current HEAD (pre-#22); next time check out latest
  `development` before launching so findings aren't stale.
