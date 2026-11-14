require "system_test_case"

class ComboboxSystemTest < SystemTestCase
  PEOPLE = {
    "1" => "Alan Turing", "2" => "Alice Liddell", "3" => "Ada Lovelace", "4" => "Grace Hopper", "5" => "Alonzo Church"
  }.freeze

  setup do
    serve("/people") do |request|
      query = request.params["q"].to_s.downcase
      matches = PEOPLE.select { |_, name| name.downcase.include?(query) }
      render_html(<<~ERB, matches: matches)
        <turbo-frame id="people">
          <% matches.each do |id, name| %>
            <%= render ComponentLibrary2100::ComboboxOptionComponent.new(value: id, label: name) %>
          <% end %>
        </turbo-frame>
      ERB
    end
  end

  def render_combobox(options = "")
    render_page <<~ERB
      <label for="person">Person</label>
      <%= ui_combobox(name: "person_id", src: "/people", frame_id: "people", input: {id: "person"}, delay: 20 #{options}) %>
      <button type="button">Elsewhere</button>
    ERB
    assert_selector "[data-controller=cl-combobox]"
  end

  def input = find_field("Person")
  def hidden = find("input[type=hidden]", visible: :all)

  def type_query(text)
    input.send_keys(text)
    assert_selector "[role=option]"
  end

  test "typing loads options and announces the count" do
    render_combobox
    input.send_keys("al")

    assert_selector "[role=listbox] [role=option]", count: 3
    assert_selector "[role=status]", text: "3 results", visible: :all
    assert_equal "true", input["aria-expanded"]
  end

  test "no matches announces No results and stays closed" do
    render_combobox
    input.send_keys("zzz")

    assert_selector "[role=status]", text: "No results", visible: :all
    assert_equal "false", input["aria-expanded"]
  end

  test "Down and Up move the active option" do
    render_combobox
    type_query("al")
    options = all("[role=option]").map { |option| option[:id] }

    input.send_keys(:down)
    assert_equal options[0], input["aria-activedescendant"]
    assert_selector "##{options[0]}[aria-selected=true]"
    input.send_keys(:down)
    assert_equal options[1], input["aria-activedescendant"]
    assert_selector "##{options[0]}[aria-selected=false]"
    input.send_keys(:up)
    assert_equal options[0], input["aria-activedescendant"]
  end

  test "Enter fills the hidden and visible inputs" do
    render_combobox
    type_query("grace")
    input.send_keys(:down, :enter)

    assert_equal "Grace Hopper", input.value
    assert_equal "4", hidden.value
    assert_equal "person_id", hidden[:name]
    assert_no_selector "[role=listbox]"
  end

  test "Escape closes the list and a second Escape clears the input" do
    render_combobox
    type_query("al")

    input.send_keys(:escape)
    assert_no_selector "[role=listbox]"
    assert_equal "al", input.value

    input.send_keys(:escape)
    assert_equal "", input.value
  end

  test "force selection clears unmatched text on blur" do
    render_combobox(", force_selection: true")
    type_query("al")
    find("button", text: "Elsewhere").click

    assert_equal "", input.value
    assert_equal "", hidden.value
  end

  test "force selection keeps a chosen option on blur" do
    render_combobox(", force_selection: true")
    type_query("ada")
    input.send_keys(:down, :enter)
    find("button", text: "Elsewhere").click

    assert_equal "Ada Lovelace", input.value
    assert_equal "3", hidden.value
  end

  test "free text is the value without force selection" do
    render_combobox
    input.send_keys("zzz")
    find("button", text: "Elsewhere").click

    assert_equal "zzz", input.value
    assert_equal "zzz", hidden.value
  end

  test "clicking an option selects it" do
    render_combobox
    type_query("ali")
    find("[role=option]", text: "Alice Liddell").click

    assert_equal "Alice Liddell", input.value
    assert_equal "2", hidden.value
  end
end

class ComboboxMultipleSystemTest < SystemTestCase
  PEOPLE = ComboboxSystemTest::PEOPLE

  setup do
    serve("/people") do |request|
      query = request.params["q"].to_s.downcase
      matches = PEOPLE.select { |_, name| name.downcase.include?(query) }
      render_html(<<~ERB, matches: matches)
        <turbo-frame id="people">
          <% matches.each do |id, name| %>
            <%= render ComponentLibrary2100::ComboboxOptionComponent.new(value: id, label: name) %>
          <% end %>
        </turbo-frame>
      ERB
    end
  end

  def render_tags(options = "")
    render_page <<~ERB
      <label for="tags">Collaborators</label>
      <%= ui_combobox(name: "post[collaborators][]", multiple: true, label: "Collaborators", src: "/people", frame_id: "people",
            input: {id: "tags"}, delay: 20 #{options}) %>
      <button type="button">Elsewhere</button>
    ERB
    assert_selector "[data-controller=cl-combobox]"
  end

  def input = find_field("Collaborators")
  def values = all("input[type=hidden]", visible: :all).map(&:value)
  def chips = all("[data-cl-combobox-target=chips] [data-value]").map { |chip| chip[:"data-value"] }

  test "typing and Enter adds free text as a chip" do
    render_tags(", allow_free_text: true")
    input.send_keys("zed", :enter)

    assert_equal %w[zed], chips
    assert_equal ["", "zed"], values
    assert_equal "", input.value
    assert_selector "[role=status]", text: "zed added", visible: :all
  end

  test "a comma adds free text as a chip" do
    render_tags(", allow_free_text: true")
    input.send_keys("zed,")

    assert_equal %w[zed], chips
    assert_equal "", input.value
  end

  test "free text is not added without allow_free_text" do
    render_tags
    input.send_keys("zed", :enter)

    assert_empty chips
  end

  test "choosing a suggestion adds it and it is not suggested again" do
    render_tags
    input.send_keys("al")
    assert_selector "[role=option]", count: 3
    input.send_keys(:down, :down, :enter)

    assert_equal %w[2], chips
    assert_equal ["", "2"], values
    assert_selector "[data-cl-combobox-target=chips] [aria-label='Remove Alice Liddell']"

    input.send_keys("al")
    assert_selector "[role=option]", text: "Alonzo Church"
    assert_selector "[role=option]", count: 2
    assert_no_selector "[role=option]", text: "Alice Liddell"
  end

  test "clicking a suggestion adds it" do
    render_tags
    input.send_keys("grace")
    find("[role=option]", text: "Grace Hopper").click

    assert_equal %w[4], chips
  end

  test "the remove button removes the chip and returns focus to the input" do
    render_tags(", allow_free_text: true")
    input.send_keys("one,", "two,")
    find("button[aria-label='Remove one']").click

    assert_equal %w[two], chips
    assert_equal ["", "two"], values
    assert_equal "tags", page.evaluate_script("document.activeElement.id")
    assert_selector "[role=status]", text: "one removed", visible: :all
  end

  test "Backspace on an empty input removes the last chip" do
    render_tags(", allow_free_text: true")
    input.send_keys("one,", "two,")
    input.send_keys(:backspace)

    assert_equal %w[one], chips
    input.send_keys("x", :backspace)
    assert_equal %w[one], chips
  end

  test "reaching max hides the input and announces it, removing restores it" do
    render_tags(", allow_free_text: true, max: 2")
    input.send_keys("one,", "two,")

    assert_selector "#tags", visible: :hidden
    assert_selector "[data-cl-combobox-target=limit]", text: "Maximum of 2 reached", visible: :all
    find("button[aria-label='Remove two']").click

    assert_selector "#tags"
    assert_selector "[data-cl-combobox-target=limit]", text: "", visible: :all
  end

  test "initial values render as chips and clearing every chip leaves the empty field" do
    render_page <<~ERB
      <%= ui_combobox(name: "tags", multiple: true, values: %w[a b], label: "Tags", src: nil, input: {id: "tags"}) %>
    ERB
    assert_selector "[data-controller=cl-combobox]"
    assert_equal %w[a b], chips

    find("button[aria-label='Remove a']").click
    find("button[aria-label='Remove b']").click
    assert_equal [""], values
  end

  test "static options filter in the browser" do
    render_page <<~ERB
      <%= ui_combobox(name: "tags", multiple: true, options: %w[ruby rails rust], label: "Tags", src: nil, input: {id: "tags"}) %>
    ERB
    assert_selector "[data-controller=cl-combobox]"
    find("#tags").send_keys("ru")

    assert_selector "[role=option]", count: 2
    find("#tags").send_keys(:down, :enter)
    assert_equal %w[ruby], chips
  end
end
