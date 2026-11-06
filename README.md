# ComponentLibrary2100

Bootstrap 5-style components for Rails, built with [ViewComponent](https://viewcomponent.org), Stimulus and Tailwind CSS v4. Small by design: components render semantic HTML with Tailwind utilities, take plain keyword arguments, and let you override anything.

**Status:** 0.1.0 scaffold. Components: Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, ListGroup, Pagination, Progress, Spinner, Table. Needs Ruby 3.2+, Rails 7.1+, ViewComponent 4, Tailwind v4 (`tailwindcss-rails`), importmap.

## Install

```ruby
# Gemfile
gem "component_library_2100", github: "the-codetrane/2100-component-library", tag: "v0.1.0"
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
```

Tests boot a tiny in-process Rails app (`test/test_helper.rb`) and render each component with `ViewComponent::TestCase`.

## Roadmap

Interactive components (Accordion, Collapse, Dropdown, Modal on native `<dialog>`, Offcanvas, Tabs, Toast, Tooltip, Popover), Navbar, Carousel, and a form builder.
