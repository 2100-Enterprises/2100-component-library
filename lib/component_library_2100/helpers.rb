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
      alert badge breadcrumb button button_group card close_button
      list_group pagination progress spinner table
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
  end
end
