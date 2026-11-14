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
      carousel scrollspy input_group floating_label range table_header choice_group file_upload combobox combobox_option timeline timeline_event chip chip_group toggle_group
      pwa_install bulk_action_bar
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

    CHECKBOX = "size-4 pointer-coarse:size-6 shrink-0 cursor-pointer accent-primary disabled:cursor-default " \
               "focus-visible:outline-none focus-visible:ring-4 focus-visible:ring-primary/25"

    # A row checkbox for `cl-bulk-select`. `label:` is required: it is the accessible name
    # (aria-label), such as "Select Ada Lovelace". Extra options become HTML attributes.
    #
    #   <%= ui_selection_checkbox label: "Select #{post.title}", value: post.id %>
    def ui_selection_checkbox(label:, value:, name: "ids[]", **options)
      bulk_checkbox("item", label, name: name, value: value, **options)
    end

    # The select-all checkbox for `cl-bulk-select`. It has no name, so it isn't submitted.
    def ui_select_all_checkbox(label: "Select all", **options)
      bulk_checkbox("all", label, action: "change->cl-bulk-select#toggleAll", **options)
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
        *apple_web_app_meta_tags(title, status_bar),
        tag.meta(name: "application-name", content: application_name),
        tag.meta(name: "mobile-web-app-capable", content: "yes"),
        tag.meta(name: "theme-color", content: theme_color),
        tag.link(rel: "manifest", href: manifest),
        (tag.link(rel: "apple-touch-icon", href: apple_touch_icon, sizes: "180x180") if apple_touch_icon)
      ].compact, "\n")
    end

    private

    def bulk_checkbox(target, label, action: "change->cl-bulk-select#update", **options)
      raise ArgumentError, "label: is required, it names the checkbox for screen readers" if label.blank?

      data = {cl_bulk_select_target: target, action: action}.merge(options.delete(:data) || {})
      css = ComponentLibrary2100.merge_classes(CHECKBOX, options.delete(:class))
      tag.input(type: "checkbox", class: css, data: data, aria: {label: label}.merge(options.delete(:aria) || {}), **options)
    end

    def apple_web_app_meta_tags(title, status_bar)
      [
        tag.meta(name: "apple-mobile-web-app-capable", content: "yes"),
        tag.meta(name: "apple-mobile-web-app-status-bar-style", content: status_bar),
        tag.meta(name: "apple-mobile-web-app-title", content: title)
      ]
    end
  end
end
