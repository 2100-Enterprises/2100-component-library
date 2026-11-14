require "system_test_case"

class BulkSelectSystemTest < SystemTestCase
  PAGE = <<~ERB
    <div data-controller="cl-bulk-select">
      <%= ui_bulk_action_bar label: "Post actions", noun: "post", noun_plural: "posts" do |bar| %>
        <% bar.with_action { ui_button "Delete", variant: :danger } %>
      <% end %>
      <%= ui_select_all_checkbox %>
      <turbo-frame id="rows">
        <% %w[A B C].each do |name| %>
          <%= ui_selection_checkbox label: "Select \#{name}", value: name %>
        <% end %>
      </turbo-frame>
    </div>
  ERB

  def bar = find("[role=region]", visible: :all)

  test "the bar shows only while something is selected and counts them" do
    render_page PAGE
    assert_no_selector "[role=region]"

    check "Select A"
    assert_selector "[role=region]", text: "1 post selected"
    check "Select B"
    assert_selector "[role=region]", text: "2 posts selected"
    assert_selector "[role=status]", text: "2 posts selected", visible: :all
    assert_equal "2", find("[data-controller~=cl-bulk-select]")["data-cl-bulk-select-count-value"]
  end

  test "select all is indeterminate for some and checks every row" do
    render_page PAGE
    check "Select A"
    assert page.evaluate_script("document.querySelector('[data-cl-bulk-select-target=all]').indeterminate")

    check "Select all"
    assert_selector "[role=region]", text: "3 posts selected"
    assert has_checked_field?("Select C")
    refute page.evaluate_script("document.querySelector('[data-cl-bulk-select-target=all]').indeterminate")
  end

  test "clear unchecks everything and hides the bar" do
    render_page PAGE
    check "Select all"
    click_on "Clear"

    assert_no_selector "[role=region]"
    assert has_unchecked_field?("Select A")
    assert has_unchecked_field?("Select all")
  end

  test "rows added after connect are counted" do
    render_page PAGE
    check "Select A"
    page.execute_script(<<~JS)
      const box = document.querySelector("[data-cl-bulk-select-target=item]").cloneNode()
      box.setAttribute("aria-label", "Select D")
      box.checked = true
      document.getElementById("rows").append(box)
    JS

    assert_selector "[role=region]", text: "2 posts selected"
  end
end
