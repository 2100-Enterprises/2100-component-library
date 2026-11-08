module ComponentLibrary2100
  # Bootstrap's scrollspy: a nav whose active link follows the section currently in view.
  #
  # <%= render ScrollspyComponent.new(label: "On this page") do |spy| %>
  #   <% spy.with_item("Intro", href: "#intro") %>
  #   <% spy.with_item("Details", href: "#details") %>
  #   <% spy.with_item("Pricing", href: "#pricing") %>
  # <% end %>
  #
  # Each `href:` points at the id of a section on the page. The `cl-scrollspy` Stimulus controller
  # watches those sections with an IntersectionObserver and marks the matching link
  # `aria-current="true"`. `smooth:` (default true) smooth-scrolls on click; `offset:` (px) shifts
  # the scroll target to clear a sticky header. The nav is a labelled landmark.
  class ScrollspyComponent < BaseComponent
    LIST = "flex flex-col gap-1 pl-0 m-0 list-none border-l border-border"
    LINK = "#{Variants::TOUCH_TARGET} block py-1.5 pl-3 -ml-px border-l-2 border-transparent text-secondary " \
           "hover:text-body hover:border-border " \
           "aria-[current]:text-primary aria-[current]:font-medium aria-[current]:border-primary"

    renders_many :items, ->(label = nil, href:, active: false, **opts, &block) {
      text = block ? capture(&block) : label
      tag.li(link_to(text, href, class: LINK, aria: {current: ("true" if active)}.compact,
        data: {cl_scrollspy_target: "link", action: "cl-scrollspy#click"}, **opts))
    }

    def initialize(label: "Page sections", offset: 0, smooth: true, **html_options)
      super(**html_options)
      @label = label
      @offset = offset
      @smooth = smooth
    end

    def call
      tag.nav(tag.ul(safe_join(items), class: LIST),
        **attrs(nil, aria: {label: @label},
          data: {controller: "cl-scrollspy", cl_scrollspy_offset_value: @offset, cl_scrollspy_smooth_value: @smooth}))
    end
  end
end
