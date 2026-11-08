module ComponentLibrary2100
  # Thin view helpers so ERB call sites stay terse:
  #
  #   <%= ui_button "Save", variant: :success %>
  #   <%= ui_card do |card| %> ... <% end %>
  #
  # Each helper builds `ComponentLibrary2100::<Name>Component` with the keyword
  # arguments, uses the first positional argument as content, and passes any block
  # through (so slots work: `ui_card { |c| c.with_header { "Hi" } }`).
  module Helpers
    NAMES = %w[
      accordion alert badge breadcrumb button button_group card close_button collapse dropdown
      list_group modal offcanvas pagination popover progress spinner table tabs toast toast_container tooltip
      nav switch form_field radio_card_group error_summary confirm_dialog
      page_header empty_state avatar navbar stepper
      skeleton description_list stat stats sort_header
      carousel scrollspy input_group floating_label range table_header choice_group file_upload combobox combobox_option timeline timeline_event
    ].freeze

    NAMES.each do |name|
      define_method(:"ui_#{name}") do |content = nil, **options, &block|
        component = "ComponentLibrary2100::#{name.camelize}Component".constantize.new(**options)

        if block
          render(component, &block)
        elsif content
          render(component) { content }
        else
          render(component)
        end
      end
    end

    # `form_with` using ComponentLibrary2100::FormBuilder:
    #
    #   <%= ui_form_with model: @user do |f| %>
    #     <%= f.email_field :email, hint: "We never share it." %>
    #   <% end %>
    def ui_form_with(**options, &block)
      form_with(**options, builder: ComponentLibrary2100::FormBuilder, &block)
    end
  end
end
