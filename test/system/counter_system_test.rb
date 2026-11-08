require "system_test_case"

class CounterSystemTest < SystemTestCase
  def page_with(counter, control: nil)
    render_page <<~ERB
      <%= render ComponentLibrary2100::FormFieldComponent.new(control_id: "f", label: "Field", counter: #{counter}) do |field| %>
        #{control || '<textarea name="f" <%= tag.attributes(**field.control_options) %>></textarea>'}
      <% end %>
    ERB
    assert_selector "[data-controller~=cl-counter]"
    assert_selector "[data-cl-counter-target=count]", text: /\S/
  end

  def status = find("[role=status]", visible: :all)

  test "typing updates the visible count at once and the live region after a pause" do
    page_with("{max: 10}")
    assert_text "10 characters left"
    assert_equal "", status.text(:all)

    find("textarea").send_keys("abc")
    assert_selector "[data-cl-counter-target=count]", text: "7 characters left"
    assert_equal "", status.text(:all)
    assert_selector "[role=status]", text: "7 characters left", visible: :all, wait: 3
  end

  test "the live region does not follow every keystroke" do
    page_with("{max: 100}")
    field = find("textarea")
    "abcde".each_char { |c| field.send_keys(c) }

    assert_selector "[data-cl-counter-target=count]", text: "95 characters left"
    assert_equal "", status.text(:all)
    assert_selector "[role=status]", text: "95 characters left", visible: :all, wait: 3
  end

  test "max reports characters over" do
    page_with("{max: 3}")
    find("textarea").send_keys("abcde")

    assert_selector "[data-cl-counter-target=count]", text: "2 characters over"
    assert_no_selector "textarea[aria-invalid]"
  end

  test "min counts down to zero then clears" do
    page_with("{min: 4}")
    assert_text "4 more characters needed"

    find("textarea").send_keys("abc")
    assert_selector "[data-cl-counter-target=count]", text: "1 more character needed"

    find("textarea").send_keys("d")
    assert_no_text "needed"
    assert_equal "", find("[data-cl-counter-target=count]", visible: :all).text(:all)
  end

  test "custom messages" do
    page_with("{max: 10, left: '%{count} to go'}")
    find("textarea").send_keys("ab")
    assert_selector "[data-cl-counter-target=count]", text: "8 to go"
  end

  test "rich text counts the text of the hidden input" do
    page_with("{max: 20, html: true}", control: <<~HTML)
      <input type="hidden" id="body" name="body" value="">
      <div tabindex="0" id="editor" input="body" data-cl-counter-target="input">editor</div>
    HTML
    assert_text "20 characters left"

    page.execute_script(<<~JS)
      const hidden = document.getElementById("body")
      hidden.value = "<div><strong>Hello</strong> there</div>"
      document.getElementById("editor").dispatchEvent(new Event("input", { bubbles: true }))
    JS

    assert_selector "[data-cl-counter-target=count]", text: "9 characters left"
  end

  test "rich text counts an entity as one character and ignores edge whitespace" do
    page_with("{max: 20, html: true}", control: <<~HTML)
      <input type="hidden" id="body" name="body" value="">
      <div tabindex="0" id="editor" input="body" data-cl-counter-target="input">editor</div>
    HTML

    page.execute_script(<<~JS)
      const hidden = document.getElementById("body")
      hidden.value = "<div>&nbsp;Tom &amp; <em>Jerry</em>&nbsp;</div>"
      document.getElementById("editor").dispatchEvent(new Event("input", { bubbles: true }))
    JS

    assert_selector "[data-cl-counter-target=count]", text: "9 characters left"
  end
end
