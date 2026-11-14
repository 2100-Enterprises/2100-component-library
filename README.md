# ComponentLibrary2100

Bootstrap 5-style components for Rails, built with [ViewComponent](https://viewcomponent.org), Stimulus and Tailwind CSS v4. Small by design: components render semantic HTML with Tailwind utilities, take plain keyword arguments, and let you override anything.

**Status:** 0.7.0 scaffold. Components: Accordion, Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, Carousel, CloseButton, Collapse, Dropdown, ListGroup, Modal, Nav, Navbar, Offcanvas, Pagination, Popover, Progress, Scrollspy, Spinner, Switch, Table, Tabs, Toast, Tooltip, a form builder (with FormField, Switch, RadioCardGroup, ErrorSummary, InputGroup, FloatingLabel and Range) and the [extras](#extras) PageHeader, EmptyState, Avatar, Stepper, Skeleton, DescriptionList, Stat, Stats and SortHeader. Needs Ruby 3.2+, Rails 7.1+, ViewComponent 4, Tailwind v4 (`tailwindcss-rails`), importmap.

## Install

```ruby
# Gemfile
gem "component_library_2100", github: "the-codetrane/2100-component-library", tag: "v0.12.3"
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

Run `bundle exec rake lookbook` to browse a live preview of every component (see [Development](#development)).

Alert, Badge, Breadcrumb, Button, ButtonGroup, Card, CloseButton, ListGroup, Pagination and Spinner take the Bootstrap options listed above, so they have no section of their own.

### Nav

Tabs or pills made of links, for moving between pages (TabsComponent switches panels on one page, and looks the same).

```erb
<%= ui_nav style: :pills, label: "Account" do |nav| %>
  <% nav.with_item("Profile", href: profile_path, active: true) %>   <%# aria-current="page" %>
  <% nav.with_item("Billing", href: billing_path) %>
  <% nav.with_item("Archived", href: "#", disabled: true) %>
<% end %>
```

`style:` is `:tabs` (default) or `:pills`. `fill: true` stretches the items across the width and `justified: true` makes them equal widths. `label:` wraps the list in a `<nav aria-label>` landmark; without it you get the bare `<ul>`. HTML attributes go on the `<ul>`; extra item options (`data:`, `class:` ...) go on the link.

### Navbar

The bar across the top of an app: brand, links, and actions such as an account dropdown.

```erb
<%= ui_navbar label: "Main", expand: :lg, theme: :dark do |navbar| %>
  <% navbar.with_brand(href: root_path) { "2100" } %>                <%# or with_brand("2100") for plain text %>
  <% navbar.with_item("Projects", href: projects_path, active: true) %>   <%# aria-current="page" %>
  <% navbar.with_item("Clients", href: clients_path) %>
  <% navbar.with_menu("Content") do |menu| %>                              <%# a group of links %>
    <% menu.with_item("Planned posts", href: posts_path, active: true) %>
    <% menu.with_item("Drafts", href: drafts_path) %>
  <% end %>
  <% navbar.with_actions do %>
    <%= ui_dropdown(placement: "bottom-end") { |menu| menu.with_trigger { "Account" }; menu.with_item("Sign out", href: session_path, method: :delete) } %>
  <% end %>
<% end %>
```

It's a `<nav>` landmark named by `label:`. Below the `expand:` breakpoint (`:sm`, `:md`, `:lg` default, `:xl`, `:xxl`) the links move into an Offcanvas opened by a menu button, which has `menu_label:` (default "Menu") as its accessible name, `aria-controls` pointing at the panel, and `aria-expanded` kept in step by `cl-dialog`. `expand: true` never collapses; `expand: false` always does. Actions stay in the bar at every width. `theme:` is `:light` (default) or `:dark`, coloured from the `light`/`dark` tokens, or `:surface`, coloured from `surface` and `body` so it follows [dark mode](#dark-mode); the panel matches. `placement:` docks the panel (`:end` default). HTML attributes go on the `<nav>`; extra item options go on the link.

`with_menu(label, active: false, **opts) { |menu| menu.with_item(...) }` groups links. Items and menus render in the order you add them. From the breakpoint up a menu is a [Dropdown](#dropdown) (native popover, arrow keys, Escape) in the bar, its trigger styled like a link with a caret; `opts` go on the dropdown. The trigger gets `data-current` and an underline when `active: true` or any child is active (the button itself never takes `aria-current`); active children keep `aria-current="page"`. Below the breakpoint the group is a labelled list in the panel (`<li><span id>Content</span><ul aria-labelledby>...</ul></li>`) with no dropdown. Ids are generated, or derive from `id:` (`content`, `content-label`).

### Progress

Unlike Bootstrap's, the bar doesn't animate a change of value: width is a layout property, and animating `scaleX` instead would squash a `label:`. A new value shows at once. Striped bars still move with `animated: true`.

### Table

```erb
<%= ui_table striped: true do |table| %>
  <% table.with_caption(visible: false) { "Clients" } %>
  <thead><tr><%= ui_table_header "Name" %><%= ui_table_header "Email" %></tr></thead>
  <tbody><tr><%= ui_table_header "Ada", scope: :row %><td>ada@example.com</td></tr></tbody>
<% end %>
```

Give every table a name: `with_caption` renders a `<caption>`, visible unless `visible: false`, or pass `aria: {label: ...}`. `ui_table_header` is a `<th>` with `scope` (`:col` by default, `:row` for row headers). Use `ui_sort_header` for sortable columns. With `responsive:` and a caption, the scrolling wrapper is a focusable region named by the caption, so keyboard users can scroll it; without a caption it stays a plain `div`.

## Forms

`ComponentLibrary2100::FormBuilder` turns each field helper into a whole field: label, Bootstrap form-control styling, the model's error under the control, and a hint. `aria-describedby` and `aria-invalid` are wired for you, and `aria-invalid` is also what turns the border red.

```erb
<%= ui_form_with model: @user do |f| %>   <%# form_with(..., builder: ComponentLibrary2100::FormBuilder) %>
  <%= f.error_summary %>                  <%# lists errors, each linking to its field %>
  <%= f.text_field :name, hint: "As it appears on your ID" %>
  <%= f.email_field :email, required: true %>
  <%= f.password_field :password %>       <%# Show/Hide button (cl-password); toggle: false for none %>
  <%= f.telephone_field :phone, optional: true %>
  <%= f.number_field :age, label: "Age in years" %>
  <%= f.select :role, %w[Admin Member], {include_blank: true} %>
  <%= f.text_area :bio, rows: 4 %>
  <%= f.radio_cards :plan, [["Basic", "basic", "One project"], ["Pro", "pro", "Unlimited projects"]], columns: 2 %>
  <%= f.switch :newsletter, label: "Email me updates" %>   <%# f.check for a plain checkbox %>
  <%= f.submit "Save" %>                  <%# a ButtonComponent; takes variant:, size: %>
<% end %>
```

To use it for every form, set `config.action_view.default_form_builder = "ComponentLibrary2100::FormBuilder"`.

Every field helper (`text_field`, `email_field`, `password_field`, `telephone_field`/`phone_field`, `number_field`, `url_field`, `search_field`, `date_field`, `text_area`/`textarea`, `select`) also takes:

| Option | Does |
|---|---|
| `label:` | Label text, or `false` for none (then give the control an `aria: {label:}`). Defaults to `human_attribute_name` |
| `hint:` | Help text under the control |
| `optional:` | `true` adds "(optional)" to the label; a string changes the wording |
| `error:` | Replaces the message from `object.errors`; `false` hides it |
| `wrapper:` | HTML attributes for the field's `<div>` (`wrapper: {class: "mb-3"}`), or `false` for just the styled control |

Everything else (`class:`, `data:`, `required:` ...) goes on the control, and `class:` merges. For `select`, put these options in the options hash (the third argument), as Rails does. `rich_text_area` gets the same label/hint/error wrapper when the app has Action Text; the gem doesn't depend on it.

Pieces you can use without the builder:

- **FormField** wraps any control: `ui_form_field(label: "Email", control_id: "email", hint: "...", error: @error) { |field| email_field_tag "email", nil, **field.control_options }`. `control_options(class: ..., kind: :select)` returns the id, classes and aria attributes.
- **Switch** is Bootstrap's form-check: `ui_switch name: "user[newsletter]", label: "Email me", checked: true` (`type: :checkbox` or `:radio`, `inline: true`, `hint:`, `error:`). A switch is a checkbox with `role="switch"`. Checkboxes and switches with a `name:` include a hidden `unchecked_value:` ("0"; `false` for none), like Rails' `check_box`. HTML attributes go on the `<input>`; `wrapper:` takes the `<div>`'s. `autosubmit: true` submits the surrounding form on change (`cl-autosubmit`), for a toggle that saves itself inside a `form_with`.
- **RadioCardGroup** is a `<fieldset>` of radio cards: `ui_radio_card_group name: "plan", legend: "Plan", checked: "pro", choices: [{value: "pro", label: "Pro", description: "Unlimited"}]`. Choices can also be `[label, value, description]` arrays or strings.
- **ErrorSummary**: `ui_error_summary errors: @user.errors` (or an array of messages and `[message, href]` pairs). It renders nothing when there are no errors.
- **InputGroup** joins a control with add-ons into one connected control. `with_prepend`/`with_append` add-ons (plain text is wrapped in the styled span; pass a block for a `ui_button`) sit around `with_control`, whose input carries `ComponentLibrary2100::InputGroupComponent::CONTROL`; `size:` is `:sm`/`:lg`:

  ```erb
  <%= ui_input_group do |group| %>
    <% group.with_prepend { "$" } %>
    <% group.with_control do %><%= number_field_tag :amount, nil, class: ComponentLibrary2100::InputGroupComponent::CONTROL %><% end %>
    <% group.with_append { ".00" } %>
  <% end %>
  ```
- **FloatingLabel** floats the label into the control when it is focused or filled, with no JavaScript. The control must carry `ComponentLibrary2100::FloatingLabelComponent::CONTROL` (which includes `peer` and leaves room for the label) and `placeholder: " "`, and share the `control_id`:

  ```erb
  <%= ui_floating_label label: "Email", control_id: "email" do %>
    <%= email_field_tag :email, nil, id: "email", placeholder: " ", class: ComponentLibrary2100::FloatingLabelComponent::CONTROL %>
  <% end %>
  ```
- **Range** is a styled `<input type="range">`: `ui_range name: "volume", value: 40, min: 0, max: 100, step: 5, label: "Volume", hint: "0–100"`. `label:`/`hint:` are wired with `aria-describedby`; the thumb grows on touch screens. HTML attributes go on the input.

### Choice groups and date and time fields

```erb
<%= f.check_boxes :roles, %w[Admin Editor Viewer], label: "Roles", hint: "Pick any.", inline: true %>
<%= f.radios :contact, [["Email", "email"], ["Phone", "phone"]], label: "Best way to reach you" %>
<%= f.datetime_local_field :starts_at, min: Time.current %>
```

`check_boxes` and `radios` render a `<fieldset>` with a `<legend>`, with the hint and error tied to it by `aria-describedby`. Each option is a native input in a clickable label at least 44px tall. A hidden empty value is sent first, so a group with nothing chosen still submits. Choices are `[label, value]` pairs, `{value:, label:, disabled:}` hashes or strings. `date_field`, `time_field`, `datetime_local_field` and `month_field` are the browser's own pickers in the usual field wrapper, so there's no custom date picker to maintain. Pass Date or Time objects to `min:` and `max:`, because Rails rewrites strings for some of them.
### Live counter

```erb
<%= f.text_area :bio, counter: {max: 2000} %>
<%= f.password_field :password, counter: {min: 12} %>
<%= f.rich_text_area :notes, counter: {max: 5000, html: true} %>
```

The rule is added to the hint on the server. With JavaScript, `cl-counter` shows a visible count that follows the typing. An `aria-live="polite"` region repeats it after a pause (`delay`, 600ms), so a screen reader isn't interrupted on every key. `html: true` counts the text content of rich text, read from the hidden input Trix writes to. Messages can be replaced with `left:`, `over:` and `needed:`, using `%{count}` for the number. `wrapper: false` drops the counter, because the wrapper holds the controller.
### FileUpload

```erb
<%= ui_form_with model: @document, multipart: true do |f| %>
  <%= f.file_upload :file, accept: %w[.pdf .docx image/*], max_bytes: 25.megabytes,
                    hint: "Documents and images, up to 25 MB.", dropzone: true %>
  <%= f.submit "Upload" %>
<% end %>
```

A native file input, so it works without JavaScript and the server re-checks size and type. With JavaScript (`cl-file-upload`), chosen files appear with their size and a "Remove <filename>" button. Too-large or wrong-type files get a warning tied to the input with `aria-describedby`, and a polite live region announces what changed. A rejected file stays chosen, so the server's error still shows if it's submitted. `max_label:` ("25 MB") is derived from `max_bytes:`. `multiple: true` takes several files. `dropzone: true` adds a drop area; keyboard users still use the button. With `direct_upload: true` on the input, Active Storage's `direct-upload:*` events drive a progress bar. Helper `ui_file_upload`.
### Combobox

```erb
<%= f.combobox :person_id, src: people_search_path, text: @membership.person&.name, force_selection: true %>

<%# people_search: render the frame the request names (the Turbo-Frame header) %>
<turbo-frame id="<%= request.headers["Turbo-Frame"] %>">
  <% @people.each do |person| %>
    <%= ui_combobox_option value: person.id, label: person.name %>
  <% end %>
</turbo-frame>
```

Server-side suggestions (PrimeVue's AutoComplete) on the WAI-ARIA 1.2 combobox pattern: `role=combobox` with `aria-autocomplete`, `aria-expanded`, `aria-controls` and `aria-activedescendant`, and a `listbox` of options. Typing loads `src?q=` into a Turbo Frame after `delay:` (250ms) once `min_length:` (1) is reached. A polite live region says "3 results" or "No results" (`messages:` replaces them). Down and Up move, Enter chooses, Escape closes and a second Escape clears, Alt+Down opens, and Tab chooses nothing. The active option is filled, outlined and checked, so it doesn't rely on colour. `ComboboxOptionComponent::Group.new(label:)` groups options. Without JavaScript the visible input submits its text. Needs Turbo in the host app. Helpers `ui_combobox` and `ui_combobox_option`.

## Interactive components

These lean on the platform instead of re-implementing it, so there is little JavaScript to maintain:

| Component | Built on | Notes |
|---|---|---|
| Accordion | `<details name>` | No JavaScript. `always_open: true` drops the shared name. |
| Carousel | `cl-carousel` | Slides are a slot (`carousel.with_slide`). Controls, indicator dots, captions; `ride:` autoplays, `interval:` per slide, `wrap:`, `crossfade:`. Arrow keys, swipe, pause-on-hover and pause-when-hidden; WAI-ARIA carousel pattern. |
| Scrollspy | `cl-scrollspy` | A nav (items via `spy.with_item(label, href: "#id")`) whose active link follows the section in view via IntersectionObserver. `smooth:` scrolls on click, `offset:` clears a sticky header. |
| Collapse | grid-rows transition | `cl-collapse` toggles attributes; no heights are measured. |
| Dropdown, Popover | popover API (`popover="auto"`) | Browser handles outside click, Escape and focus return; `cl-popover` places it and adds arrow-key navigation for menus. |
| Modal, Offcanvas | `<dialog>` + `showModal()` | Focus trap, inert page and Escape come from the browser. Scrolling inside the panel or over its backdrop doesn't scroll the page behind (not yet in Safari). `static_backdrop: true` ignores backdrop clicks. `close:` takes CloseButton options (`close: {white: true}` on a dark panel). A trigger with `data-cl-dialog-target="trigger"` gets `aria-expanded` kept in step, as the built-in trigger does, along with `aria-controls`. The title is an `<h2>`, or `heading_level:` 1 to 6. `description_id:` sets `aria-describedby`. Offcanvas needs `title:` or `aria: {label:}`, and raises without one. |
| Tabs | WAI-ARIA tabs pattern | `cl-tabs`; tabs and panels pair by position. |
| Toast | `cl-dismiss` + `aria-live` container | Render toasts inside a `ToastContainerComponent`. `delay: 0` keeps one open. The countdown pauses on hover, on focus and while the tab is hidden, then resumes with the time left. `close:` takes options for the close button, which is small by default. |
| Tooltip | popover API (`popover="manual"`) | Wrap something focusable. Shows on hover and keyboard focus. |

Dropdown items with `href:` and a non-GET `method:` render a `button_to` form inside the menu, so they submit with `_method` and the CSRF token while keeping the menu item role and arrow-key navigation: `menu.with_item("Sign out", href: session_path, method: :delete)`. `params:` and `form:` pass through to `button_to`, and `data: {turbo_confirm: "..."}` goes on the button.

Triggers are slots that take Button options: `modal.with_trigger(variant: :danger) { "Delete" }`. Open or close from anywhere inside a component with `data-action="cl-dialog#open"`, `cl-dialog#close`, `cl-collapse#toggle` or `cl-popover#close`.

Floating elements use a small placement helper (`position.js`) that flips and clamps to the viewport. It does not follow scrolling ancestors or draw arrows. It needs a browser with the popover API and `<dialog>` (all current evergreen browsers).

### Styled confirm

`data-turbo-confirm` can open a ModalComponent-style dialog instead of the browser's `confirm()`. Render the dialog once in your layout and hand the library's confirm method to Turbo:

```erb
<%# app/views/layouts/application.html.erb, inside <body> %>
<%= ui_confirm_dialog %>   <%# title: "Are you sure?", accept: "Confirm", cancel: "Cancel", variant: :danger %>
```

```js
// app/javascript/application.js
import { Turbo } from "@hotwired/turbo-rails"
import { useStyledConfirm } from "component_library_2100"
useStyledConfirm(Turbo)
```

`useStyledConfirm` sets `Turbo.config.forms.confirm` (Turbo 8) or calls `Turbo.setConfirmMethod` (older Turbo). To do it by hand, pass `confirmMethod` from the same import to either. The method returns a Promise that resolves `true` on Confirm and `false` on Cancel, Escape or a backdrop click, and falls back to `window.confirm` on a page without the dialog. A form or its submit button can set `data-turbo-confirm-title` and `data-turbo-confirm-accept` to change the title and the confirm button's text. The dialog has `role="alertdialog"` and opens with Cancel focused.

## Extras

These go beyond Bootstrap 5. They follow the same conventions (`class:` merging, HTML attributes on the root, a `ui_*` helper).

### PageHeader

```erb
<%= ui_page_header title: "Projects", subtitle: "Everything your team is working on" do |header| %>
  <% header.with_breadcrumb do %>
    <%= ui_breadcrumb { |c| c.with_item("Home", href: root_path); c.with_item("Projects") } %>
  <% end %>
  <% header.with_badge(variant: :success) { "Live" } %>   <%# BadgeComponent options; repeatable %>
  <% header.with_actions do %>
    <%= ui_button "New project", href: new_project_path %>
  <% end %>
<% end %>
```

Actions sit to the right from the `sm` breakpoint and wrap under the title on narrow screens. `level:` picks the heading tag (default `h1`). Block content renders under the subtitle.

### EmptyState

```erb
<%= ui_empty_state title: "No projects yet", text: "Projects you create appear here." do |empty| %>
  <% empty.with_icon { inline_svg_tag "folder.svg" } %>   <%# decorative; an <svg> is sized to 3rem %>
  <% empty.with_action { ui_button "New project", href: new_project_path } %>
<% end %>
```

`level:` picks the heading tag (default `h2`).

### Avatar

```erb
<%= ui_avatar name: "Ada Lovelace" %>                               <%# "AL", read out as "Ada Lovelace" %>
<%= ui_avatar name: "Ada Lovelace", size: :sm, variant: :primary %>
<%= ui_avatar initials: "AL", label: "Your account" %>
```

Initials come from the first and last words of `name:`. `size:` is `:sm` or `:md` (default); `variant:` is any colour variant (default `:secondary`). It has `role="img"` and the name (or `label:`) as its `aria-label`; with neither, it's hidden from assistive technology.

### Stepper

```erb
<%# A lifecycle: steps before current: are complete, after it upcoming %>
<%= ui_stepper label: "Project status", current: 3 do |stepper| %>
  <% %w[Draft Proposed Approved In\ progress Complete].each { |name| stepper.with_step(name) } %>
<% end %>

<%# Onboarding with links and hints %>
<%= ui_stepper label: "Getting started" do |stepper| %>
  <% stepper.with_step("Account", state: :complete, href: account_path, hint: "Done") %>
  <% stepper.with_step("Team", state: :current, href: team_path) %>
  <% stepper.with_step("Billing", state: :upcoming) %>
<% end %>

<%# Inside a form: each step is a submit button, so the form saves and moves on %>
<%= ui_stepper label: "Plan", current: 2 do |stepper| %>
  <% stepper.with_step("What", name: "step", value: "what") %>
  <% stepper.with_step("When", name: "step", value: "when") %>
  <% stepper.with_step("Who", name: "step", value: "who") %>
<% end %>
```

An `<ol>` named by `label:`. Each step's `state:` is `:complete`, `:current` or `:upcoming`; or give the stepper `current:` (the 1-based number of the current step) and leave `state:` off. The current step has `aria-current="step"`, and complete steps end with visually hidden `complete_text:` ("(completed)" by default; `nil` for none). A step is plain text, a link (`href:`) or a submit button (`name:` and `value:`); other options (`form:`, `disabled:`, `data:` ...) go on that element. `hint:` adds a line under the label, tied to a link or button with `aria-describedby`. Steps stack by default (mobile first) and switch to a row from `breakpoint:`, which is `:sm`, `:md` (default), `:lg`, `:xl` or `:xxl`; `breakpoint: false` always stacks.

### DescriptionList

```erb
<%= ui_description_list do |dl| %>
  <% dl.with_item(term: "Status") { ui_badge "Active", variant: :success } %>
  <% dl.with_item(term: "Email", description: "ada@example.com") %>
<% end %>
```

A `<dl>` of term/description pairs for a record's details (an extra: not in Bootstrap). `layout:` is `:stacked` (default; description under the term) or `:inline` (term and description in columns from the `sm` breakpoint). `dividers:` draws a line between rows (default true). Each item takes `term:` and either a `description:` string or a block for rich content (a badge, a link), plus the usual HTML attributes. Helper `ui_description_list`.

### Skeleton

```erb
<div aria-busy="true">
  <%= ui_skeleton lines: 3 %>
</div>
```

A pulsing placeholder for content that is still loading (an extra: not in Bootstrap). It is decorative, so it is `aria-hidden`; put `aria-busy="true"` on the region it stands in and swap it for the real content when that arrives (for example a lazy Turbo Frame). `shape:` is `:text` (default), `:block` or `:circle`; `lines:` draws that many text rows, the last one shorter. Size it with `class:`. The pulse stops under `prefers-reduced-motion`. Helper `ui_skeleton`.

### Stat and Stats

```erb
<%= ui_stats label: "This month" do |stats| %>
  <% stats.with_stat(label: "Clients", value: "48", hint: "6 new") %>
  <% stats.with_stat(label: "Open invoices", value: "12", change: "3", trend: :down) %>
  <% stats.with_stat(label: "Revenue", value: "$12,400", change: "8%", trend: :up) %>
<% end %>
```

Metrics for a dashboard (extras: not in Bootstrap). A Stat is a `<dl>` card: `label:` is the term, `value:` the headline figure, plus optional `change:` and `hint:`. `trend:` (`:up`, `:down` or `:flat`) adds an arrow and visually hidden "Increased by"/"Decreased by" text; the change is green going up and red going down, so pass `variant:` when down is good (`trend: :down, variant: :success` for falling costs). `card: false` drops the border and padding. Stats is a grid: one column on phones, two from `sm`, and `columns:` (2, 3 or 4; default 3) from `lg`. `label:` makes it a `section` named for screen readers. Helpers `ui_stat` and `ui_stats`.

### SortHeader

```erb
<%= ui_table do %>
  <thead>
    <tr>
      <%= ui_sort_header "Name", href: clients_path(sort: "name", dir: "desc"), direction: :asc %>
      <%= ui_sort_header "Balance", href: clients_path(sort: "balance"), align: :end,
                         link: {data: {turbo_frame: "clients"}} %>
    </tr>
  </thead>
  ...
<% end %>
```

A sortable column heading (an extra: not in Bootstrap): a `<th scope="col">` holding a link. You build `href:`, so it works with any sorting code and with Turbo Frames. `direction:` is the column's current sort: `:asc`, `:desc` or nil. The sorted column gets `aria-sort` and an arrow; the others show a faint icon that darkens on hover and focus. `align: :end` right-aligns numeric columns and shows the icon before the label. `link:` takes options for the `<a>`; other HTML attributes go on the `<th>`. The link answers to 44px on touch screens. Helper `ui_sort_header`.

### Timeline

```erb
<%= ui_timeline label: "Project activity", id: "activity" do |timeline| %>
  <% timeline.with_event(time: update.created_at, title: "Proposal approved", variant: :success) { "Dana signed off." } %>
<% end %>

<%# app/views/updates/create.turbo_stream.erb %>
<%= turbo_stream.prepend "activity" do %>
  <%= ui_timeline_event time: @update.created_at, title: @update.title %>
<% end %>
```

An activity feed (an extra: not in Bootstrap): an `<ol>` of events, each with a `<time datetime>`. Markers are aria-hidden and `variant:` only tints them, so put what happened in the title or text. `alternate: true` alternates sides from `md:` up and stacks on phones. `time_label:` replaces the default date format, and `with_icon` replaces the dot. Each event is a self-contained `<li>`, so `turbo_stream.prepend` or `append` works. No JavaScript. Helpers `ui_timeline` and `ui_timeline_event`.
### Chip

```erb
<%= ui_chip_group label: "Active filters" do |chips| %>
  <% chips.with_chip(label: "Status: open", remove: admin_projects_path(params.permit(:q))) %>
  <% chips.with_chip(label: "Ada", variant: :primary, remove: {href: membership_path(@membership), method: :delete}) %>
<% end %>
```

A value someone chose or filtered by (an extra: not in Bootstrap). Badge is for statuses. `remove:` with a URL renders a link, the server-driven way to clear a filter. With a non-GET `method:` it renders a `button_to` form. The control is named "Remove <label>", which `remove: {label:}` overrides, and answers to 44px on touch screens. Without `remove:` a chip is a static `<span>`. Removing is a server round trip, so redirect back and let the page put focus where it makes sense. Helpers `ui_chip` and `ui_chip_group`.

## Progressive Web App

Everything a host app needs to install to the home screen with the shared 2100 identity: icons, head tags, a service worker and an install banner. The manifest stays in the host app, since its name and colors are the app's own.

**1. Routes and manifest.** Rails 7.2+ ships `rails/pwa`. Uncomment its routes in `config/routes.rb`, then point `app/views/pwa/manifest.json.erb` at the shared icons with `asset_path` (see [`app/assets/images/component_library_2100/pwa/`](app/assets/images/component_library_2100/pwa/README.md)). On Rails 7.1, serve both files from a controller of your own.

**2. Head tags**, in each layout people might install from:

```erb
<%= ui_pwa_meta_tags title: "2100", application_name: "2100 Enterprises", theme_color: "#0B1220" %>
```

They link the manifest (`manifest:`, default `/manifest.json`), set `theme-color`, and add the `apple-*` tags iOS reads instead of the manifest, plus a 180px `apple-touch-icon` (`apple_touch_icon:`, or `false`). `status_bar:` defaults to `"default"`; `"black-translucent"` draws the page under the iOS status bar, so use it only where the top bar pads for `env(safe-area-inset-top)`.

**3. Service worker.** Make `app/views/pwa/service-worker.js.erb` a single line:

```erb
<%= render "component_library_2100/pwa/service_worker", cache_version: "v1", precache: ["/icon.png"] %>
```

Pages are network-first, falling back to `offline_url:` (default `/offline.html`, which you provide, self-contained) when offline. Same-origin static assets are stale-while-revalidate. Bump `cache_version:` to retire the old cache. Paths under `skip:` are never cached; the default, `["/rails/active_storage/"]`, keeps signed-in users' files off the device, so keep it when you pass your own list. `cache_prefix:` (default `"2100-pwa"`) names the cache, and activation only deletes caches with that prefix.

Register it from `application.js`. It waits for the page's `load` event and resolves `null` where service workers aren't available:

```js
import { registerServiceWorker } from "component_library_2100/pwa"
registerServiceWorker()   // or registerServiceWorker("/sw", { scope: "/app/" })
```

`isStandalone()` from the same module is true inside the installed app.

**4. Install banner**, once in the layout's `<body>`:

```erb
<%= ui_pwa_install app_name: "2100 Enterprises" %>
```

It renders hidden. The `cl-pwa-install` controller shows a one-tap Install button where the browser fires `beforeinstallprompt` (Chromium on Android and desktop), and Add to Home Screen guidance on iOS Safari. It never shows in the installed app, and a dismissal is remembered for `dismiss_days:` (default 30). `icon:` defaults to the shared 192px icon (`false` for none); `message:`, `ios_message:` and `install_label:` change the copy, and `close:` takes options for the close button, which reaches 44px only on touch screens unless you size it (`close: {class: "size-4 p-3.5"}`). It dispatches `cl-pwa-install:shown` (`detail.platform` is `"prompt"` or `"ios"`), `:accepted`, `:declined` and `:dismissed` for analytics.

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

It also defines `--radius-ui`, `--radius-ui-sm` and `--radius-ui-lg`, and these neutral greys, set to Bootstrap 5.0's values:

| Token | Default | Used for |
|---|---|---|
| `--color-body` | `#212529` | Text in tables, cards, menus, dialogs, form controls |
| `--color-body-muted` | `#495057` | Active tab text, list group action text |
| `--color-border` | `#dee2e6` | Table rules, tab and modal dividers, pagination, radio cards, upcoming Stepper markers and connectors |
| `--color-border-subtle` | `#e9ecef` | Tab hover borders |
| `--color-border-input` | `#ced4da` | Form control borders |
| `--color-border-translucent` | `rgb(0 0 0 / 0.125)` | Card, list group, accordion, Dropdown menu and divider, Modal, Offcanvas and Popover edges |
| `--color-surface` | `#fff` | Card, menu, dialog, list group, pagination, form control and active tab backgrounds; Toast at 85% |
| `--color-surface-subtle` | `#f8f9fa` | List group action hover |
| `--color-surface-muted` | `#e9ecef` | Menu and pagination hover, disabled controls, progress track |
| `--color-surface-tint` | `rgb(0 0 0 / 0.03)` | Card header and footer |
| `--color-surface-stripe` | `rgb(0 0 0 / 0.05)` | Striped table rows |
| `--color-surface-hover` | `rgb(0 0 0 / 0.075)` | Hovered table rows |
| `--color-backdrop` | `rgb(0 0 0 / 0.5)` | Modal and Offcanvas backdrops |
| `--color-link-hover` | `#0a58ca` | Pagination link hover (primary, darkened) |
| `--color-tooltip`, `--color-tooltip-on` | `rgb(0 0 0 / 0.9)`, `#fff` | Tooltip background and text |
| `--color-toast-border` | `rgb(0 0 0 / 0.1)` | Toast edge |
| `--color-switch` | `rgb(0 0 0 / 0.25)` | Unchecked switch border and knob |
| `--color-popover-header` | `#f0f0f0` | Popover title bar |
| `--color-close` | `#000` | CloseButton icon, unless `white:` |

Override them in your `@theme` to retint every component at once. The translucent ones darken whatever is behind them (in dark mode they lighten it). Not tokens: the CloseButton `white:` icon and the Progress bar's white label and stripes, which are always white on a coloured fill.

Your own `@theme` wins over these, so a token with the same name but another purpose changes the components. A pale `--color-success` meant for borders makes success buttons unreadable. Give those tokens other names.

## Dark mode

Opt-in, and off until you ask for it. Put `data-theme` on `<html>`:

| `data-theme` | Result |
|---|---|
| none | Light, as before |
| `"light"` | Light |
| `"dark"` | Dark |
| `"system"` | Follows the OS (`prefers-color-scheme`) |

In dark mode `engine.css` gives every token above a dark value and sets `color-scheme: dark`, so native controls and scrollbars match. The neutrals, and the subtle, border and emphasis shades, are Bootstrap 5.3's dark values. The solid fills lighten and take dark `-on` text, as in Material 3's dark scheme, so one colour works as a button fill, as link text and as an outline. `light` and `dark` keep their light-mode fills. Every text token passes WCAG AA on `surface` and `surface-subtle`, and the test suite checks it.

Write your own dark values with the same switch, after the import:

```css
:root {
  @variant theme-dark {
    --color-primary: #38bdf8;
    --color-surface: #0f172a;
  }
}
```

`theme-dark:` works on any class too (`theme-dark:hidden`), but prefer a token: it changes every component at once. Your page background isn't a component, so set it yourself, for example `class="bg-surface-subtle text-body"` on `<body>`. Navbar's `theme: :surface` follows the mode; `:light` and `:dark` don't.

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

`bundle exec rake test:system` runs the browser tests in `test/system`, which drive the Stimulus controllers in headless Chrome, so it needs Chrome installed. Each test subclasses `SystemTestCase` (`test/system_test_case.rb`), renders ERB with `render_page`, and can add endpoints with `serve`, for example a URL a Turbo Frame loads. The page loads Turbo, Stimulus and the library through an import map, as a host app does, and a JavaScript error in the console fails the test. `rake test` leaves these out.

`bundle exec rake lookbook` serves a preview of every component with [Lookbook](https://lookbook.build) at http://localhost:4000 (set `PORT` to change it). The previews live in `previews/component_library_2100/`. Each one subclasses `BasePreview`, sets its sidebar group with `@logical_path`, and gets controls from `@param` comments. A preview that needs markup calls `template(:name, **locals)`, which renders `<preview>/<name>.html.erb` beside the class. Use that rather than `render_with_template`, because ViewComponent's own lookup lands in `component_library2100/`. The app lives in `lookbook/config.ru`. It loads Turbo, Stimulus and the library through the same import map as the system tests, turns on styled confirms, compiles `engine.css` with Tailwind and rebuilds it as files change, and answers `/examples/people` for the Combobox previews. The theme menu switches `data-theme` between light and dark. `test/previews_test.rb` renders every preview and fails when a component in `Helpers::NAMES` has none, so add a preview with each new component.

CI runs on every PR: the tests on each supported Ruby and on the oldest gem versions the gemspec allows (`gemfiles/oldest.gemfile`, so keep the two in step), RuboCop, `bundler-audit`, a gem build and a workflow audit. A weekly run repeats this against the latest gems and opens an issue if it fails.

### Merging

Once CI is green, `bin/pr-triage` merges a PR into `development` unless one of these applies. Nothing reaches an app until a person bumps the version.

- **It's sensitive:** it touches `lib/`, `config/`, `app/javascript/`, `.github/`, the gemspec, or another path in `SENSITIVE` in `script/review_policy.rb`. It gets the `needs-human-review` label, and the required **Human review** check stays red until a person adds `human-reviewed`. A new push takes that label off, so review again after pushing. After adding the label, wait for **Human review** to turn green, because GitHub blocks the merge until it does.
- **It's labelled `do-not-auto-merge`:** it stays open, and **Human review** stays red until the label comes off. This includes drafts, which otherwise merge like any other PR.
- **It's from a fork:** it never merges itself.

### Releasing

Add notes to `## Unreleased` in `CHANGELOG.md` as you go. To release, open a PR that changes `VERSION` in `lib/component_library_2100/version.rb`, renames `## Unreleased` to the new version, adds a fresh `## Unreleased` above it, and updates the tag in the install instructions. CI fails the PR if the notes are missing. Merging it runs CI again, then creates the tag and GitHub Release. Tags can't be moved or deleted, so a fix goes out as a new version.

## Roadmap

Carousel.

## License

MIT. See [LICENSE](LICENSE).
