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
end
