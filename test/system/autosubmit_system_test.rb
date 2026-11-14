require "system_test_case"

class AutosubmitSystemTest < SystemTestCase
  def page_with(delay: nil)
    value = delay ? %( data-cl-autosubmit-delay-value="#{delay}") : ""
    render_page <<~ERB
      <form action="/save" method="get" data-turbo="false">
        <input type="search" name="q" aria-label="Search" data-controller="cl-autosubmit" data-action="input->cl-autosubmit#submit"#{value}>
        <button type="submit">Go</button>
      </form>
    ERB
    serve("/save") { |request| render_html("<p>saved: #{Rack::Utils.escape_html(request.params["q"])}</p>") }
  end

  test "without a delay it submits on every input" do
    page_with
    fill_in "Search", with: "a"
    assert_text "saved: a"
  end

  test "a delay waits for typing to pause and submits once" do
    page_with(delay: 300)
    field = find_field("Search")
    "abc".each_char { |c| field.send_keys(c) }
    assert_text "saved: abc"
  end

  test "submitting the form another way cancels the pending submit" do
    page_with(delay: 500)
    find_field("Search").send_keys("x")
    click_on "Go"
    assert_text "saved: x"
    assert_current_path(/q=x/)
  end
end
