module ComponentLibrary2100
  # <%= render ButtonGroupComponent.new(aria: { label: "Text alignment" }) do %>
  #   <%= ui_button "Left" %> <%= ui_button "Right" %>
  # <% end %>
  #
  # Size the buttons individually; the group only handles layout and shared borders.
  class ButtonGroupComponent < BaseComponent
    HORIZONTAL = "inline-flex align-middle " \
                 "*:relative *:flex-auto *:not-first:-ml-px *:not-first:rounded-s-none *:not-last:rounded-e-none"
    VERTICAL = "inline-flex flex-col items-start justify-center align-middle " \
               "*:relative *:w-full *:not-first:-mt-px *:not-first:rounded-t-none *:not-last:rounded-b-none"

    def initialize(vertical: false, **html_options)
      super(**html_options)
      @vertical = vertical
    end

    def call
      tag.div(content, **attrs(@vertical ? VERTICAL : HORIZONTAL, role: "group"))
    end
  end
end
