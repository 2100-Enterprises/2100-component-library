require "test_helper"
require "active_model"

class BuilderGroupsTest < ViewComponent::TestCase
  include ComponentLibrary2100

  class Profile
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :roles
    attribute :contact, :string
    attribute :starts_at, :time
    attribute :meeting, :datetime
    attribute :billing_month, :string

    validates :roles, presence: true
    validates :contact, :starts_at, :meeting, :billing_month, presence: true

    def self.name = "Profile"
  end

  def form(profile = Profile.new, &fields)
    render_in_view_context { ui_form_with(model: profile, url: "/profiles", &fields) }
  end

  def invalid_profile
    Profile.new.tap(&:valid?)
  end

  test "check_boxes renders a fieldset with a legend and labelled checkboxes" do
    form { |f| f.check_boxes :roles, [["Admin", "admin"], "editor"] }

    assert_selector "fieldset legend", text: "Roles"
    assert_selector "fieldset input[type=checkbox][name='profile[roles][]']", count: 2
    assert_selector "label", text: "Admin"
    assert_selector "label", text: "editor"
    assert_field "Admin", type: :checkbox
  end

  test "radios renders radio buttons sharing a name" do
    form { |f| f.radios :contact, [["Email", "email"], ["Phone", "phone"]], label: "Contact by" }

    assert_selector "fieldset legend", text: "Contact by"
    assert_selector "input[type=radio][name='profile[contact]']", count: 2
    assert_field "Phone", type: :radio
  end

  test "a hidden empty value is sent first so nothing checked still submits" do
    form { |f| f.check_boxes(:roles, %w[a b]) + f.radios(:contact, %w[x y]) }

    assert_selector "input[type=hidden][name='profile[roles][]'][value='']", visible: :all
    assert_selector "input[type=hidden][name='profile[contact]'][value='']", visible: :all
  end

  test "checked state comes from the model" do
    form(Profile.new(roles: %w[editor], contact: "phone")) do |f|
      f.check_boxes(:roles, [["Admin", "admin"], ["Editor", "editor"]]) + f.radios(:contact, [["Email", "email"], ["Phone", "phone"]])
    end

    assert_field "Editor", type: :checkbox, checked: true
    assert_field "Admin", type: :checkbox, checked: false
    assert_field "Phone", type: :radio, checked: true
    assert_field "Email", type: :radio, checked: false
  end

  test "hint and error tie to the fieldset and come from the model" do
    form(invalid_profile) { |f| f.check_boxes :roles, %w[a], hint: "Pick any" }

    fieldset = page.find("fieldset")
    ids = fieldset["aria-describedby"].split
    assert_equal 2, ids.size
    assert_selector "##{ids.first}", text: "Roles can't be blank"
    assert_selector "##{ids.last}", text: "Pick any"
    assert_selector "input[type=checkbox][aria-invalid=true]"
  end

  test "error: overrides the model message and false removes it" do
    form(invalid_profile) { |f| f.radios(:contact, %w[a], error: "Choose one") + f.check_boxes(:roles, %w[b], error: false) }

    assert_text "Choose one"
    assert_no_text "Roles can't be blank"
  end

  test "no aria-describedby or aria-invalid without a hint or error" do
    form { |f| f.radios :contact, %w[a b] }

    assert_no_selector "fieldset[aria-describedby]"
    assert_no_selector "input[aria-invalid]"
  end

  test "disabled options are disabled" do
    form { |f| f.radios :contact, [{value: "a", label: "A"}, {value: "b", label: "B", disabled: true}] }

    assert_field "A", type: :radio, disabled: false
    assert_field "B", type: :radio, disabled: true
  end

  test "each row is a tall, clickable label" do
    form { |f| f.check_boxes :roles, %w[a] }

    assert_selector "label.min-h-11[for]"
    assert_equal page.find("label")["for"], page.find("input[type=checkbox]")[:id]
  end

  test "inline lays the options out in a row" do
    form { |f| f.check_boxes :roles, %w[a b], inline: true }
    assert_selector "fieldset .flex-row"

    form { |f| f.check_boxes :roles, %w[a b] }
    assert_selector "fieldset .flex-col"
  end

  test "time, datetime-local and month fields get a label, error and hint" do
    form(invalid_profile) do |f|
      f.time_field(:starts_at, hint: "Local time", min: "09:00") +
        f.datetime_local_field(:meeting) +
        f.month_field(:billing_month, max: Date.new(2030, 12, 1))
    end

    assert_field "Starts at", type: :time
    assert_selector "input[type=time][min^='09:00'][aria-invalid=true]"
    assert_selector "input[type=datetime-local][aria-invalid=true]"
    assert_selector "input[type=month][max^='2030-12'][aria-invalid=true]"
    assert_selector "label[for=profile_meeting]", text: "Meeting"
    assert_selector "label[for=profile_billing_month]", text: "Billing month"
    assert_selector "#profile_starts_at-hint", text: "Local time"
    assert_selector "#profile_starts_at-error", text: "Starts at can't be blank"
    assert_selector "input#profile_starts_at[aria-describedby='profile_starts_at-error profile_starts_at-hint']"
  end
end
