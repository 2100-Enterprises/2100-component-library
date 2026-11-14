module ComponentLibrary2100
  # A form builder whose field helpers render a whole Bootstrap-style field: label, control,
  # inline error (from the model's errors) and hint.
  #
  #   <%= ui_form_with model: @user do |f| %>
  #     <%= f.error_summary %>
  #     <%= f.text_field :name, hint: "As it appears on your ID" %>
  #     <%= f.email_field :email %>
  #     <%= f.password_field :password %>                  <%# with a Show/Hide button %>
  #     <%= f.telephone_field :phone, optional: true %>
  #     <%= f.select :role, %w[Admin Member] %>
  #     <%= f.combobox :person_id, src: people_path, text: @user.person_name %>
  #     <%= f.text_area :bio, rows: 4 %>
  #     <%= f.file_upload :avatar, accept: %w[image/*], max_bytes: 5.megabytes %>
  #     <%= f.radio_cards :plan, [["Basic", "basic", "One project"], ["Pro", "pro", "Unlimited"]], columns: 2 %>
  #     <%= f.check_boxes :roles, %w[Admin Editor], hint: "Pick any", inline: true %>
  #     <%= f.radios :contact, [["Email", "email"], ["Phone", "phone"]] %>
  #     <%= f.time_field :starts_at, min: "09:00", max: "17:00" %>
  #     <%= f.switch :newsletter, label: "Email me updates" %>
  #     <%= f.submit "Save" %>
  #   <% end %>
  #
  # Use it with `ui_form_with`, `form_with(builder: ComponentLibrary2100::FormBuilder)`, or app-wide
  # with `config.action_view.default_form_builder = "ComponentLibrary2100::FormBuilder"`.
  #
  # Every field helper takes these options besides its usual ones:
  #   label:    text, or false for none (default: the attribute's human name)
  #   hint:     help text under the control
  #   optional: true or a string, appended to the label
  #   error:    overrides the message taken from `object.errors` (false for none)
  #   wrapper:  HTML attributes for the wrapping <div>, or false for the bare, styled control
  # Everything else (class:, data:, required: ...) goes on the control as usual, so `min:` and `max:`
  # reach number, date, time, datetime-local and month fields.
  #   counter:  {max: 2000} or {min: 12}, a live character count (see FormFieldComponent);
  #             `html: true` counts rich text. Needs the wrapper, so it is ignored with `wrapper: false`
  #   autosubmit: true submits the form when the control changes (`cl-autosubmit`); `{delay: 300}`
  #             submits 300ms after the last keystroke, for search and text fields
  # Everything else (class:, data:, required: ...) goes on the control as usual.
  class FormBuilder < ActionView::Helpers::FormBuilder
    FIELD_OPTIONS = %i[label hint optional error wrapper counter].freeze
    COMBOBOX_OPTIONS = %i[text min_length delay force_selection frame_id messages listbox_label].freeze

    include ComponentFields

    %i[text_field email_field telephone_field phone_field number_field url_field search_field date_field time_field datetime_local_field month_field].each do |helper|
      define_method(helper) do |method, options = {}|
        field(method, options) { |control_options| super(method, control_options) }
      end
    end

    # Adds a Show/Hide button driven by the `cl-password` controller; `toggle: false` leaves it out.
    def password_field(method, options = {})
      options = options.dup
      toggle = options.delete(:toggle) != false

      field(method, options) do |control_options|
        next super(method, control_options) unless toggle

        control_options = control_options.merge(
          class: ComponentLibrary2100.merge_classes(control_options[:class], "pr-16"),
          data: (control_options[:data] || {}).merge(cl_password_target: "input")
        )
        @template.tag.div(safe_join([super(method, control_options), password_toggle(control_options[:id])]),
          class: "relative", data: {controller: "cl-password"})
      end
    end

    def text_area(method, options = {})
      field(method, options, kind: :textarea) { |control_options| super(method, control_options) }
    end

    # Rails 8 names it `textarea`; `text_area` is an alias there, and the only name in 7.1.
    def textarea(method, options = {})
      text_area(method, options)
    end

    # The label/hint/... options go with the select options (the third argument), as in Rails.
    def select(method, choices = nil, options = {}, html_options = {}, &block)
      options = options.dup
      config = options.extract!(*FIELD_OPTIONS)

      field(method, config.merge(html_options), kind: :select) do |control_options|
        super(method, choices, options, control_options, &block)
      end
    end

    # Wraps Action Text's `rich_text_area` when the app has Action Text; there's no dependency on it.
    def rich_text_area(method, options = {})
      raise NoMethodError, "rich_text_area needs Action Text (bin/rails action_text:install)" unless defined?(super)

      field(method, options) { |control_options| super(method, control_options.except(:class)) }
    end

    def rich_textarea(method, options = {})
      rich_text_area(method, options)
    end

    # A text input with server-side suggestions (ComboboxComponent), in the usual field wrapper.
    # `src:` is the endpoint that answers `?q=` with a Turbo Frame of ComboboxOptionComponents, and
    # `text:` is the label shown for the current value (default: the value itself).
    def combobox(method, src:, **options)
      options = options.to_h.symbolize_keys
      settings = options.extract!(*COMBOBOX_OPTIONS)
      settings[:text] ||= value_of(method)

      field(method, options) do |control_options|
        @template.render(ComboboxComponent.new(
          name: field_name(method), src: src, value: value_of(method), input: control_options, **settings
        ))
      end
    end

    # The object's errors, each linked to its field. Renders nothing when there are none.
    def error_summary(title: "Please fix the following:", **options)
      return unless object.respond_to?(:errors)

      messages = object.errors.map do |error|
        [error.full_message, (error.attribute == :base) ? nil : "##{field_id(error.attribute)}"]
      end
      @template.render(ErrorSummaryComponent.new(errors: messages, title: title, **options))
    end

    # A ButtonComponent submit button. Takes ButtonComponent options (`variant:`, `size:` ...).
    def submit(value = nil, options = {})
      if value.is_a?(Hash)
        options = value
        value = nil
      end
      value ||= submit_default_value

      @template.render(ButtonComponent.new(type: :submit, name: "commit", value: value, **options.symbolize_keys)) { value }
    end

    private

    def field(method, options, kind: :control)
      options = options.to_h.symbolize_keys
      config = options.extract!(*FIELD_OPTIONS)
      options = with_autosubmit(options, options.delete(:autosubmit))
      component = field_component(method, options[:id], config)
      control_options = component.control_options(options, kind: kind)
      return yield(control_options) if config[:wrapper] == false

      @template.render(component) { yield(control_options) }
    end

    def field_component(method, id, config)
      FormFieldComponent.new(
        control_id: id || field_id(method), label: label_text(method, config[:label]),
        error: config.key?(:error) ? config[:error].presence : error_message(method),
        **config.slice(:hint, :optional, :counter), **(config[:wrapper] || {})
      )
    end

    def label_text(method, label)
      return label unless label.nil?
      return object.class.human_attribute_name(method) if object.class.respond_to?(:human_attribute_name)

      method.to_s.humanize
    end

    def error_message(method)
      return unless object.respond_to?(:errors)

      object.errors.full_messages_for(method).to_sentence.presence
    end

    def value_of(method)
      object.public_send(method) if object.respond_to?(method)
    end

    def password_toggle(input_id)
      @template.tag.button(
        safe_join([@template.tag.span("Show", data: {cl_password_target: "label"}), @template.tag.span(" password", class: "sr-only")]),
        type: :button, class: "absolute inset-y-0 right-0 px-3 text-sm text-primary bg-transparent border-0 cursor-pointer " \
                              "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25 rounded-r-ui",
        aria: {controls: input_id}, data: {action: "cl-password#toggle"}
      )
    end

    def safe_join(parts) = @template.safe_join(parts)
  end
end
