# ComponentLibrary2100

Bootstrap 5-style components for Rails, built with [ViewComponent](https://viewcomponent.org), Stimulus and Tailwind CSS v4. Small by design: components render semantic HTML with Tailwind utilities, take plain keyword arguments, and let you override anything.

**Status:** 0.2.0 scaffold. Components: Accordion, Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, Collapse, Dropdown, ListGroup, Modal, Offcanvas, Pagination, Popover, Progress, Spinner, Table, Tabs, Toast, Tooltip. Needs Ruby 3.2+, Rails 7.1+, ViewComponent 4, Tailwind v4 (`tailwindcss-rails`), importmap.

## Install

```ruby
# Gemfile
gem "component_library_2100", github: "the-codetrane/2100-component-library", tag: "v0.2.0"
```

```sh
bundle install
bin/rails g component_library_2100:install
```

The generator does three things (do them by hand if your files differ). The third is the `.gitignore` entry in step 1.

1. Adds `@import "./component_library_2100.css";` to `app/assets/tailwind/application.css`, after `@import "tailwindcss"`. That file is written by `rake component_library_2100:tailwind` (it runs automatically before `tailwindcss:build` / `tailwindcss:watch`) and points Tailwind at the gem's theme tokens and component sources. It holds an absolute path, so the generator also adds it to `.gitignore`.
2. Registers the Stimulus controllers in `app/javascript/controllers/index.js`:

   ```js
   import { register as registerComponentLibrary2100 } from "component_library_2100"
   registerComponentLibrary2100(application)
   ```

For local development: `bundle config local.component_library_2100 ../2100-component-library`.

## Use

```erb
<%= render ComponentLibrary2100::ButtonComponent.new(variant: :success, size: :lg) { "Save" } %>

<%= ui_button "Save", variant: :success %>            <%# same thing, via the helper %>
<%= ui_alert "Saved!", variant: :success, dismissible: true %>

<%= ui_card class: "w-72" do |card| %>
  <% card.with_header { "Featured" } %>
  <h5 class="mb-2 text-xl font-medium">Title</h5>
  <p>Body copy.</p>
<% end %>
```

Every component accepts the Bootstrap vocabulary it has (`variant:`, `size:`, `outline:`, `pill:`, `striped:` ...) plus any HTML attributes. A `ui_*` helper exists for every component (`ui_button_group`, `ui_list_group`, ...).

## Components

### Alert

<img src="docs/images/alert.png" width="720" alt="Alerts in four variants, plus a dismissible one with a close button">

### Badge

<img src="docs/images/badge.png" width="720" alt="Badges in all eight variants, square and pill">

### Breadcrumb

<img src="docs/images/breadcrumb.png" width="720" alt="Breadcrumb trail: Home / Library / Data">

### Button

<img src="docs/images/button.png" width="720" alt="Solid and outline buttons in each variant, then sizes, disabled and link styles">

### ButtonGroup

<img src="docs/images/button_group.png" width="720" alt="Horizontal solid, horizontal outline and vertical button groups">

### Card

<img src="docs/images/card.png" width="720" alt="Card with a header, title, body copy, button and footer">

### CloseButton

<img src="docs/images/close_button.png" width="720" alt="Close buttons on light and dark backgrounds">

### ListGroup

<img src="docs/images/list_group.png" width="720" alt="List groups showing active, plain, disabled and coloured items">

### Pagination

<img src="docs/images/pagination.png" width="720" alt="Pagination at default and small sizes">

### Progress

<img src="docs/images/progress.png" width="720" alt="Progress bars with labels, stripes and variants">

### Spinner

<img src="docs/images/spinner.png" width="720" alt="Border and grow spinners in several colours and sizes">

### Table

<img src="docs/images/table.png" width="720" alt="Striped table of people with status badges">

## Interactive components

These lean on the platform instead of re-implementing it, so there is little JavaScript to maintain:

| Component | Built on | Notes |
|---|---|---|
| Accordion | `<details name>` | No JavaScript. `always_open: true` drops the shared name. |
| Collapse | grid-rows transition | `cl-collapse` toggles attributes; no heights are measured. |
| Dropdown, Popover | popover API (`popover="auto"`) | Browser handles outside click, Escape and focus return; `cl-popover` places it and adds arrow-key navigation for menus. |
| Modal, Offcanvas | `<dialog>` + `showModal()` | Focus trap, inert page and Escape come from the browser. `static_backdrop: true` ignores backdrop clicks. |
| Tabs | WAI-ARIA tabs pattern | `cl-tabs`; tabs and panels pair by position. |
| Toast | `cl-dismiss` + `aria-live` container | Render toasts inside a `ToastContainerComponent`. `delay: 0` keeps one open. |
| Tooltip | popover API (`popover="manual"`) | Wrap something focusable. Shows on hover and keyboard focus. |

Triggers are slots that take Button options: `modal.with_trigger(variant: :danger) { "Delete" }`. Open or close from anywhere inside a component with `data-action="cl-dialog#open"`, `cl-dialog#close`, `cl-collapse#toggle` or `cl-popover#close`.

Floating elements use a small placement helper (`position.js`) that flips and clamps to the viewport. It does not follow scrolling ancestors or draw arrows. It needs a browser with the popover API and `<dialog>` (all current evergreen browsers).

## Overriding

| Need | How |
|---|---|
| One-off style change | `class:` is merged with `tailwind_merge`, so `class: "px-8 rounded-full"` replaces the defaults instead of fighting them |
| Extra attributes | `id:`, `data:`, `aria:` etc. are passed to the root element. `data-controller` values are concatenated with the component's own |
| Theme (colours, radius) | Redefine tokens after the import: `@theme { --color-primary: #7c3aed; --radius-ui: .5rem; }` |
| New variant | Add its `--color-<name>*` tokens to `@theme`, then add a line to the tables in `Variants` (classes must be written out in full for Tailwind to see them), or pass `class:` per call |
| Custom Tailwind classes in merges | `ComponentLibrary2100.merger = TailwindMerge::Merger.new(config: {...})`. Keep the radius names from `ComponentLibrary2100::MERGER_CONFIG` in your config |
| Small behaviour change | Subclass: `class AppButton < ComponentLibrary2100::ButtonComponent` |
| Full control | `bin/rails g component_library_2100:eject button` copies the component into your app, where it shadows the gem's |

## Reserved theme tokens

`engine.css` defines these `--color-*` tokens for `primary`, `secondary`, `success`, `danger`, `warning`, `info`, `light` and `dark`:

| Token | Used for |
|---|---|
| `--color-<name>` | Solid fills, so it needs to be dark or bright enough to carry `-on` text |
| `--color-<name>-on` | Text on a solid fill |
| `--color-<name>-subtle` | Tinted surfaces |
| `--color-<name>-border` | Borders on tinted surfaces |
| `--color-<name>-emphasis` | Text on tinted surfaces |

It also defines `--radius-ui`, `--radius-ui-sm` and `--radius-ui-lg`. Your own `@theme` wins over these, so a token with the same name but another purpose changes the components. A pale `--color-success` meant for borders makes success buttons unreadable. Give those tokens other names.

## Differences from Bootstrap

- No outer margins (`mb-3` etc.): spacing is the caller's job.
- Hover on solid buttons uses `brightness-90` rather than a computed shade. It stays when you pass a `hover:bg-*` class, so that color comes out 10% darker. Add `hover:brightness-100` to cancel it.
- Responsive tables use Tailwind's breakpoints.
- Not included: Bootstrap's grid, utilities, Reboot or Sass. Tailwind covers those.

## Development

```sh
bundle install
bundle exec rake test
bundle exec rubocop
```

Tests boot a tiny in-process Rails app (`test/test_helper.rb`) and render each component with `ViewComponent::TestCase`.

The images above come from `bundle exec rake screenshots`, which renders the examples in `script/screenshots.rb` and writes `docs/images/`. It needs Chrome installed. Rerun it after changing how a component looks.

CI runs on every PR: the tests on each supported Ruby and on the oldest gem versions the gemspec allows (`gemfiles/oldest.gemfile`, so keep the two in step), RuboCop, `bundler-audit`, a gem build and a workflow audit. A weekly run repeats this against the latest gems and opens an issue if it fails.

### Merging

Once CI is green, `bin/pr-triage` merges a PR into `development` unless one of these applies. Nothing reaches an app until a person bumps the version.

- **It's sensitive:** it touches `lib/`, `config/`, `app/javascript/`, `.github/`, the gemspec, or another path in `SENSITIVE` in `script/review_policy.rb`. It gets the `needs-human-review` label, and the required **Human review** check stays red until a person adds `human-reviewed`. A new push takes that label off, so review again after pushing. After adding the label, wait for **Human review** to turn green, because GitHub blocks the merge until it does.
- **It's labelled `do-not-auto-merge`:** it stays open, and **Human review** stays red until the label comes off. This includes drafts, which otherwise merge like any other PR.
- **It's from a fork:** it never merges itself.

### Releasing

Add notes to `## Unreleased` in `CHANGELOG.md` as you go. To release, open a PR that changes `VERSION` in `lib/component_library_2100/version.rb`, renames `## Unreleased` to the new version, adds a fresh `## Unreleased` above it, and updates the tag in the install instructions. CI fails the PR if the notes are missing. Merging it runs CI again, then creates the tag and GitHub Release. Tags can't be moved or deleted, so a fix goes out as a new version.

## Roadmap

Navbar, Carousel, and a form builder.

## License

MIT. See [LICENSE](LICENSE).
