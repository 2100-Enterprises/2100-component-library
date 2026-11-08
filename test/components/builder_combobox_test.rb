require "test_helper"
require "active_model"

class BuilderComboboxTest < ViewComponent::TestCase
  class Membership
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :person_id, :string

    validates :person_id, presence: {message: "Choose a person"}

    def self.name = "Membership"
  end

  def form(membership = Membership.new, &fields)
    render_in_view_context { ui_form_with(model: membership, url: "/memberships", &fields) }
  end

  def test_labels_the_combobox_input_and_names_the_value
    form { |f| f.combobox :person_id, src: "/people", label: "Person", hint: "Type a name or email." }

    assert_selector "label[for=membership_person_id]", text: "Person"
    assert_selector "input#membership_person_id[role=combobox][aria-describedby~='membership_person_id-hint']"
    assert_selector "[data-controller~=cl-combobox]"
    assert_includes rendered_content, %(name="membership[person_id]")
  end

  def test_shows_the_current_label_with_the_value
    form(Membership.new(person_id: "3")) { |f| f.combobox :person_id, src: "/people", text: "Ada Lovelace" }

    assert_selector "input[role=combobox][value='Ada Lovelace']"
    assert_selector "input[type=hidden][value='3']", visible: :all
  end

  def test_shows_the_model_error
    membership = Membership.new.tap(&:validate)
    form(membership) { |f| f.combobox :person_id, src: "/people" }

    assert_selector "input[role=combobox][aria-invalid=true]"
    assert_text "Choose a person"
  end
end
