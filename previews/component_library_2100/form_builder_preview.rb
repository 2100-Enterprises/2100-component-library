require "active_model"

module ComponentLibrary2100
  # ComponentLibrary2100::FormBuilder through `ui_form_with`: every field helper renders its label,
  # control, hint and the model's error.
  # @logical_path forms
  class FormBuilderPreview < BasePreview
    # A stand-in for a host app's model.
    class Person
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :name, :string
      attribute :email, :string
      attribute :password, :string
      attribute :role, :string
      attribute :bio, :string
      attribute :plan, :string, default: "pro"
      attribute :roles, default: -> { ["editor"] }
      attribute :contact, :string, default: "email"
      attribute :starts_at, :string
      attribute :newsletter, :boolean, default: true
    end

    # @param show_errors toggle "Add errors, as after a failed save"
    def playground(show_errors: false)
      person = Person.new(name: "Ada")
      if show_errors
        person.errors.add(:email, :blank)
        person.errors.add(:name, :too_short, count: 5)
      end
      template(:playground, person: person)
    end
  end
end
