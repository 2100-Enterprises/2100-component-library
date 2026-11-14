require "test_helper"

class ComboboxComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def combobox(**options)
    render_inline(ComboboxComponent.new(name: "person_id", src: "/people", frame_id: "people", **options))
  end

  def test_input_is_a_combobox_wired_to_its_listbox
    combobox(input: {id: "person", aria: {label: "Person"}})

    assert_selector "input#person[type=text][name=person_id][role=combobox][autocomplete=off][aria-label=Person]" \
                    "[aria-autocomplete=list][aria-haspopup=listbox][aria-expanded=false]"
    listbox_id = page.find("input#person")["aria-controls"]
    assert_selector "[role=listbox]##{listbox_id}[hidden][aria-busy=false]", visible: :all
  end

  def test_no_active_descendant_until_the_controller_sets_one
    combobox

    assert_no_selector "input[aria-activedescendant]"
  end

  def test_listbox_holds_the_turbo_frame_options_load_into
    combobox

    assert_selector "[role=listbox] turbo-frame#people", visible: :all
  end

  def test_hidden_input_holds_the_value_and_the_visible_input_the_text
    combobox(value: "7", text: "Ada Lovelace")

    assert_selector "input[type=hidden][value='7']:not([name])", visible: :all
    assert_selector "input[role=combobox][value='Ada Lovelace']"
  end

  def test_text_defaults_to_the_value
    combobox(value: "Ada")

    assert_selector "input[role=combobox][value=Ada]"
  end

  def test_polite_live_region
    combobox

    assert_selector "[role=status][aria-live=polite]", visible: :all
  end

  def test_invalid_sets_aria_invalid
    combobox(invalid: true)

    assert_selector "input[role=combobox][aria-invalid=true]"
  end

  def test_input_options_are_merged
    combobox(input: {placeholder: "Search", class: "w-64", aria: {describedby: "hint"}})

    assert_selector "input[role=combobox][placeholder=Search][aria-describedby=hint][aria-haspopup=listbox].w-64"
  end

  def test_configuration_reaches_the_controller
    combobox(min_length: 2, delay: 100, force_selection: true, class: "mb-3")

    assert_selector "div.mb-3[data-controller=cl-combobox][data-cl-combobox-src-value='/people']" \
                    "[data-cl-combobox-min-length-value='2'][data-cl-combobox-delay-value='100'][data-cl-combobox-force-selection-value='true']"
  end

  def test_option_has_role_id_and_data
    render_inline(ComboboxOptionComponent.new(value: 7, label: "Ada Lovelace"))

    assert_selector "div[role=option][id][aria-selected=false][data-value='7'][data-label='Ada Lovelace']", text: "Ada Lovelace"
  end

  def test_option_label_defaults_to_the_value_and_a_block_replaces_the_content
    render_inline(ComboboxOptionComponent.new(value: "Ada")) { "<b>Ada</b>".html_safe }

    assert_selector "[role=option][data-label=Ada] b", text: "Ada"
  end

  def test_disabled_option
    render_inline(ComboboxOptionComponent.new(value: 1, disabled: true))

    assert_selector "[role=option][aria-disabled=true]"
  end

  def test_group_is_labelled_by_its_heading
    render_inline(ComboboxOptionComponent::Group.new(label: "Engineering")) { "<div role='option'>Ada</div>".html_safe }

    heading_id = page.find("[role=group]")["aria-labelledby"]
    assert_selector "##{heading_id}", text: "Engineering"
    assert_selector "[role=group] [role=option]", text: "Ada"
  end

  def tags(**options)
    combobox(name: "post[tags]", src: nil, multiple: true, label: "Collaborators", values: %w[ada grace], **options)
  end

  def test_multiple_submits_one_hidden_input_per_value_after_an_empty_one
    tags

    names = page.all("input[type=hidden]", visible: :all).map { |field| [field[:name], field[:value]] }
    assert_equal [["post[tags][]", ""], ["post[tags][]", "ada"], ["post[tags][]", "grace"]], names
    assert_selector "input[role=combobox]:not([name])"
  end

  def test_multiple_renders_values_as_chips_with_named_remove_buttons
    tags

    assert_selector "[role=group][aria-label=Collaborators] span[data-value=ada]", text: "ada"
    assert_selector "button[type=button][aria-label='Remove ada']"
    assert_selector "button[aria-label='Remove grace']"
    assert_selector "[role=group] a", count: 0
  end

  def test_multiple_names_the_input_after_the_label_unless_the_input_is_named
    tags
    assert_selector "input[role=combobox][aria-label=Collaborators]"

    tags(input: {aria: {label: "Add a tag"}})
    assert_selector "input[role=combobox][aria-label='Add a tag']"
  end

  def test_multiple_keeps_the_combobox_wiring
    tags(input: {id: "tags"})

    assert_selector "input#tags[role=combobox][aria-autocomplete=list][aria-haspopup=listbox][aria-expanded=false]"
    assert_selector "[role=listbox]", visible: :all
    assert_selector "[data-controller=cl-combobox][data-cl-combobox-multiple-value=true]"
  end

  def test_multiple_passes_max_and_free_text_to_the_controller
    tags(max: 3, allow_free_text: true)

    assert_selector "[data-cl-combobox-max-value='3'][data-cl-combobox-allow-free-text-value=true]"
    assert_selector "[role=status]", count: 2, visible: :all
    assert_selector "input[role=combobox]:not([hidden])"
  end

  def test_multiple_hides_the_input_once_max_is_reached
    tags(max: 2)

    assert_selector "input[role=combobox][hidden]", visible: :all
  end

  def test_multiple_ships_a_chip_template_for_the_controller
    tags

    assert_selector "template[data-cl-combobox-target=template]", visible: :all
    assert_match(/<template[^>]*>.*<button[^>]*aria-label="Remove "/m, rendered_content)
  end

  def test_multiple_keeps_an_existing_array_suffix
    combobox(name: "tags[]", src: nil, multiple: true)

    assert_selector "input[type=hidden][name='tags[]']", visible: :all, count: 1
  end

  def test_static_options_render_inside_the_frame
    combobox(src: nil, options: ["Ada", ["Grace Hopper", "g"]], multiple: true)

    assert_selector "turbo-frame [role=option][data-value=Ada]", visible: :all
    assert_selector "turbo-frame [role=option][data-value=g][data-label='Grace Hopper']", visible: :all
  end

  def test_single_mode_has_no_chip_markup
    combobox

    assert_no_selector "[role=group]"
    assert_no_selector "template", visible: :all
  end
end
