require "test_helper"

class BulkSelectTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def helpers_view = vc_test_controller.view_context.extend(ComponentLibrary2100::Helpers)

  def test_the_bar_is_a_hidden_named_region_wired_to_the_controller
    render_inline(BulkActionBarComponent.new(label: "Post actions", noun: "post")) do |bar|
      bar.with_action { "Delete" }
    end

    assert_selector "[role=region][aria-label='Post actions'][hidden][data-cl-bulk-select-target=bar]", visible: :all
    assert_selector "[data-cl-bulk-select-target=count][data-noun=post][data-noun-plural=posts]", visible: :all
    assert_selector "[role=region]", text: "Delete", visible: :all
    assert_selector "button[data-action='cl-bulk-select#clear']", text: "Clear", visible: :all
    assert_selector "[role=status][data-cl-bulk-select-target=status]", visible: :all
  end

  def test_noun_plural_and_position
    render_inline(BulkActionBarComponent.new(noun: "person", noun_plural: "people", position: :top))

    assert_selector "[data-noun-plural=people]", visible: :all
    assert_selector "[role=region].top-4", visible: :all
  end

  def test_an_unknown_position_raises
    assert_raises(ArgumentError) { render_inline(BulkActionBarComponent.new(position: :left)) }
  end

  def test_selection_checkbox
    html = helpers_view.ui_selection_checkbox(label: "Select Ada", value: 7)
    node = Capybara.string(html)

    assert node.has_css?("input[type=checkbox][name='ids[]'][value='7'][aria-label='Select Ada'][data-cl-bulk-select-target=item]")
    assert node.has_css?("input[data-action='change->cl-bulk-select#update'].pointer-coarse\\:size-6")
  end

  def test_selection_checkbox_requires_a_label
    assert_raises(ArgumentError) { helpers_view.ui_selection_checkbox(label: " ", value: 1) }
    assert_raises(ArgumentError) { helpers_view.ui_selection_checkbox(label: nil, value: 1) }
  end

  def test_select_all_checkbox
    node = Capybara.string(helpers_view.ui_select_all_checkbox)

    assert node.has_css?("input[type=checkbox][aria-label='Select all'][data-cl-bulk-select-target=all][data-action='change->cl-bulk-select#toggleAll']")
    assert node.has_no_css?("input[name]")
  end

  def test_extra_options_merge
    node = Capybara.string(helpers_view.ui_selection_checkbox(label: "x", value: 1, id: "a", checked: true, data: {foo: "1"}))

    assert node.has_css?("input#a[checked][data-foo='1'][data-cl-bulk-select-target=item]")
  end

  def test_the_helper_renders_the_bar
    html = helpers_view.ui_bulk_action_bar(label: "Actions") { |bar| bar.with_action { "Go" } }

    assert Capybara.string(html).has_css?("[role=region][aria-label=Actions]", visible: :all)
  end
end
