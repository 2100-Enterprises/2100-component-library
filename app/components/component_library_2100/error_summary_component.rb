module ComponentLibrary2100
  # <%= render ErrorSummaryComponent.new(errors: @user.errors) %>
  # <%= render ErrorSummaryComponent.new(errors: ["Email can't be blank", ["Name is too short", "#user_name"]]) %>
  #
  # A danger alert listing a form's errors, for the top of the form. It renders nothing when
  # there are none. Pass ActiveModel errors, or an array whose entries are messages or
  # `[message, href]` pairs, which become links to the fields. `f.error_summary` in
  # ComponentLibrary2100::FormBuilder links each error to its field for you.
  # It has `role="alert"` so it's announced when it appears, and `tabindex="-1"` so you can move
  # focus to it. HTML attributes go on the outer <div>.
  class ErrorSummaryComponent < BaseComponent
    BASE = "p-4 border rounded-ui #{Variants::SUBTLE[:danger]}".freeze
    TITLE = "m-0 mb-2 text-base font-bold"
    LIST = "m-0 pl-5 list-disc"
    LINK = "text-danger-emphasis underline"

    def initialize(errors: [], title: "Please fix the following:", **html_options)
      super(**html_options)
      @messages = normalize(errors)
      @title = title
    end

    def render? = @messages.any?

    def call
      items = @messages.map { |message, href| tag.li(href ? link_to(message, href, class: LINK) : message) }
      tag.div(safe_join([tag.h2(@title, class: TITLE), tag.ul(safe_join(items), class: LIST)]),
        **attrs(BASE, role: "alert", tabindex: -1))
    end

    private

    def normalize(errors)
      return errors.full_messages.map { |message| [message, nil] } if errors.respond_to?(:full_messages)

      Array(errors).map { |entry| entry.is_a?(Array) ? entry.first(2) : [entry, nil] }
    end
  end
end
