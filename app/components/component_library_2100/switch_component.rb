module ComponentLibrary2100
  # <%= render SwitchComponent.new(name: "user[newsletter]", label: "Email me updates", checked: true) %>
  # <%= render SwitchComponent.new(name: "terms", label: "I agree", type: :checkbox) %>
  # <%= render SwitchComponent.new(name: "plan", value: "pro", label: "Pro", type: :radio, inline: true) %>
  #
  # Bootstrap's form-check: a checkbox, radio or switch with its label, and an optional hint
  # and error. A switch is a checkbox with `role="switch"`. A checkbox or switch with a `name:`
  # also renders a hidden field holding `unchecked_value:` ("0" by default, `false` for none),
  # so unchecking it submits a value, as Rails' `check_box` does.
  #
  # Inside a form (`form_with`, or the `ComponentLibrary2100::FormBuilder` via `f.switch`) it
  # submits with the form. `autosubmit: true` submits the surrounding form as soon as it changes,
  # for a settings toggle that saves itself:
  #
  #   <%= form_with url: notifications_path, method: :patch do %>
  #     <%= ui_switch name: "enabled", label: "Notifications", checked: @enabled, autosubmit: true %>
  #   <% end %>
  #
  # HTML attributes go on the <input>, because that's what you'll want to wire up (`data:`,
  # `aria:`, `form:`); `wrapper:` takes attributes for the outer <div>.
  # type: :switch (default), :checkbox or :radio.
  class SwitchComponent < BaseComponent
    WRAPPER = "flex items-start gap-2"
    INLINE = "inline-flex items-start gap-2 mr-4"
    LABEL = "cursor-pointer select-none"

    FOCUS = "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"
    INPUTS = {
      checkbox: "mt-1 size-4 shrink-0 cursor-pointer accent-primary disabled:cursor-default #{FOCUS}",
      radio: "mt-1 size-4 shrink-0 cursor-pointer accent-primary disabled:cursor-default #{FOCUS}",
      switch: "mt-1 w-8 h-4 shrink-0 cursor-pointer appearance-none rounded-full border border-black/25 bg-white " \
              "bg-no-repeat bg-left bg-[length:0.875rem_0.875rem] bg-[radial-gradient(circle,rgb(0_0_0/0.25)_0.3rem,transparent_0.33rem)] " \
              "transition-[background-position] duration-150 " \
              "checked:bg-right checked:bg-primary checked:border-primary " \
              "checked:bg-[radial-gradient(circle,var(--color-primary-on)_0.3rem,transparent_0.33rem)] " \
              "disabled:opacity-50 disabled:cursor-default aria-invalid:border-danger #{FOCUS}"
    }.freeze

    def initialize(name: nil, label: nil, type: :switch, checked: false, value: "1", unchecked_value: "0", id: nil,
      hint: nil, error: nil, inline: false, disabled: false, autosubmit: false, wrapper: {}, **html_options)
      super(**html_options)
      @name = name
      @label = label
      @type = type.to_sym
      @checked = checked
      @value = value
      @unchecked_value = unchecked_value
      @id = id || generated_id(@type.to_s)
      @hint = hint
      @error = error.presence
      @inline = inline
      @disabled = disabled
      @autosubmit = autosubmit
      @wrapper = wrapper
    end

    def call
      text = content.presence || @label
      body = tag.div(safe_join([tag.label(text, for: @id, class: LABEL), feedback].compact))

      tag.div(safe_join([hidden_field, input, body].compact), **merge_attrs(@wrapper, @inline ? INLINE : WRAPPER))
    end

    private

    def input
      css = Variants.fetch(INPUTS, @type, kind: "type")
      tag.input(**attrs(css, **input_defaults))
    end

    def input_defaults
      {
        type: (@type == :radio) ? "radio" : "checkbox",
        role: ("switch" if @type == :switch),
        name: @name, value: @value, id: @id, checked: @checked, disabled: @disabled,
        aria: {describedby: describedby, invalid: (true if @error)}.compact,
        data: (@autosubmit ? {action: "change->cl-autosubmit#submit", controller: "cl-autosubmit"} : {})
      }
    end

    def hidden_field
      return if @type == :radio || @name.nil? || @unchecked_value == false

      tag.input(type: "hidden", name: @name, value: @unchecked_value, autocomplete: "off", disabled: @disabled)
    end

    def feedback
      parts = [
        (tag.div(@error, id: "#{@id}-error", class: FormFieldComponent::ERROR) if @error),
        (tag.div(@hint, id: "#{@id}-hint", class: FormFieldComponent::HINT) if @hint)
      ].compact
      safe_join(parts) if parts.any?
    end

    def describedby
      [("#{@id}-error" if @error), ("#{@id}-hint" if @hint)].compact.join(" ").presence
    end
  end
end
