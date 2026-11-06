# Changelog

## Unreleased

- README shows an image of each component, regenerated with `rake screenshots`.
- Needs `tailwind_merge` 1.5.1 or newer. Older versions allowed by the gemspec crashed on the first render, because they can't read `MERGER_CONFIG`.
- Sets upper limits on `rails` (`< 9`) and `tailwind_merge` (`< 2`).
- Licensed under MIT.
- Initial scaffold: engine, theme tokens, install/eject generators.
- Components: Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, ListGroup, Pagination, Progress, Spinner, Table.
- The Tailwind entry file moves from `app/assets/builds/` to `app/assets/tailwind/`, because `stylesheet_link_tag :app` linked it and published an absolute server path. Existing apps need to change their import to `@import "./component_library_2100.css";`, git-ignore the new path, and delete the old file.
- `class:` now replaces the `rounded-ui` tokens.
- Importmap pins are no longer preloaded.
- A dismissible Alert's close button sits beside the `role="alert"` element rather than inside it. HTML attributes stay on the alert, and `data-controller` is on a new wrapper.
- Interactive components: Accordion, Collapse, Dropdown, Modal, Offcanvas, Popover, Tabs, Toast (with ToastContainer), Tooltip. They use native `<details>`, `<dialog>` and the popover API, plus the Stimulus controllers `cl-collapse`, `cl-dialog`, `cl-popover`, `cl-tabs` and `cl-tooltip`.
- `data-action` values now concatenate with a component's own, as `data-controller` already did.
- `cl-dismiss` fades through `data-closing` (give the element `data-closing:opacity-0`) instead of adding `opacity-0` from JavaScript, which Tailwind never scanned. It also takes `data-cl-dismiss-delay-value` to close itself after a delay. Apps that use `cl-dismiss` on their own markup need to add `data-closing:opacity-0`.
