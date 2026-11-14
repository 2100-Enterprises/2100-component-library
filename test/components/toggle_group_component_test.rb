require "test_helper"
require "active_model"

class ToggleGroupComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def group(**opts, &block)
    block ||= proc { |g|
      g.with_option("Instagram", value: "instagram", checked: true)
      g.with_option("TikTok", value: "tiktok", disabled: true)
    }
    render_inline(ToggleGroupComponent.new(name: "platforms", label: "Platforms", **opts), &block)
  end

  def test_checkbox_names_get_brackets
    group

    assert_selector "fieldset legend", text: "Platforms"
    assert_selector "label input.peer.sr-only[type=checkbox][name='platforms[]'][value=instagram]"
  end

  def test_radio_keeps_the_name
    group(type: :radio)

    assert_selector "input[type=radio][name=platforms]", count: 2
  end

  def test_checked_and_disabled
    group

    assert_selector "input[value=instagram][checked]"
    assert_no_selector "input[value=tiktok][checked]"
    assert_selector "input[value=tiktok][disabled]"
  end

  def test_variant_and_segmented_style
    group(style: :segmented, variant: :success)

    assert_selector "span.peer-checked\\:bg-success", count: 2
    assert_selector "span.rounded-s-ui", count: 1
    assert_selector "span.rounded-e-ui", count: 1
  end

  def test_option_variant_overrides_group
    group { |g| g.with_option("A", value: "a", variant: :danger) }

    assert_selector "span.peer-checked\\:bg-danger"
  end

  def test_icon_only_requires_a_label
    assert_raises(ArgumentError) do
      group { |g| g.with_option(value: "grid", icon_only: true) { "x" } }
    end
  end

  def test_icon_only_renders_a_hidden_name
    group { |g| g.with_option(value: "grid", icon_only: true, label: "Grid view") { "ICON" } }

    assert_selector "label span.sr-only", text: "Grid view"
    assert_text "ICON"
  end

  def test_autosubmit_data_attributes
    group(autosubmit: true)

    assert_selector "input[data-controller='cl-autosubmit'][data-action='change->cl-autosubmit#submit']", count: 2
  end

  def test_no_autosubmit_by_default
    group

    assert_no_selector "input[data-controller]"
  end

  def test_legend_visible_or_hidden
    group
    assert_no_selector "legend.sr-only"

    group(legend_visible: false)
    assert_selector "legend.sr-only", text: "Platforms"
  end

  def test_choices_and_checked
    render_inline(ToggleGroupComponent.new(name: "p", label: "P", choices: [["A", "a"], ["B", "b"]], checked: %w[b], hidden: true))

    assert_selector "input[type=hidden][name='p[]'][value='']", visible: :all
    assert_selector "input[value=b][checked]"
    assert_no_selector "input[value=a][checked]"
  end

  def test_unknown_type_raises
    assert_raises(ArgumentError) { ToggleGroupComponent.new(name: "x", label: "X", type: :switch) }
  end

  def test_helper_is_registered
    assert_includes ComponentLibrary2100::Helpers::NAMES, "toggle_group"
  end

  class Post
    include ActiveModel::Model
    include ActiveModel::Attributes
    attribute :platforms
    def self.name = "Post"
  end

  def test_form_builder_toggle_group
    post = Post.new(platforms: %w[tiktok])
    render_in_view_context do
      ui_form_with(model: post, url: "/posts") { |f| f.toggle_group :platforms, [["Instagram", "instagram"], ["TikTok", "tiktok"]], label: "Platforms" }
    end

    assert_selector "input[type=checkbox][name='post[platforms][]'][value=tiktok][checked]"
    assert_selector "input[type=hidden][name='post[platforms][]']", visible: :all
    assert_selector "legend", text: "Platforms"
  end
end
