# Mobile audit — consolidated & verified

Source: 3 Qwen mobile-audit workers (display / forms / overlays), Nov 7 2026.
Every finding was re-checked against current source. **Result: 19 of 21 findings
are false positives.** The workers did not resolve the design system's existing
mobile touch strategy.

## Why the audit was mostly wrong
The library already has a deliberate, documented tap-target system the workers missed:
- `Variants::TOUCH_TARGET` — an invisible `::before` that expands standalone small
  controls to 44px **only on touch devices** (`pointer-coarse:`), changing neither
  layout nor look. Used by close_button, button, breadcrumb, sort_header.
- `pointer-coarse:` real-size overrides for adjacent controls that can't overlap:
  dropdown items (`pointer-coarse:py-2.5`), pagination (`pointer-coarse:min-h-11
  min-w-11`), switch (`pointer-coarse:mt-3.5` + large clickable label).

The workers saw raw `size-4` / `py-1` / `w-8 h-4` / `w-[400px]` and flagged them,
missing the touch-device overrides and `max-w-full` caps right next to them.

## Verdict per finding
| File | Reported | Verdict |
|---|---|---|
| close_button | tap target too small (high) | FALSE — has `TOUCH_TARGET` |
| button sm/md/lg | under 44px | FALSE — has `TOUCH_TARGET` |
| alert close | ~40px | FALSE — renders CloseButtonComponent |
| toast close | insufficient (high) | FALSE — renders CloseButtonComponent |
| switch | 16px inputs | FALSE — `pointer-coarse:` + large label |
| pagination | py-1 too small | FALSE — `pointer-coarse:min-h-11 min-w-11` |
| dropdown items | too small | FALSE — `pointer-coarse:py-2.5` |
| tooltip | small target | FALSE — wraps caller's own focusable child |
| offcanvas width | 400px overflows 320px (high) | FALSE — line has `max-w-full` |
| badge | nowrap overflow (low) | FALSE — intentional (Bootstrap badge) |
| toast | `text-sm` iOS zoom (med) | FALSE — not a focusable input |
| **offcanvas top/bottom** | **`vh` not `dvh` (med)** | **REAL — fixed → `h-[30dvh]`** |
| **toast_container** | **no safe-area inset (high)** | **REAL — fixed → `env(safe-area-inset-*)` padding** |

## Fixes applied (2 files)
- `offcanvas_component.rb`: top/bottom placements `h-[30vh]` → `h-[30dvh]`.
- `toast_container_component.rb`: `p-3` → per-side `max(0.75rem, env(safe-area-inset-*))`.

## Process lesson for the next audit
Give workers the design-system vocabulary up front: tell them `TOUCH_TARGET` and
`pointer-coarse:` satisfy the 44px rule and `max-w-full` caps width, so they verify
against the resolved classes instead of raw literals. And write reports to
`.git/qwen-workers/*.md` so they survive worktree cleanup.
