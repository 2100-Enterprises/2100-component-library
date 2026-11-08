require "system_test_case"
require "tmpdir"

class FileUploadSystemTest < SystemTestCase
  setup { @dir = Dir.mktmpdir }
  teardown { FileUtils.remove_entry(@dir) }

  def file(name, bytes)
    File.join(@dir, name).tap { |path| File.binwrite(path, "x" * bytes) }
  end

  def page_with(options = "")
    render_page(%(<%= ui_file_upload(id: "doc", label: "Document", #{options}) %>))
    assert_selector "[data-enhanced]"
  end

  test "choosing a file shows its name and size, and Remove clears it" do
    page_with
    attach_file "Document", file("plan.pdf", 2048)

    within("ul") do
      assert_text "plan.pdf"
      assert_text "2.0 KB"
    end
    assert_selector "[role=status]", text: "plan.pdf is ready to upload.", visible: :all

    click_on "Remove plan.pdf"
    assert_no_selector "ul li"
    assert_equal "", find("#doc").value
    assert_selector "[role=status]", text: "Removed plan.pdf. No file chosen.", visible: :all
  end

  test "an oversized file shows a warning tied to the input and stays chosen" do
    page_with "max_bytes: 1024"
    attach_file "Document", file("big.pdf", 4096)

    assert_text "This file is larger than 1 KB."
    assert_selector "#doc[aria-describedby~='doc-warning-0']"
    assert_selector "[role=status]", text: "big.pdf: This file is larger than 1 KB.", visible: :all
    assert_selector "li", text: "big.pdf"
  end

  test "a wrong-type file shows a warning" do
    page_with %(accept: ".pdf")
    attach_file "Document", file("notes.exe", 10)

    assert_text "This kind of file can't be uploaded."
  end

  test "an accepted file shows no warning" do
    page_with %(accept: [".pdf", "image/*"])
    attach_file "Document", file("plan.pdf", 10)

    assert_text "plan.pdf"
    assert_no_text "can't be uploaded"
  end

  test "multiple lists each file and Remove takes out just one" do
    page_with "multiple: true"
    attach_file "Document", [file("a.txt", 5), file("b.txt", 1_572_864)]

    assert_selector "li", count: 2
    assert_text "1.5 MB"
    assert_selector "[role=status]", text: "2 files ready to upload", visible: :all

    click_on "Remove a.txt"
    assert_selector "li", count: 1
    assert_no_selector "li", text: "a.txt"
    assert_selector "li", text: "b.txt"
    assert_equal 1, page.evaluate_script("document.getElementById('doc').files.length")
    assert_equal "b.txt", page.evaluate_script("document.getElementById('doc').files[0].name")
  end

  test "dropping a file on the dropzone fills the input" do
    page_with "dropzone: true"
    page.execute_script(<<~JS)
      const transfer = new DataTransfer()
      transfer.items.add(new File(["hello"], "dropped.txt", { type: "text/plain" }))
      const zone = document.querySelector("[data-cl-file-upload-target=zone]")
      zone.dispatchEvent(new DragEvent("dragover", { dataTransfer: transfer, bubbles: true, cancelable: true }))
      window.highlighted = zone.hasAttribute("data-dragging")
      zone.dispatchEvent(new DragEvent("drop", { dataTransfer: transfer, bubbles: true, cancelable: true }))
    JS

    assert_selector "li", text: "dropped.txt"
    assert page.evaluate_script("window.highlighted")
    assert_no_selector "[data-dragging]"
    assert_equal "dropped.txt", page.evaluate_script("document.getElementById('doc').files[0].name")
  end

  test "direct upload events drive the progress bar" do
    page_with %(data: {direct_upload_url: "/uploads"})
    page.execute_script(<<~JS)
      const input = document.getElementById("doc")
      const fire = (name, detail) => input.dispatchEvent(new CustomEvent(`direct-upload:${name}`, { bubbles: true, detail }))
      fire("initialize", { id: 1, file: { name: "a" } })
      fire("progress", { id: 1, progress: 40 })
    JS

    assert_selector "[role=progressbar][aria-valuenow='40']"
  end
end
