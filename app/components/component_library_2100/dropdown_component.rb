module ComponentLibrary2100
  # <%= render DropdownComponent.new(placement: "bottom-end") do |menu| %>
  #   <% menu.with_trigger(variant: :secondary) { "Actions" } %>
  #   <% menu.with_header("Project") %>
  #   <% menu.with_item("Edit", href: "/edit") %>
  #   <% menu.with_item("Archive", data: { action: "archive#run" }) %>
  #   <% menu.with_divider %>
  #   <% menu.with_item("Delete", href: "/delete", disabled: true) %>
  #   <% menu.with_item("Sign out", href: "/session", method: :delete) %>
  # <% end %>
  #
  # The menu is a native popover: the browser handles opening, outside clicks, Escape and returning
  # focus. Arrow keys, Home and End move between items. Items with `href:` are links, the rest are
  # buttons. An item with `href:` and a `method:` other than GET is a `button_to` form, so it submits
  # (with Rails' `_method` and CSRF fields) while staying a menu item; `params:` and `form:` go to
  # `button_to`. HTML attributes go on the menu; the trigger takes ButtonComponent options.
  # placement: "bottom-start" (default), "bottom-end", "top-start", "right", ... (see position.js).
  class DropdownComponent < BaseComponent
    MENU = "m-0 inset-auto min-w-40 px-0 py-2 text-base text-body bg-white border border-border-menu rounded-ui shadow-lg " \
           "not-data-positioned:invisible"
    ITEM = "block w-full px-4 py-1 text-left font-normal text-body no-underline whitespace-nowrap bg-transparent border-0 cursor-pointer " \
           "hover:bg-surface-muted focus-visible:bg-surface-muted focus:outline-none"
    ACTIVE = "text-primary-on bg-primary hover:bg-primary focus-visible:bg-primary"
    DISABLED = "pointer-events-none text-secondary bg-transparent"
    HEADER = "block px-4 py-1 mb-0 text-sm whitespace-nowrap text-secondary"
    DIVIDER = "h-0 my-2 border-t border-border-menu"
    CARET = "after:inline-block after:ml-[.255em] after:align-[.255em] after:content-[''] " \
            "after:border-x-[.3em] after:border-t-[.3em] after:border-b-0 after:border-x-transparent"

    renders_one :trigger, ->(**opts) { ButtonComponent.new(**merge_attrs(opts, CARET, **trigger_defaults)) }

    renders_many :entries, types: {
      item: {
        as: :item,
        renders: ->(label = nil, href: nil, method: nil, active: false, disabled: false, params: {}, form: {}, **opts, &block) {
          text = block ? capture(&block) : label
          css = [ITEM, (ACTIVE if active), (DISABLED if disabled)]
          shared = {role: "menuitem", tabindex: -1, data: {action: "click->cl-popover#close"}}

          if href && method && method.to_s.downcase != "get"
            button = merge_attrs(opts, css, type: :submit, disabled: disabled, **shared)
            button_to(href, method: method, params: params, form: merge_attrs(form, "m-0"), **button) { text }
          elsif href
            aria = {current: (true if active), disabled: (true if disabled)}.compact
            tag.a(text, **merge_attrs(opts, css, href: href, aria: aria, **shared))
          else
            tag.button(text, **merge_attrs(opts, css, type: :button, disabled: disabled, **shared))
          end
        }
      },
      divider: {
        as: :divider,
        renders: ->(**opts) { tag.div(**merge_attrs(opts, DIVIDER, role: "separator")) }
      },
      header: {
        as: :header,
        renders: ->(label = nil, **opts, &block) {
          tag.div(block ? capture(&block) : label, **merge_attrs(opts, HEADER, role: "presentation"))
        }
      }
    }

    def initialize(placement: "bottom-start", **html_options)
      super(**html_options)
      @placement = placement
      @id = html_options[:id] || generated_id("dropdown")
    end

    def call
      tag.div(safe_join([trigger, menu]), class: "inline-block", data: {controller: "cl-popover", cl_popover_placement_value: @placement})
    end

    private

    def menu
      tag.div(safe_join(entries), **attrs(MENU, id: @id, popover: "auto", role: "menu", data: {
        cl_popover_target: "panel", action: "toggle->cl-popover#sync keydown->cl-popover#navigate"
      }))
    end

    def trigger_defaults
      {
        variant: :secondary,
        popovertarget: @id,
        aria: {haspopup: "menu", expanded: false},
        data: {cl_popover_target: "trigger"}
      }
    end
  end
end
