module ComponentLibrary2100
  # <%= render BreadcrumbComponent.new do |crumbs| %>
  #   <% crumbs.with_item("Home", href: "/") %>
  #   <% crumbs.with_item("Library", href: "/library") %>
  #   <% crumbs.with_item("Data") %>   <%# no href: current page %>
  # <% end %>
  class BreadcrumbComponent < BaseComponent
    LIST = "flex flex-wrap p-0 m-0 list-none"
    ITEM = "not-first:before:content-['/'] not-first:before:px-2 not-first:before:text-secondary"
    LINK = "text-primary underline"

    renders_many :items, ->(label = nil, href: nil, **opts, &block) {
      text = block ? capture(&block) : label
      defaults = href ? {} : {aria: {current: "page"}}
      css = [ITEM, ("text-secondary" unless href)]

      tag.li(href ? link_to(text, href, class: LINK) : text, **merge_attrs(opts, css, **defaults))
    }

    def call
      tag.nav(tag.ol(safe_join(items), class: LIST), **attrs(nil, aria: {label: "breadcrumb"}))
    end
  end
end
