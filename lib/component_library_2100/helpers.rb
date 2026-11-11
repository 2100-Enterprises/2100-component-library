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
      carousel scrollspy input_group floating_label range table_header choice_group file_upload combobox combobox_option timeline timeline_event chip chip_group
      pwa_install
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

    # The <head> tags that make a page installable and give it the right Home Screen identity.
    # iOS reads the apple-* tags rather than the manifest when it adds a page to the Home Screen.
    #
    #   <%= ui_pwa_meta_tags title: "2100", application_name: "2100 Enterprises", theme_color: "#0B1220" %>
    #
    # status_bar: the iOS status bar style. "black-translucent" draws the page under the status bar,
    # so only use it on a layout whose top bar pads for env(safe-area-inset-top).
    # manifest: the manifest URL (rails/pwa serves /manifest.json). apple_touch_icon: a 180px PNG, or false.
    def ui_pwa_meta_tags(title:, theme_color:, application_name: title, status_bar: "default",
      manifest: "/manifest.json", apple_touch_icon: "/apple-touch-icon.png")
      safe_join([
        tag.meta(name: "apple-mobile-web-app-capable", content: "yes"),
        tag.meta(name: "apple-mobile-web-app-status-bar-style", content: status_bar),
        tag.meta(name: "apple-mobile-web-app-title", content: title),
        tag.meta(name: "application-name", content: application_name),
        tag.meta(name: "mobile-web-app-capable", content: "yes"),
        tag.meta(name: "theme-color", content: theme_color),
        tag.link(rel: "manifest", href: manifest),
        (tag.link(rel: "apple-touch-icon", href: apple_touch_icon, sizes: "180x180") if apple_touch_icon)
      ].compact, "\n")
    end
  end
end
