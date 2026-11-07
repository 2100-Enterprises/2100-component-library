# Changelog

## Unreleased

- Nav: Bootstrap `.nav` tabs and pills made of links, with `active:` (`aria-current="page"`), `disabled:`, `fill:`, `justified:` and an optional `label:` landmark. Looks like Tabs. Helper `ui_nav`.
- Form builder: `ComponentLibrary2100::FormBuilder` and `ui_form_with`. Field helpers render a label, Bootstrap form-control styling, the model's inline error and a hint, with `aria-describedby`/`aria-invalid` wired, plus `optional:`, `label: false`, `error:` and `wrapper: false`. Covers text, email, password (Show/Hide button, new `cl-password` controller), tel, number, url, search, date, select and textarea; `rich_text_area` when Action Text is present; `radio_cards`, `switch`, `check`, `error_summary`, and `submit` as a ButtonComponent.
- New form components: FormField (wraps any control), RadioCardGroup, ErrorSummary. Helpers `ui_form_field`, `ui_radio_card_group`, `ui_error_summary`.
- Switch: Bootstrap form-check and form-switch (`type: :switch`, `:checkbox`, `:radio`) with label, hint, error and Rails' hidden unchecked value. `autosubmit: true` submits its form on change (new `cl-autosubmit` controller). Helper `ui_switch`.
- Dropdown: `with_item(..., href:, method: :delete)` (any non-GET method) renders a `button_to` form inside the menu, keeping the menuitem role and arrow keys. `params:` and `form:` pass through. Existing items are unchanged.
- Styled confirm: ConfirmDialog (`ui_confirm_dialog`) and the `cl-confirm` controller, plus `confirmMethod` and `useStyledConfirm(Turbo)` exported from `component_library_2100`, which set Turbo's confirm method (`Turbo.config.forms.confirm`, or `Turbo.setConfirmMethod` on older Turbo).
- Extras, beyond Bootstrap: PageHeader (breadcrumb, title, badges, subtitle, actions that wrap on small screens), EmptyState (icon, title, text, action) and Avatar (initials from a name, `:sm`/`:md`, colour variants, accessible label). Helpers `ui_page_header`, `ui_empty_state`, `ui_avatar`.

### For 0.5.0 (app shell)

- Navbar: brand, links with `active:` (`aria-current="page"`) and an `actions` slot that stays in the bar. Below `expand:` (`:sm` to `:xxl`, default `:lg`; `true` never collapses, `false` always does) the links move into an Offcanvas behind a menu button with an accessible name (`menu_label:`), `aria-controls` and `aria-expanded`. `theme: :light` or `:dark`. Helper `ui_navbar`.
- Stepper (extra): an `<ol>` of steps that are `:complete`, `:current` (`aria-current="step"`) or `:upcoming`, set per step or from `current:`. Steps can be text, links (`href:`) or submit buttons (`name:`/`value:`), with an optional `hint:`. Stacked first, a row from `breakpoint:` (`:sm`, `:md` default, `:lg`, `:xl`, `:xxl`; `false` always stacks). Helper `ui_stepper`.
- Theme tokens for the neutral greys: `--color-body`, `--color-body-muted`, `--color-border`, `--color-border-subtle`, `--color-border-input`, `--color-border-translucent`, `--color-border-menu`, `--color-border-overlay`, `--color-surface`, `--color-surface-subtle`, `--color-surface-muted`, `--color-surface-tint`, `--color-surface-stripe`, `--color-surface-hover`, `--color-backdrop` and `--color-link-hover`, plus `--color-tooltip`, `--color-tooltip-on`, `--color-toast-border`, `--color-switch` and `--color-popover-header`. Table, Card, Dropdown, Modal, Offcanvas, Popover, Tooltip, Toast, Switch, Tabs, Nav, Pagination, ListGroup, Accordion, Progress, RadioCardGroup and form controls use them instead of hard-coded values. The defaults are the old values, so nothing looks different.
- Modal and Offcanvas take `close:`, options for the header's close button.
- `cl-dialog` keeps `aria-expanded` on its `trigger` targets in step with the dialog.

## 0.3.0

- Progress puts `aria:` on the `role="progressbar"` element rather than the track, so `aria: {label: "Upload"}` names the bar.
- Toast takes `close:`, options for its close button.
- Toast no longer runs off narrow screens.

## 0.2.0

- README shows an image of each component, regenerated with `rake screenshots`.
- Needs `tailwind_merge` 1.5.1 or newer. Older versions allowed by the gemspec crashed on the first render, because they can't read `MERGER_CONFIG`.
- Sets upper limits on `rails` (`< 9`) and `tailwind_merge` (`< 2`).
- Licensed under MIT.
- Interactive components: Accordion, Collapse, Dropdown, Modal, Offcanvas, Popover, Tabs, Toast (with ToastContainer), Tooltip. They use native `<details>`, `<dialog>` and the popover API, plus the Stimulus controllers `cl-collapse`, `cl-dialog`, `cl-popover`, `cl-tabs` and `cl-tooltip`.
- `data-action` values now concatenate with a component's own, as `data-controller` already did.
- `cl-dismiss` fades through `data-closing` (give the element `data-closing:opacity-0`) instead of adding `opacity-0` from JavaScript, which Tailwind never scanned. It also takes `data-cl-dismiss-delay-value` to close itself after a delay. Apps that use `cl-dismiss` on their own markup need to add `data-closing:opacity-0`.

## 0.1.0

- Initial scaffold: engine, theme tokens, install/eject generators.
- Components: Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, ListGroup, Pagination, Progress, Spinner, Table.
- The Tailwind entry file moves from `app/assets/builds/` to `app/assets/tailwind/`, because `stylesheet_link_tag :app` linked it and published an absolute server path. Existing apps need to change their import to `@import "./component_library_2100.css";`, git-ignore the new path, and delete the old file.
- `class:` now replaces the `rounded-ui` tokens.
- Importmap pins are no longer preloaded.
- A dismissible Alert's close button sits beside the `role="alert"` element rather than inside it. HTML attributes stay on the alert, and `data-controller` is on a new wrapper.
