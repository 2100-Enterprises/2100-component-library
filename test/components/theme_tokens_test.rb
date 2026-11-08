require "test_helper"

# The neutral greys come from theme tokens in engine.css, so an app can retint every component.
class ThemeTokensTest < ViewComponent::TestCase
  include ComponentLibrary2100

  ENGINE_CSS = File.read(File.expand_path("../../app/assets/tailwind/component_library_2100/engine.css", __dir__))

  # Bootstrap 5.0's values, so the default rendering doesn't change.
  TOKENS = {
    "body" => "#212529", "body-muted" => "#495057",
    "border" => "#dee2e6", "border-subtle" => "#e9ecef", "border-input" => "#ced4da",
    "border-translucent" => "rgb(0 0 0 / 0.125)",
    "surface-muted" => "#e9ecef", "surface-tint" => "rgb(0 0 0 / 0.03)",
    "surface-stripe" => "rgb(0 0 0 / 0.05)", "surface-hover" => "rgb(0 0 0 / 0.075)",
    "surface" => "#fff", "surface-subtle" => "#f8f9fa", "backdrop" => "rgb(0 0 0 / 0.5)", "link-hover" => "#0a58ca",
    "tooltip" => "rgb(0 0 0 / 0.9)", "tooltip-on" => "#fff", "toast-border" => "rgb(0 0 0 / 0.1)",
    "switch" => "rgb(0 0 0 / 0.25)", "popover-header" => "#f0f0f0", "close" => "#000"
  }.freeze

  # The tokens in the first @theme block, and the declarations inside the theme-dark block.
  LIGHT_TOKENS = ENGINE_CSS[/^@theme \{(.*?)^\}/m, 1].scan(/--color-([a-z-]+):/).flatten
  DARK_BLOCK = ENGINE_CSS[/^    @variant theme-dark \{(.*?)^    \}/m, 1]
  DARK_TOKENS = DARK_BLOCK.scan(/--color-([a-z-]+): ([^;]+);/).to_h

  # Absolute colours, the same in either mode, and on-colours whose light value is already dark.
  UNCHANGED = %w[light dark light-on dark-on warning-on info-on].freeze

  GREYS = /#(212529|495057|dee2e6|e9ecef|ced4da|f8f9fa|f0f0f0|0a58ca)|black\/|bg-white|border-b-white|rgb\(0_0_0/

  def test_engine_css_defines_each_token_with_the_bootstrap_value
    TOKENS.each { |name, value| assert_includes ENGINE_CSS, "--color-#{name}: #{value};" }
  end

  def test_dark_mode_sets_every_token_but_the_absolute_ones
    assert_equal LIGHT_TOKENS.sort - UNCHANGED, DARK_TOKENS.keys.sort
    assert_includes DARK_BLOCK, "color-scheme: dark;"
  end

  def test_dark_mode_is_opt_in_by_data_theme
    assert_match(/@custom-variant theme-dark \{\s*&:where\(\[data-theme="dark"\], \[data-theme="dark"\] \*\)/, ENGINE_CSS)
    assert_match(/@media \(prefers-color-scheme: dark\) \{\s*&:where\(\[data-theme="system"\], \[data-theme="system"\] \*\)/, ENGINE_CSS)
    refute_match(/^\s*@media \(prefers-color-scheme: dark\) \{\s*:root/, ENGINE_CSS)
  end

  # WCAG AA: body text 4.5:1 on each surface, and each fill's text 4.5:1 on that fill, in dark mode.
  def test_dark_mode_text_meets_contrast
    %w[surface surface-subtle].each do |surface|
      %w[body body-muted primary secondary success danger warning info].each do |text|
        assert_operator contrast(DARK_TOKENS[text], DARK_TOKENS[surface]), :>=, 4.5, "#{text} on #{surface}"
      end
    end
    %w[primary secondary success danger].each do |fill|
      assert_operator contrast(DARK_TOKENS["#{fill}-on"], DARK_TOKENS[fill]), :>=, 4.5, "#{fill}-on on #{fill}"
    end
    %w[primary secondary success danger warning info].each do |name|
      assert_operator contrast(DARK_TOKENS["#{name}-emphasis"], DARK_TOKENS["#{name}-subtle"]), :>=, 4.5, "#{name} alert"
    end
  end

  def test_components_no_longer_hard_code_the_tokenised_greys
    sources = Dir[File.expand_path("../../app/{components,form_builders}/**/*.rb", __dir__)]
    offenders = sources.select { |file| File.read(file).match?(GREYS) }.map { |file| File.basename(file) }

    assert_empty offenders
  end

  def test_table_uses_tokens
    render_inline(TableComponent.new(striped: true, hover: true)) { "<tbody><tr><td>1</td></tr></tbody>".html_safe }

    css = page.find("table")["class"]
    %w[text-body [&_:is(th,td)]:border-border [&_tbody_tr:nth-of-type(odd)]:bg-surface-stripe [&_tbody_tr:hover]:bg-surface-hover].each do |token|
      assert_includes css.split, token
    end
  end

  def test_card_uses_tokens
    render_inline(CardComponent.new) do |card|
      card.with_header { "Head" }
      card.with_footer { "Foot" }
      "Body"
    end

    assert_selector "div.border-border-translucent > div.bg-surface-tint.border-b.border-border-translucent", text: "Head"
    assert_selector "div.bg-surface-tint.border-t.border-border-translucent", text: "Foot"
  end

  def test_dropdown_uses_tokens
    render_inline(DropdownComponent.new) do |menu|
      menu.with_trigger { "Menu" }
      menu.with_item("Edit", href: "/edit")
      menu.with_divider
    end

    assert_selector "[role=menu].text-body.border-border-translucent", visible: :all
    assert_selector "a.text-body.hover\\:bg-surface-muted", text: "Edit", visible: :all
    assert_selector "[role=separator].border-border-translucent", visible: :all
  end

  def test_modal_and_tabs_use_tokens
    render_inline(ModalComponent.new(title: "Hi")) { "Body" }
    assert_selector "dialog.text-body.border-border-translucent", visible: :all
    assert_selector "dialog div.border-b.border-border", visible: :all

    render_inline(TabsComponent.new) do |tabs|
      tabs.with_tab(title: "One") { "1" }
    end
    assert_selector "[role=tablist].border-border"
  end

  def test_surfaces_and_overlays_use_tokens
    render_inline(OffcanvasComponent.new(title: "Menu")) { "x" }
    assert_selector "dialog.bg-surface.backdrop\\:bg-backdrop", visible: :all

    render_inline(TooltipComponent.new(text: "Tip")) { "<button>?</button>".html_safe }
    assert_selector "[popover].bg-tooltip.text-tooltip-on", visible: :all

    render_inline(ToastComponent.new) { "Saved" }
    assert_selector ".bg-surface\\/85.border-toast-border"

    render_inline(PopoverComponent.new(title: "Title")) { |popover| popover.with_trigger { "?" } }
    assert_selector ".bg-popover-header", text: "Title", visible: :all
  end

  def test_switch_list_group_and_pagination_use_tokens
    render_inline(SwitchComponent.new(name: "on", label: "On"))
    switch = page.find("input[type=checkbox][role=switch], input[type=checkbox]:not([type=hidden])", match: :first)
    assert_includes switch["class"].split, "border-switch"
    assert_includes switch["class"], "var(--color-switch)"

    render_inline(ListGroupComponent.new) { |list| list.with_item(href: "/a") { "A" } }
    assert_selector "a.bg-surface.hover\\:bg-surface-subtle"

    render_inline(PaginationComponent.new) { |pages| pages.with_item("1", href: "?page=1") }
    assert_selector "a.bg-surface.hover\\:text-link-hover"
  end

  def test_a_caller_class_still_replaces_a_token
    render_inline(CardComponent.new(class: "border-primary")) { "x" }

    assert_selector "div.border-primary:not(.border-border-translucent)"
  end

  private

  def contrast(first, second)
    light, dark = [luminance(first), luminance(second)].sort.reverse
    (light + 0.05) / (dark + 0.05)
  end

  def luminance(hex)
    hex = hex.delete("#")
    hex = hex.chars.map { |c| c * 2 }.join if hex.length == 3
    r, g, b = hex.scan(/../).map { |pair| pair.to_i(16) / 255.0 }.map { |c| (c <= 0.03928) ? c / 12.92 : ((c + 0.055) / 1.055)**2.4 }
    0.2126 * r + 0.7152 * g + 0.0722 * b
  end
end
