# Changelog

## Unreleased

- `NavbarComponent#with_menu(label, active:, **opts)` groups links: a dropdown in the bar (trigger styled as a link, `data-current` when active or any child is) and a labelled list in the offcanvas panel. Items and menus render in call order; `with_item` is unchanged. Navbar links and menu triggers also get 44px touch targets on coarse pointers.

## 0.12.3

- `ModalComponent` and `OffcanvasComponent` stop scrolling inside the panel, or over its backdrop, from scrolling the page behind (`overscroll-behavior: contain`; Safari doesn't support it yet).
- A `TableComponent` with `responsive:` and a caption wraps the table in a focusable `role="region"` named by the caption, so keyboard users can scroll it. Without a caption the wrapper is unchanged.
- `PwaInstallComponent` takes `close:`, options for its close button, as `ToastComponent` does.

## 0.12.2

- Restores the `px-5 py-4` padding on the `AccordionItemComponent` body, which 0.12.0 dropped. Without it, flush content such as list groups and tables that uses negative margins to reach the card edge was clipped by the item's `overflow-hidden`.

## 0.12.1

- Fixes the version file. The v0.12.0 tag pointed at a commit whose `version.rb` still said 0.11.0, so Dependabot kept trying to repin apps that already used v0.12.0. Use v0.12.1; its tag and `version.rb` agree.
- Restores the changelog history that the 0.12.0 release commit overwrote.

## 0.12.0

### Docs

- The README no longer shows component images, and `rake screenshots` (with `script/screenshots.rb`, `docs/images/` and the `ferrum` development gem) is gone. Browse the components with `rake lookbook` instead.

### Progressive Web App

- `ui_pwa_meta_tags` renders the head tags that make a page installable: the manifest link, `theme-color`, the `apple-*` tags iOS reads and an `apple-touch-icon`. The iOS status bar defaults to opaque.
- `component_library_2100/pwa/_service_worker.js.erb`, a service worker a host app renders from its `app/views/pwa/service-worker.js.erb`: network-first pages with an offline fallback, stale-while-revalidate static assets, versioned caches, and `skip:` prefixes that are never cached (Active Storage by default).
- `registerServiceWorker()` and `isStandalone()`, pinned at `component_library_2100/pwa` and exported from `component_library_2100`.
- `PwaInstallComponent` (`ui_pwa_install`) and its `cl-pwa-install` controller: a hidden install banner that offers one-tap install where the browser fires `beforeinstallprompt`, Add to Home Screen guidance on iOS Safari, and remembers a dismissal.

### Modal and Offcanvas

- `ModalComponent` (and `ConfirmDialogComponent`, which renders one) fades and drops into place on open, and fades out on close, over 200ms. Its backdrop fades in and out with it.
- `OffcanvasComponent` slides out on close instead of vanishing, and its backdrop fades in and out.
- A closing dialog stays in the top layer until its animation ends, by transitioning `display` and `overlay` discretely. Browsers without `@starting-style` open and close instantly, as before, and so does any browser under `prefers-reduced-motion`. Firefox and Safari can't transition `overlay`, so they may close without the fade.
- System tests can opt into the library's compiled CSS with `render_page(erb, styles: true)`.

### Fade animations

- `StatComponent` and `AccordionItemComponent` content fades in on load, with staggered delays for sequential reveal (100ms gaps)
- `fade-in`, `fade-in-down`, `fade-in-up`, `fade-in-left` animation variants with CSS custom properties for easy reuse
- `motion-reduce:transition-none` support for all animations to respect user's reduced motion preference
- AccordionItem content fades in/out on open/close via CSS transitions (no JavaScript)

## 0.11.0

### Breaking

- `OffcanvasComponent` needs an accessible name: `title:`, `aria: {label: ...}` or `aria: {labelledby: ...}`. Without one it raises `ArgumentError`. Navbar's menu already passes its `menu_label:` (default "Menu") as the title, so a Navbar is unaffected.
- The title of `ModalComponent`, `OffcanvasComponent` and `ConfirmDialogComponent` is an `<h2>` instead of an `<h5>`. It looks the same. Update any selector or style that targets the `h5`, or pass `heading_level: 5` to keep the old markup.

### Dialogs

- `heading_level:` (1 to 6, default 2) on Modal, Offcanvas and ConfirmDialog.
- `description_id:` on Modal and Offcanvas sets `aria-describedby`. ConfirmDialog is described by its message.
- The built-in Modal and Offcanvas triggers get `aria-controls`, and a live `aria-expanded` that `cl-dialog` keeps in step, including on Escape. The dialog always has an id.
### Toast

- Auto-dismiss pauses while a toast is hovered, while focus is inside it, or while the tab is hidden, and resumes with the time that was left, not the full delay (WCAG 2.2.1). `cl-dismiss` dispatches `cl-dismiss:paused` and `cl-dismiss:resumed`. Alerts and toasts without a delay are unchanged.
### Table

- `ui_table` takes a `caption` slot that names the table for screen readers: `table.with_caption { "Clients" }`, visible by default, or `with_caption(visible: false)` for screen readers only. It renders as the table's first child, inside the `responsive:` wrapper.
- `TableHeaderComponent` (`ui_table_header`): a `<th>` that always has a `scope`, `:col` by default, or `:row`, `:colgroup` or `:rowgroup`. An unknown scope raises `ArgumentError`.
### Forms

- `f.check_boxes :roles, choices` and `f.radios :contact, choices` render a group of native checkboxes or radio buttons in a `<fieldset>` with a `<legend>`. They go through the new `ChoiceGroupComponent` (`ui_choice_group`). The hint and error are tied to the fieldset with `aria-describedby`, and `aria-invalid` goes on each input. `inline: true` lays the options in a row. Each option is a clickable label at least 44px tall. A hidden empty value is sent first, so an empty submission still sends the attribute (`hidden: false` drops it). Choices take the same shapes as `radio_cards`.
- `time_field`, `datetime_local_field` and `month_field` get the label, hint and error wrapper, like `date_field`. Use `min:` and `max:` for limits, and validate them on the server too.
- Live character counter: `counter: {max: 2000}` or `counter: {min: 12}` on any builder field or `FormFieldComponent`. The server adds the rule to the hint ("Up to 2,000 characters."), so it reads the same without JavaScript. The new `cl-counter` controller shows a visible count as you type ("1,950 characters left", "4 more characters needed"), and a polite live region repeats it after typing pauses, so screen readers don't announce every keystroke. `html: true` counts the text of rich text. `left:`, `over:`, `needed:` and `hint:` replace the messages. The counter never sets `aria-invalid`; only server errors do.
### FileUpload

- `FileUploadComponent` (`ui_file_upload`, `f.file_upload`): a styled native `<input type="file">` that works in a plain multipart form without JavaScript, with the server staying the source of truth for size and type. With the new `cl-file-upload` controller, each chosen file shows its name, size and a "Remove <filename>" button. A file that's too large (`max_bytes:`) or of the wrong type (`accept:`, joined with commas and no spaces) gets a warning tied to the input by `aria-describedby`. A polite live region announces changes. `multiple: true` lists every file. `dropzone: true` adds a drop area around the input, which stays the keyboard path. Active Storage `direct-upload:*` events drive a progress bar.
### Combobox

- `ComboboxComponent` (`ui_combobox`, `f.combobox`): a text input with server-side suggestions, following the WAI-ARIA 1.2 combobox pattern. After `min_length:` characters and a `delay:`, the `cl-combobox` controller loads `src?q=<text>` into a Turbo Frame. The endpoint answers with `ComboboxOptionComponent` (`ui_combobox_option`) items, optionally inside `ComboboxOptionComponent::Group`, so it never writes ARIA by hand. A hidden input holds the value and the visible input holds the label. `force_selection: true` clears unmatched text on blur.
- Keys: Down and Up move, Enter chooses, Escape closes and a second Escape clears, Alt+Down opens, Alt+Up chooses, and Tab closes. A polite live region announces the result count, `aria-busy` marks loading, and `cl-combobox:select` carries `{value, label}`. Without JavaScript it's a plain text input in the host form. Needs Turbo.
### Timeline

- `TimelineComponent` (`ui_timeline`): an activity feed as an ordered list. Each `timeline.with_event(time:, title:, variant:, icon:, time_label:) { body }` renders a `<time datetime>`, an aria-hidden marker that `variant:` tints, and its text. `alternate: true` alternates sides from `md:` up, and `label:` names the list. No JavaScript.
- `TimelineEventComponent` (`ui_timeline_event`): one self-contained `<li>`, so a Turbo Stream can `prepend` an event into the list. The connector line and the alternate sides are plain CSS, and they stay right when events are added.
### Chip

- `ChipComponent` (`ui_chip`) and `ChipGroupComponent` (`ui_chip_group`): removable values such as active filters, chosen members or file types. `remove:` takes a URL, which renders a link, or `{href:, method:, label:, params:}`, which renders a `button_to` form for a non-GET method so it keeps the CSRF token. The control is named "Remove <label>" and answers to 44px on touch screens. Without `remove:` a chip is a static `<span>`. `ui_chip_group(label:)` renders a labelled `<ul>`, with chips added through `with_chip`. No JavaScript.

## 0.10.0

### Dark mode

- Opt-in dark mode: `data-theme="dark"` on `<html>` turns it on, `data-theme="system"` follows the OS, and no attribute changes nothing. Every colour token gets a dark value, and `color-scheme: dark` is set. Solid fills lighten and take dark `-on` text, so a fill also reads as text on a dark surface. The README's [Dark mode](README.md#dark-mode) section has the details.
- `theme-dark:` variant, for an app's own classes and dark token values, following the same switch.
- `--color-close` token (default `#000`): CloseButton's icon uses it instead of `text-black`, so it shows on a dark surface. `white: true` is unchanged.
- Navbar `theme: :surface`: the bar and its menu panel use `surface` and `body` tokens, so they follow dark mode. `:light` stays the default.

## 0.9.0

### Breaking

- Button is `inline-flex items-center justify-center gap-1.5` instead of `inline-block align-middle`, so a label sits in the middle of a button made taller with a `min-h-` class, and an icon lines up beside it. A `class:` with a display utility (`hidden`, `block`, `inline-block`) still replaces it.
- Button is `font-medium` instead of `font-normal`.
- Every Button has one focus style, `ButtonComponent::FOCUS`: `focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2`. It replaces the half-transparent `ring-4` in each variant's colour. `Variants::RING` stays, but Button no longer uses it.
- To upgrade: drop any `min-h-` workarounds that only re-centred a label, and any `class:` that restyled a Button's focus ring to make it consistent. Check buttons that relied on `inline-block` flowing their content as text.

### Dropdown

- The trigger's caret is spaced and centred by the button's gap, so it has no margin or `vertical-align`.

## 0.8.0

### Bootstrap parity

- Carousel: a slideshow with controls, indicator dots, captions and autoplay, driven by `cl-carousel`. Slides are a slot (`carousel.with_slide(active:, interval:, caption_title:, caption_text:) { ... }`). `ride: true` autoplays on load; `interval:` (ms) is the default, overridable per slide; `wrap:` cycles past the ends (default true); `crossfade: true` fades instead of sliding; `controls:`/`indicators:` default true. Arrow-key navigation, swipe, pause-on-hover and pause-when-tab-hidden are built in; follows the WAI-ARIA carousel pattern and honours `prefers-reduced-motion`. Helper `ui_carousel`.
- Scrollspy: a nav whose active link follows the section in view, driven by `cl-scrollspy` with an IntersectionObserver. Items are a slot (`spy.with_item("Intro", href: "#intro", active:)`); the matching link gets `aria-current="true"`. `smooth:` (default true) smooth-scrolls on click; `offset:` (px) clears a sticky header. Helper `ui_scrollspy`.
- InputGroup: joins a form control with leading/trailing add-ons into one connected control. Slots `with_prepend`, `with_append` (plain text is wrapped in the styled add-on span; pass a block for a button) and `with_control` (your input carries `InputGroupComponent::CONTROL`). Children share borders and only the outer corners round. `size:` is nil, `:sm` or `:lg`. No JavaScript. Helper `ui_input_group`.
- FloatingLabel: a label that sits inside the control and floats up when it is focused or filled, pure CSS via Tailwind `peer` utilities (no JavaScript). `FloatingLabelComponent.new(label:, control_id:)` with a block for the control, which must carry `FloatingLabelComponent::CONTROL` (includes `peer` and room for the label) and `placeholder: " "`. Helper `ui_floating_label`.
- Range: a styled `<input type="range">` (Bootstrap's form-range). `RangeComponent.new(name:, value:, min:, max:, step:, label:, hint:, disabled:)`; `label:`/`hint:` are wired with `aria-describedby`. The thumb grows on touch screens. No JavaScript. Helper `ui_range`.

### Mobile and accessibility

- Offcanvas: `:top`/`:bottom` placements are `30dvh` tall instead of `30vh`, so the panel no longer jumps when a phone's address bar shows or hides.
- ToastContainer: padding respects `env(safe-area-inset-*)` on each side (at least `0.75rem`), so toasts clear the notch and home indicator.
- Navbar: the toggler's focus ring now renders (`focus-visible:ring-4` was missing, so only the ring colour was set), matching nav links.
- ListGroupItem: actionable items (`href:` or `action: true`) get `pointer-coarse:py-2.5`, reaching 44px on touch screens.

### PWA brand icons

- Shared PWA icons in `app/assets/images/component_library_2100/pwa/`: `icon-192.png`, `icon-384.png`, `icon-512.png` (`purpose: any`) and `icon-192-maskable.png`, `icon-512-maskable.png` (`purpose: maskable`, glyph inside the 80% safe zone). Reference them from a host app's `manifest.json.erb` with `asset_path("component_library_2100/pwa/icon-192.png")`; see the folder README.

## 0.7.0

### Building blocks

- Skeleton: a pulsing, `aria-hidden` placeholder for content that is still loading (an extra, not in Bootstrap). `shape:` is `:text` (default), `:block` or `:circle`; `lines:` draws several text rows with a shorter last line. Size it with `class:`; the pulse stops under `prefers-reduced-motion`. Helper `ui_skeleton`.
- DescriptionList: a `<dl>` of term/description pairs for a record's details (an extra, not in Bootstrap). `layout:` is `:stacked` (default) or `:inline` (columns from `sm`); `dividers:` draws a line between rows (default true). Items take `term:` and either `description:` or a block. Helper `ui_description_list`.
- Stat and Stats: dashboard metrics (extras, not in Bootstrap). Stat is a `<dl>` card with `label:`, `value:`, optional `change:`, `trend:` (`:up`, `:down`, `:flat`: an arrow plus visually hidden "Increased by"/"Decreased by"), `variant:` to recolour the change when down is good, `hint:` and `card: false`. Stats lays stats out in a grid: one column on phones, two from `sm`, `columns:` (2, 3 or 4) from `lg`, and `label:` makes it a named `section`. Helpers `ui_stat`, `ui_stats`.
- SortHeader: a sortable `<th scope="col">` (an extra, not in Bootstrap). You pass `href:`; `direction:` (`:asc`, `:desc` or nil) sets `aria-sort` and the arrow, unsorted columns get a faint icon that darkens on hover. `align: :end` for numbers, `link:` for the anchor's options (e.g. a Turbo Frame). The link answers to 44px on touch screens. Helper `ui_sort_header`.

## 0.6.1

### Progress

- The bar no longer has a width transition, so a change of value shows at once instead of animating a layout property. `scaleX` was ruled out because it would squash a `label:`. Striped `animated: true` bars still move.

### Mobile

Needs Tailwind 4.1 or later, for `pointer-coarse:` and `wrap-anywhere`. Every touch change below applies only on touch screens, so mouse users see no difference.

- Button, CloseButton and Breadcrumb links answer to at least 44px on touch screens, through an invisible `::before`, with no change to look or layout. `Variants::TOUCH_TARGET` holds the classes.
- Dropdown items, Pagination links, Switch rows and text inputs and selects are at least 44px tall on touch screens.
- Dropdown menus stay within the screen. Long items and headers wrap instead of running off the edge.
- Pagination wraps onto a second line when it runs out of room.

## 0.6.0

### Breaking

- `--color-border-menu` and `--color-border-overlay` are gone. Dropdown (menu and divider), Modal, Offcanvas and Popover now use `--color-border-translucent`, like Card, ListGroup and Accordion. Their edges get slightly lighter: 12.5% black instead of 15% (Dropdown) and 20% (Modal, Offcanvas, Popover).
- To upgrade: replace `border-border-menu` and `border-border-overlay` classes with `border-border-translucent`. If your `@theme` set either removed token, set `--color-border-translucent` instead, or pass `class:` to keep a darker edge on one component.

## 0.5.0

0.4.0 was never tagged: its changes ship here with the app shell.

### Building blocks

- Nav: Bootstrap `.nav` tabs and pills made of links, with `active:` (`aria-current="page"`), `disabled:`, `fill:`, `justified:` and an optional `label:` landmark. Looks like Tabs. Helper `ui_nav`.
- Form builder: `ComponentLibrary2100::FormBuilder` and `ui_form_with`. Field helpers render a label, Bootstrap form-control styling, the model's inline error and a hint, with `aria-describedby`/`aria-invalid` wired, plus `optional:`, `label: false`, `error:` and `wrapper: false`. Covers text, email, password (Show/Hide button, new `cl-password` controller), tel, number, url, search, date, select and textarea; `rich_text_area` when Action Text is present; `radio_cards`, `switch`, `check`, `error_summary`, and `submit` as a ButtonComponent.
- New form components: FormField (wraps any control), RadioCardGroup, ErrorSummary. Helpers `ui_form_field`, `ui_radio_card_group`, `ui_error_summary`.
- Switch: Bootstrap form-check and form-switch (`type: :switch`, `:checkbox`, `:radio`) with label, hint, error and Rails' hidden unchecked value. `autosubmit: true` submits its form on change (new `cl-autosubmit` controller). Helper `ui_switch`.
- Dropdown: `with_item(..., href:, method: :delete)` (any non-GET method) renders a `button_to` form inside the menu, keeping the menuitem role and arrow keys. `params:` and `form:` pass through. Existing items are unchanged.
- Styled confirm: ConfirmDialog (`ui_confirm_dialog`) and the `cl-confirm` controller, plus `confirmMethod` and `useStyledConfirm(Turbo)` exported from `component_library_2100`, which set Turbo's confirm method (`Turbo.config.forms.confirm`, or `Turbo.setConfirmMethod` on older Turbo).
- Extras, beyond Bootstrap: PageHeader (breadcrumb, title, badges, subtitle, actions that wrap on small screens), EmptyState (icon, title, text, action) and Avatar (initials from a name, `:sm`/`:md`, colour variants, accessible label). Helpers `ui_page_header`, `ui_empty_state`, `ui_avatar`.

### App shell

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
