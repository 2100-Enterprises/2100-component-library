require "test_helper"
require "active_model"

# The builder passes `counter:` through to FormFieldComponent.
class BuilderCounterTest < ViewComponent::TestCase
  class Note
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :body, :string
    attribute :password, :string

    def self.name = "Note"
  end

  def form(&fields)
    render_in_view_context { ui_form_with(model: Note.new, url: "/notes", &fields) }
  end

  def test_text_area_takes_a_counter
    form { |f| f.text_area :body, counter: {max: 2000} }

    assert_selector "div[data-controller~=cl-counter] textarea#note_body[data-cl-counter-target=input]"
    assert_selector "#note_body-hint", text: "Up to 2,000 characters."
  end

  def test_password_field_keeps_its_toggle_and_takes_a_counter
    form { |f| f.password_field :password, counter: {min: 12} }

    assert_selector "input#note_password[type=password][data-cl-counter-target=input]"
    assert_selector "[data-controller~=cl-password]"
    assert_selector "#note_password-hint", text: "At least 12 characters."
  end

  def test_no_counter_without_the_wrapper
    form { |f| f.text_field :body, counter: {max: 10}, wrapper: false }

    assert_no_selector "[data-controller~=cl-counter]"
  end
end
