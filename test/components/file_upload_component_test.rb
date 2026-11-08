require "test_helper"

class FileUploadComponentTest < ViewComponent::TestCase
  include ComponentLibrary2100

  def test_renders_a_file_input_with_a_name
    render_inline(FileUploadComponent.new(name: "doc[file]", id: "f"))

    assert_selector "input[type=file][name='doc[file]']#f"
    assert_no_selector "input[multiple]"
  end

  def test_generates_an_id_when_none_given
    render_inline(FileUploadComponent.new(name: "x"))

    assert_selector "input[type=file][id^='file-upload-']"
  end

  def test_label_points_at_the_input
    render_inline(FileUploadComponent.new(id: "f", label: "Add a file"))

    assert_selector "label[for=f]", text: "Add a file"
  end

  def test_hint_and_error_are_wired_with_aria
    render_inline(FileUploadComponent.new(id: "f", hint: "Up to 5 MB", error: "Choose a file"))

    assert_selector "input[aria-invalid=true][aria-describedby='f-error f-hint']"
    assert_selector "#f-hint", text: "Up to 5 MB"
    assert_selector "#f-error", text: "Choose a file"
  end

  def test_no_description_without_hint_or_error
    render_inline(FileUploadComponent.new(id: "f"))

    assert_no_selector "input[aria-describedby]"
    assert_no_selector "input[aria-invalid]"
  end

  def test_accept_array_is_joined_with_commas_and_no_spaces
    render_inline(FileUploadComponent.new(accept: [".pdf", ".docx", "image/*"]))

    assert_selector "input[accept='.pdf,.docx,image/*']"
  end

  def test_accept_string_is_normalised
    render_inline(FileUploadComponent.new(accept: ".pdf, .png  .jpg"))

    assert_selector "input[accept='.pdf,.png,.jpg']"
  end

  def test_max_label_is_derived_from_max_bytes
    render_inline(FileUploadComponent.new(max_bytes: 5.megabytes))

    assert_selector "[data-cl-file-upload-max-bytes-value='5242880'][data-cl-file-upload-max-label-value='5 MB']"
  end

  def test_derived_max_label_uses_one_decimal
    render_inline(FileUploadComponent.new(max_bytes: 1536 * 1024))

    assert_selector "[data-cl-file-upload-max-label-value='1.5 MB']"
  end

  def test_given_max_label_wins
    render_inline(FileUploadComponent.new(max_bytes: 100, max_label: "a hundred bytes"))

    assert_selector "[data-cl-file-upload-max-label-value='a hundred bytes']"
  end

  def test_required
    render_inline(FileUploadComponent.new(required: true))

    assert_selector "input[type=file][required]"
  end

  def test_multiple_sets_the_attribute_and_an_array_name
    render_inline(FileUploadComponent.new(name: "doc[files]", multiple: true))

    assert_selector "input[type=file][multiple][name='doc[files][]']"
  end

  def test_has_a_polite_live_region_and_a_hidden_staged_list
    render_inline(FileUploadComponent.new)

    assert_selector "p[role=status].sr-only", visible: :all
    assert_selector "ul[hidden]", visible: :all
  end

  def test_no_dropzone_by_default
    render_inline(FileUploadComponent.new)

    assert_no_selector "[data-cl-file-upload-target=zone]"
  end

  def test_dropzone_wraps_the_input_and_is_not_focusable
    render_inline(FileUploadComponent.new(dropzone: true, id: "f"))

    assert_selector "[data-cl-file-upload-target=zone] input[type=file]#f"
    assert_no_selector "[data-cl-file-upload-target=zone][tabindex]"
    assert_text "Or drop a file here."
  end

  def test_dropzone_text_is_plural_for_multiple
    render_inline(FileUploadComponent.new(dropzone: true, multiple: true))

    assert_text "Or drop files here."
  end

  def test_progress_bar_is_hidden_until_a_direct_upload_runs
    render_inline(FileUploadComponent.new(data: {direct_upload_url: "/uploads"}))

    assert_selector "[data-cl-file-upload-target=progress][hidden] [role=progressbar][aria-valuenow='0']", visible: :all
    assert_selector "input[data-direct-upload-url='/uploads']"
  end

  def test_html_attributes_go_on_the_input
    render_inline(FileUploadComponent.new(class: "w-64", data: {test: "x"}))

    assert_selector "input.w-64[data-test=x]"
  end
end
