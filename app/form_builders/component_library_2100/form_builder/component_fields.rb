module ComponentLibrary2100
  class FormBuilder < ActionView::Helpers::FormBuilder
    # The FormBuilder helpers that render a whole component, which takes its own name, id, label
    # and error, rather than a Rails control inside a FormFieldComponent.
    module ComponentFields
      # A Bootstrap form-switch for a boolean attribute, rendered by SwitchComponent.
      # Takes SwitchComponent options (`type: :checkbox` for a plain checkbox, `autosubmit:`, ...).
      def switch(method, label: nil, error: nil, **options)
        checked = checked_option(options, boolean_value(method))
        component_field(SwitchComponent, method, label, error, checked: checked, **options)
      end

      # A plain checkbox in the same layout as `switch`.
      def check(method, **options)
        switch(method, type: :checkbox, **options)
      end

      # A styled native file input (FileUploadComponent) with a staged-file list, size and type
      # warnings, and an optional dropzone. Takes FileUploadComponent options (`accept:`,
      # `max_bytes:`, `multiple:`, `dropzone:`, `hint:` ...). The form needs `multipart: true`.
      def file_upload(method, label: nil, error: nil, **options)
        component_field(FileUploadComponent, method, label, error, **options)
      end

      # Radio buttons as cards (RadioCardGroupComponent). `choices` are `[label, value, description]`
      # arrays, `{value:, label:, description:, disabled:}` hashes or strings. `label:` is the legend.
      def radio_cards(method, choices, label: nil, error: nil, **options)
        checked = checked_option(options, value_of(method))
        component_field(RadioCardGroupComponent, method, label, error, label_key: :legend, choices: choices, checked: checked, **options)
      end

      # A group of checkboxes (ChoiceGroupComponent) in a <fieldset>; `label:` is the legend. Submits `""`
      # when none are checked. Choices are as for `radio_cards`; `inline: true` lays them in a row.
      def check_boxes(method, choices, **options)
        choice_group(:checkbox, method, choices, **options)
      end

      # A group of radio buttons (ChoiceGroupComponent), like `check_boxes`.
      def radios(method, choices, **options)
        choice_group(:radio, method, choices, **options)
      end

      private

      # Renders the component with its name, id, label (or legend) and error filled in from the
      # attribute, the way `field` fills in a FormFieldComponent.
      def component_field(component, method, label, error, label_key: :label, name: field_name(method), **options)
        @template.render(component.new(
          name: name, id: options.delete(:id) || field_id(method), label_key => label_text(method, label),
          error: error.nil? ? error_message(method) : error.presence, **options
        ))
      end

      def choice_group(type, method, choices, label: nil, error: nil, **options)
        checked = checked_option(options, value_of(method))
        component_field(ChoiceGroupComponent, method, label, error, label_key: :legend, name: field_name(method, multiple: type == :checkbox),
          type: type, choices: choices, checked: checked, **options)
      end

      # `checked:` when it was given, even as nil or false, else the attribute's value.
      def checked_option(options, default) = options.key?(:checked) ? options.delete(:checked) : default

      def boolean_value(method)
        ActiveModel::Type::Boolean.new.cast(value_of(method)) || false
      end

      # Merges the `autosubmit:` option into the control's data attributes, keeping the caller's own.
      def with_autosubmit(options, autosubmit)
        data = ComponentLibrary2100.autosubmit_data(autosubmit)
        return options if data.empty?

        mine = options[:data] || {}
        data[:action] = [data[:action], mine[:action]].compact.join(" ")
        data[:controller] = [data[:controller], mine[:controller]].compact.join(" ")
        options.merge(data: mine.merge(data))
      end
    end
  end
end
