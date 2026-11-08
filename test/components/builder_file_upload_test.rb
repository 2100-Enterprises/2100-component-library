require "test_helper"
require "active_model"

class BuilderFileUploadTest < ViewComponent::TestCase
  class Document
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :file

    validates :file, presence: {message: "Choose a file to upload"}

    def self.name = "Document"
  end

  def form(document = Document.new, &fields)
    render_in_view_context { ui_form_with(model: document, url: "/documents", multipart: true, &fields) }
  end

  def test_names_the_input_after_the_attribute_and_labels_it
    form { |f| f.file_upload :file, accept: %w[.pdf image/*], max_bytes: 5 * 1024 * 1024 }

    assert_selector "input[type=file][name='document[file]']#document_file[accept='.pdf,image/*']"
    assert_selector "label[for=document_file]", text: "File"
  end

  def test_multiple_appends_brackets_once
    form { |f| f.file_upload :file, multiple: true }

    assert_selector "input[type=file][multiple][name='document[file][]']"
  end

  def test_shows_the_model_error
    document = Document.new.tap(&:validate)
    form(document) { |f| f.file_upload :file }

    assert_selector "input#document_file[aria-invalid=true]"
    assert_text "Choose a file to upload"
  end
end
