require "test_helper"
require "active_model"

class FormComponentsTest < ViewComponent::TestCase
  include ComponentLibrary2100
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::TagHelper

  class User
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :name, :string
    attribute :email, :string
    attribute :password, :string
    attribute :phone, :string
    attribute :age, :integer
    attribute :role, :string
    attribute :bio, :string
    attribute :plan, :string
    attribute :newsletter, :boolean

    validates :email, presence: true

    def self.name = "User"
  end

  def form(user = User.new, &fields)
    render_in_view_context { ui_form_with(model: user, url: "/users", &fields) }
  end

  def invalid_user
    User.new.tap(&:validate)
  end

  # FormFieldComponent

  def test_form_field_wires_label_hint_and_error
    render_inline(FormFieldComponent.new(control_id: "email", label: "Email", hint: "Never shared", error: "is wrong", optional: true, class: "mb-3")) do |field|
      tag.input(type: "email", **field.control_options(class: "w-64"))
    end

    assert_selector "div.mb-3 > label[for=email]", text: "Email (optional)"
    input = page.find("input#email")
    assert_equal "email-error email-hint", input["aria-describedby"]
    assert_equal "true", input["aria-invalid"]
    assert_includes input[:class].split, "w-64"
    refute_includes input[:class].split, "w-full"
    assert_selector "#email-error.text-danger", text: "is wrong"
    assert_selector "#email-hint.text-secondary", text: "Never shared"
  end

  def test_form_field_without_error_or_hint
    render_inline(FormFieldComponent.new(control_id: "q", label: false)) { |field| tag.input(**field.control_options) }

    assert_no_selector "label"
    assert_no_selector "input[aria-describedby]"
    assert_no_selector "input[aria-invalid]"
  end

  # FormBuilder

  def test_text_fields_render_whole_fields
    form do |f|
      safe_join([
        f.text_field(:name, hint: "Full name"),
        f.email_field(:email, required: true),
        f.telephone_field(:phone, optional: true),
        f.number_field(:age, label: "Age in years")
      ])
    end

    assert_selector "form[action='/users']"
    assert_selector "label[for=user_name]", text: "Name"
    assert_selector "input#user_name[type=text][name='user[name]'][aria-describedby=user_name-hint].rounded-ui"
    assert_selector "input#user_email[type=email][required]"
    assert_selector "label[for=user_phone]", text: "Phone (optional)"
    assert_selector "input#user_phone[type=tel]"
    assert_selector "label[for=user_age]", text: "Age in years"
    assert_selector "input#user_age[type=number]"
  end

  def test_errors_come_from_the_model
    form(invalid_user) { |f| safe_join([f.error_summary, f.email_field(:email)]) }

    assert_selector "input#user_email[aria-invalid=true][aria-describedby=user_email-error]"
    assert_selector "#user_email-error", text: "Email can't be blank"
    assert_selector "[role=alert][tabindex='-1'] li a[href='#user_email']", text: "Email can't be blank"
  end

  def test_error_false_and_wrapper_false
    form(invalid_user) { |f| f.email_field(:email, error: false, wrapper: false, class: "w-40") }

    assert_no_selector "label"
    assert_no_selector "[aria-invalid]"
    assert_selector "input#user_email.w-40.rounded-ui"
  end

  def test_password_field_has_a_toggle
    form { |f| safe_join([f.password_field(:password), f.password_field(:password, toggle: false, id: "plain")]) }

    assert_selector "[data-controller=cl-password] input#user_password[type=password][data-cl-password-target=input].pr-16"
    assert_selector "button[type=button][aria-controls=user_password][data-action='cl-password#toggle']", text: "Show password"
    assert_selector "[data-cl-password-target=label]", text: "Show"
    assert_selector "input#plain[type=password]:not([data-cl-password-target])"
  end

  def test_select_and_textarea
    form(User.new(role: "Member")) do |f|
      safe_join([f.select(:role, %w[Admin Member], {hint: "Pick one", include_blank: true}, {class: "w-48"}), f.text_area(:bio, rows: 3)])
    end

    assert_selector "select#user_role.w-48[aria-describedby=user_role-hint] option", count: 3
    assert_selector "select option[selected]", text: "Member"
    refute_includes page.find("select")[:class], "appearance-none"
    assert_selector "label[for=user_bio]", text: "Bio"
    assert_selector "textarea#user_bio[rows='3'].rounded-ui"
  end

  def test_switch_and_check_use_the_attribute
    form(User.new(newsletter: true)) { |f| safe_join([f.switch(:newsletter, label: "Email me"), f.check(:newsletter, id: "box")]) }

    assert_selector "input[type=hidden][name='user[newsletter]'][value='0']", visible: :all, count: 2
    assert_selector "input#user_newsletter[type=checkbox][role=switch][name='user[newsletter]'][value='1'][checked]"
    assert_selector "label[for=user_newsletter]", text: "Email me"
    assert_selector "input#box[type=checkbox]:not([role])[checked]"
  end

  def test_radio_cards_from_the_builder
    form(User.new(plan: "pro")) do |f|
      f.radio_cards(:plan, [["Basic", "basic", "One project"], ["Pro", "pro"]], columns: 2, hint: "Change any time")
    end

    assert_selector "fieldset#user_plan[aria-describedby=user_plan-hint] legend", text: "Plan"
    assert_selector "fieldset .sm\\:grid-cols-2 > label", count: 2
    assert_selector "label[for=user_plan-0] input[type=radio][name='user[plan]'][value=basic]:not([checked])"
    assert_selector "label[for=user_plan-1] input[value=pro][checked]"
    assert_selector "label", text: "One project"
  end

  def test_submit_is_a_button_component
    form { |f| f.submit("Save", variant: :success) }

    assert_selector "button[type=submit][name=commit][value=Save].bg-success", text: "Save"
  end

  def test_submit_default_value
    form { |f| f.submit }

    assert_selector "button[type=submit]", text: "Create User"
  end

  def test_rich_text_area_needs_action_text
    error = assert_raises(NoMethodError) { form { |f| f.rich_text_area(:bio) } }
    assert_match "Action Text", error.message
  end

  # SwitchComponent

  def test_switch_standalone
    render_inline(SwitchComponent.new(name: "on", label: "Notifications", id: "n", hint: "Daily", error: "Required",
      autosubmit: true, wrapper: {class: "mb-2"}, data: {action: "change->x#y"}))

    assert_selector "div.mb-2 > input[type=hidden][name=on][value='0']", visible: :all
    input = page.find("input#n[type=checkbox][role=switch]")
    assert_equal "n-error n-hint", input["aria-describedby"]
    assert_equal "true", input["aria-invalid"]
    assert_equal "cl-autosubmit", input["data-controller"]
    assert_equal "change->cl-autosubmit#submit change->x#y", input["data-action"]
    assert_selector "label[for=n]", text: "Notifications"
    assert_selector "#n-hint", text: "Daily"
  end

  def test_switch_autosubmit_with_delay
    render_inline(SwitchComponent.new(name: "on", id: "n", autosubmit: {delay: 300})) { "On" }

    input = page.find("input#n")
    assert_equal "cl-autosubmit", input["data-controller"]
    assert_equal "input->cl-autosubmit#submit", input["data-action"]
    assert_equal "300", input["data-cl-autosubmit-delay-value"]
  end

  def test_builder_autosubmit
    form do |f|
      safe_join([
        f.search_field(:name, autosubmit: {delay: 300}, data: {action: "focus->x#y", controller: "x"}),
        f.text_field(:email, autosubmit: true),
        f.select(:role, %w[a b], {}, autosubmit: true),
        f.text_field(:phone)
      ])
    end

    name = page.find("input#user_name")
    assert_equal "cl-autosubmit x", name["data-controller"]
    assert_equal "input->cl-autosubmit#submit focus->x#y", name["data-action"]
    assert_equal "300", name["data-cl-autosubmit-delay-value"]
    email = page.find("input#user_email")
    assert_equal "change->cl-autosubmit#submit", email["data-action"]
    assert_nil email["data-cl-autosubmit-delay-value"]
    assert_equal "change->cl-autosubmit#submit", page.find("select#user_role")["data-action"]
    assert_nil page.find("input#user_phone")["data-controller"]
  end

  def test_radio_and_inline_check
    render_inline(SwitchComponent.new(name: "size", value: "s", type: :radio, inline: true, checked: true)) { "Small" }

    assert_selector "div.inline-flex > input[type=radio][name=size][value=s][checked]"
    assert_no_selector "input[type=hidden]", visible: :all
    assert_selector "label", text: "Small"
  end

  def test_switch_without_hidden_field
    render_inline(SwitchComponent.new(name: "x", unchecked_value: false, disabled: true))

    assert_no_selector "input[type=hidden]", visible: :all
    assert_selector "input[disabled]"
  end

  # RadioCardGroupComponent / ErrorSummaryComponent

  def test_radio_card_group_standalone
    render_inline(RadioCardGroupComponent.new(name: "plan", legend: "Plan", id: "plan", error: "Pick a plan", optional: true,
      choices: [{value: "a", label: "A", description: "First"}, {value: "b", label: "B", disabled: true}, "C"]))

    assert_selector "fieldset#plan[aria-describedby=plan-error] legend", text: "Plan (optional)"
    assert_selector "input[type=radio][aria-invalid=true]", count: 3
    assert_selector "input#plan-1[disabled]"
    assert_selector "input#plan-2[value=C]"
    assert_selector "label.border-danger", count: 3
    assert_no_selector "input[checked]"
  end

  def test_error_summary_renders_nothing_without_errors
    render_inline(ErrorSummaryComponent.new(errors: []))
    assert_no_selector "div"

    render_inline(ErrorSummaryComponent.new(errors: ["One", ["Two", "#two"]], title: "Oops"))
    assert_selector "h2", text: "Oops"
    assert_selector "li", text: "One"
    assert_selector "li a[href='#two']", text: "Two"
  end
end
