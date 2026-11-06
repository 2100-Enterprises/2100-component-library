# Changelog

## Unreleased

- Initial scaffold: engine, theme tokens, install/eject generators.
- Components: Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, ListGroup, Pagination, Progress, Spinner, Table.
- The Tailwind entry file moves from `app/assets/builds/` to `app/assets/tailwind/`, because `stylesheet_link_tag :app` linked it and published an absolute server path. Existing apps need to change their import to `@import "./component_library_2100.css";`, git-ignore the new path, and delete the old file.
- `class:` now replaces the `rounded-ui` tokens.
- Importmap pins are no longer preloaded.
- A dismissible Alert's close button sits beside the `role="alert"` element rather than inside it. HTML attributes stay on the alert, and `data-controller` is on a new wrapper.
